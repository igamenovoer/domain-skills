# Rule Family Priorities

## Workflow

1. Validate families and scope; preserve the caller's family order.
2. Read priorities and sequence under **Storage**. Allocate only for enabling actions.
3. Update selection and priority together; use **Removal** for disable.
4. Resolve conflicts by scope, then priority, and report material precedence decisions.

For other requests, use the native planning tool without inventing missing priority history.

## Family Identity

Each ordinary mentality or explicitly named Human Speak or Rigor Control flavor is one family. Brooks production and test rules share a priority; selector groups and Ponytail presets are not new families.

A nonempty project set `P` has one nonnegative family priority; a nonempty memory-enabled set `M+` has another. `M-` needs no priority. Inherited project rules keep project provenance even when the same family has other memory-enabled rules.

## Priority Assignment

Each project and each agent's project-bound memory has its own increasing `next_priority`. A confirmed fresh scope starts at `0`. Each fresh explicit enable assigns the current counter to the family's entire enabled set, then increments it.

- Re-enabling or enabling an already selected subset still reprioritizes the family; it does not enable other IDs.
- Ponytail intensity replacement counts as enable. Edit-scope-only configuration does not.
- For multiple families, allocate once each in caller order, regardless of target-file count. Deduplicate first; clarify materially ambiguous order.
- Deploy, disable, recall, help, review, ordinary work, and invalid/pending requests allocate nothing. Completing or retrying one request reuses its committed allocation.

## Storage

State the family priority beside selected IDs in the [unified section](runtime-injection.md#unified-mentality-section), with flexible wording such as `Brooks, priority 2`. Store the known counter once inside that section:

```markdown
<!-- imsight-skill:imsight-mentality-mgr/next-project-priority: 3 -->
```

This enables nothing. Introduce it with the first enable; preserve it after removals, catalog refreshes, and old-block consolidation.

Before project selection/configuration, inspect counters across discovered project-wide instruction files and explicit targets, including files excluded from writing. Use the greatest valid known counter; it must exceed all inspected assigned priorities. Lower mirrors may remain after file-specific actions but must never move the sequence backward. Matching family copies represent one allocation. Missing mirrors can inherit known history; missing/invalid sequence cannot be reconstructed from surviving priorities because deleted families leave gaps.

Write only selected targets through [Write protocol](runtime-injection.md#write-protocol); report differences left by explicit targeting. Disable and edit-scope-only actions may mirror a known counter without incrementing it. Deployment preserves values and creates no sequence.

Memory priorities/counter stay in this agent's context, bound to project root. Preserve them across supported same-agent handoffs; subagents start independent sequences for explicitly assigned rules.

Validate nonnegative integer priorities, distinct numbers for different families within a scope, and a counter greater than assigned priorities. Conflicting same-family records follow [file-state resolution](runtime-injection.md#instruction-file-selection). Missing or malformed history remains unresolved: recover known state or obtain explicit ordering, never infer it from filenames, IDs, or registration order. Read-only actions do not repair state.

## Removal

Partial disable keeps family priority. An empty enabled set loses that priority but retains negative memory overrides, explicit settings, and the scope's counter. Project entries become reference-only. Never renumber survivors, compact gaps, or reuse deleted priorities.

| Example in one scope | Family priorities | Next |
| --- | --- | --- |
| Enable Brooks, then Ponytail | Brooks `0`, Ponytail `1` | `2` |
| Disable Ponytail | Brooks `0` | `2` |
| Re-enable Ponytail | Brooks `0`, Ponytail `2` | `3` |
| Enable already selected Brooks again | Ponytail `2`, Brooks `3` | `4` |
| Disable all, then enable Docs Writer | Docs Writer `4` | `5` |

## Conflict Resolution

Higher-priority instructions, task authority, and unrelated repository requirements remain above mentality preferences. Resolve per-rule memory overrides first. For conflicting applicable guidance, memory scope wins over project scope regardless of numbers; within a scope, higher family priority wins. Apply compatible lower-priority guidance normally.

Rules inside one family use applicability and judgment notes. Report unresolved tensions or unknown priorities instead of inventing a tie-break. Priority changes neither stored selections nor edit boundaries and never cancels a memory disable.

Recall identifies family, source scope, priority, and winning guidance for actual conflicts. Use `none` for empty selection, `unavailable` for missing evidence; without a task, report configured state only.

## Guardrails

- DO NOT renumber families, reuse removed priorities, or allocate on non-enabling actions.
- DO NOT compare numbers across scopes to override memory with project guidance.
- DO NOT store memory sequences in project files or infer missing history.
