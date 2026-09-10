# Migration Provenance

This directory preserves the standalone `imsight-code-explainer` source skill exactly as it existed before becoming a parent-scoped documentation subskill.

## Copied Source

| Source File | Provenance File | SHA-256 |
| --- | --- | --- |
| `SKILL.md` | `src/SKILL-SOURCE.md` | `43c6b9cc7a09d58cea30617f877f7c83b69ee4eec12edd9bbf362966a63584aa` |
| `agents/openai.yaml` | `src/agents/openai.yaml` | `9b98782349d1ccc21e92e37af84a1e8d85956ebf0db057ef373a8b3ba388185d` |
| `assets/annotated-code-example.html` | `src/assets/annotated-code-example.html` | `3176aa5bf91d22907ba0b74a4ba422607a0b736d18f7f06294118bd8c16cc487` |
| `references/presentation-contract.md` | `src/references/presentation-contract.md` | `27486f723d4f96a7c8c31d22d3019ef47aa3b96704c42ab05f24b0551db97d92` |

The entrypoint is intentionally renamed `SKILL-SOURCE.md` so exact-name skill scanners do not discover the provenance snapshot as runtime behavior. Files under `src/` are audit copies and must remain unedited.

## Analysis Coverage

`analysis/analysis-of-imsight-code-explainer.md` covers the complete source entrypoint, agent invocation posture, directly linked presentation contract, HTML example, inputs, outputs, verification gates, blockers, durable side effects, and resource ownership.

No source files were excluded from provenance or analysis.
