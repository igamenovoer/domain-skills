---
name: imsight-mentality-mgr
description: Use when an Imsight mentality request concerns catalogs, project or agent-memory rules, communication or rigor flavors, experiment evidence, simplification settings, effective mentality recall, or explicit Brooks or Ponytail reviews, or when applicable work has resolved mentality rules. Do not use for ordinary factual memory or unrelated preferences.
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

# Imsight Mentality Manager

Manage principle catalogs, project defaults, and each agent's chat-memory overrides. Deployment makes rules available; selection determines what applies.

## Workflow

1. Resolve the action and named child below. Human Speak and Rigor Control management require an explicit flavor; otherwise show the selected child's chooser before any mutation.
2. Load only that child's entrypoint and relevant selector, action, or review sections. Use [actions.md](references/actions.md) for management, [composition.md](references/composition.md) for ordinary application, and the child's procedure for an explicit review.
3. Resolve scope and definitions through the needed sections of [runtime-injection.md](references/runtime-injection.md). Read [priorities.md](references/priorities.md) when allocating or comparing family priorities. Validate the whole request before effects.
4. Execute and report canonical IDs, scope, priorities, and actual file effects. Memory actions also summarize meanings and definition retention.

For requests outside this flow, use the native planning tool with these contracts; do not invent activation or authority.

## Invocation

Bare invocation shows help; a named ordinary child recalls its state and shows help. Human Speak and Rigor Control instead ask for a flavor. Manager-wide recall reports ordinary children and shows both flavor choosers.

Example: `imsight-mentality-mgr->brooks->enable-memory()` with `r1 r5`. Flavors are flat commands, such as `imsight-mentality-mgr->human-speak->han-style()` with `enable-memory h1 h5` or `imsight-mentality-mgr->rigor-control->product-showcase()` with `enable-memory all`.

- `enable/disable <mentality>` defaults to agent memory. Omitted memory selectors mean all current rules; explicit selectors choose a subset.
- Project enable/disable requires explicit scope and selectors, including `all` when intended. Naming an instruction file selects project scope.
- Project actions publish missing catalogs and update all existing project-wide coding-agent files (`AGENTS.md`, `CLAUDE.md`, etc.) unless the user selects specific files. Create root `AGENTS.md` only when none exist. Follow [file selection](references/runtime-injection.md#instruction-file-selection).
- Missing flavors, invalid selectors, or conflicting scope instructions require resolution before mutation. Omitted enable/disable scope alone does not.

## Subcommands

| Action | Effect | Detail |
| --- | --- | --- |
| `deploy` | Publish complete catalogs and availability references; enable nothing. | [Deploy](references/actions.md#deploy) |
| `enable-project` | Add project rules and allocate fresh family priority. | [Enable Project](references/actions.md#enable-project) |
| `disable-project` | Remove project rules; preserve independent settings. | [Disable Project](references/actions.md#disable-project) |
| `enable-memory` | Remember enabled overrides for this agent. | [Enable Memory](references/actions.md#enable-memory) |
| `disable-memory` | Remember explicit disabled overrides for this agent. | [Disable Memory](references/actions.md#disable-memory) |
| `recall` | Report project, memory, and effective state. | [Recall](references/actions.md#recall) |
| `help` | Explain available actions without mutation. | This entrypoint |

## Subskills

| Mentality | When to Route Here | Entry |
| --- | --- | --- |
| `brooks` | Route here for maintainable code and tests or an explicit diagnostic review. | [Brooks](subskills/brooks/SKILL-MAIN.md) |
| `ponytail` | Route here for implementation simplification with independent intensity and edit scope or an explicit simplification review. | [Ponytail](subskills/ponytail/SKILL-MAIN.md) |
| `docs-writer` | Route here when durable prose should describe its current state without incidental revision history. | [Docs Writer](subskills/docs-writer/SKILL-MAIN.md) |
| `agile-experimenter` | Route here when experiment scope and evidence should be calibrated to the next decision. | [Agile Experimenter](subskills/agile-experimenter/SKILL-MAIN.md) |
| `human-speak` | Route here when human-facing communication should follow an explicitly selected writing flavor. | [Human Speak](subskills/human-speak/SKILL-MAIN.md) |
| `rigor-control` | Route here when engineering and verification rigor should match an explicitly selected assurance flavor. | [Rigor Control](subskills/rigor-control/SKILL-MAIN.md) |

Unknown names return this inventory. Children own canonical IDs, definitions, examples, and applicability; flavored children keep independent state per flavor.

## Scope Contract

- Catalogs live under `.imsight-arts/mentality/`; they contain definitions, not activation.
- Project guidance uses one [unified section](references/runtime-injection.md#unified-mentality-section) per target instruction file. Rewrite current meaning instead of appending operation templates; see [examples](references/instruction-examples.md) when needed.
- Explicit agent-memory overrides win over project selection; otherwise inherit, with unselected rules disabled. Memory stays in this agent's context and writes no files.
- Within one scope, higher family priority wins conflicts. Fresh enables, including re-enables, receive the next nonnegative priority; disabling preserves gaps. Memory scope outranks project scope regardless of numbers.
- Retain deployed meanings by project path and ID; retain undeployed meanings as operative content. Settings resolve independently. Explicit review criteria last only for that review.

## Maintenance

Keep shared semantics in parent references and child-specific guidance with its child. Load only needed sections. Keep definitions and original examples self-contained; put optional upstream links and rule mappings in separate `References` sections. Do not bundle third-party material or put source pointers inside rule descriptions or deployed catalogs.

## Guardrails

- DO NOT infer activation from deployment, discovery, or bare invocation.
- DO NOT infer a missing flavor for Human Speak or Rigor Control.
- DO NOT write files for memory actions, recall, or help, or publish an agent's effective selection as project rules.
- DO NOT lose explicit disabled overrides or copy another agent's memory implicitly.
- DO NOT load all catalogs or upstream references for routine application.
- DO NOT let mentality rules override task authority, unrelated repository instructions, or higher-priority requirements.
