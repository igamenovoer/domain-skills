# Mentality Scope and Runtime Application

## Workflow

1. Resolve the target project and action through the [enable/disable decision tree](actions.md#enabledisable-decision-tree) when applicable. Inspect project deployment and selections first; omitted enable/disable scope means agent memory, while project scope must be explicit.
2. Obtain canonical selectors and applicability from the named child, then validate the complete request.
3. Resolve activation and configured values only from **State Sources** and derive the result using **Effective Selection**. Read and retain their meanings through **Definition Retention**.
4. Apply the requested shared action's mutation boundary from [actions.md](actions.md), using **Managed Project Files** for project writes. Child configuration follows **Child Settings**; explicit review follows **Review Criteria and Reports** without an activation transition.
5. For ordinary substantive work, apply only effective, applicable guidance through [composition.md](composition.md), including the selected examples and judgment notes when needed. Explicit review uses its separately resolved invocation criteria.
6. Report actual scope and effects through **Memory Confirmation** when applicable; preserve agent identity, definitions, and explicit negative overrides across any supported handoff.

If the task does not map cleanly to these steps, use the native planning tool to preserve the caller's scope, validated selectors, and independent agent contexts without inventing persistence.

## State Sources

| Source | Meaning | Who changes it |
| --- | --- | --- |
| `.imsight-arts/mentality/<mentality>-principles.md` | Complete shared definitions and examples; no activation state. | Explicit `deploy`, or required deployment within an explicit project action. |
| `AGENTS.md` catalog discovery block | Location and purpose of available principles; no activation state. | Explicit `deploy`, or discovery reconciliation within an explicit project action. |
| `AGENTS.md` project-selection block | Canonical principles enabled project-wide and explicitly configured child settings. | Explicit project actions or a child's declared project configuration action. |
| Current agent's chat context | Explicit enabled and disabled rule overrides and child-setting overrides for this agent only. | Explicit memory actions or a child's declared memory configuration action. |

Resolve the project root from the user-provided directory, otherwise the current version-control root, otherwise the current working directory. These project-facing files intentionally live under that root; a generic report-output override does not relocate them.

Re-read project selection for recall and before applicable work. A catalog is evidence of a principle's definition, never evidence that any agent selected it. There is no mentality-wide enabled flag, automatic activation, or shared record of agents' effective selections. A named enable/disable without scope is a memory action; omitted memory selectors expand to all current canonical IDs once and never select future additions automatically.

An absent project-selection block means no project-enabled rules. A known fresh agent with no remembered instruction inherits project settings. After lost context, absence of a memory record does not prove that no override was previously given: label memory as unavailable and any project-only reconstruction as provisional. Recover an explicit handoff when available rather than guessing.

### Flavor-qualified bindings

A child may own flavor commands with separate rule and storage bindings. Human Speak declares these in [state.md](../subskills/human-speak/references/state.md#flavor-bindings). For management calls, require an explicitly named flavor before resolving `all`, deployment, recall, or either scope's mutations; otherwise show the child's chooser. Existing project or remembered selections do not fill an omitted flavor. Ordinary work may apply already selected flavor-qualified rules without reopening that chooser.

Use the selected target's state identity for memory and provenance, such as `human-speak/mark-life-style`, and its declared storage key for every generic `<mentality>` path or marker template in this skill, such as `human-speak-mark-life-style`. Ordinary mentalities use their registered name for both. Full rule identities such as `human-speak/mark-life-style:h1` disambiguate short IDs; each flavor has independent `P`, `M+`, and `M-` sets. The family has no aggregate rule set or default-flavor flag.

Resolve storage keys only through declared bindings. Flavor commands share their containing child's resources and do not introduce a nested skill. Their catalog and source-bundle publication contracts cover only the selected flavor. Unknown flavors or storage keys remain unresolved; do not derive a new binding or merge them into another target.

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

The most recent explicit memory instruction for a rule replaces its earlier memory override. A shared project rule action changes only `P`; declared child configuration may also change that child's project settings. Neither cancels an agent's existing overrides, even when requested later. No project-scoped disabled tombstones are needed: removing a project requirement still permits an explicit local enable.

An explicit memory disable must remain remembered even when the project currently leaves the rule disabled. Absence of an override means inheritance; clearing an override is conceptually distinct from disabling and is not an alias of any declared action.

### Agent Record

Retain canonical enabled and disabled IDs, explicit child-setting values, and the definition references or content specified below in the current agent's conversation context. No file or prescribed serialization schema is needed. Expand selector groups before retention. Qualify IDs by mentality when composing or reporting several children so one child's identifiers cannot mutate another's selection.

### Applicability and conflicts

Effective selection expresses configured intent. A selected principle is applied only when its documented applicability matches the current task. Recall distinguishes configured selection from current-task application.

Agent-memory guidance overrides conflicting project-scope mentality guidance, including conflicts between different principle IDs. Preserve both definitions and report the task-specific precedence decision; a conflict does not edit either scope. Same-scope conflicts follow explicit task requirements and documented judgment notes; if still material and unresolved, surface the choice instead of inventing rule priorities.

This override policy is part of the project mentality contract itself. It does not allow mentality rules to bypass unrelated repository instructions, system or developer instructions, explicit user requirements, or tool and permission constraints.

## Definition Retention

Use this contract for every mentality's rules, presets, switches, flags, and edit-scope settings. Keep each item's canonical identity, selected value (including disabled or false), and source scope independent of how its meaning is retained.

1. Check the project's deployed details for the specific item. A catalog's existence, a discovery entry, or a setting's selected value alone does not establish that its behavior is documented there.
2. When the definition is present and usable, read it and retain the project root, project-relative path, and canonical ID, name, flag, or section anchor that locates it. This is a `project-reference`; retain that locator without duplicating the full definition in memory. Reopen the referenced details when needed for application or recall.
3. Otherwise, read the child's maintained definition and retain its operative content in context. This is `inline-content`; keep what to do, applicability, important constraints, exceptions, and judgment notes needed for faithful application. A bare ID, slogan, or installed-skill path is insufficient. Reuse the retained content while it remains available.
4. Resolve each item separately. A partial deployment may provide rule references while a preset or edit boundary needs inline content. Definition storage does not enable rules, change values or precedence, or enlarge task authority.
5. If a remembered reference no longer resolves, recover the definition from available retained content or the maintained child resource and disclose the inline fallback. Unknown identities or unavailable meanings remain unresolved; do not guess, discard overrides, or deploy files to repair memory.

Prefer valid deployed definitions without requiring their files to match installed source hashes. If inspected deployed and maintained definitions disagree materially, report the discrepancy instead of silently combining meanings or changing policy. Content identities for historical offline source bundles serve archival publication, not a rule-application compatibility gate.

All retention happens in the current conversation or a host-supported context summary. Memory actions do not write catalogs, `AGENTS.md`, session files, or persistent-memory stores, and do not install hooks or skills. Unavailable project deployment is a normal inline-content case, not a prerequisite to activation.

### Memory Confirmation

After a memory action or memory configuration, state the mentality, canonical selections and explicit overrides, effective result, and scope `agent-memory`. Summarize each requested rule or setting's practical meaning in plain language so the user can verify understanding. Identify project-reference paths and IDs for deployed details, and mark meanings retained as inline-content; group items sharing a path. Confirm that no files were written and state any unresolved context limits without promising durable memory.

For recall, use the same definition summary for remembered and effective items, preserving their actual source scopes. Ordinary work need not repeat the full confirmation. A compact user-facing summary does not replace the operative inline content required in the agent's context or handoff.

## Child Settings

Children may declare additional settings without changing shared per-rule precedence. [Ponytail state](../subskills/ponytail/references/state.md) defines an intensity preset replacement operation and an independent `edit-scope` field. Intensity is stored as expanded canonical rule selections, not a competing mode flag; recall derives a preset label only when a selection exactly matches it. Individual rule actions keep their union/subtraction semantics and preserve child settings.

For Ponytail, an agent's explicit edit-scope override wins over the project's field; no setting means `new-code-only`. An explicit edit-scope setting enables no principles. Child project configuration uses the existing mentality project block and concurrent-write protocol; memory configuration stays in that agent's chat context. Recall and same-agent handoffs include setting provenance and unresolved context. A changed intensity never changes edit scope implicitly, and configuration never authorizes an unrelated task.

Use **Definition Retention** for these settings as well as rule IDs. Retaining a preset's meaning does not introduce a second authoritative intensity flag; its stored selection remains the expanded IDs. A catalog that defines principles but omits an edit-scope definition cannot serve as that setting's reference.

## Review Criteria and Reports

[Review contracts](review-common.md) default to effective selection. Explicit user selectors replace criteria only for that review, including a named principle ordinarily disabled in agent memory. This is an explicit task instruction, not another persistent scope or a memory enable. Later recall and ordinary work still use the unchanged project and memory selections. Ponytail resolves invocation-only intensity and edit-scope parameters through its own contract; destructive scope permits recommendations within the task boundary and never applies fixes during review.

Review returns findings in chat by default. An explicitly requested saved report may record the criteria assessed, findings, and evidence limits as a historical review snapshot. It must not serialize the agent's enabled/disabled memory record. Reports are never read as activation state, handoff memory, catalog discovery, or project selection. Save through the review contract's unique output directory without changing the managed project blocks.

## Managed Project Files

Catalog discovery and project selection use independent blocks. Write only the blocks owned by the requested action and its required deployment preparation; preserve unrelated contents and ordering. Explicit project enable/disable and child project configuration include **Project application preparation** before updating application or settings blocks.

### Catalog artifact

For each deployed mentality, use this path and exact marker pattern, replacing `<mentality>` with its registered name:

```text
.imsight-arts/mentality/<mentality>-principles.md
<!-- imsight-skill:imsight-mentality-mgr/<mentality>-principles:start -->
...complete principle reference...
<!-- imsight-skill:imsight-mentality-mgr/<mentality>-principles:end -->
```

The reference includes a title, entrance skill name, canonical rule index, and an explicit statement that publication does not enable rules. Copy the child's specified catalog sections and their full examples, judgment notes, applicability, and provenance. Preserve internal example indentation and fenced code; keep ordinary Markdown paragraphs on logical lines. Exclude skill-control workflows, session state, active-selection fields, and instructions to apply every listed rule. Resolve or rewrite relative links so the deployed document stands alone inside the target project; do not embed installed child paths that will be invalid on another machine.

A deployed catalog is a project-owned snapshot. Reuse complete usable deployment during project actions; publish missing or incomplete material through **Project application preparation**. Refresh an otherwise complete catalog only through an explicit deployment request. Memory actions, recall, and ordinary work do not regenerate it. The child remains authoritative for canonical selector identities; resolve each rule and setting through **Definition Retention**.

### Offline source bundles

Use the exact source directory declared by the selected child or flavor. Brooks and Ponytail declare `references/sources/`; Human Speak's Mark-Life Style declares `references/sources/mark-life-style/`. Copy the complete declared directory, including its index, source documents or identified excerpts, and licenses, into `.imsight-arts/mentality/sources/<mentality>/<bundle-id>/`, using the selected target's storage key. Other children need no source directory unless they declare one. Treat source documents as historical evidence, not active rules or runnable code. Origin URLs remain inside source records for attribution; application, recall, review, and deployment use bundled material without fetching them.

Use a deterministic content identity so different catalog snapshots and concurrent agents can retain their own source versions. Build a UTF-8 inventory with one `relative-path<TAB>file-sha256<LF>` record per file, sorted by relative path; `bundle-id` is the full SHA-256 of those inventory bytes. Preserve source bytes and relative filenames when copying. An existing identical bundle is a no-op; complete a partial bundle only when its present files match the expected paths and bytes. A content mismatch at that identity is a conflict, not permission to overwrite. Leave previous bundles in place rather than deleting sources still referenced by an older catalog.

Rewrite the catalog's declared source prefix, such as `sources/` or Human Speak's `sources/mark-life-style/`, to `sources/<mentality>/<bundle-id>/`, preserving filenames and fragments consistently. Links between copied source documents remain relative within that directory. Verify the local link closure before publication; no catalog or required source link may escape into the installed skill, `extern/`, or an absolute machine path. Source files and catalog examples must contain the needed explanation; optional origin links do not satisfy a missing local dependency.

Publish source files before the catalog and the catalog before its discovery block. Report partial effects if publication fails. Source bundles use content identity rather than catalog block markers and contain no project selection, agent memory, or session-state record.

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

Create or update this block only for an explicit project action, including a child's declared project configuration action. Preserve child-specific fields when changing only rule IDs:

```markdown
<!-- imsight-skill:imsight-mentality-mgr/brooks-project:start -->
## Project Mentality Rules: Brooks

- Project-enabled principles: `r1` (`comprehension`), `r5` (`dependency-direction`).
- Definitions and examples: [Brooks principles](.imsight-arts/mentality/brooks-principles.md).
- Application: these principles apply project-wide when relevant to the task, except where this agent has an explicit in-memory enabled or disabled override. Agent scope wins in conflicts with project-scope mentality guidance.
- Independence: each agent retains its own overrides; do not write an agent's remembered selection or effective result into this block.
<!-- imsight-skill:imsight-mentality-mgr/brooks-project:end -->
```

Use canonical IDs beside their names for enabled rules; handle empty selections below. Do not copy examples or complete rule text into `AGENTS.md`; its project index references the complete catalog. Keep source markers exact and on their own lines outside code fences; adapt visible headings to the surrounding document.

### Empty project selection

After an explicit project disable, remove the affected project-selection block when no enabled rules or independently configured child settings remain. Delete both markers and everything between them, including the heading, catalog link, application or required-use instructions, and independence reminders. An absent block already means no project-enabled rules; retaining `none`, disabled-status prose, or memory-only loading instructions wastes context. Also remove a pre-existing empty block when the requested disable changes no IDs.

If explicit child settings remain, preserve their values in the same marked block with only a heading, `Project-enabled principles: none.`, and the setting fields. Do not retain rule-application instructions or discard explicit settings merely because they equal a default. Unresolved IDs or state are not an empty selection.

For example, after required deployment and discovery preparation, disabling all Brooks project rules removes only the `brooks-project` block. Keep the `brooks-catalog` discovery block, deployed catalog and sources, other mentalities, and every agent's memory overrides. Disabling only `r1` while `r5` remains keeps the application block for `r5`. A memory-only disable never edits either block.

### Project application preparation

Explicit project enable, project disable, and child project configuration authorize the required deployment and `AGENTS.md` updates as one operation. Do not ask for a separate deployment request or confirmation solely because the catalog is missing. This preparation also applies to project disable with an empty or absent application block; discovery may still need to be created.

1. Validate the complete requested mentality selections, required flavors, scope, and settings before any writes. Inspect the selected target's existing catalog, declared source dependencies, discovery, and project state using the marker ownership and concurrency rules in **Write protocol**. A missing Human Speak flavor returns its chooser and leaves preparation unstarted.
2. Reuse a complete, usable deployed catalog and its required local sources. Do not require source-hash equality with the installed skill or refresh complete material just because installed wording differs. Handle material definition disagreements through **Definition Retention**.
3. If the catalog or required sources are missing or incomplete, perform [Deploy](actions.md#deploy) for the complete selected catalog, including its examples, judgment notes, and declared source bundle. A selector subset still requires complete catalog publication. For Human Speak, this is the named flavor's catalog only. Preserve owned-content boundaries; malformed markers, unowned content, and conflicting source bytes remain conflicts, not permission to overwrite.
4. Ensure the catalog discovery block in `AGENTS.md` points to the available project-local definitions. If only discovery is missing or incomplete, reconcile that block without republishing the complete catalog. Publish sources before the catalog and its discovery reference.
5. Once preparation succeeds, return to the requested action to re-read project state and update selection or configuration. Verify that `AGENTS.md` reflects the request, including block removal when appropriate; identical content is a no-op. Preserve unrelated guidance, other mentalities, independent settings outside the request, and every agent's memory overrides. Report deployment, instruction-file changes, and any partial effects if an operation fails.

### Write protocol

1. Read the latest target contents and validate the complete requested outputs before writing.
2. Locate the exact start/end markers for the action's block. Replace one well-formed matching block in place, or remove it when **Empty project selection** requires deletion. When neither marker exists, insert a block or create the required file only if the requested action needs stored content; an already absent block targeted for removal is a no-op.
3. Reject partial, reversed, nested, or duplicate matching markers. An existing catalog artifact without its matching markers is not owned output and must not be overwritten. If existing mentality directives use an incompatible scope or representation, report the conflict for explicit reconciliation instead of guessing which rules are project-wide.
4. Preserve other mentalities' blocks, unrelated guidance, and unrelated artifact content. Immediately before writing shared `AGENTS.md`, check for intervening changes; if it changed, re-read and recompute the targeted edit rather than writing a stale whole-file snapshot. Use a lock or conditional write when the host supports one; otherwise report any detected concurrent conflict instead of claiming atomic multi-agent writes.
5. For deployment, publish any offline source bundle, then the validated catalog, then its discovery reference so new references never point to unwritten files. If a write fails, report actual partial effects and complete or safely recover only the action's owned changes.
6. Verify exactly one matching block for each retained or published artifact, and no matching markers or residual application text for each removed block. Check source-bundle identity and local links when applicable, correct canonical IDs and retained settings, preserved out-of-scope state, and a no-op result when applying the same action again to unchanged inputs.

### Missing and inconsistent material

Project actions resolve absent or incomplete deployment through **Project application preparation** before changing selection or settings. If preparation cannot complete, report the blocking material and any partial publication; do not claim the project action succeeded or silently convert it to memory scope.

Memory actions and recall use maintained child definitions for undeployed items without writing files. Unknown project or remembered IDs remain visible as unresolved state; never silently discard them or substitute a different principle.

## Agent Identity and Handoffs

Shared files never carry an agent-specific active selection. Two agents reading the same project instructions independently merge them with their own overrides.

When delegating work, state the intended principle overrides in the subagent's task message if they should transfer. Sharing a repository or spawning a subagent alone does not authorize copying the parent's personal selection. If a harness inherits conversation history, distinguish the delegated agent's explicit assignment from records belonging to the parent; ambiguous ownership must not silently become child overrides. A subagent's memory actions do not update its parent or siblings.

For a same-agent compaction or handoff, retain enabled and disabled override sets, child-setting values and source scopes, and any required task boundary in the host-supported context summary. Preserve project-bound paths plus identifiers for project-reference items, and operative content for inline-content items. Keep explicit false values and negative overrides; never reduce inline definitions to IDs or skill paths. Do not write a session-state file to simulate memory. A skill invocation alone installs no lifecycle hooks and guarantees neither cross-turn reinjection nor recovery after context loss.

## Guardrails

- DO NOT infer activation from catalogs, discovery references, or a deployed rule count.
- DO NOT store agent-memory records or reusable effective-selection state in project files; an explicitly requested review report may record its assessed criteria solely as historical evidence.
- DO NOT refresh complete deployed catalogs or alter agent memory as a side effect of project enable/disable; required deployment follows **Project application preparation**.
- DO NOT discard negative memory overrides during recall, compaction, or delegation.
- DO NOT override an agent's memory just because a later action changed project scope.
- DO NOT overwrite malformed, ambiguous, or unowned managed content.
- DO NOT treat another agent's record as the current agent's remembered state.
- DO NOT reconstruct missing memory from guesses or claim persistence without actual host support.
