# Rule Family Priorities

## Workflow

1. Resolve the selected families, rule IDs, and scope through the shared actions. Preserve the caller's family order and validate the complete request before mutation.
2. Read that scope's family priorities and next-priority value under **Storage**, deduplicating mirrored instruction-file records. For an enabling action, allocate through **Priority Assignment**.
3. Update selection and priority together within the action's authorized scope. Disabling follows **Removal**; reading definitions, deployment, and recall allocate nothing.
4. Resolve applicable conflicts by scope, then family priority, using **Conflict Resolution**.
5. Report family priorities with the selections and retain the sequence across supported same-agent handoffs.

If the task does not map cleanly to these steps, use the native planning tool to preserve explicit scope, activation order, and agent independence without inventing missing priorities.

## Family Identity

A family is one independently selected mentality, such as `brooks`, `ponytail`, `docs-writer`, or `agile-experimenter`. Each explicitly named Human Speak flavor is its own family, such as `human-speak/han-style`; Human Speak itself has no combined priority. Brooks production and testing groups share the Brooks priority. Selector groups and Ponytail presets do not create additional families.

Each family with enabled rules has one integer priority `>= 0` in each scope where it has an explicit enabled selection. All rules in that family's project set `P` share its project priority; all rules in its agent-memory set `M+` share its memory priority. Inherited project rules keep project provenance and priority even when other rules of the same family have memory overrides. Disabled overrides in `M-` do not need a priority.

## Priority Assignment

Maintain a separate monotonically increasing `next_priority` for project scope and for each agent's memory scope in that project. A confirmed fresh scope starts at `0`. On each successful explicit enable, assign the family's priority from `next_priority`, then increment `next_priority` by one. This is the previous assigned priority plus one, including when earlier families have since been disabled or removed.

- A new enable request also reprioritizes an already enabled family, even when its rule IDs do not change. Enabling a subset raises the priority of all rules enabled in that family and scope; it does not enable unselected rules or change the other scope.
- An explicit Ponytail intensity configuration counts as an enable because it replaces the selected rule set with a preset. An edit-scope-only configuration does not allocate or change priority.
- For multiple families in one request, allocate once per distinct family in the caller's stated order, first to last. Normalize and deduplicate before allocation. Clarify a materially ambiguous order instead of using catalog or registration order.
- Multiple target instruction files do not multiply allocations. Assign one priority per requested family, then write the same resulting priority and counter to all selected files.
- Invalid requests, pending flavor choices, deployment, disable, help, recall, ordinary application, and review-only selectors do not allocate priorities. A retry of the same in-flight write must not be mistaken for a fresh user enable; re-read committed state before retrying an uncertain write.

Priorities order enabled families; they do not select additional rules, change definitions, or authorize new work.

## Storage

State each enabled family's nonnegative integer priority beside its selected IDs in the [unified mentality section](runtime-injection.md#unified-mentality-section), for example `Brooks, priority 2`. Wording and layout may vary; the number and family association must be unambiguous. Follow [Instruction File Selection](runtime-injection.md#instruction-file-selection) for `AGENTS.md`, `CLAUDE.md`, and other targets.

Keep the known next-priority value once inside that section as a compact bookkeeping comment, not a separate block or repeated field per family:

```markdown
<!-- imsight-skill:imsight-mentality-mgr/next-project-priority: 3 -->
```

