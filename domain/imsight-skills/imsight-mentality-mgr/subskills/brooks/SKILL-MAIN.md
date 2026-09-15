---
name: brooks
description: Use when an Imsight mentality request names Brooks, coding and test-design work has effective Brooks principles, or the user explicitly requests a Brooks review of code, tests, a diff, or a PR. Do not use for health scores, automatic refactoring sweeps, or unrelated non-coding work.
---

# Brooks Mentality

## Overview

Brooks provides preventive principles for maintainable production code and trustworthy tests, plus an explicit diagnostic review using those same six production and six test principles. It optimizes comprehension, changeability, domain fidelity, and test evidence. Constructive application and review share canonical IDs; review criteria do not create another activation scope.

## Workflow

1. **Resolve intent** using **Subcommands**, or recognize an applicable task with effective Brooks principles.
2. **Validate selectors** using [state.md](references/state.md), which owns this mentality's canonical IDs and groups.
3. **Execute the resolved action** through its linked detail section. For explicit review, follow [review.md](references/review.md), including invocation-only selection, code scope, diagnostics, and reporting.
4. **For ordinary coding and test-design work**, resolve scope through [runtime-injection.md](../../references/runtime-injection.md), then apply the selected definitions under **Applying the Mentality**.
5. **Report actual effects** following the selected action contract; during ordinary work mention the mentality only for material tradeoffs or requested status.

If the task does not map cleanly to these steps, use the native planning tool to build a bounded plan from the declared actions, scope precedence, principles, and user intent without assuming activation.

## When to Use

Use for Brooks catalog deployment, explicit project or agent-memory selection, recall, coding and test-design work with effective Brooks principles, or an explicitly requested Brooks review. A request to inspect the catalog does not activate its rules. Mentioning a design concept during implementation does not request a diagnostic review. Review can inspect existing files, changed tests, pasted code, or a PR without requiring prior catalog deployment.

## Subcommands

The scope-management actions inherit the shared workflows unchanged with `brooks` as the selected mentality. The parent owns activation semantics; this child owns selectors, definitions, applicability, and the review procedure.

