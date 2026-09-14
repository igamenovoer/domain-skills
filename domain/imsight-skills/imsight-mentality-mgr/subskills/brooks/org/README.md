# Brooks Review Provenance

This directory preserves the upstream material used to adapt Brooks review into the mentality manager. It is documentation and an immutable source snapshot, not an executable skill or a source of activation rules. Execute the maintained [review contract](../references/review.md) and its bundled references.

## Origin

- Upstream: [hyhmrright/brooks-lint](https://github.com/hyhmrright/brooks-lint).
- Revision: `1892f7857802f4175ba191b8dae42b5cfbc5f292`.
- Local import source: `extern/orphan/brooks-lint` in the domain-skills repository, inspected on 2026-09-14. This checkout is not required by the installed mentality manager.
- License: MIT, Copyright (c) 2025 hyhmrright. The complete original [license and permission notice](src/LICENSE) is included with the copied and adapted material.

## Snapshot Inventory

Paths under `src/` preserve their upstream relative location. Every copied file retains its original bytes; the source entrypoint is named `SKILL-SOURCE.md` to prevent skill discovery from treating provenance as an installed entrypoint.

| Upstream path | Local snapshot | Purpose |
| --- | --- | --- |
| `skills/brooks-review/SKILL.md` | [SKILL-SOURCE.md](src/skills/brooks-review/SKILL-SOURCE.md) | Trigger, setup, dependency, and process contract. |
| `skills/brooks-review/pr-review-guide.md` | [pr-review-guide.md](src/skills/brooks-review/pr-review-guide.md) | Production scan, three-signal test check, scope, and severity heuristics. |
| `skills/_shared/common.md` | [common.md](src/skills/_shared/common.md) | Evidence discipline, configuration, scope detection, reporting, scoring, history, and triage. |
| `skills/_shared/source-coverage.md` | [source-coverage.md](src/skills/_shared/source-coverage.md) | Twelve-book grounding, tradeoffs, and exceptions. |
| `skills/_shared/decay-risks.md` | [decay-risks.md](src/skills/_shared/decay-risks.md) | Six production diagnostic dimensions. |
| `skills/_shared/test-decay-risks.md` | [test-decay-risks.md](src/skills/_shared/test-decay-risks.md) | Six test diagnostic dimensions, including those beyond the upstream quick check. |
| `skills/_shared/remedy-guide.md` | [remedy-guide.md](src/skills/_shared/remedy-guide.md) | Concrete remedy target, action, and rationale. |
| `skills/_shared/custom-risks-guide.md` | [custom-risks-guide.md](src/skills/_shared/custom-risks-guide.md) | Configuration extension inspected and excluded from active review. |
| `commands/brooks-review.md` | [brooks-review.md](src/commands/brooks-review.md) | Original host-specific wrapper inspected and excluded from runtime. |
| `.brooks-lint.example.yaml` | [.brooks-lint.example.yaml](src/.brooks-lint.example.yaml) | Configuration inputs inspected when removing the second selection system. |
| `LICENSE` | [LICENSE](src/LICENSE) | Original copyright and permission notice. |

The complete upstream review skill and its relevant shared support are preserved. Other Brooks skills, installers, plugin metadata, website assets, and evaluation corpora are not bundled. Snapshot references to other upstream modes remain untouched; those modes are not supported runtime dependencies of this adaptation.

## Adaptation Map

| Source behavior | Maintained adaptation |
| --- | --- |
| Broad review and design-keyword triggers | Explicit Brooks review route in the parent and Brooks child; ordinary principle application remains constructive. |
| Independent uppercase risk vocabulary | The existing lowercase r1–r6 and t1–t6 IDs, with uppercase accepted as aliases; no separate diagnostic state. |
| All risks by default, configurable focus/disable | Effective project/memory rules by default, or explicit criteria for one review without an activation transition. |
| Production risk scan and quick T1/T4/T5 check | Selected production and all six test dimensions in [review-risks.md](../references/review-risks.md), with explicit assessment limits. |
| Symptom → Source → Consequence → Remedy | Retained in [review.md](../references/review.md), requiring precise code evidence, causal consequences, and actionable remedies. |
| Threshold-driven warnings and severity | Contextual signals and consequence-based severity, with counterexamples in the risk entries and [review-sources.md](../references/review-sources.md). |
| Staged-first scope and hardcoded main fallback | Explicit user/PR scope, both local diff layers when appropriate, and an evidence-based branch base. |
| Generated-file and test-change shortcuts | Confirm generated status; inspect hand-authored behavior and existing tests; test-only changes receive selected test checks. |
| Numeric score, automatic history, suppression triage | Omitted. Findings return in chat; explicitly requested reports use independent output paths and never become activation state. |
| Optional --fix remedy sharpening | Every finding already requires a concrete target, action, and rationale; review does not apply fixes. |
| Custom risks, sweep delegation, host-specific wrapper | Excluded. All active procedures and references are inside the mentality-manager bundle. |

## Maintenance

Edit maintained files under the Brooks entrypoint and `references/`. Preserve `src/` unchanged and update the inventory if importing a different source revision. Validate the active bundle independently of this snapshot and of the original checkout. Project report artifacts document assessed criteria; they are never a replacement for project selection or agent memory.