The example means the next project enable receives priority `3`; it enables nothing. Introduce the counter with the first project enable. Keep it after every family becomes reference-only so later enables do not reuse old numbers. Preserve its value when consolidating older owned blocks or refreshing catalogs. A project enable updates the counter and affected family entries in the same section rewrite through [Write protocol](runtime-injection.md#write-protocol). Re-read project state after concurrent changes and recompute before writing.

Before a project selection or configuration action, inspect sequence state across the discovered project-wide instruction files and explicit targets, including any discovered files excluded from writing by an explicit target choice. Use the greatest valid stored next-priority value; it must exceed every assigned project priority in the inspected files. Lower counters can remain after a file-specific action and must never move the sequence backward. Matching entries for one family are one allocation, not duplicate priorities. Missing mirrors may inherit known sequence state; a missing or invalid sequence cannot be reconstructed from current family numbers alone because removed families may have left gaps. Mirror the resulting known counter only to the selected targets and report any differences left by an explicit file choice. Disable and edit-scope-only configuration may copy the known counter but never increment it; deployment alone preserves sequence values and creates no new sequence.

Agent priorities and their next-priority value live only in that agent's chat context, bound to the project root. Memory actions write no files and never increment the project counter. Preserve the counter, family priorities, enabled and disabled IDs, and definition retention during same-agent handoffs. A subagent starts its own memory sequence for explicitly assigned rules; it does not copy a parent's numbers or counter implicitly.

Validate nonnegative integer priorities, distinct numbers for different enabled families within one scope, and a next-priority value greater than every assigned number in that scope. Missing, duplicate, or malformed priorities and lost sequence state are unresolved, not permission to infer order from instruction filenames, registration order, or rule IDs. Resolve differing records for the same family through [Instruction File Selection](runtime-injection.md#instruction-file-selection); never choose a record solely because its file was read last. Recover known state or obtain an explicit ordering for reconciliation; recall and ordinary work do not repair files or invent history. A confirmed fresh scope with no prior allocation needs no stored counter until its first enable.

## Removal

Disabling some rules preserves the family's priority for its remaining enabled rules. When its scope's enabled set becomes empty, remove that scope's family priority. Preserve memory-disabled overrides, independent child settings, and the scope's next-priority value. Reduce empty project selections to reference-only entries through [Empty project selection](runtime-injection.md#empty-project-selection). Retain explicit settings in their entry without a family priority.

Never renumber surviving families, compact gaps, or decrease the counter. Re-enabling a removed family receives the next fresh number.

The following sequence is illustrative and stays within one scope:

| Action | Enabled family priorities | Next priority |
| --- | --- | --- |
| Enable Brooks, then Ponytail | Brooks `0`, Ponytail `1` | `2` |
| Enable Agile Experimenter | Brooks `0`, Ponytail `1`, Agile Experimenter `2` | `3` |
| Disable all Ponytail rules | Brooks `0`, Agile Experimenter `2` | `3` |
| Enable Ponytail again | Brooks `0`, Agile Experimenter `2`, Ponytail `3` | `4` |
| Enable already selected Brooks rules again | Agile Experimenter `2`, Ponytail `3`, Brooks `4` | `5` |
| Disable all families, then enable Docs Writer | Docs Writer `5` | `6` |

## Conflict Resolution

Keep system, developer, explicit user, unrelated repository, tool, permission, and task-boundary requirements above mentality preferences. Resolve rule selection first: an explicit memory enable or disable overrides that rule's project selection.

For conflicting applicable guidance, agent-memory scope wins over project scope regardless of the numbers. Within the same scope, the family with the larger priority wins; apply compatible guidance from the other family normally. A memory family at `0` therefore outranks a conflicting project family at `50`, while project `5` outranks project `2`. Numbers from separate scopes are not compared.

Rules within one family share a priority, so use their applicability and judgment notes to resolve internal tensions. Surface a material unresolved conflict or unavailable priority rather than inventing a tie-break. Priority never widens an edit boundary, suppresses an explicit disabled override, or deletes stored selections.

Recall shows family identity, enabled IDs, source scope, and priority; use `none` for an empty scoped selection and `unavailable` for missing priority evidence. Explain material overrides with both families, scopes, and numbers. Without a substantive task, report configured priorities without asserting that a conflict exists.

## Guardrails

- DO NOT renumber existing families or reuse deleted priorities.
- DO NOT let a project priority override explicit agent-memory guidance.
- DO NOT store memory priorities or the agent's sequence in shared project files.
- DO NOT allocate priorities through deployment, recall, review, or ordinary application.
- DO NOT infer missing priority order from file layout, catalog order, or another agent's state.
