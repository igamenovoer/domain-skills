---
name: imsight-mentality-mgr
description: Use when an Imsight mentality request concerns catalogs, project or agent-memory rules, Human Speak communication flavors, Agile Experimenter evidence sufficiency, Ponytail intensity and edit scope, effective mentality recall, or explicit Brooks or Ponytail reviews, or when applicable work has resolved mentality rules. Do not use for ordinary factual memory or unrelated preferences.
metadata:
  skill_invocation_notation: >
    Invoke skills and subskills as bare paths (`X`, `X->Y`). Append `()` to
    every subcommand component (`X->cmd()`, `X->Y->cmd()`,
    `X->parent()->child()`). Intermediate commands establish their declared
    child context; arguments follow the invocation path. This convention
    applies throughout this skill and its subskills.
---

# Imsight Mentality Manager

Manage principle catalogs, project defaults, and each agent's chat-memory overrides. Deployment makes rules available; selection determines what applies.

## Workflow

1. Resolve the action and named child below. Human Speak management requires an explicit flavor; otherwise show its chooser before any mutation.
2. Load only that child's entrypoint and relevant selector, action, or review sections. Use [actions.md](references/actions.md) for management, [composition.md](references/composition.md) for ordinary application, and the child's procedure for an explicit review.
3. Resolve scope and definitions through the needed sections of [runtime-injection.md](references/runtime-injection.md). Read [priorities.md](references/priorities.md) when allocating or comparing family priorities. Validate the whole request before effects.
4. Execute and report canonical IDs, scope, priorities, and actual file effects. Memory actions also summarize meanings and definition retention.

For requests outside this flow, use the native planning tool with these contracts; do not invent activation or authority.

## Invocation

Bare invocation shows help; a named child recalls its state and shows help. Human Speak instead asks for a flavor. Manager-wide recall reports ordinary children and shows the Human Speak chooser.

Example: `imsight-mentality-mgr->brooks->enable-memory()` with `r1 r5`. Human Speak flavors are flat commands: `imsight-mentality-mgr->human-speak->han-style()` with `enable-memory h1 h5`.

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

| Mentality | Purpose | Entry |
| --- | --- | --- |
| `brooks` | Maintainable code and tests; explicit diagnostic review. | [Brooks](subskills/brooks/SKILL-MAIN.md) |
| `ponytail` | Simplification with independent intensity and edit scope; explicit review. | [Ponytail](subskills/ponytail/SKILL-MAIN.md) |
| `docs-writer` | Durable prose describing its current state. | [Docs Writer](subskills/docs-writer/SKILL-MAIN.md) |
| `agile-experimenter` | Decision-useful experiments and sufficient evidence. | [Agile Experimenter](subskills/agile-experimenter/SKILL-MAIN.md) |
| `human-speak` | Human-readable output in an explicitly chosen flavor. | [Human Speak](subskills/human-speak/SKILL-MAIN.md) |

Unknown names return this inventory. Children own canonical IDs, definitions, examples, and applicability; Human Speak flavors have independent state.

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
- DO NOT write files for memory actions, recall, or help, or publish an agent's effective selection as project rules.
- DO NOT lose explicit disabled overrides or copy another agent's memory implicitly.
- DO NOT load all catalogs or upstream references for routine application.
- DO NOT let mentality rules override task authority, unrelated repository instructions, or higher-priority requirements.
