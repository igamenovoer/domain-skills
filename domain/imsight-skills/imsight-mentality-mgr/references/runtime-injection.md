# Mentality Scope and Runtime Application

## Workflow

1. Resolve the target project and action scope from the explicit request; keep catalog publication, project selection, and agent memory separate.
2. Obtain canonical selectors and applicability from the named child, then validate the complete request.
3. Read only the state sources defined under **State Sources** and derive the result using **Effective Selection**.
4. Apply the requested action's mutation boundary from [actions.md](actions.md), using **Managed Project Files** for project writes.
5. For substantive work, apply only effective, applicable guidance through [composition.md](composition.md), including the selected examples and judgment notes when needed.
6. Report actual scope and effects; preserve agent identity and explicit negative overrides across any supported handoff.

If the task does not map cleanly to these steps, use the native planning tool to preserve the caller's scope, validated selectors, and independent agent contexts without inventing persistence.

## State Sources

| Source | Meaning | Who changes it |
| --- | --- | --- |
| `.imsight-arts/mentality/<mentality>-principles.md` | Complete shared definitions and examples; no activation state. | Explicit `deploy`. |
| `AGENTS.md` catalog discovery block | Location and purpose of available principles; no activation state. | Explicit `deploy`. |
| `AGENTS.md` project-selection block | Canonical principles enabled project-wide. | Explicit `enable-project` or `disable-project`. |
| Current agent's chat context | Explicit enabled and disabled overrides for this agent only. | Explicit `enable-memory` or `disable-memory`. |

Resolve the project root from the user-provided directory, otherwise the current version-control root, otherwise the current working directory. These project-facing files intentionally live under that root; a generic report-output override does not relocate them.

Re-read project selection for recall and before applicable work. A catalog is evidence of a principle's definition, never evidence that any agent selected it. There is no mentality-wide enabled flag, built-in all-rules selection, or shared record of agents' effective selections.

An absent project-selection block means no project-enabled rules. A known fresh agent with no remembered instruction inherits project settings. After lost context, absence of a memory record does not prove that no override was previously given: label memory as unavailable and any project-only reconstruction as provisional. Recover an explicit handoff when available rather than guessing.

## Effective Selection

Each mentality owns its canonical rule IDs. Resolve each rule independently:

| Project setting | Agent-memory override | Effective setting | Source |
| --- | --- | --- | --- |
| Enabled | Inherit | Enabled | Project |
| Disabled or absent | Inherit | Disabled | Default |
| Any | Enabled | Enabled | Agent memory |
| Any | Disabled | Disabled | Agent memory |

For validated, disjoint override sets:

```text
P = project-enabled rule IDs
M+ = this agent's explicitly enabled rule IDs
M- = this agent's explicitly disabled rule IDs
Effective selection = (P union M+) minus M-
```

Memory actions remove the opposite override before adding the requested one, so an ID never belongs to both `M+` and `M-`. Repeated actions are idempotent. If restored state contains both and no explicit instruction order resolves them, report inconsistent memory rather than guessing or persisting a repair.

The most recent explicit memory instruction for a rule replaces its earlier memory override. A project action changes only `P`, even when requested later; it never cancels an agent's existing override. No project-scoped disabled tombstones are needed: removing a project requirement still permits an explicit local enable.

An explicit memory disable must remain remembered even when the project currently leaves the rule disabled. Absence of an override means inheritance; clearing an override is conceptually distinct from disabling and is not an alias of any declared action.

### Agent record

A host may carry a record in the current agent's context using this illustrative shape. The skill does not write it to a file:

```json
{
  "mentalities": {
    "brooks": {
      "enabled_rules": ["r1", "t2"],
      "disabled_rules": ["r5"]
    }
  }
}
```

Store canonical IDs, not selector groups. Each child resolves only its own selectors and state entry. Qualify IDs by mentality when composing or reporting several children so one child's identifiers cannot mutate another's selection.

### Applicability and conflicts

Effective selection expresses configured intent. A selected principle is applied only when its documented applicability matches the current task. Recall distinguishes configured selection from current-task application.

Agent-memory guidance overrides conflicting project-scope mentality guidance, including conflicts between different principle IDs. Preserve both definitions and report the task-specific precedence decision; a conflict does not edit either scope. Same-scope conflicts follow explicit task requirements and documented judgment notes; if still material and unresolved, surface the choice instead of inventing rule priorities.

This override policy is part of the project mentality contract itself. It does not allow mentality rules to bypass unrelated repository instructions, system or developer instructions, explicit user requirements, or tool and permission constraints.

## Managed Project Files

Catalog discovery and project selection use independent blocks. Write only the block owned by the requested action and preserve unrelated contents and ordering.

### Catalog artifact

For each deployed mentality, use this path and exact marker pattern, replacing `<mentality>` with its registered name:

```text
.imsight-arts/mentality/<mentality>-principles.md
<!-- imsight-skill:imsight-mentality-mgr/<mentality>-principles:start -->
...complete principle reference...
<!-- imsight-skill:imsight-mentality-mgr/<mentality>-principles:end -->
```

The reference includes a title, entrance skill name, canonical rule index, and an explicit statement that publication does not enable rules. Copy the child's specified catalog sections and their full examples, judgment notes, applicability, and provenance. Preserve internal example indentation and fenced code; keep ordinary Markdown paragraphs on logical lines. Exclude skill-control workflows, session state, active-selection fields, and instructions to apply every listed rule. Resolve or rewrite relative links so the deployed document stands alone inside the target project; do not embed installed child paths that will be invalid on another machine.