For example, `$imsight-mentality-mgr brooks enable-memory r1 r5` remembers those rules for this agent; `$imsight-mentality-mgr brooks review all` selects all criteria for one review.

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `deploy` | Publish the complete catalog without enabling principles. | [Shared definition](../../references/actions.md#deploy) |
| `enable-project` | Add selected principles to project-wide requirements. | [Shared definition](../../references/actions.md#enable-project) |
| `disable-project` | Remove selected principles from project-wide requirements. | [Shared definition](../../references/actions.md#disable-project) |
| `enable-memory` | Remember enabled overrides for this agent only. | [Shared definition](../../references/actions.md#enable-memory) |
| `disable-memory` | Remember disabled overrides for this agent only. | [Shared definition](../../references/actions.md#disable-memory) |
| `recall` | Explain project selection, memory overrides, and effective principles. | [Shared definition](../../references/actions.md#recall) |
| `review` | Diagnose existing code using effective or explicitly selected criteria for this invocation, without changing activation or code. | [Review](references/review.md) |
| `help` | Explain Brooks principles, selectors, and actions without changing state. | This entrypoint |

## Applying the Mentality

1. Read the existing flow and relevant callers before selecting a change boundary.
2. Resolve effective principles and their scope through the shared runtime contract; exclude rules that do not apply to the requested production or test work.
3. Read and retain each applicable principle's reminder, example, and judgment notes through shared [Definition Retention](../../references/runtime-injection.md#definition-retention).
4. Implement the smallest coherent change satisfying the task; use symptoms and thresholds as prompts for judgment rather than automatic refactoring verdicts.
5. Verify behavior and test architecture in proportion to the affected risk.

Apply guidance before, during, and after editing. Render constructive reminders with their source scope; do not inject unselected rules, severity labels, scores, or report templates into ordinary implementation. Diagnostic findings belong to an explicitly requested review.

## Catalog Publication

The canonical source is [principles.md](references/principles.md). Publish `.imsight-arts/mentality/brooks-principles.md` using the shared deployment contract. Include the complete `Production Rules`, `Test Rules`, and `Applicability` sections and every nested example and judgment note, with a title, canonical rule index, entrance skill name, and availability-only statement. Exclude the source workflow and skill-control guardrails; the artifact documents principles, not activation or agent state.

The catalog contains only maintained definitions and original teaching examples. Exclude this entrypoint's external reference table and third-party material. It must work without the installed skill, an original checkout, books, or network access.

Publishing or refreshing the catalog does not change either scope. Project actions include required deployment and update the selected coding-agent instruction files (`AGENTS.md`, `CLAUDE.md`, etc.); memory actions change only the current agent's explicit overrides. Apply the shared precedence rather than a mentality-wide enabled flag.

## Review Resources

[Review](references/review.md) owns execution and reporting; [review-risks.md](references/review-risks.md) maps diagnostic symptoms to the existing IDs; [review-judgment.md](references/review-judgment.md) supplies practical tradeoff guidance. These maintained resources are sufficient to execute reviews.

## Rationalization Table

| Rationalization | Counter |
| --- | --- |
| “Brooks Lint can catch this later.” | The mentality exists to shape the design before debt is embedded. |
| “This change is too small for the rules.” | Apply selected rules proportionately; small duplicated decisions and wrong boundaries still propagate. |
| “More abstraction is cleaner.” | R4 requires present value; a hypothetical future consumer is not evidence. |
| “Fewer lines means simpler code.” | Brooks measures comprehension and change cost, not line-count minimalism. |
| “The tests pass, so test design is fine.” | Passing tests may still be obscure, brittle, duplicated, mock-bound, or aimed at the wrong risks. |
| “A threshold was crossed, so refactoring is mandatory.” | Thresholds are review signals; context and the documented exceptions still govern. |

## Red Flags

- Planning to clean up structure only after the feature works.
- Copying a business decision because extracting it feels premature.
- Adding a layer, option, dependency, or interface for an imagined future need.
- Testing private state or mock choreography instead of observable behavior.
- Moving domain rules into generic services or infrastructure-oriented models.
- Treating a numeric symptom as proof without examining context.

## References

These links identify conceptual background and the rules it concerns. Consult them only for an explicit source or attribution request. Ordinary application, review, and deployment use the maintained definitions and original examples without opening these links. This section is not part of the deployed catalog.

| Reference | Rules concerned |
| --- | --- |
| [Brooks Lint production risks](https://github.com/hyhmrright/brooks-lint/blob/1892f7857802f4175ba191b8dae42b5cfbc5f292/skills/_shared/decay-risks.md) | r1–r6: production design concerns. |
| [Brooks Lint test risks](https://github.com/hyhmrright/brooks-lint/blob/1892f7857802f4175ba191b8dae42b5cfbc5f292/skills/_shared/test-decay-risks.md) | t1–t6: test design concerns. |
| [Brooks Lint review](https://github.com/hyhmrright/brooks-lint/blob/1892f7857802f4175ba191b8dae42b5cfbc5f292/skills/brooks-review/SKILL.md) | r1–r6 and t1–t6: diagnostic review framing. |
| [Software Engineering at Google — Style Guides](https://abseil.io/resources/swe-book/html/ch08.html) | r1. |
| [Martin Fowler — the Shotgun Surgery problem](https://martinfowler.com/articles/modularizing-react-apps.html) | r2. |
| [The Pragmatic Programmer — DRY](https://books.pragprog.com/tips/) | r3. |
| [Martin Fowler — YAGNI](https://martinfowler.com/bliki/Yagni.html) | r4. |
| [Microsoft — Clean architecture](https://learn.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures) | r5. |
| [Microsoft — Designing a DDD domain model](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/microservice-domain-model) | r6. |
| [Google Testing Blog — Writing Descriptive Test Names](https://testing.googleblog.com/2014/10/testing-on-toilet-writing-descriptive.html) | t1. |
| [Software Engineering at Google — Unit Testing](https://abseil.io/resources/swe-book/html/ch12.html) | t2. |
| [Google Testing Blog — Cleanly Create Test Data](https://testing.googleblog.com/2018/02/testing-on-toilet-cleanly-create-test.html) | t3. |
| [Google Testing Blog — Don't Overuse Mocks](https://testing.googleblog.com/2013/05/testing-on-toilet-dont-overuse-mocks.html) | t4. |
| [Google Testing Blog — Understanding Your Coverage Data](https://testing.googleblog.com/2008/03/tott-understanding-your-coverage-data.html) | t5. |
| [Google Testing Blog — Just Say No to More End-to-End Tests](https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html) | t6. |

## Guardrails

- DO NOT shorten code merely to reduce lines when comprehension or domain fidelity would worsen.
- DO NOT start a diagnostic review from ordinary mentality application without an explicit review request.
- DO NOT apply code fixes or alter activation while executing review.
- DO NOT treat heuristic thresholds as mandatory refactoring triggers.
- DO NOT apply a principle suppressed by this agent's explicit memory override during ordinary work or default review; an explicit review selector overrides criteria only for that invocation.
- DO NOT treat catalog deployment as project or agent activation.
- DO NOT copy this agent's remembered selection into shared project instructions.
- DO NOT let mentality guidance override unrelated repository instructions or explicit task requirements.
