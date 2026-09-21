---
name: brooks
description: Use when an Imsight mentality request names Brooks, coding and test-design work has effective Brooks principles, or the user explicitly requests a Brooks review of code, tests, a diff, or a PR. Do not use for health scores, automatic refactoring sweeps, or unrelated non-coding work.
metadata:
  skill_invocation_notation: >
    Top-level skill entrypoints use SKILL.md. Parent-scoped subskill entrypoints use
    SKILL-MAIN.md and are loaded explicitly through their parent; nested SKILL.md is
    accepted only as legacy input when SKILL-MAIN.md is absent.
    Skill and subskill entrypoints use bare object paths: `X` invokes skill X and
    `X->Y->Z` invokes subskill Z. Subcommands use parenthesized components:
    `X->cmd()` invokes a direct subcommand, `X->Y->cmd()` invokes a subcommand of
    subskill Y, and `X->parent()->child()` invokes child subcommand child exposed
    by parent subcommand parent. Intermediate subcommands act as object generators.
    Forms such as `X()` and `X->Y()` are invalid for skill or subskill entrypoints.
---

# Brooks Mentality

Maintainable production code and trustworthy tests, with six production and six test principles shared by constructive application and explicit review.

## Workflow

1. Resolve intent and [selectors](references/state.md).
2. For management, use the shared action below. For an explicit review, load [review.md](references/review.md) and only its needed diagnostics.
3. For ordinary coding, resolve [effective selection](../../references/runtime-injection.md#effective-selection), then apply relevant definitions below.
4. Report action effects; mention mentality during ordinary work only for material tradeoffs or on request.

For other requests, use the native planning tool without inferring activation or review intent.

## Subcommands

Shared actions inherit the parent contract.

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

Read the affected flow and callers, then retain selected [definitions, examples, and judgment](references/principles.md) through [Definition Retention](../../references/runtime-injection.md#definition-retention). Make the smallest coherent change meeting the task. Optimize comprehension, changeability, domain fidelity, and useful test evidence; verify proportionately. Thresholds prompt judgment, not automatic refactoring.

Ordinary implementation uses constructive guidance, not review severity labels, scores, or report templates. Mentioning a design concept does not request a diagnostic review.

## Catalog Publication

Publish `.imsight-arts/mentality/brooks-principles.md` through the shared [catalog contract](../../references/runtime-injection.md#catalog-artifact). Copy complete `Production Rules`, `Test Rules`, and `Applicability` sections from [principles.md](references/principles.md), including every example and judgment note. Exclude workflow, control guardrails, and References.

## Review Resources

[review.md](references/review.md) owns the procedure; [review-risks.md](references/review-risks.md) supplies ID-matched diagnostics and [review-judgment.md](references/review-judgment.md) supplies tradeoffs. Reviews need no upstream material or prior deployment.

## References

Optional attribution/background only; open on explicit request. Excluded from deployed catalogs.

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

- DO NOT trade comprehension or domain fidelity for line-count reduction.
- DO NOT start review, apply review fixes, or alter activation without the corresponding request.
- DO NOT treat thresholds as mandatory refactoring or passing tests as proof of good test design.