A deployed catalog is a project-owned snapshot. Refresh it only through an explicit deployment request. Recall and ordinary work do not silently regenerate it. The child remains authoritative for canonical selector identities; use an available valid deployed definition for application, otherwise load the maintained child definition in memory and report the missing project copy. If deployed and installed definitions disagree materially, report the discrepancy rather than silently combining versions or changing project policy.

### Catalog discovery in `AGENTS.md`

Use this separate discovery block, substituting the actual mentality, title, and path:

```markdown
<!-- imsight-skill:imsight-mentality-mgr/brooks-catalog:start -->
## Available Mentality: Brooks

- Entrance skill: `imsight-mentality-mgr`.
- Principle catalog: [Brooks principles](.imsight-arts/mentality/brooks-principles.md), including definitions, examples, and judgment notes.
- Availability only: this listing enables no principles. Apply rules only when selected in the project block or this agent's chat memory.
- Scope resolution: agent-memory enabled or disabled overrides take precedence over project selection; absent memory overrides inherit project settings. Apply only task-relevant rules.
<!-- imsight-skill:imsight-mentality-mgr/brooks-catalog:end -->
```

This block lists reference material. It must not list an agent's selection or tell every reader to apply the whole catalog.

### Project selection in `AGENTS.md`

Create or update this block only for an explicit project action:

```markdown
<!-- imsight-skill:imsight-mentality-mgr/brooks-project:start -->
## Project Mentality Rules: Brooks

- Project-enabled principles: `r1` (`comprehension`), `r5` (`dependency-direction`).
- Definitions and examples: [Brooks principles](.imsight-arts/mentality/brooks-principles.md).
- Application: these principles apply project-wide when relevant to the task, except where this agent has an explicit in-memory enabled or disabled override. Agent scope wins in conflicts with project-scope mentality guidance.
- Independence: each agent retains its own overrides; do not write an agent's remembered selection or effective result into this block.
<!-- imsight-skill:imsight-mentality-mgr/brooks-project:end -->
```

Use canonical IDs beside their names and write `Project-enabled principles: none.` for an explicitly emptied set. Do not copy examples or complete rule text into `AGENTS.md`; its project index references the complete catalog. Keep source markers exact and on their own lines outside code fences; adapt visible headings to the surrounding document.

### Write protocol

1. Read the latest target contents and validate the complete requested outputs before writing.
2. Locate the exact start/end markers for the action's block. Replace one well-formed matching block in place; when neither exists, insert one block or create the required file.
3. Reject partial, reversed, nested, or duplicate matching markers. An existing catalog artifact without its matching markers is not owned output and must not be overwritten. If existing mentality directives use an incompatible scope or representation, report the conflict for explicit reconciliation instead of guessing which rules are project-wide.
4. Preserve other mentalities' blocks, unrelated guidance, and unrelated artifact content. Immediately before writing shared `AGENTS.md`, check for intervening changes; if it changed, re-read and recompute the targeted edit rather than writing a stale whole-file snapshot. Use a lock or conditional write when the host supports one; otherwise report any detected concurrent conflict instead of claiming atomic multi-agent writes.
5. For deployment, publish the validated catalog before its discovery reference so a new reference does not point to an unwritten file. If either write fails, report actual partial effects and complete or safely recover only the action's owned changes.
6. Verify exactly one matching block per affected file, correct references and canonical IDs, preserved out-of-scope state, and a no-op result when applying the same action again to unchanged inputs.

### Missing and inconsistent material

An explicit project enable requires a complete deployed definition and its discovery reference. Explain the needed `deploy` operation when absent; do not silently add deployment to a request that authorized only a selection change. A request explicitly combining deployment and project enabling may execute them in that order after validating all selectors.

Project disable can remove known IDs despite missing deployment material and should report any remaining broken references. Memory actions and recall can use maintained child definitions without writing files. Unknown project or remembered IDs remain visible as unresolved state; never silently discard them or substitute a different principle.

## Agent Identity and Handoffs

Shared files never carry an agent-specific active selection. Two agents reading the same project instructions independently merge them with their own overrides.

When delegating work, state the intended principle overrides in the subagent's task message if they should transfer. Sharing a repository or spawning a subagent alone does not authorize copying the parent's personal selection. If a harness inherits conversation history, distinguish the delegated agent's explicit assignment from records belonging to the parent; ambiguous ownership must not silently become child overrides. A subagent's memory actions do not update its parent or siblings.

For a same-agent compaction or handoff, retain both enabled and disabled override sets and their scope in the agent's supplied context summary when the host supports that operation. Do not write a shared session-state file to simulate memory. A skill invocation alone installs no lifecycle hooks and guarantees neither cross-turn reinjection nor recovery after context loss.

## Guardrails

- DO NOT infer activation from catalogs, discovery references, or a deployed rule count.
- DO NOT store agent-memory overrides or effective selections in project files.
- DO NOT make project enable/disable actions rewrite catalogs or agent memory.
- DO NOT discard negative memory overrides during recall, compaction, or delegation.
- DO NOT override an agent's memory just because a later action changed project scope.
- DO NOT overwrite malformed, ambiguous, or unowned managed content.
- DO NOT treat another agent's record as the current agent's remembered state.
- DO NOT reconstruct missing memory from guesses or claim persistence without actual host support.
