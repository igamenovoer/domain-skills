# Mentality Scope and Runtime Application

## Workflow

1. Resolve the target project and action through the [enable/disable decision tree](actions.md#enabledisable-decision-tree) when applicable. Inspect project deployment and instruction files through **Instruction File Selection**; omitted enable/disable scope means agent memory, while project scope must be explicit.
2. Obtain canonical selectors and applicability from the named child, then validate the complete request.
3. Resolve activation, family priorities, and configured values only from **State Sources** and derive the result using **Effective Selection** and [priorities.md](priorities.md). Read and retain their meanings through **Definition Retention**.
4. Apply the requested shared action's mutation boundary from [actions.md](actions.md), using **Managed Project Files** for project writes. Child configuration follows **Child Settings**; explicit review follows **Review Criteria and Reports** without an activation transition.
5. For ordinary substantive work, apply only effective, applicable guidance through [composition.md](composition.md), including the selected examples and judgment notes when needed. Explicit review uses its separately resolved invocation criteria.
6. Report actual scope and effects through **Memory Confirmation** when applicable; preserve agent identity, definitions, and explicit negative overrides across any supported handoff.

If the task does not map cleanly to these steps, use the native planning tool to preserve the caller's scope, validated selectors, and independent agent contexts without inventing persistence.

## State Sources

Project state lives in coding-agent instruction files such as `AGENTS.md` and `CLAUDE.md`. Resolve the applicable read set and requested write targets through **Instruction File Selection**; equivalent blocks in multiple files represent one logical selection.

| Source | Meaning | Who changes it |
| --- | --- | --- |
| `.imsight-arts/mentality/<mentality>-principles.md` | Complete shared definitions and examples; no activation state. | Explicit `deploy`, or required deployment within an explicit project action. |
| Instruction-file catalog discovery block | Location and purpose of available principles; no activation state. | Explicit `deploy`, or discovery reconciliation within an explicit project action. |
| Instruction-file project-selection block | Canonical principles enabled project-wide, their family priority, and explicitly configured child settings. | Explicit project actions or a child's declared project configuration action. |
| Instruction-file project-priority sequence block | Next project priority; retains allocation history after families are removed and enables no rules. | Explicit enabling actions advance it; project actions may mirror known sequence state. |
| Current agent's chat context | Explicit enabled and disabled rule overrides, family priorities, next memory priority, and child-setting overrides for this agent only. | Explicit memory actions or a child's declared memory configuration action. |

Resolve the project root from the user-provided directory, otherwise the current version-control root, otherwise the current working directory. Catalogs live under that root; instruction files use their established project locations. A generic report-output override does not relocate them.

Re-read project selection for recall and before applicable work. A catalog is evidence of a principle's definition, never evidence that any agent selected it. There is no mentality-wide enabled flag, automatic activation, or shared record of agents' effective selections. A named enable/disable without scope is a memory action; omitted memory selectors expand to all current canonical IDs once and never select future additions automatically.

An absent project-selection block contributes no project-enabled rules; it does not disable a selection found in another applicable instruction file. A known fresh agent with no remembered instruction inherits project settings. After lost context, absence of a memory record does not prove that no override was previously given: label memory as unavailable and any project-only reconstruction as provisional. Recover an explicit handoff when available rather than guessing.

### Instruction File Selection

This contract applies to deployment, project enable/disable, and every child's project configuration. Selecting files changes the write destination, not the action's rule-selector requirements or agent-memory scope.

1. **Discover existing project instructions.** Inspect the project root for known coding-agent files, including `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md`, and inspect established tool-specific locations such as `.claude/CLAUDE.md` or `.github/copilot-instructions.md`. Include other files identified by project layout, configuration, or repository instructions as project-wide coding-agent guidance. Recognize existing case variants such as `agents.md` and `claude.md`; preserve their actual paths and spelling.
2. **Honor explicit targets.** If the user selects one or more instruction files, update only those files; create a named file if the requested action needs it. Otherwise, update all discovered project-wide instruction files. If none exist, create root `AGENTS.md`. Do not create additional conventional files when an existing target is available. Choosing a file never removes the catalog deployment required by the action.
3. **Respect file scope and format.** Discovery is not a recursive rewrite of every matching filename. Exclude vendored copies, examples, archived files, user-global settings, and unrelated nested instructions. A file applying only to a subtree is a target only when that subtree is explicitly requested; preserve its scope rather than declaring its rules project-wide. Keep frontmatter, native applicability metadata, and unrelated instructions intact. Deduplicate symlinks or other aliases to the same underlying file; an explicit alias selection still names that shared content.
4. **Resolve the current state.** For project mutations, read the selected targets and deduplicate matching family blocks. For ordinary work, memory actions, recall, and review, use the instruction files applicable to this agent and task under the host's loading and scope rules; discovering a file alone does not make it active. Record file provenance. Different families combine; conflicting records for the same family or setting are unresolved unless established instruction precedence or the user's request determines the result. Do not invent filename precedence or merge contradictory selections. Missing copies are not conflicts: mirror the resolved affected family into the selected targets when the project action requires it.
5. **Write and verify every target.** Apply one resolved result for each requested family across the selected files, with priority allocation through [Storage](priorities.md#storage). Use the same markers in each file and resolve catalog links relative to that file's directory. Validate all targets before writing, preserve unselected files, and report the paths actually changed or any partial completion. Memory actions, recall, and review do not create or reconcile instruction files.

An explicit filename in “enable Brooks r1 in `CLAUDE.md`” selects project scope and only that file. “Enable Brooks r1 in project scope” selects every discovered project-wide instruction file without a file-choice question. This default also covers “deploy these principles” and project configuration requests.

### Flavor-qualified bindings

A child may own flavor commands with separate rule and storage bindings. Human Speak declares these in [state.md](../subskills/human-speak/references/state.md#flavor-bindings). For management calls, require an explicitly named flavor before resolving `all`, deployment, recall, or either scope's mutations; otherwise show the child's chooser. Existing project or remembered selections do not fill an omitted flavor. Ordinary work may apply already selected flavor-qualified rules without reopening that chooser.

Use the selected target's state identity for memory and provenance, such as `human-speak/mark-life-style`, and its declared storage key for every generic `<mentality>` path or marker template in this skill, such as `human-speak-mark-life-style`. Ordinary mentalities use their registered name for both. Full rule identities such as `human-speak/mark-life-style:h1` disambiguate short IDs; each flavor has independent `P`, `M+`, and `M-` sets. The family has no aggregate rule set or default-flavor flag.

Resolve storage keys only through declared bindings. Flavor commands share their containing child's resources and do not introduce a nested skill. Their catalog publication contracts cover only the selected flavor. Unknown flavors or storage keys remain unresolved; do not derive a new binding or merge them into another target.

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

Memory actions remove the opposite override before adding the requested one, so an ID never belongs to both `M+` and `M-`. Repeated set operations preserve the same IDs, but a fresh explicit enable also raises the family's priority through [Priority Assignment](priorities.md#priority-assignment). If restored state contains both and no explicit instruction order resolves them, report inconsistent memory rather than guessing or persisting a repair.

The most recent explicit memory instruction for a rule replaces its earlier memory override. A shared project rule action changes `P` and its associated project priority state; declared child configuration may also change that child's project settings. Neither cancels an agent's existing overrides or changes its memory priorities, even when requested later. No project-scoped disabled tombstones are needed: removing a project requirement still permits an explicit local enable.

An explicit memory disable must remain remembered even when the project currently leaves the rule disabled. Absence of an override means inheritance; clearing an override is conceptually distinct from disabling and is not an alias of any declared action.

### Agent Record

Retain canonical enabled and disabled IDs, each nonempty memory family's priority, the next memory priority bound to the project root, explicit child-setting values, and the definition references or content specified below in the current agent's conversation context. No file or prescribed serialization schema is needed. Expand selector groups before retention. Qualify IDs by mentality or flavor when composing or reporting several children so one family's identifiers cannot mutate another's selection. Preserve the counter after disabling every memory rule; see [Storage](priorities.md#storage).

### Applicability and conflicts

Effective selection expresses configured intent. A selected principle is applied only when its documented applicability matches the current task. Recall distinguishes configured selection from current-task application.

Agent-memory guidance overrides conflicting project-scope mentality guidance, including conflicts between different principle IDs, regardless of numeric priority. Within the same scope, higher family priority wins under [Conflict Resolution](priorities.md#conflict-resolution). Preserve both definitions and report the task-specific precedence decision; a conflict does not edit either scope. Internal family tensions follow documented applicability and judgment notes. Surface material unresolved conflicts or unavailable priority evidence rather than fabricating an order.

This override policy is part of the project mentality contract itself. It does not allow mentality rules to bypass unrelated repository instructions, system or developer instructions, explicit user requirements, or tool and permission constraints.

## Definition Retention

Use this contract for every mentality's rules, presets, switches, flags, and edit-scope settings. Keep each item's canonical identity, selected value (including disabled or false), and source scope independent of how its meaning is retained.

1. Check the project's deployed details for the specific item. A catalog's existence, a discovery entry, or a setting's selected value alone does not establish that its behavior is documented there.
2. When the definition is present and usable, read it and retain the project root, project-relative path, and canonical ID, name, flag, or section anchor that locates it. This is a `project-reference`; retain that locator without duplicating the full definition in memory. Reopen the referenced details when needed for application or recall.
3. Otherwise, read the child's maintained definition and retain its operative content in context. This is `inline-content`; keep what to do, applicability, important constraints, exceptions, and judgment notes needed for faithful application. A bare ID, slogan, or installed-skill path is insufficient. Reuse the retained content while it remains available.
4. Resolve each item separately. A partial deployment may provide rule references while a preset or edit boundary needs inline content. Definition storage does not enable rules, change values or precedence, or enlarge task authority.
5. If a remembered reference no longer resolves, recover the definition from available retained content or the maintained child resource and disclose the inline fallback. Unknown identities or unavailable meanings remain unresolved; do not guess, discard overrides, or deploy files to repair memory.

Prefer valid deployed definitions without requiring their files to match installed source hashes. If inspected deployed and maintained definitions disagree materially, report the discrepancy instead of silently combining meanings or changing policy.

All retention happens in the current conversation or a host-supported context summary. Memory actions do not write catalogs, coding-agent instruction files (`AGENTS.md`, `CLAUDE.md`, etc.), session files, or persistent-memory stores, and do not install hooks or skills. Unavailable project deployment is a normal inline-content case, not a prerequisite to activation.

### Memory Confirmation

After a memory action or memory configuration, state the mentality or flavor, canonical selections and explicit overrides, effective result, scope `agent-memory`, and the family's memory priority or `none` when its memory-enabled set is empty. Report a fresh enable's priority change even when no IDs changed. Summarize each requested rule or setting's practical meaning in plain language so the user can verify understanding. Identify project-reference paths and IDs for deployed details, and mark meanings retained as inline-content; group items sharing a path. Confirm that no files were written and state any unresolved context limits without promising durable memory.

For recall, use the same definition summary for remembered and effective items, preserving their actual source scopes. Ordinary work need not repeat the full confirmation. A compact user-facing summary does not replace the operative inline content required in the agent's context or handoff.

## Child Settings

Children may declare additional settings without changing shared per-rule precedence. [Ponytail state](../subskills/ponytail/references/state.md) defines an intensity preset replacement operation and an independent `edit-scope` field. Intensity is stored as expanded canonical rule selections, not a competing mode flag; recall derives a preset label only when a selection exactly matches it. Explicit intensity configuration allocates a fresh family priority in the selected scope; edit-scope-only configuration preserves priorities. Individual rule actions keep their union/subtraction semantics and preserve child settings.

For Ponytail, an agent's explicit edit-scope override wins over the project's field; no setting means `new-code-only`. An explicit edit-scope setting enables no principles. Child project configuration uses the existing mentality project block and concurrent-write protocol; memory configuration stays in that agent's chat context. Recall and same-agent handoffs include setting provenance and unresolved context. A changed intensity never changes edit scope implicitly, and configuration never authorizes an unrelated task.

Use **Definition Retention** for these settings as well as rule IDs. Retaining a preset's meaning does not introduce a second authoritative intensity flag; its stored selection remains the expanded IDs. A catalog that defines principles but omits an edit-scope definition cannot serve as that setting's reference.

## Review Criteria and Reports

[Review contracts](review-common.md) default to effective selection. Explicit user selectors replace criteria only for that review, including a named principle ordinarily disabled in agent memory. This is an explicit task instruction, not another persistent scope or a memory enable. Later recall and ordinary work still use the unchanged project and memory selections. Ponytail resolves invocation-only intensity and edit-scope parameters through its own contract; destructive scope permits recommendations within the task boundary and never applies fixes during review.

Review returns findings in chat by default. An explicitly requested saved report may record the criteria assessed, findings, and evidence limits as a historical review snapshot. It must not serialize the agent's enabled/disabled memory record. Reports are never read as activation state, handoff memory, catalog discovery, or project selection. Save through the review contract's unique output directory without changing the managed project blocks.

## Managed Project Files

Catalog discovery and project selection use independent blocks. Resolve every target through **Instruction File Selection**. Write only the blocks owned by the requested action and its required deployment preparation; preserve unrelated contents and ordering. Explicit project enable/disable and child project configuration include **Project application preparation** before updating application or settings blocks. Enabling actions also update the shared [project-priority sequence](priorities.md#storage) alongside their family blocks in every target instruction file.

### Catalog artifact

For each deployed mentality, use this path and exact marker pattern, replacing `<mentality>` with its registered name:

```text
.imsight-arts/mentality/<mentality>-principles.md
<!-- imsight-skill:imsight-mentality-mgr/<mentality>-principles:start -->
...complete principle reference...
<!-- imsight-skill:imsight-mentality-mgr/<mentality>-principles:end -->
```

The reference includes a title, entrance skill name, canonical rule index, and an explicit statement that publication does not enable rules. Copy the child's specified catalog sections and their original examples, judgment notes, and applicability. Preserve internal example indentation and fenced code; keep ordinary Markdown paragraphs on logical lines. Exclude skill-control workflows, session state, active-selection fields, external reference sections, and instructions to apply every listed rule. Resolve or rewrite relative links so the deployed document stands alone inside the target project; do not embed installed child paths that will be invalid on another machine.

A deployed catalog is a project-owned snapshot. Reuse complete usable deployment during project actions; publish missing or incomplete material through **Project application preparation**. Refresh an otherwise complete catalog only through an explicit deployment request. Memory actions, recall, and ordinary work do not regenerate it. The child remains authoritative for canonical selector identities; resolve each rule and setting through **Definition Retention**.

### External references

Optional upstream links belong in a separate `References` section of the owning child entrypoint or flavor command page, with the canonical rules each link concerns. They provide attribution and background, not runtime dependencies or additional rules. Open them only for an explicit source or attribution investigation; applying, enabling, recalling, reviewing, and deploying principles use the maintained definitions alone.

Keep citations, source filenames, source-origin commentary, and pointers to further reading out of rule descriptions and examples. Publish only the child-declared rule sections and original examples. Exclude reference tables, third-party files, archived snapshots, copied excerpts, and full upstream documents from project catalogs. No source directory, content hash, or source download is a deployment prerequisite.

Existing project copies are not managed runtime inputs. A deployment may refresh its owned catalog to the current self-contained form, but deleting previously copied files elsewhere requires an explicitly targeted cleanup. Do not follow stale source links as part of definition retention; obtain the operative definition from the maintained catalog when the deployed text is incomplete.

### Catalog discovery in instruction files

Use this separate discovery block in every target instruction file (`AGENTS.md`, `CLAUDE.md`, etc.), substituting the actual mentality, title, and path. The example assumes a root-level instruction file; adjust relative links for other directories:

```markdown
<!-- imsight-skill:imsight-mentality-mgr/brooks-catalog:start -->
## Available Mentality: Brooks

- Entrance skill: `imsight-mentality-mgr`.
- Principle catalog: [Brooks principles](.imsight-arts/mentality/brooks-principles.md), including definitions, examples, and judgment notes.
- Availability only: this listing enables no principles. Apply rules only when selected in the project block or this agent's chat memory.
- Scope resolution: agent-memory enabled or disabled overrides take precedence over project selection; absent memory overrides inherit project settings. Apply only task-relevant rules.
- Conflict resolution: within one scope, the family with the higher priority overrides conflicting guidance; agent scope takes precedence regardless of priority. Deployment assigns no priority.
<!-- imsight-skill:imsight-mentality-mgr/brooks-catalog:end -->
```

This block lists reference material. It must not list an agent's selection or tell every reader to apply the whole catalog.

### Project selection in instruction files

Create or update this block in every target instruction file only for an explicit project action, including a child's declared project configuration action. Preserve child-specific fields when changing only rule IDs:

```markdown
<!-- imsight-skill:imsight-mentality-mgr/brooks-project:start -->
## Project Mentality Rules: Brooks

- Project-enabled principles: `r1` (`comprehension`), `r5` (`dependency-direction`).
- Family priority: 0.
- Definitions and examples: [Brooks principles](.imsight-arts/mentality/brooks-principles.md).
- Application: these principles apply project-wide when relevant to the task, except where this agent has an explicit in-memory enabled or disabled override. Agent scope wins over project scope; within one scope, the family with the higher priority overrides conflicting guidance.
- Independence: each agent retains its own overrides; do not write an agent's remembered selection or effective result into this block.
<!-- imsight-skill:imsight-mentality-mgr/brooks-project:end -->
```

Use canonical IDs beside their names for enabled rules and the actual allocated family priority; `0` above is illustrative. Handle empty selections below. Include the shared counter through [Priority Storage](priorities.md#storage), without copying it into every family block. Do not copy examples or complete rule text into instruction files; their project indexes reference the complete catalog. Keep source markers exact and on their own lines outside code fences; adapt visible headings to the surrounding document.

### Empty project selection

After an explicit project disable, remove the affected project-selection block from every selected instruction file when no enabled rules or independently configured child settings remain. Delete both markers and everything between them, including the heading, catalog link, application or required-use instructions, and independence reminders. An absent block contributes no project-enabled rules; retaining `none`, disabled-status prose, or memory-only loading instructions wastes context. Also remove a pre-existing empty block when the requested disable changes no IDs.

If explicit child settings remain, preserve their values in the same marked block with only a heading, `Project-enabled principles: none.`, and the setting fields. Remove the family's priority when no project rules remain, but preserve the shared next-priority counter; it never keeps an empty family block alive. Do not retain rule-application instructions or discard explicit settings merely because they equal a default. Unresolved IDs or state are not an empty selection.

For example, after required deployment and discovery preparation, disabling all Brooks project rules removes only the `brooks-project` block. Keep the `brooks-catalog` discovery block, deployed catalog, other mentalities, and every agent's memory overrides. Disabling only `r1` while `r5` remains keeps the application block for `r5`. A memory-only disable never edits either block.

### Project application preparation

Explicit project enable, project disable, and child project configuration authorize the required deployment and updates to all target instruction files as one operation. Do not ask for a separate deployment request or confirmation solely because the catalog is missing. This preparation also applies to project disable with an empty or absent application block; discovery may still need to be created.

1. Validate the complete requested mentality selections, required flavors, scope, and settings before any writes. Resolve instruction-file targets through **Instruction File Selection** and inspect every target's discovery and project state plus the shared catalog using **Write protocol**. Resolve any material state differences before publishing. A missing Human Speak flavor returns its chooser and leaves preparation unstarted.
2. Reuse a complete, usable, self-contained deployed catalog. Do not require source-hash equality with the installed skill or refresh complete material just because installed wording differs. Handle material definition disagreements through **Definition Retention**.
3. If the catalog is missing, incomplete, or requires third-party material to explain its rules, perform [Deploy](actions.md#deploy) for the complete selected catalog, including its original examples and judgment notes. A selector subset still requires complete catalog publication. For Human Speak, this is the named flavor's catalog only. Preserve owned-content boundaries; malformed markers and unowned content remain conflicts, not permission to overwrite.
4. Ensure the catalog discovery block in every target instruction file points to the available project-local definitions, with a link relative to that file. If only discovery is missing or incomplete, reconcile that block without republishing the complete catalog. Publish the catalog once before its discovery references.
5. Once preparation succeeds, return to the requested action to re-read project state and update selection or configuration. Verify that every target instruction file reflects the request, including block removal when appropriate; identical content is a no-op. Preserve unrelated guidance, other mentalities, independent settings outside the request, and every agent's memory overrides. Report deployment, instruction-file changes, and any partial effects if an operation fails.

### Write protocol

1. Read the latest contents of all selected targets and validate the complete requested outputs before writing any of them. Resolve paths, aliases, scope, and state differences through **Instruction File Selection**.
2. Locate the exact start/end markers for the action's block. Replace one well-formed matching block in place, or remove it when **Empty project selection** requires deletion. When neither marker exists, insert a block or create the required file only if the requested action needs stored content; an already absent block targeted for removal is a no-op.
3. Reject partial, reversed, nested, or duplicate matching markers. An existing catalog artifact without its matching markers is not owned output and must not be overwritten. If existing mentality directives use an incompatible scope or representation, report the conflict for explicit reconciliation instead of guessing which rules are project-wide.
4. Preserve other mentalities' blocks, unrelated guidance, and unrelated artifact content. For an enable or preset configuration, allocate once per family for the whole request and update its family blocks and the shared next-priority counter together in each target file. Immediately before writing, check the inspected files for intervening changes; if any changed, re-read project state and recompute the targeted edits and allocation rather than writing stale snapshots. Use a lock or conditional write when the host supports one; do not claim atomic multi-file writes without such support.
5. For deployment, publish the validated catalog once, then its discovery references so new references never point to unwritten files. If a write fails after some targets succeed, report completed and pending paths. Complete or safely recover only the action's owned changes, reusing any priority already committed by this request; never allocate again merely to finish the remaining files.
6. Verify exactly one matching block per target file for each retained or published artifact, and no matching markers or residual application text for each removed block. For project actions, compare the affected selection, priority, and known counter across all targets, allowing relative-link differences; deployment-only actions verify discovery without reconciling activation or counters. Check catalog self-containment, local links, retained settings, and preserved out-of-scope state. Retrying the same completed write must not allocate again; a fresh user enable intentionally receives a new priority even if its IDs are unchanged.

### Missing and inconsistent material

Project actions resolve absent or incomplete deployment through **Project application preparation** before changing selection or settings. If preparation cannot complete, report the blocking material and any partial publication; do not claim the project action succeeded or silently convert it to memory scope.

Memory actions and recall use maintained child definitions for undeployed items without writing files. Unknown project or remembered IDs remain visible as unresolved state; never silently discard them or substitute a different principle.

## Agent Identity and Handoffs

Shared files never carry an agent-specific active selection. Two agents reading the same project instructions independently merge them with their own overrides.

When delegating work, state the intended principle overrides in the subagent's task message if they should transfer. Sharing a repository or spawning a subagent alone does not authorize copying the parent's personal selection. If a harness inherits conversation history, distinguish the delegated agent's explicit assignment from records belonging to the parent; ambiguous ownership must not silently become child overrides. A subagent's memory actions do not update its parent or siblings.

For a same-agent compaction or handoff, retain enabled and disabled override sets, per-family memory priorities and the project-bound next-memory-priority counter, child-setting values and source scopes, and any required task boundary in the host-supported context summary. Re-read project priorities from project files instead of copying them into memory priority state. Preserve project-bound paths plus identifiers for project-reference items, and operative content for inline-content items. Keep explicit false values and negative overrides; never reduce inline definitions to IDs or skill paths. Do not write a session-state file to simulate memory. A skill invocation alone installs no lifecycle hooks and guarantees neither cross-turn reinjection nor recovery after context loss.

## Guardrails

- DO NOT infer activation from catalogs, discovery references, or a deployed rule count.
- DO NOT store agent-memory records or reusable effective-selection state in project files; an explicitly requested review report may record its assessed criteria solely as historical evidence.
- DO NOT refresh complete deployed catalogs or alter agent memory as a side effect of project enable/disable; required deployment follows **Project application preparation**.
- DO NOT discard negative memory overrides during recall, compaction, or delegation.
- DO NOT override an agent's memory just because a later action changed project scope.
- DO NOT overwrite malformed, ambiguous, or unowned managed content.
- DO NOT treat another agent's record as the current agent's remembered state.
- DO NOT reconstruct missing memory from guesses or claim persistence without actual host support.
