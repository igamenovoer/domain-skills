---
name: ponytail
description: Use when an Imsight mentality request names Ponytail, applicable coding work has effective Ponytail rules, or the user explicitly requests a Ponytail simplification review. Supports independent simplification intensity and edit scope. Do not use for unrelated prose, automatic repository cleanup, or global persona activation.
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
    - Invoke `imsight-mentality-mgr->ponytail` for recall and concise help without changing state. Deployment publishes the full catalog and enables nothing.
    - Invoke `imsight-mentality-mgr->ponytail->configure-project()` or `imsight-mentality-mgr->ponytail->configure-memory()` with `intensity=safe|normal|extreme` and/or `edit-scope=new-code-only|destructive`. Short arguments such as `normal new-code-only` mean the same settings. Omitted axes are preserved; no arguments means help, not activation.
    - Natural wording such as “set Ponytail to normal in your memory” selects configure-memory with intensity=normal. Require explicit project or memory scope for persistent configuration; do not guess it from earlier actions.
    - Invoke this child's shared `deploy()`, `enable-project()`, `disable-project()`, `enable-memory()`, `disable-memory()`, `recall()`, or `help()` actions with their shared meanings. Rule enable/disable accepts explicit p1–p12, canonical names, or all; it never changes edit scope. Intensity presets use configure actions, not additive rule actions.
    - Invoke `imsight-mentality-mgr->ponytail->review()` with a target, optional rule selectors or intensity, and optional edit-scope. Explicit review settings last for that review only; destructive scope does not apply fixes. Natural form: `$imsight-mentality-mgr ponytail review intensity=normal edit-scope=new-code-only` followed by the target.
    - `safe`, `normal`, and `extreme` are the only intensity presets. Upstream lite/full/ultra/off modes, mode files, and hooks are not this skill's control surface. Use explicit rule disable actions to disable principles.
---

# Ponytail Mentality

## Overview

Reduce unnecessary implementation and maintenance work while preserving required behavior, meaningful edge-case defenses, and the assigned task boundary. Intensity controls which simplifications to pursue. Edit scope independently controls whether existing infrastructure may change. The skill is self-contained within the mentality manager and installs no hooks or global mode state.

## Workflow

1. **Resolve intent** from **Subcommands** and the frontmatter contract; ordinary coding work requires effective selected rules.
2. **Resolve rules and both axes** through [state.md](references/state.md). Validate the complete request and preserve agent identity before configuration or application.
3. **Execute an explicit action** through its detail page. Review follows [review.md](references/review.md); shared rule actions retain their original meanings.
4. **For implementation**, establish the assigned task and starting code boundary, read relevant flow and callers, and apply **Applying the Mentality** only to permitted code.
5. **Report effects** and any material tradeoff or boundary conflict. Recall includes effective IDs, derived intensity, edit scope, and provenance without changing state.

If the task does not map cleanly to these steps, use the native planning tool to plan from the requested outcome, selected principles, and permitted edit surface without activating unselected rules or expanding the assignment.

## When to Use

Use for Ponytail catalog and scope management, implementation with selected principles, and explicit simplification reviews. Discussing a principle or loading this child does not activate it. Configuration controls future applicable work, not permission to begin unrelated cleanup. Ordinary prose follows the user's communication requirements.

## Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `deploy` | Publish the complete catalog without enabling rules or choosing axes. | [Shared definition](../../references/actions.md#deploy) |
| `configure-project` | Replace project intensity and/or set project edit scope. | [Configure Project](references/state.md#configure-project) |
| `configure-memory` | Replace this agent's intensity and/or set its edit-scope override. | [Configure Memory](references/state.md#configure-memory) |
| `enable-project` | Add named individual rules to project selection. | [Shared definition](../../references/actions.md#enable-project) |
| `disable-project` | Remove named individual rules from project selection. | [Shared definition](../../references/actions.md#disable-project) |
| `enable-memory` | Remember enabled individual-rule overrides for this agent. | [Shared definition](../../references/actions.md#enable-memory) |
| `disable-memory` | Remember disabled individual-rule overrides for this agent. | [Shared definition](../../references/actions.md#disable-memory) |
| `recall` | Report selected rules, intensity, edit scope, and their provenance. | [Recall](references/state.md#recall) |
| `review` | Find supported simplifications within the selected criteria and edit boundary. | [Review](references/review.md) |
| `help` | Explain actions, axes, and rule IDs without changing state. | This entrypoint |

## Intensity and Edit Scope

| Intensity | Rules |
| --- | --- |
| `safe` | p1–p7: reuse, proven primitives, dependency restraint, root-cause placement, proven redundancy, focused verification, and explicit limits. |
| `normal` | Safe plus p8 collapse-structure and p9 compact-implementation. |
| `extreme` | Normal plus p10 remove-unused-flexibility, p11 replace-existing-dependencies, and p12 challenge-speculative-work. |

| Edit scope | Permitted simplification surface |
| --- | --- |
| `new-code-only` | Newly written task code that uses existing infrastructure. Preserve established infrastructure, contracts, dependencies, and behavior; allow minimal compatible wiring. |
| `destructive` | Also the existing infrastructure directly related to the task, with the smallest coherent impact. Repository-wide refactoring requires that explicit assignment. |

Safe plus new-code-only is the recommended explicit starting configuration. No rules are enabled by default. A missing edit-scope setting resolves to new-code-only independently of intensity. Even extreme plus destructive preserves meaningful defenses and the task boundary. Detailed resolution, downgrade, and baseline rules live in [state.md](references/state.md).

## Applying the Mentality

1. Identify the required behavior, affected flow and callers, existing task infrastructure, and relevant edge/failure conditions. Use the [edit boundary](references/state.md#edit-boundary) before choosing a simplification.
2. Read selected definitions and examples from the valid deployed catalog, otherwise [principles.md](references/principles.md), following the shared runtime's definition policy. Apply only the selected rules within the resolved edit scope.
3. For selected reuse rules, look for a suitable local solution, then proven standard-library/native facilities, then suitable installed dependencies, before writing custom machinery. Suitability includes edge cases and the project's supported runtime; a superficially shorter alternative is not automatically equivalent.
4. Apply selected structural rules only where their present benefit is supported. Preserve defenses required by the actual contract. Under destructive scope, keep changes confined to the task's affected infrastructure and necessary callers; stop expansion at unrelated cleanup opportunities.
5. Verify changed behavior in proportion to risk using repository conventions and available evidence. Report what was actually checked and explain any unresolved scope conflict or deliberate limitation. Honor requested explanations without a fixed line limit.

If a correct root-cause fix needs infrastructure outside new-code-only scope, use an existing explicit task instruction that authorizes that precise change or surface the boundary conflict. Do not hide the issue behind a new caller-specific workaround. A general request for a feature does not authorize a surrounding infrastructure rewrite.

## Catalog Publication

Publish `.imsight-arts/mentality/ponytail-principles.md` using the shared deployment contract. Copy the complete `Principle Index`, `Safe Rules`, `Normal Additions`, `Extreme Additions`, `Validity Requirements`, `Applicability`, and `Provenance` sections of [principles.md](references/principles.md), including every example and judgment note. Include the title, canonical index, entrance skill, and availability-only statement. Exclude control workflows, current selection, and project or agent settings. The published explanations stand alone; no installed paths or source snapshots are required.

## Maintenance

Keep canonical rules and preset membership in the principle index, state transitions and edit boundaries in state.md, and diagnostic evidence in review-patterns.md. Shared review mechanics belong to the parent. [Upstream provenance](org/README.md) records the source snapshot and MIT notice; upstream entrypoints are historical material, not runtime instructions.

## Guardrails

- DO NOT remove required edge-case defenses or change the supported contract merely to reduce code.
- DO NOT treat line counts, one caller, or one implementation as proof that infrastructure is unnecessary.
- DO NOT let intensity widen edit scope or let destructive scope expand the assigned task.
- DO NOT revise existing infrastructure under new-code-only scope without an explicit task instruction authorizing that change.
- DO NOT pursue opportunistic or codebase-wide refactoring unless it is the assigned task.
- DO NOT apply review recommendations as edits or write memory/settings during review.
- DO NOT infer activation from deployment, configuration of edit scope alone, or upstream state files.
- DO NOT copy another agent's remembered rules or edit-scope override into this agent or shared project policy.
