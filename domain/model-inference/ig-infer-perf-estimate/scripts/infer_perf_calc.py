#!/usr/bin/env python3
"""Deterministic arithmetic helper for inference-performance estimates.

This tool intentionally has no hardware catalog and chooses no efficiency factors.
All scenario inputs must be supplied by the caller with provenance recorded beside
the scenario. It uses decimal bytes and SI rates internally; human-readable GiB is
display only.
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from collections import deque
from copy import deepcopy
from pathlib import Path
from typing import Any


class ScenarioError(ValueError):
    """Raised when a scenario cannot be evaluated without guessing."""


def _number(value: Any, path: str, *, minimum: float = 0.0) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise ScenarioError(f"{path} must be a number")
    result = float(value)
    if not math.isfinite(result) or result < minimum:
        raise ScenarioError(f"{path} must be finite and >= {minimum}")
    return result


def _integer(value: Any, path: str, *, minimum: int = 0) -> int:
    result = _number(value, path, minimum=float(minimum))
    if not result.is_integer():
        raise ScenarioError(f"{path} must be an integer")
    return int(result)


def _required(mapping: dict[str, Any], key: str, path: str) -> Any:
    if key not in mapping:
        raise ScenarioError(f"missing {path}.{key}")
    return mapping[key]


def _load(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ScenarioError(f"cannot read {path}: {exc}") from exc
    if not isinstance(data, dict):
        raise ScenarioError("scenario root must be a JSON object")
    return data


def _unique_map(items: Any, path: str) -> dict[str, dict[str, Any]]:
    if not isinstance(items, list):
        raise ScenarioError(f"{path} must be a list")
    result: dict[str, dict[str, Any]] = {}
    for index, item in enumerate(items):
        if not isinstance(item, dict):
            raise ScenarioError(f"{path}[{index}] must be an object")
        item_id = item.get("id")
        if not isinstance(item_id, str) or not item_id:
            raise ScenarioError(f"{path}[{index}].id must be a non-empty string")
        if item_id in result:
            raise ScenarioError(f"duplicate {path} id: {item_id}")
        result[item_id] = item
    return result


def _efficiency(value: Any, path: str) -> float:
    result = _number(value, path, minimum=0.0)
    if result <= 0.0 or result > 1.0:
        raise ScenarioError(f"{path} must be in (0, 1]")
    return result


def _validate_units(scenario: dict[str, Any], warnings: list[str]) -> None:
    units = scenario.get("units")
    if units != {"bytes": "decimal", "rates": "per_second", "time": "milliseconds"}:
        raise ScenarioError(
            "units must exactly declare decimal bytes, per-second rates, and milliseconds"
        )
    evidence = scenario.get("evidence")
    if not evidence:
        warnings.append(
            "scenario has no evidence ledger; arithmetic is reproducible but inputs are not sourced"
        )
    elif not isinstance(evidence, dict):
        raise ScenarioError("evidence must be an object keyed by evidence id")
    elif any(
        isinstance(item, dict) and item.get("status") == "placeholder-do-not-publish"
        for item in evidence.values()
    ):
        warnings.append("scenario still contains illustrative placeholder evidence")


def _operator_times(scenario: dict[str, Any]) -> tuple[dict[str, Any], list[str]]:
    hardware = _required(scenario, "hardware", "scenario")
    if not isinstance(hardware, dict):
        raise ScenarioError("hardware must be an object")
    compute = _required(hardware, "compute", "hardware")
    hbm = _required(hardware, "hbm", "hardware")
    if not isinstance(compute, dict) or not isinstance(hbm, dict):
        raise ScenarioError("hardware.compute and hardware.hbm must be objects")

    peak_flops = _number(
        _required(compute, "peak_flops_per_s", "hardware.compute"),
        "hardware.compute.peak_flops_per_s",
        minimum=1.0,
    )
    default_compute_eta = _efficiency(
        _required(compute, "default_efficiency", "hardware.compute"),
        "hardware.compute.default_efficiency",
    )
    hbm_bw = _number(
        _required(hbm, "bandwidth_bytes_per_s", "hardware.hbm"),
        "hardware.hbm.bandwidth_bytes_per_s",
        minimum=1.0,
    )
    default_hbm_eta = _efficiency(
        _required(hbm, "default_efficiency", "hardware.hbm"),
        "hardware.hbm.default_efficiency",
    )
    conversion = hardware.get("conversion")

    operators = _unique_map(scenario.get("operators", []), "operators")
    result: dict[str, Any] = {}
    warnings: list[str] = []
    for operator_id, operator in operators.items():
        prefix = f"operators[{operator_id}]"
        flops = _number(operator.get("flops", 0), f"{prefix}.flops")
        hbm_bytes = _number(operator.get("hbm_bytes", 0), f"{prefix}.hbm_bytes")
        converted = _number(operator.get("conversion_values", 0), f"{prefix}.conversion_values")
        fixed_ms = _number(operator.get("fixed_ms", 0), f"{prefix}.fixed_ms")
        compute_eta = _efficiency(
            operator.get("compute_efficiency", default_compute_eta),
            f"{prefix}.compute_efficiency",
        )
        hbm_eta = _efficiency(
            operator.get("hbm_efficiency", default_hbm_eta),
            f"{prefix}.hbm_efficiency",
        )
        compute_ms = 1000.0 * flops / (compute_eta * peak_flops)
        memory_ms = 1000.0 * hbm_bytes / (hbm_eta * hbm_bw)
        conversion_ms = 0.0
        if converted:
            if not isinstance(conversion, dict):
                raise ScenarioError(
                    f"{prefix} has conversion_values but hardware.conversion is missing"
                )
            conversion_rate = _number(
                _required(conversion, "values_per_s", "hardware.conversion"),
                "hardware.conversion.values_per_s",
                minimum=1.0,
            )
            conversion_eta = _efficiency(
                operator.get(
                    "conversion_efficiency",
                    _required(conversion, "default_efficiency", "hardware.conversion"),
                ),
                f"{prefix}.conversion_efficiency",
            )
            conversion_ms = 1000.0 * converted / (conversion_eta * conversion_rate)

        composition = operator.get("composition", "fused")
        roofs = [compute_ms, memory_ms, conversion_ms]
        if composition == "fused":
            duration_ms = max(roofs) + fixed_ms
            formula = "max(compute_ms, memory_ms, conversion_ms) + fixed_ms"
        elif composition == "sequential":
            duration_ms = sum(roofs) + fixed_ms
            formula = "compute_ms + memory_ms + conversion_ms + fixed_ms"
        else:
            raise ScenarioError(f"{prefix}.composition must be fused or sequential")
        if flops == hbm_bytes == converted == fixed_ms == 0:
            warnings.append(f"operator {operator_id} has zero modeled work")
        result[operator_id] = {
            "duration_ms": duration_ms,
            "composition": composition,
            "compute_ms": compute_ms,
            "memory_ms": memory_ms,
            "conversion_ms": conversion_ms,
            "fixed_ms": fixed_ms,
            "dominant_roof": max(
                ("compute", compute_ms),
                ("memory", memory_ms),
                ("conversion", conversion_ms),
                key=lambda pair: pair[1],
            )[0],
            "formula": formula,
        }
    return result, warnings


def _critical_path(scenario: dict[str, Any], operator_times: dict[str, Any]) -> dict[str, Any]:
    events = _unique_map(scenario.get("events", []), "events")
    if not events:
        return {"duration_ms": 0.0, "path": [], "events": {}}

    dependents: dict[str, list[str]] = {event_id: [] for event_id in events}
    indegree: dict[str, int] = {}
    durations: dict[str, float] = {}
    for event_id, event in events.items():
        dependencies = event.get("depends_on", [])
        if not isinstance(dependencies, list) or not all(
            isinstance(dep, str) for dep in dependencies
        ):
            raise ScenarioError(f"events[{event_id}].depends_on must be a list of ids")
        indegree[event_id] = len(dependencies)
        for dependency in dependencies:
            if dependency not in events:
                raise ScenarioError(f"events[{event_id}] depends on unknown event {dependency}")
            dependents[dependency].append(event_id)
        if "operator_id" in event and "duration_ms" in event:
            raise ScenarioError(
                f"events[{event_id}] must use either operator_id or duration_ms, not both"
            )
        if "operator_id" in event:
            operator_id = event["operator_id"]
            if operator_id not in operator_times:
                raise ScenarioError(f"events[{event_id}] references unknown operator {operator_id}")
            duration = operator_times[operator_id]["duration_ms"]
        else:
            duration = _number(
                _required(event, "duration_ms", f"events[{event_id}]"),
                f"events[{event_id}].duration_ms",
            )
        repeat = _integer(event.get("repeat", 1), f"events[{event_id}].repeat", minimum=1)
        durations[event_id] = duration * repeat

    queue = deque(sorted(event_id for event_id, degree in indegree.items() if degree == 0))
    earliest_finish: dict[str, float] = {}
    predecessor: dict[str, str | None] = {}
    visited = 0
    while queue:
        event_id = queue.popleft()
        visited += 1
        dependencies = events[event_id].get("depends_on", [])
        if dependencies:
            prior = max(dependencies, key=lambda dep: earliest_finish[dep])
            start = earliest_finish[prior]
            predecessor[event_id] = prior
        else:
            start = 0.0
            predecessor[event_id] = None
        earliest_finish[event_id] = start + durations[event_id]
        for dependent in sorted(dependents[event_id]):
            indegree[dependent] -= 1
            if indegree[dependent] == 0:
                queue.append(dependent)
    if visited != len(events):
        raise ScenarioError("events contain a dependency cycle")

    final_event = max(earliest_finish, key=earliest_finish.get)
    path: list[str] = []
    cursor: str | None = final_event
    while cursor is not None:
        path.append(cursor)
        cursor = predecessor[cursor]
    path.reverse()
    event_output = {
        event_id: {
            "duration_ms": durations[event_id],
            "earliest_finish_ms": earliest_finish[event_id],
            "depends_on": events[event_id].get("depends_on", []),
        }
        for event_id in events
    }
    return {
        "duration_ms": earliest_finish[final_event],
        "path": path,
        "events": event_output,
    }


def _memory(scenario: dict[str, Any], warnings: list[str]) -> dict[str, Any]:
    deployment = _required(scenario, "deployment", "scenario")
    if not isinstance(deployment, dict):
        raise ScenarioError("deployment must be an object")
    replicas = _integer(
        _required(deployment, "replicas", "deployment"), "deployment.replicas", minimum=1
    )
    concurrent_users = _integer(
        _required(deployment, "concurrent_users", "deployment"),
        "deployment.concurrent_users",
        minimum=1,
    )
    devices = _unique_map(_required(deployment, "devices", "deployment"), "devices")
    state = _required(scenario, "logical_state", "scenario")
    if not isinstance(state, dict):
        raise ScenarioError("logical_state must be an object")
    components = _unique_map(_required(state, "components", "logical_state"), "components")
    placements = scenario.get("placement", [])
    if not isinstance(placements, list):
        raise ScenarioError("placement must be a list")

    fixed_by_device = {device_id: 0.0 for device_id in devices}
    request_by_device = {device_id: 0.0 for device_id in devices}
    placement_trace: list[dict[str, Any]] = []
    seen_components: set[str] = set()
    for index, placement in enumerate(placements):
        if not isinstance(placement, dict):
            raise ScenarioError(f"placement[{index}] must be an object")
        component_id = placement.get("component_id")
        device_id = placement.get("device_id")
        if component_id not in components:
            raise ScenarioError(f"placement[{index}] has unknown component {component_id}")
        if device_id not in devices:
            raise ScenarioError(f"placement[{index}] has unknown device {device_id}")
        multiplier = _number(placement.get("multiplier", 1.0), f"placement[{index}].multiplier")
        component = components[component_id]
        fixed_bytes = _number(
            component.get("fixed_bytes", 0), f"components[{component_id}].fixed_bytes"
        )
        per_request_bytes = _number(
            component.get("bytes_per_request", 0),
            f"components[{component_id}].bytes_per_request",
        )
        fixed_by_device[device_id] += fixed_bytes * multiplier
        request_by_device[device_id] += per_request_bytes * multiplier
        seen_components.add(component_id)
        placement_trace.append(
            {
                "component_id": component_id,
                "device_id": device_id,
                "multiplier": multiplier,
                "fixed_bytes": fixed_bytes * multiplier,
                "bytes_per_request": per_request_bytes * multiplier,
            }
        )
    unplaced = sorted(set(components) - seen_components)
    if unplaced:
        raise ScenarioError(f"logical components lack physical placement: {', '.join(unplaced)}")

    requested_users_per_replica = math.ceil(concurrent_users / replicas)
    per_device: dict[str, Any] = {}
    capacities: list[int] = []
    for device_id, device in devices.items():
        prefix = f"devices[{device_id}]"
        hbm_bytes = _number(
            _required(device, "hbm_bytes", prefix), f"{prefix}.hbm_bytes", minimum=1.0
        )
        max_fraction = _efficiency(
            _required(device, "max_fraction", prefix), f"{prefix}.max_fraction"
        )
        reserve = _number(device.get("runtime_reserve_bytes", 0), f"{prefix}.runtime_reserve_bytes")
        budget = hbm_bytes * max_fraction
        fixed = fixed_by_device[device_id]
        per_request = request_by_device[device_id]
        headroom = budget - reserve - fixed
        if headroom < 0:
            capacity = 0
            capacities.append(capacity)
        elif per_request == 0:
            capacity: int | None = None
        else:
            capacity = max(0, math.floor(headroom / per_request))
            capacities.append(capacity)
        requested_used = reserve + fixed + per_request * requested_users_per_replica
        per_device[device_id] = {
            "budget_bytes": budget,
            "runtime_reserve_bytes": reserve,
            "fixed_bytes": fixed,
            "bytes_per_request": per_request,
            "requested_users_per_replica": requested_users_per_replica,
            "requested_used_bytes": requested_used,
            "requested_free_bytes": budget - requested_used,
            "request_capacity": capacity,
            "fits_requested_users": requested_used <= budget,
        }
    if not capacities:
        warnings.append("no per-request memory was placed; memory admission is unbounded here")
        per_replica_capacity: int | None = None
        total_capacity: int | None = None
        admitted = concurrent_users
    else:
        per_replica_capacity = min(capacities)
        total_capacity = replicas * per_replica_capacity
        admitted = min(concurrent_users, total_capacity)
        if concurrent_users > total_capacity:
            warnings.append(
                f"requested {concurrent_users} users but HBM admission ceiling is {total_capacity}"
            )
    admitted_users_per_replica = math.ceil(admitted / replicas)
    for details in per_device.values():
        admitted_used = (
            details["runtime_reserve_bytes"]
            + details["fixed_bytes"]
            + details["bytes_per_request"] * admitted_users_per_replica
        )
        details["admitted_used_bytes"] = admitted_used
        details["admitted_free_bytes"] = details["budget_bytes"] - admitted_used
    return {
        "replicas": replicas,
        "requested_concurrent_users": concurrent_users,
        "requested_users_per_replica": requested_users_per_replica,
        "admitted_users_per_replica": admitted_users_per_replica,
        "admitted_users": admitted,
        "per_replica_capacity": per_replica_capacity,
        "total_capacity": total_capacity,
        "limiting_devices": [
            device_id
            for device_id, details in per_device.items()
            if details["request_capacity"] == per_replica_capacity
        ]
        if per_replica_capacity is not None
        else [],
        "per_device": per_device,
        "placement_trace": placement_trace,
        "formula": (
            "floor((hbm_bytes*max_fraction-runtime_reserve_bytes-fixed_bytes)"
            "/bytes_per_request), limited by the smallest device"
        ),
    }


def _serving(
    scenario: dict[str, Any], critical_path: dict[str, Any], memory: dict[str, Any]
) -> dict[str, Any]:
    serving = _required(scenario, "serving", "scenario")
    if not isinstance(serving, dict):
        raise ScenarioError("serving must be an object")
    emitted = _number(
        _required(serving, "emitted_output_tokens_per_user_step", "serving"),
        "serving.emitted_output_tokens_per_user_step",
        minimum=0.0,
    )
    if emitted <= 0:
        raise ScenarioError("serving.emitted_output_tokens_per_user_step must be > 0")
    foreground_extra = _number(serving.get("foreground_extra_ms", 0), "serving.foreground_extra_ms")
    foreground_ms = critical_path["duration_ms"] + foreground_extra
    local_users = memory["admitted_users_per_replica"]

    services = serving.get("background_services", [])
    if not isinstance(services, list):
        raise ScenarioError("serving.background_services must be a list")
    background_rows: list[dict[str, Any]] = []
    background_floor_ms = 0.0
    seen: set[str] = set()
    for index, service in enumerate(services):
        if not isinstance(service, dict):
            raise ScenarioError(f"background_services[{index}] must be an object")
        service_id = service.get("id")
        if not isinstance(service_id, str) or not service_id or service_id in seen:
            raise ScenarioError(f"background_services[{index}].id must be unique")
        seen.add(service_id)
        demand = _number(
            _required(service, "demand_ms_per_user_step", f"background_services[{service_id}]"),
            f"background_services[{service_id}].demand_ms_per_user_step",
        )
        lanes = _integer(
            service.get("parallel_lanes", 1),
            f"background_services[{service_id}].parallel_lanes",
            minimum=1,
        )
        service_floor = demand * local_users / lanes
        background_floor_ms = max(background_floor_ms, service_floor)
        background_rows.append(
            {
                "id": service_id,
                "demand_ms_per_user_step": demand,
                "parallel_lanes": lanes,
                "users_per_replica": local_users,
                "service_floor_ms": service_floor,
            }
        )
    step_ms = max(foreground_ms, background_floor_ms)
    if step_ms <= 0:
        raise ScenarioError("modeled serving step is zero")
    admitted = memory["admitted_users"]
    per_user_tps = 1000.0 * emitted / step_ms
    aggregate_tps = admitted * per_user_tps
    return {
        "foreground_ms": foreground_ms,
        "background_service_floor_ms": background_floor_ms,
        "step_ms": step_ms,
        "tpot_ms_per_emitted_token": step_ms / emitted,
        "per_user_output_tokens_per_s": per_user_tps,
        "aggregate_output_tokens_per_s": aggregate_tps,
        "admitted_users": admitted,
        "background_services": background_rows,
        "formula": {
            "step": "max(foreground_critical_path_ms, background_service_floor_ms)",
            "per_user": "1000*emitted_output_tokens_per_user_step/step_ms",
            "aggregate": "admitted_users*per_user_output_tokens_per_s",
        },
    }


def estimate(scenario: dict[str, Any]) -> dict[str, Any]:
    warnings: list[str] = []
    _validate_units(scenario, warnings)
    schema_version = _integer(
        _required(scenario, "schema_version", "scenario"), "schema_version", minimum=1
    )
    scenario_id = _required(scenario, "scenario_id", "scenario")
    if not isinstance(scenario_id, str) or not scenario_id:
        raise ScenarioError("scenario_id must be a non-empty string")
    operator_times, operator_warnings = _operator_times(scenario)
    warnings.extend(operator_warnings)
    critical_path = _critical_path(scenario, operator_times)
    memory = _memory(scenario, warnings)
    serving = _serving(scenario, critical_path, memory)
    if not math.isclose(
        serving["aggregate_output_tokens_per_s"],
        serving["admitted_users"] * serving["per_user_output_tokens_per_s"],
        rel_tol=1e-12,
    ):
        raise ScenarioError("internal throughput identity failed")
    return {
        "schema_version": schema_version,
        "scenario_id": scenario_id,
        "status": "bounded-by-input-assumptions",
        "warnings": warnings,
        "operator_rooflines": operator_times,
        "critical_path": critical_path,
        "memory": memory,
        "serving": serving,
        "unit_note": "All stored byte values are decimal bytes; GiB is display-only.",
    }


def _flatten_numbers(value: Any, prefix: str = "") -> dict[str, float]:
    result: dict[str, float] = {}
    if isinstance(value, dict):
        for key, child in value.items():
            child_prefix = f"{prefix}.{key}" if prefix else key
            result.update(_flatten_numbers(child, child_prefix))
    elif isinstance(value, (int, float)) and not isinstance(value, bool):
        result[prefix] = float(value)
    return result


def compare(left: dict[str, Any], right: dict[str, Any]) -> dict[str, Any]:
    left_estimate = estimate(left)
    right_estimate = estimate(right)
    left_values = _flatten_numbers(left_estimate)
    right_values = _flatten_numbers(right_estimate)
    deltas: dict[str, Any] = {}
    for key in sorted(set(left_values) & set(right_values)):
        before = left_values[key]
        after = right_values[key]
        delta = after - before
        deltas[key] = {
            "left": before,
            "right": after,
            "absolute_delta": delta,
            "relative_delta": None if before == 0 else delta / before,
        }
    return {
        "left_scenario_id": left_estimate["scenario_id"],
        "right_scenario_id": right_estimate["scenario_id"],
        "normalization_warning": (
            "A numeric delta is meaningful only when metric, workload, admission, and "
            "external serving assumptions are controlled. Audit scenario inputs separately."
        ),
        "deltas": deltas,
    }


def validate(scenario: dict[str, Any]) -> dict[str, Any]:
    result = estimate(scenario)
    checks = [
        {
            "id": "throughput-identity",
            "passed": math.isclose(
                result["serving"]["aggregate_output_tokens_per_s"],
                result["serving"]["admitted_users"]
                * result["serving"]["per_user_output_tokens_per_s"],
                rel_tol=1e-12,
            ),
        },
        {
            "id": "requested-users-fit",
            "passed": result["memory"]["requested_concurrent_users"]
            <= result["memory"]["admitted_users"],
        },
        {
            "id": "nonnegative-event-times",
            "passed": all(
                event["duration_ms"] >= 0 for event in result["critical_path"]["events"].values()
            ),
        },
    ]
    return {
        "scenario_id": result["scenario_id"],
        "passed": all(check["passed"] for check in checks) and not result["warnings"],
        "checks": checks,
        "warnings": result["warnings"],
    }


def _fixture() -> dict[str, Any]:
    return {
        "schema_version": 1,
        "scenario_id": "self-test",
        "units": {
            "bytes": "decimal",
            "rates": "per_second",
            "time": "milliseconds",
        },
        "evidence": {"fixture": {"class": "derived", "note": "self-test only"}},
        "hardware": {
            "compute": {"peak_flops_per_s": 1000, "default_efficiency": 0.5},
            "hbm": {"bandwidth_bytes_per_s": 1000, "default_efficiency": 0.5},
            "conversion": {"values_per_s": 1000, "default_efficiency": 0.5},
        },
        "deployment": {
            "replicas": 2,
            "concurrent_users": 8,
            "devices": [
                {
                    "id": "limiting-stage",
                    "hbm_bytes": 1000,
                    "max_fraction": 1.0,
                    "runtime_reserve_bytes": 100,
                },
                {
                    "id": "other-stage",
                    "hbm_bytes": 1000,
                    "max_fraction": 1.0,
                    "runtime_reserve_bytes": 100,
                },
            ],
        },
        "logical_state": {
            "components": [
                {"id": "weights-a", "fixed_bytes": 200, "bytes_per_request": 0},
                {"id": "weights-b", "fixed_bytes": 100, "bytes_per_request": 0},
                {"id": "kv", "fixed_bytes": 0, "bytes_per_request": 100},
            ]
        },
        "placement": [
            {"component_id": "weights-a", "device_id": "limiting-stage"},
            {"component_id": "weights-b", "device_id": "other-stage"},
            {"component_id": "kv", "device_id": "limiting-stage"},
            {"component_id": "kv", "device_id": "other-stage", "multiplier": 0.5},
        ],
        "operators": [
            {
                "id": "fused",
                "flops": 100,
                "hbm_bytes": 200,
                "conversion_values": 50,
                "composition": "fused",
            },
            {
                "id": "serial",
                "flops": 50,
                "hbm_bytes": 50,
                "composition": "sequential",
            },
        ],
        "events": [
            {"id": "a", "operator_id": "fused", "depends_on": []},
            {"id": "b", "duration_ms": 25, "depends_on": ["a"]},
            {"id": "c", "operator_id": "serial", "depends_on": ["a"]},
        ],
        "serving": {
            "emitted_output_tokens_per_user_step": 1,
            "background_services": [
                {"id": "dma", "demand_ms_per_user_step": 10, "parallel_lanes": 2}
            ],
        },
    }


def self_test() -> dict[str, Any]:
    fixture = _fixture()
    result = estimate(fixture)
    assert result["memory"]["per_replica_capacity"] == 7
    assert result["memory"]["total_capacity"] == 14
    assert result["critical_path"]["path"] == ["a", "c"]
    assert math.isclose(
        result["serving"]["aggregate_output_tokens_per_s"],
        result["serving"]["admitted_users"] * result["serving"]["per_user_output_tokens_per_s"],
    )
    larger = deepcopy(fixture)
    larger["logical_state"]["components"][2]["bytes_per_request"] *= 2
    assert estimate(larger)["memory"]["total_capacity"] < result["memory"]["total_capacity"]
    fixed_oom = deepcopy(fixture)
    fixed_oom["logical_state"]["components"][0]["fixed_bytes"] = 1001
    assert estimate(fixed_oom)["memory"]["total_capacity"] == 0
    cycle = deepcopy(fixture)
    cycle["events"][0]["depends_on"] = ["b"]
    try:
        estimate(cycle)
    except ScenarioError:
        pass
    else:
        raise AssertionError("cycle fixture was not rejected")
    return {
        "passed": True,
        "checks": [
            "limiting-device admission",
            "replica capacity",
            "DAG critical path",
            "aggregate/per-user throughput identity",
            "memory monotonicity",
            "fixed-state OOM rejection",
            "dependency-cycle rejection",
        ],
    }


def _write(payload: dict[str, Any], output: Path | None, pretty: bool) -> None:
    text = json.dumps(payload, indent=2 if pretty else None, sort_keys=True)
    if output is None:
        print(text)
    else:
        output.write_text(text + "\n", encoding="utf-8")


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)
    for command in ("estimate", "validate"):
        child = subparsers.add_parser(command)
        child.add_argument("scenario", type=Path)
        child.add_argument("--output", "-o", type=Path)
        child.add_argument("--pretty", action="store_true")
    child = subparsers.add_parser("compare")
    child.add_argument("left", type=Path)
    child.add_argument("right", type=Path)
    child.add_argument("--output", "-o", type=Path)
    child.add_argument("--pretty", action="store_true")
    child = subparsers.add_parser("self-test")
    child.add_argument("--pretty", action="store_true")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    try:
        if args.command == "estimate":
            payload = estimate(_load(args.scenario))
            _write(payload, args.output, args.pretty)
            return 0
        if args.command == "validate":
            payload = validate(_load(args.scenario))
            _write(payload, args.output, args.pretty)
            return 0 if payload["passed"] else 1
        if args.command == "compare":
            payload = compare(_load(args.left), _load(args.right))
            _write(payload, args.output, args.pretty)
            return 0
        if args.command == "self-test":
            _write(self_test(), None, args.pretty)
            return 0
    except (ScenarioError, AssertionError) as exc:
        print(json.dumps({"error": str(exc)}), file=sys.stderr)
        return 2
    raise AssertionError("unreachable")


if __name__ == "__main__":
    raise SystemExit(main())
