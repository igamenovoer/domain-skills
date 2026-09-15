# Ponytail Selectors, Configuration, and Edit Boundary

## Workflow

1. Resolve the action, project, and state scope through the [shared runtime](../../../references/runtime-injection.md) and the child entrypoint. Enable/disable defaults to agent memory; configuration retains its declared scope requirements. Bare entrypoint/configuration calls without actionable arguments return help or recall.
2. Validate all parameters using **Selectors and Axes**; shared enable/disable accepts rule selectors, while configuration replaces a preset and/or changes edit scope.
3. Resolve rules and edit scope independently under **State and Precedence**, then execute **Configure Project**, **Configure Memory**, a shared action, or review's invocation-only resolution.
4. Before application or review, establish the assigned task and permitted surface under **Edit Boundary**. Settings do not authorize unrelated work.
5. Report changes or perform **Recall**, preserving both negative rule overrides and edit-scope provenance without copying another agent's state.

If the request does not map cleanly to these steps, use the native planning tool to preserve the independent axes, explicit state scope, and task boundary. Ask only for information that materially prevents correct resolution; no ambiguity authorizes a state mutation.

## Selectors and Axes

The [principle index](principles.md#principle-index) owns the canonical IDs, names, and preset membership. Normalize rule codes and names case-insensitively; accept p1–p12, canonical hyphenated names, and explicit all. Validate and deduplicate the complete request before effects. IDs are local to Ponytail.

Use the shared [enable/disable decision tree](../../../references/actions.md#enabledisable-decision-tree): omitted scope means agent memory, and omitted memory selectors expand to all current Ponytail IDs while preserving edit scope. Project rule enable/disable requires explicit selectors and includes required deployment and updates to all selected coding-agent instruction files (`AGENTS.md`, `CLAUDE.md`, etc.). This shorthand does not change configuration's missing-parameter behavior or review's default criteria.

| Input | Meaning |
| --- | --- |
| intensity=safe | Exactly p1–p7. |
| intensity=normal | Exactly p1–p9. |
| intensity=extreme | Exactly p1–p12. |
| edit-scope=new-code-only | Preserve established infrastructure while applying selected rules to new task code. |
| edit-scope=destructive | Permit minimal revisions of existing task-related infrastructure. |

Configuration accepts either or both named parameters, or unambiguous short values such as `normal new-code-only`. No parameters means help without mutation. Missing parameters preserve their current axis; in particular, changing intensity never resets or broadens edit scope. Reject conflicting repeated parameters, unknown modes, mixed preset-plus-individual selectors in one configuration, and unsupported upstream lite/full/ultra/off values. Individual rules remain controllable through the existing enable/disable actions.

Preset names belong to configuration and review, not shared additive enable/disable selectors. If a caller clearly asks to set a preset in project or memory scope, route that intent to the corresponding configure action and report the replacement semantics. Do not treat enabling a group as a silent downgrade: setting safe after extreme must remove the additional criteria in that state scope.

## State and Precedence

Use the existing project rule set P and current-agent overrides M+ and M-. The formula remains `E = (P union M+) minus M-`. Configuration expands a preset into IDs; there is no separately persisted intensity flag. Derive a selection's label as safe, normal, or extreme only on an exact match with the current preset; otherwise report custom, none, or unresolved. Individual edits can make a preset custom. Re-reading a catalog never re-expands stored IDs or enables new rules.

Ponytail is one rule family in the shared [priority contract](../../../references/priorities.md). Explicit rule enable and intensity configuration allocate a fresh priority for its complete enabled set in the selected scope, even if the IDs are unchanged. Disabling preserves the priority while rules remain; edit-scope-only configuration, recall, and review do not reprioritize it. Agent scope still wins over project scope, then higher family priority wins same-scope conflicts. Priority never widens the edit boundary.

Edit scope is a separate optional scalar. Resolve this agent's explicit value first, then the project's explicit value, then new-code-only. Missing agent value means inherit, not a remembered new-code-only override. An explicit remembered new-code-only must mask a later project destructive setting. Rule enable/disable operations preserve this field, and a scope-only configuration changes no rule IDs.

Unknown or malformed settings are unresolved, not permission for destructive edits. Preserve unknown rule IDs visibly as unresolved state under the shared runtime contract; do not silently drop them while configuring known IDs. Resolve or obtain an explicit replacement of inconsistent state before a configuration would erase it. Apply the shared lost-context rules: an unavailable memory record is not an empty one. Recover a same-agent handoff when available; otherwise disclose uncertainty and do not modify existing infrastructure based on a guessed scope. Other agents' records never supply local overrides.

### Storage

- Catalog: `.imsight-arts/mentality/ponytail-principles.md`.
- Instruction entry: `ponytail` in the shared unified mentality section.
- Memory namespace: ponytail, with enabled_rules, disabled_rules, family priority when enabled_rules is nonempty, and optional edit_scope; the shared next-memory-priority counter belongs to this agent and project.

Retain rule and setting meanings through shared [Definition Retention](../../../references/runtime-injection.md#definition-retention). Check whether the project's deployed details define each preset or edit boundary; a principle catalog alone does not imply coverage of every setting. Keep the setting's value and source independently of its definition reference or content.

For example, `configure-memory normal new-code-only` remembers enabled IDs p1 through p9, disabled IDs p10 through p12, a fresh memory family priority, and the explicit edit-scope value. If deployed details define the rules and preset but omit edit scope, retain their project-bound paths and identifiers. Retain the operative **New-code-only** boundary below as inline content, including allowed wiring, explicit task-authority exceptions, and the distinction between new code and rewritten infrastructure. This example requires no memory file or prescribed serialization schema.

The Ponytail entry follows the shared [unified-section contract](../../../references/runtime-injection.md#unified-mentality-section). Keep its selected IDs, priority, catalog link, and any explicit `edit-scope` value together; an absent setting uses the default. Preserve explicit settings in rule-only changes and avoid a redundant authoritative intensity flag. With no selected rules, retain the setting in a reference-only entry without a family priority or instructions to apply the catalog. See [settings-only example](../../../references/instruction-examples.md#retain-an-independent-setting) for an illustrative rewrite; exact wording and layout are flexible.

## Configure Project

1. Require project scope and at least one validated axis. Run shared [Project application preparation](../../../references/runtime-injection.md#project-application-preparation), including required catalog publication and preparation of final references without an intermediate instruction-file write. A scope-only setting still enables no rules.
2. Read current P, project family priority, the shared counter, and the project edit-scope field. If intensity is supplied, replace P with that preset's exact ID set and allocate a fresh project priority through the shared contract. If edit scope is supplied, replace that field. Preserve every omitted axis, agent override, and unrelated family entry; an edit-scope-only request preserves priority and counter.
3. After resolving the final settings and selection, rewrite the unified section once per target with the Ponytail entry and any allocated counter through the shared write protocol. Keep common scope guidance once and use a reference-only entry with retained settings and no family priority when no rules are enabled.
4. Verify canonical IDs, priority and counter, settings, deployment/discovery, and unrelated contents. Report the resulting project selection, family priority, edit scope, and changed paths; agent overrides may produce different effective results. A fresh intensity request reprioritizes Ponytail even when its rule IDs already match.

## Configure Memory

1. Require memory scope and at least one validated axis; no deployment is needed. Use only the current agent's record. Read the requested rule, preset, and edit-scope meanings through shared [Definition Retention](../../../references/runtime-injection.md#definition-retention).
2. If intensity is supplied, let S be its expansion and U the current twelve Ponytail IDs. Replace this child's overrides with `M+ = S` and `M- = U minus S`, then allocate a fresh memory family priority. This intentionally replaces earlier Ponytail rule overrides, including individual ones; it masks project rules above the chosen preset. Other families' stored selections and priorities are unchanged.
3. If edit scope is supplied, remember that scalar; otherwise preserve the existing override or inheritance. The explicit parameter `edit-scope=inherit`, accepted only by this memory configuration action, removes this agent's scope override without changing any rule override.
4. Retain the family priority and shared next-memory-priority counter with each affected rule or setting's definition reference or content, then report E, family priorities, derived intensity, effective edit scope, and each setting's source through [Memory Confirmation](../../../references/runtime-injection.md#memory-confirmation). Summarize practical behavior and the permitted edit surface; write no files. Later individual enable/disable actions modify M+/M- and priority through the shared contract, without rewriting edit scope.

Configuration is explicit replacement, while shared individual rule actions remain additive/subtractive. For example, setting safe after extreme makes E exactly p1–p7 for that agent, even if the project selects extreme. A later explicit enable-memory p8 makes its selection custom. Disabling all rules does not reset edit scope or create an off mode; recall shows no effective rules and the retained scope separately.

## Edit Boundary

Establish what existed at the start of the assigned implementation task. Existing infrastructure includes shared helpers, services, interfaces, contracts, dependency declarations, configuration, callers, and test/build support already present, including pre-existing uncommitted work. Newly written code is task-owned additions, potentially inside existing files, that use those contracts. A copied, moved, renamed, or rewritten old implementation remains existing infrastructure. Reinvocation and compaction do not reset this boundary.

Retain the task purpose and baseline identity in the same agent's context or supported handoff; do not create a shared session file. Use the initial diff/status, named base revision, or supplied task artifacts to distinguish pre-existing work from additions. For review, use the supplied task/patch baseline when it identifies the proposed additions; merely being untracked or added in the current diff is not enough to reclassify an existing implementation. If the boundary is unavailable, describe what can be classified, ask for the missing baseline if needed, and do not assume the whole target is new.

### New-code-only

Apply selected rules only to new task code while preserving existing infrastructure and its supported behavior. Minimal compatible wiring is allowed, such as registering a new handler through the established registry or adding an import/call without changing old contracts. New tests may use existing fixtures and runners. Replacing a helper, changing a shared signature, deleting an existing abstraction, removing a dependency, or reorganizing test infrastructure is an existing-infrastructure edit, regardless of diff size.

Normal or extreme intensity may simplify new wrappers, functions, and modules without permitting those edits to old infrastructure. A selected rule without an eligible target is inapplicable, not authority to widen the surface. If the correct fix requires an existing-infrastructure edit, honor a precise explicit task instruction already authorizing that edit or surface the remaining boundary conflict. Do not patch a symptom in a new caller or silently widen scope to make the task fit.

### Destructive

Make the smallest coherent change needed for the assigned task. Revise existing infrastructure only where the task requires it, including necessary caller or contract updates. For each such change, identify its connection to the requested outcome and the behavior that must remain valid. Follow genuine dependencies needed for correctness; stop at unrelated cleanup opportunities. Preserve unrelated infrastructure, APIs, and behavior.

Do not undertake opportunistic cleanup or codebase-wide refactoring unless that is the assigned task. Even when a broad refactor is explicitly assigned, keep each change justified by that assignment and preserve its requirements. Destructive permits source-code revision within this boundary; it does not authorize deleting user data, changing external services, or applying fixes during review. Intensity controls which simplifications are considered inside this boundary and never enlarges it.

## Recall

Follow the shared recall action, then add:

- Project IDs, project family priority, and derived project intensity, this agent's enabled/disabled overrides and memory family priority, and E with its derived effective intensity. Show custom selections as IDs instead of claiming a preset.
- Project edit scope, this agent's edit-scope override or inherit, effective edit scope, and its source. Label unavailable memory separately.
- For a supplied task, the known starting boundary and which selected rules are applicable, blocked by the edit boundary, or unresolved. Without a task, applicability is not evaluated.
- Any review-only overrides belong to that report, not subsequent configured recall. No report is a memory or policy input.

Same-agent handoffs retain both negative overrides and the optional edit-scope override, the family priority and shared memory counter, plus the task baseline. Preserve definition paths and identifiers or operative inline content for rules and settings through the shared retention contract. Subagents receive only their explicitly assigned overrides and boundary; sharing the project does not transfer this agent's settings or priority sequence.

## Guardrails

- DO NOT treat a missing edit-scope override as an explicit remembered setting.
- DO NOT change edit scope when setting intensity or enabling/disabling rules.
- DO NOT implement a preset downgrade as a union that leaves more aggressive rules enabled.
- DO NOT persist intensity labels as competing activation state or auto-expand them after catalog updates.
- DO NOT treat destructive scope as permission to refactor unrelated infrastructure.
- DO NOT classify rewritten existing code as new to bypass the edit boundary.
- DO NOT change selections or configured values while recalling or reviewing them.
