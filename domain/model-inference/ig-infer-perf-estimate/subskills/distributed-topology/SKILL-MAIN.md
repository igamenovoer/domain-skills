---
name: distributed-topology
description: Use when an inference estimate depends on TP, PP, DP, EP, DCP/context parallelism, replicas, rank placement, stage imbalance, collectives, NUMA, PCIe, NVLink/NVSwitch, host DRAM, InfiniBand, cache locality, or multi-GPU contention. Do not use for single-device operator arithmetic alone.
metadata:
  skill_invocation_notation: >
    Skill and subskill entrypoints use bare object paths. Subcommands use
    parenthesized components after the owning skill or subskill.
---

# Distributed Topology and Communication

## Overview

Map model state and execution events onto actual ranks, stages, nodes, memory domains,
and links before applying any scaling factor. Parallelism changes ownership,
communication, contention, and scheduling differently; “divide by world size” is not a
topology model.

## Workflow

1. **Freeze the deployment graph.** Record physical GPUs, nodes, HBM, CPU NUMA domains,
   PCIe roots, NVLink/NVSwitch fabric, NICs, link directionality, and the exact runtime
   placement and parallelism configuration.
2. **Load the topology method.** Read
   `references/parallelism-communication.md` completely before dividing state,
   multiplying throughput, or assigning a network path.
3. **Create rank and stage maps.** List each rank's node, device, replica, TP/PP/EP/DCP
   coordinates, owned layers/experts, weights, sequence state, host-memory source, and
   outgoing communication edges.
4. **Classify every component.** Mark tensors and work as stage-owned, head-sharded,
   sequence-sharded, expert-sharded, replicated, shared, or communicated. Reconcile the
   classification with the model-memory ledger.
5. **Model link and collective costs.** Derive payloads, message counts, algorithms,
   latency, sustainable bandwidth, and the narrowest concurrent PCIe/DRAM/network
   service domain. Separate local H2D, peer copy, and remote-memory traffic.
6. **Build per-stage service curves.** Include heterogeneous layers, LM head, experts,
   collectives, PP boundaries, and cache events. Use the slowest stage and an explicit
   microbatch/request-group recurrence rather than layer-count balance.
7. **Compose replicas and alternatives.** Assign exact users to replicas, sum their
   independent throughput, and evaluate TP/PP/EP/DCP or cache-broadcast alternatives as
   distinct scenarios with their added communication.
8. **Return topology artifacts.** Report placement, per-rank capacity, stage cadence,
   collective/link demand, bottleneck domains, assumptions, and unmodeled contention.

If the request does not map cleanly to this workflow, use the native planning tool to
build a step-by-step plan from this subskill, its reference, and the user's constraints,
then execute that plan.

## When to Use

- Use for multi-GPU or multi-node inference, PP stage placement, TP/EP/DCP collectives,
  replicas, distributed KV cache, cache broadcast, or disaggregated memory.
- Use when per-GPU memory, transfer bandwidth, or throughput was derived from world size.
- Use when two simultaneous copies share a PCIe root or memory controller, or when host
  cache locality determines whether InfiniBand is used.
- Use when PP fill, stage imbalance, or replica distribution causes surprising
  per-user or aggregate throughput.
- Do not use as the only route for tensor-shape discovery, kernel efficiency, online
  queueing distributions, or inference quality.

## Subcommands

| Subcommand | Use For | Terminal Result |
| --- | --- | --- |
| `map-topology()` | Inventory devices, NUMA, links, and shared service domains | Physical topology and path map |
| `place-model()` | Map layers, experts, weights, and state to ranks | Rank/stage ownership table |
| `collectives()` | Model TP/EP/DCP and PP communication | Payload, algorithm, latency, and bandwidth roofs |
| `pipeline()` | Derive stage curves, microbatch groups, and cadence | PP latency/throughput recurrence and imbalance |
| `replicas()` | Assign load and combine independent replica service | Per-replica and aggregate results |
| `audit-topology()` | Diagnose a distributed memory or scaling result | Corrected placement, path, and contention analysis |
| `help()` | Explain these routes and required inputs | Concise command summary |

Invoke them as, for example,
`ig-infer-perf-estimate->distributed-topology->pipeline()`.

## Troubleshooting Guide

- TP size divided every per-user cache value.
  - If shared MLA or index history has no sharded dimension in the runtime, then restore
    a full copy per TP rank and model DCP separately.
- A two-node PP deployment charges every cache fetch to InfiniBand.
  - If each stage's host cache is NUMA-local to its node, then use local DRAM-to-PCIe H2D
    paths and reserve InfiniBand for actual cross-node activations or remote cache.
- Aggregate throughput scales faster than added devices.
  - If denominators, replicas, or concurrent link ceilings differ, then normalize
    per-user/per-replica metrics and enforce shared-resource service rates.
- Equal layer counts still produce a slow PP stage.
  - If layers, experts, LM head, or links are heterogeneous, then balance by measured or
    modeled stage time and packed memory, not block count.
- Single-GPU H2D measurements predict impossible multi-GPU transfer.
  - If copies share a PCIe root or host-memory domain, then measure or bound their
    simultaneous aggregate makespan and use the tightest domain roof.

## Guardrails

- DO NOT divide tensors, bytes, FLOPs, or latency by world size without an explicit ownership dimension.
- DO NOT relabel pure-TP cache replication as DCP or sequence sharding.
- DO NOT assume equal layer counts imply equal stage time or equal stage memory.
- DO NOT assign InfiniBand to node-local H2D or omit it from genuinely remote paths.
- DO NOT grant concurrent GPUs independent use of the same measured single-copy bandwidth.
- DO NOT assume a collective algorithm, link direction, or payload bandwidth from nominal fabric marketing rates.
- DO NOT apply pipeline fill as an inverse multiplier to one user's autoregressive latency.
- DO NOT multiply one replica's throughput by replica count without assigning requests and checking independent bottlenecks.
