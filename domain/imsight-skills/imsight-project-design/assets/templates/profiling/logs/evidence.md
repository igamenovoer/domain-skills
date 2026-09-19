# Profiling evidence index

Status: <STATUS>

## Locations and execution identity

<PATHS_TO_REMOTE_AND_LOCAL_ARTIFACTS>

GPU: <DEVICE_MODEL_INDEX_UUID_NUMA>. Reservation PID: <PID>. Profiler: <TOOL_VERSION_EXECUTABLE_SHA256>.

## Commands

From `<WORKING_DIRECTORY>`:

```bash
<EXACT_COMMAND_1>

<EXACT_COMMAND_2>
```

## Run 1: <ARM_NAME>

| Cycle | Prefill seconds, excluded | Measured decode seconds |
| --- | ---: | ---: |
| Warmup | <time> | <time>; not a timing trial |
| Measured 1 | <time> | <time> |
| Measured 2 | <time> | <time> |

Median: **<time> s**. Relative to <reference>: **<percent>**, accepted as parity under <margin>.

Admission: <PROCESS_STATUS_CLEANUP_CHECKS_ENVIRONMENT_CLASSIFICATION>

| Artifact | SHA-256 of exact bytes |
| --- | --- |
| `<path-1>` | `<hash>` |
| `<path-2>` | `<hash>` |

## Run 2: <ARM_NAME>

<SIMILAR_STRUCTURE_FOR_NEXT_ARM>

## Analysis validation

<ANALYZER_CHECKS_REGRESSION_TESTS_FULL_CHECK_RESULTS>
