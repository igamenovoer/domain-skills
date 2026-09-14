---
name: brooks
description: Use when an Imsight mentality request names Brooks, or coding and test-design work has effective Brooks principles. Do not use for post-hoc Brooks Lint audits, health scores, or unrelated non-coding work.
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
  invocation_contract: |
    - Invoke `imsight-mentality-mgr->brooks` for recall and concise help without changing state.
    - Invoke `imsight-mentality-mgr->brooks->deploy()` to publish this mentality's complete catalog without enabling it.
    - Invoke `imsight-mentality-mgr->brooks->enable-project()` or `imsight-mentality-mgr->brooks->disable-project()` with explicit selectors to change project scope.
    - Invoke `imsight-mentality-mgr->brooks->enable-memory()` or `imsight-mentality-mgr->brooks->disable-memory()` with explicit selectors to change only this agent's remembered overrides.
    - Invoke `imsight-mentality-mgr->brooks->recall()` to report the scope resolution without writing files or changing memory.
    - Natural invocation may use `$imsight-mentality-mgr brooks enable-memory r1 r5`. Use `all` explicitly to select every principle for an enable/disable action.
---

# Brooks Mentality

## Overview

Brooks provides preventive principles for maintainable production code and trustworthy tests. Its six production principles and six test principles address Brooks Lint's decay risks during construction. It optimizes comprehension, changeability, domain fidelity, and test evidence.

## Workflow

1. **Resolve intent** using **Subcommands** and the frontmatter `metadata.invocation_contract`, or recognize an applicable task with effective Brooks principles.
2. **Validate selectors** using [state.md](references/state.md), which owns this mentality's canonical IDs and groups.
3. **Execute the resolved action** through its shared detail section.
4. **For substantive work**, resolve scope through [runtime-injection.md](../../references/runtime-injection.md), then apply the selected definitions under **Applying the Mentality**.
5. **Report actual effects** following the shared action contract; during ordinary work mention the mentality only for material tradeoffs or requested status.

If the task does not map cleanly to these steps, use the native planning tool to build a bounded plan from the declared actions, scope precedence, principles, and user intent without assuming activation.

## When to Use

Use for Brooks catalog deployment, explicit project or agent-memory selection, recall, or coding and test-design work with effective Brooks principles. A request to inspect the catalog does not activate its rules. Do not turn application into a Brooks Lint audit, health score, or refactoring sweep.

## Subcommands

These actions inherit the shared workflows unchanged with `brooks` as the selected mentality. The parent owns action and scope semantics; this child owns selectors, definitions, and applicability.

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `deploy` | Publish the complete catalog without enabling principles. | [Shared definition](../../references/actions.md#deploy) |
| `enable-project` | Add selected principles to project-wide requirements. | [Shared definition](../../references/actions.md#enable-project) |
| `disable-project` | Remove selected principles from project-wide requirements. | [Shared definition](../../references/actions.md#disable-project) |
| `enable-memory` | Remember enabled overrides for this agent only. | [Shared definition](../../references/actions.md#enable-memory) |
| `disable-memory` | Remember disabled overrides for this agent only. | [Shared definition](../../references/actions.md#disable-memory) |
| `recall` | Explain project selection, memory overrides, and effective principles. | [Shared definition](../../references/actions.md#recall) |
| `help` | Explain Brooks principles, selectors, and actions without changing state. | This entrypoint |

## Applying the Mentality

1. Read the existing flow and relevant callers before selecting a change boundary.
2. Resolve effective principles and their scope through the shared runtime contract; exclude rules that do not apply to the requested production or test work.
3. Read each applicable principle's reminder, example, and judgment notes from the deployed catalog or maintained definition.
4. Implement the smallest coherent change satisfying the task; use symptoms and thresholds as prompts for judgment rather than automatic refactoring verdicts.
5. Verify behavior and test architecture in proportion to the affected risk.

Apply guidance before, during, and after editing. Render constructive reminders with their source scope; do not inject unselected rules, severity labels, scores, or report templates.

## Catalog Publication

The canonical source is [principles.md](references/principles.md). Publish `.imsight-arts/mentality/brooks-principles.md` using the shared deployment contract. Include the complete `Production Rules`, `Test Rules`, `Applicability`, and `Provenance` sections and every nested example and judgment note, with a title, canonical rule index, entrance skill name, and availability-only statement. Exclude the source workflow and skill-control guardrails; the artifact documents principles, not activation or agent state.

Publishing or refreshing the catalog does not change either scope. Project actions change only `AGENTS.md`; memory actions change only the current agent's explicit overrides. Apply the shared precedence rather than a mentality-wide enabled flag.

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

## Guardrails

- DO NOT shorten code merely to reduce lines when comprehension or domain fidelity would worsen.
- DO NOT turn Brooks application into a lint audit or automatic refactoring sweep.
- DO NOT treat heuristic thresholds as mandatory refactoring triggers.
- DO NOT apply a principle suppressed by this agent's explicit memory override.
- DO NOT treat catalog deployment as project or agent activation.
- DO NOT copy this agent's remembered selection into shared project instructions.
- DO NOT let mentality guidance override unrelated repository instructions or explicit task requirements.
