---
name: ponytail
description: Use when an Imsight mentality request names Ponytail, applicable coding work has effective Ponytail rules, or the user explicitly requests a Ponytail simplification review. Supports independent simplification intensity and edit scope. Do not use for unrelated prose, automatic repository cleanup, or global persona activation.
---

# Ponytail Mentality

## Overview

Reduce unnecessary implementation and maintenance work while preserving required behavior, meaningful edge-case defenses, and the assigned task boundary. Intensity controls which simplifications to pursue. Edit scope independently controls whether existing infrastructure may change. The skill is self-contained within the mentality manager and installs no hooks or global mode state.

## Workflow

1. **Resolve intent** from **Subcommands** and the selected action reference; ordinary coding work requires effective selected rules.
2. **Resolve rules and both axes** through [state.md](references/state.md). Validate the complete request and preserve agent identity before configuration or application.
3. **Execute an explicit action** through its detail page. Review follows [review.md](references/review.md); shared rule actions retain their original meanings.
4. **For implementation**, establish the assigned task and starting code boundary, read relevant flow and callers, and apply **Applying the Mentality** only to permitted code.
5. **Report effects** and any material tradeoff or boundary conflict. Recall includes effective IDs, derived intensity, edit scope, and provenance without changing state.

If the task does not map cleanly to these steps, use the native planning tool to plan from the requested outcome, selected principles, and permitted edit surface without activating unselected rules or expanding the assignment.

## When to Use

Use for Ponytail catalog and scope management, implementation with selected principles, and explicit simplification reviews. Discussing a principle or loading this child does not activate it. Configuration controls future applicable work, not permission to begin unrelated cleanup. Ordinary prose follows the user's communication requirements.

## Subcommands

Shared rule actions retain the parent's meanings with `ponytail` selected. Configure actions accept intensity and/or edit scope through [state.md](references/state.md); review accepts invocation-only criteria and scope through [review.md](references/review.md).

For example, `$imsight-mentality-mgr ponytail configure-memory normal new-code-only` sets both axes in this agent's memory. “Set Ponytail to normal in your memory” selects the same action with intensity only; omitted axes are preserved, and configuration without arguments shows help. Persistent configuration requires explicit project or memory scope, never a guess based on earlier actions.

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `deploy` | Publish the complete catalog without enabling rules or choosing axes. | [Shared definition](../../references/actions.md#deploy) |
| `configure-project` | Replace project intensity and/or set project edit scope. | [Configure Project](references/state.md#configure-project) |
| `configure-memory` | Replace this agent's intensity and/or set its edit-scope override. | [Configure Memory](references/state.md#configure-memory) |
| `enable-project` | Add named individual rules to project selection. | [Shared definition](../../references/actions.md#enable-project) |
| `disable-project` | Remove named individual rules from project selection. | [Shared definition](../../references/actions.md#disable-project) |
| `enable-memory` | Remember enabled rule overrides; omitted selectors mean all current rules. | [Shared definition](../../references/actions.md#enable-memory) |
| `disable-memory` | Remember disabled rule overrides; omitted selectors mean all current rules. | [Shared definition](../../references/actions.md#disable-memory) |
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
2. Read and retain selected rule definitions, **Representative Do / Don't comparisons**, and configured setting meanings through shared [Definition Retention](../../references/runtime-injection.md#definition-retention). Use each comparison's stated contract and judgment note; apply only the selected rules within the resolved edit scope.
3. For selected reuse rules, look for a suitable local solution, then proven standard-library/native facilities, then suitable installed dependencies, before writing custom machinery. Suitability includes edge cases and the project's supported runtime; a superficially shorter alternative is not automatically equivalent.
4. Apply selected structural rules only where their present benefit is supported. Preserve defenses required by the actual contract. Under destructive scope, keep changes confined to the task's affected infrastructure and necessary callers; stop expansion at unrelated cleanup opportunities.
5. Use existing evidence and repository-required checks; apply selected p6 to decide whether further verification is warranted. New tests are not an automatic consequence of an edit. Report what was actually checked and explain any material unresolved risk, scope conflict, or deliberate limitation. Honor requested explanations without a fixed line limit.

If a correct root-cause fix needs infrastructure outside new-code-only scope, use an existing explicit task instruction that authorizes that precise change or surface the boundary conflict. Do not hide the issue behind a new caller-specific workaround. A general request for a feature does not authorize a surrounding infrastructure rewrite.

## Catalog Publication

Publish `.imsight-arts/mentality/ponytail-principles.md` using the shared deployment contract. Copy the complete `Principle Index`, `Safe Rules`, `Normal Additions`, `Extreme Additions`, `Validity Requirements`, `Applicability`, and `Provenance` sections of [principles.md](references/principles.md), including every Do / Don't code comparison, its assumptions, judgment note, source attribution, and the example license notice. Declare all files in `references/sources/`, indexed by [offline sources](references/sources/index.md), as the source bundle; copy it and rewrite catalog links through the shared [offline publication contract](../../references/runtime-injection.md#offline-source-bundles). Include the title, canonical index, entrance skill, and availability-only statement. Exclude control workflows, current selection, and project or agent settings. The published catalog and its source directory work without installed paths, the original checkout, or network access.

## Maintenance

Keep canonical rules and preset membership in the principle index, state transitions and edit boundaries in state.md, and diagnostic evidence in review-patterns.md. Shared review mechanics belong to the parent. [Offline sources](references/sources/index.md) retain the relevant originals or explicitly identified excerpts with origin links and licenses. [Upstream provenance](org/README.md) records the immutable archive; source entrypoints and examples are historical material, not runtime instructions.

## Guardrails

- DO NOT remove required edge-case defenses or change the supported contract merely to reduce code.
- DO NOT treat line counts, one caller, or one implementation as proof that infrastructure is unnecessary.
- DO NOT let intensity widen edit scope or let destructive scope expand the assigned task.
- DO NOT revise existing infrastructure under new-code-only scope without an explicit task instruction authorizing that change.
- DO NOT pursue opportunistic or codebase-wide refactoring unless it is the assigned task.
- DO NOT apply review recommendations as edits or change activation and configured settings during review.
- DO NOT infer activation from deployment, configuration of edit scope alone, or upstream state files.
- DO NOT copy another agent's remembered rules or edit-scope override into this agent or shared project policy.
