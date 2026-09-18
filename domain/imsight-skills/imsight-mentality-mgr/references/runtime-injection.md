# Mentality Scope and Runtime Application

## Workflow

1. Resolve project, action, and selectors through [actions](actions.md). Inspect existing state; unqualified enable/disable means agent memory.
2. Resolve **State Sources**, **Effective Selection**, and needed **Definition Retention**. Use [priorities](priorities.md) for allocation and conflicts.
3. Execute only the action's effects. Project writes use **Managed Project Files**; settings and review follow their sections below.
4. Apply selected, relevant guidance through [composition](composition.md). Report actual effects and preserve agent identity across handoffs.

For other requests, use the native planning tool while preserving scope and validated state. Read only the sections needed for the action.

## State Sources

| Source | Contents | Mutation |
| --- | --- | --- |
| `.imsight-arts/mentality/<mentality>-principles.md` | Definitions and examples, never activation. | Deploy or required project-action publication. |
| Unified section in coding-agent instruction files | Catalog references, selected IDs, family priorities, explicit child settings. | Deploy changes availability only; project actions change requested state. |
| Counter inside that section | Next project priority, including allocation history after removals. | Enables advance it; project actions may mirror known state. |
| Current agent's context | Explicit enabled/disabled overrides, memory priorities/counter, settings, retained meanings. | Explicit memory actions only. |

Project root: user-selected directory, otherwise version-control root, otherwise working directory. Catalogs live there; instruction files keep established locations. Report-output overrides do not relocate them.

Re-read applicable project state for recall and before substantive work. Missing or reference-only entries contribute no enabled rules and do not disable another applicable entry. There is no family-wide activation flag. A known fresh agent inherits project settings; lost memory is unavailable, not empty. Recover an explicit handoff or label project-only reconstruction provisional.

### Instruction File Selection

Use this contract for deployment and all project selection/configuration actions:

1. Find project-wide coding-agent guidance: root `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, established tool locations such as `.claude/CLAUDE.md` and `.github/copilot-instructions.md`, and other files identified by project configuration. Recognize case variants and preserve actual paths.
2. Write only explicitly selected files when supplied; otherwise write all discovered project-wide files. Create a named file when needed. If none exist, create root `AGENTS.md`; do not create extra conventional files beside existing targets. File targeting does not remove required catalog publication.
3. Respect scope and format. Exclude vendored, archived, example, user-global, and unrelated nested files. Subtree-only instructions are targets only for that explicitly requested subtree; preserve their scope. Keep native metadata and unrelated content. Deduplicate aliases to the same underlying file; an alias still names shared content.
4. For mutations, resolve state across selected targets. For ordinary work, memory, recall, and review, read only files applicable under the host's loading/scope rules; discovery alone does not activate a file. Record provenance and deduplicate matching entries. Different families combine. Conflicting records need established precedence or an explicit resolution; do not invent filename precedence or merge contradictory selections. Missing mirrors are not conflicts.
5. Mirror the requested result to every selected target, allocating priority once per family. Adjust links relative to each file. Validate all targets first, preserve unselected files, and report actual or partial effects. Read-only and memory actions never reconcile files.

“Enable Brooks r1 in CLAUDE.md” selects project scope and only that file. “Enable Brooks r1 in project scope” selects all discovered targets without a file-choice question.

### Flavor-qualified bindings

Human Speak requires an explicit flavor for every management invocation, including recall. Missing choices return its chooser before mutation; existing state never supplies a default. Ordinary work may apply already selected flavors.

Use the child's declared [bindings](../subskills/human-speak/references/state.md#flavor-bindings): state identity, such as `human-speak/han-style`, qualifies rules and memory; storage key, such as `human-speak-han-style`, supplies catalog paths and markers. Each flavor has independent `P`, `M+`, and `M-`. Ordinary children use their registered name for both identities. Unknown bindings remain unresolved; do not derive arbitrary paths or a combined Human Speak catalog.

## Effective Selection

```text
P  = project-enabled IDs
M+ = this agent's explicitly enabled IDs
M- = this agent's explicitly disabled IDs
E  = (P union M+) minus M-
```

Explicit memory enables/disables win per rule; absence means inherit, then disabled by default. Memory actions remove the opposite override, keeping `M+` and `M-` disjoint. The latest explicit memory instruction wins; inconsistent restored sets without a known order remain unresolved.

Keep explicit overrides even when project state already matches. A memory disable must mask later project enables. Project actions never erase memory overrides or priorities. Removing a project rule creates no disabled tombstone and still permits memory activation. Clearing an override is not the same as disabling it.

### Agent Record

Keep family-qualified IDs, each nonempty memory family's priority, the project-bound next-memory-priority counter, explicit settings, and retained meanings in this agent's context. Expand groups to current IDs; future catalog additions remain unselected. No file or serialization schema is required.

### Applicability and conflicts

Selection is not applicability: apply only rules relevant to the task. Memory-scope guidance outranks project guidance, then higher family priority wins within one scope; use [Conflict Resolution](priorities.md#conflict-resolution). Internal tensions use rule judgment notes. Report material unresolved conflicts without changing stored selections. Mentality precedence never overrides task authority, unrelated repository instructions, or higher-priority requirements.

## Definition Retention

For every rule and setting, retain identity, selected value, and scope separately from its definition:

1. If its meaning is deployed and usable, read it and retain the project root, relative path, and ID/name/anchor (`project-reference`). Reopen only when needed.
2. Otherwise retain operative content, including constraints, exceptions, and judgment (`inline-content`). A bare ID, slogan, or installed path is insufficient. Resolve each item independently; a rule catalog may omit a setting's definition.
3. If a reference stops resolving, recover retained content or the maintained child definition and disclose the fallback. Unknown meanings remain unresolved; do not repair memory through file writes.

Prefer usable deployed definitions without a hash-equality gate. Report material disagreements with maintained definitions rather than silently combining them. Retaining meaning neither enables rules nor widens authority. Memory actions write no catalogs, instruction files, session files, persistent-memory stores, or hooks.

### Memory Confirmation

After memory changes, report family/flavor, canonical overrides, effective result, memory priority, and `agent-memory` scope. Summarize requested meanings and settings so the user can verify them; group project-reference locators and identify inline-content retention. Report reprioritization even if IDs match, zero file effects, and unresolved context limits. The summary does not replace full operative content in memory.

Recall uses the same meaning/provenance summary. Ordinary work need not repeat it; do not promise memory beyond supported context retention.

## Child Settings

Settings resolve independently: explicit agent value, then project value, then child default. [Ponytail](../subskills/ponytail/references/state.md) expands intensity into canonical IDs; it stores no competing intensity flag. Intensity configuration replaces rules and allocates priority. Edit-scope-only configuration enables nothing and preserves priority; rule actions preserve edit scope. Missing edit scope means `new-code-only`.

Project configuration edits the family's unified entry; memory configuration stays in context. Retain each setting's meaning through **Definition Retention**. Neither configuration nor priority authorizes unrelated work or changes the other axis implicitly.

## Review Criteria and Reports

[Reviews](review-common.md) default to effective rules. Explicit review selectors or child settings replace criteria for that invocation only, including normally memory-disabled rules; they change no activation, priorities, or subsequent recall. Ponytail's destructive review permits scoped recommendations, not fixes.

Findings stay in chat unless saving is explicitly requested. Saved reports are historical evidence, never memory, activation, catalog discovery, or settings for another task. Follow the shared review storage contract.

## Managed Project Files

Maintain one coherent mentality section per selected instruction file. Prepare catalogs and final state first, then rewrite the section once. Use [adjustment examples](instruction-examples.md) when useful, not as mandatory templates.

### Catalog artifact

Publish each selected child's complete declared catalog, including original examples, judgment, and applicability:

```text
.imsight-arts/mentality/<mentality>-principles.md
<!-- imsight-skill:imsight-mentality-mgr/<mentality>-principles:start -->
...complete definitions...
<!-- imsight-skill:imsight-mentality-mgr/<mentality>-principles:end -->
```

Include title, entrance skill, canonical index, and an availability-only statement. Exclude control workflows, activation/session state, and external references. Preserve code indentation and logical Markdown paragraphs; resolve links so the catalog works without installed paths or network access.

Reuse complete usable catalogs during project actions; refresh them only for an explicit deployment request. Publish missing or incomplete material automatically for project actions. Memory, recall, and ordinary work never regenerate catalogs.

### External references

Optional upstream links and rule mappings belong only in child/flavor `References` sections, opened for explicit source or attribution requests. Keep citations, filenames, origin commentary, and further-reading pointers out of rule descriptions and examples.

Publish maintained definitions and original examples only: no third-party files, copied excerpts, snapshots, source directories, hashes, or download prerequisites. Previously deployed source copies are not runtime inputs; deleting them elsewhere requires targeted cleanup. Do not follow stale source links to recover definitions; use maintained guidance when deployed content is incomplete.

### Unified mentality section

Use readable prose, bullets, or a compact table suited to the file. Meaning is fixed; wording and layout are not. Keep IDs, names, priorities, settings, family/flavor identities, and paths unambiguous without requiring fixed field labels.

- One entry per family combines its selection and catalog reference. Put enabled IDs/names and priority before the link; list actual IDs, not `all`, ranges, or a preset that could expand later.
- Put active guidance before minimal reference-only entries. Availability and settings alone enable no rules. Keep explicit settings beside their family.
- Explain once, leading with an affirmative directive: instruct agents to follow the selected, task-relevant project or memory rules as working instructions for planning, execution, and replies, on par with the file's other rules; explicit memory rule/setting overrides win; within one scope higher family priority wins. Frame restriction clauses ("apply only selected rules") as secondary scope boundaries, never as the headline. Emphasize the directive and the authority clause with bolding so the obligation is unmistakable. Read details only for selected rules or an explicit request.
- If all families are inactive, shorten shared prose to availability and selective reading. Remove obsolete application text, disabled-ID inventories, history, and repeated boilerplate. Never publish an agent's effective or remembered selection.
- Retain the known next-priority counter once through [Storage](priorities.md#storage), including after all rules are removed. A fresh never-enabled scope needs no counter.

Use one ownership boundary, without per-family discovery/application markers. The envelope illustrates metadata only; adapt the heading and replace the placeholder with current guidance:

```markdown
<!-- imsight-skill:imsight-mentality-mgr/project-guidance:start -->
## Mentality

...current guidance and entries...
<!-- imsight-skill:imsight-mentality-mgr/next-project-priority: 3 -->
<!-- imsight-skill:imsight-mentality-mgr/project-guidance:end -->
```

Keep markers exact and outside code fences in the target file. Adjust relative links per file; keep full definitions/examples in catalogs. Mention the entrance skill at most once if useful.

### Empty project selection

Replace an emptied family's application text with a minimal catalog reference; remove its priority. Retain explicit settings, clearly conditional on rules being selected. Clean up obsolete activation text even if the disable changes no IDs. Preserve catalogs, availability, other families, the known counter, and all memory overrides. If every family is inactive, no shared prose may instruct agents to apply the catalogs.

### Consolidating existing guidance

During authorized deploy/project writes, consolidate well-formed older owned `<storage-key>-catalog`, `<storage-key>-project`, and `project-priority-sequence` blocks into the unified section. Resolve state first; preserve every family's facts and sequence, apply the requested change, then remove duplicate old blocks. Formatting alone changes neither activation nor priority.

Merge into an existing unified section when present. Different prose is acceptable; contradictory meanings, unknown IDs, malformed boundaries, or uncertain ownership remain unresolved. Preserve unowned content. Read-only and memory actions never consolidate files.

### Project application preparation

Project selection/configuration authorizes required deployment without a separate confirmation, even for disabling an absent selection.

1. Validate flavors, selectors, scope, settings, target files, and current state before writes. Resolve material conflicts; pending flavor choices stop preparation.
2. Reuse complete usable catalogs; handle material definition disagreements through **Definition Retention**.
3. Publish missing, incomplete, or externally dependent catalogs through **Catalog artifact** and the child's publication contract. Publish complete catalogs even for selected subsets; Human Speak publishes only the named flavor.
4. Return prepared links and prior state to the caller. Do not run the whole deploy action or write a preliminary discovery section.

Preparation writes catalog files only. The calling action computes final selections/settings and writes one coherent section per target.

### Write protocol

1. Read all target contents and validate outputs before writing. Collect the entire owned section so unrelated family state survives recomposition.
2. Locate unified markers or recognized older owned blocks. Recompose one section; insert it if absent and required. Preserve unrelated user content.
3. Reject malformed, nested, duplicate, or uncertain boundaries. An existing catalog without its matching markers is unowned. Interpret readable state semantically; layout differences are not conflicts.
4. Allocate once per enabled family, including resulting selections and counter in each target. Before writing, check for concurrent changes and re-read/recompute if needed. Use locks or conditional writes when supported; do not claim unsupported atomicity.
5. Publish catalogs before final instruction sections. On partial failure, report completed/pending paths and recover only this request's changes. Reuse any priority already committed by the request when completing remaining files.
6. Verify one section, one entry per family, at most one counter, valid catalog links, and no superseded owned text. Compare affected state across targets by meaning, allowing prose/link differences. Preserve unrelated state; deployment changes availability only. Retries do not allocate again; fresh enables do.

### Missing and inconsistent material

If project preparation fails, report the dependency and partial effects; do not claim success or substitute memory scope. Memory and recall may retain maintained definitions inline without file writes. Unknown IDs or meanings stay visible as unresolved, never silently discarded.

## Agent Identity and Handoffs

Project files contain no agent-specific effective selection. Delegation transfers only explicitly assigned overrides and boundaries, not a parent's memory implicitly; distinguish inherited history from the child's assignment. Subagents keep independent memory sequences and never update parent/sibling overrides.

For same-agent handoff or compaction, retain enabled/disabled IDs, priorities and project-bound memory counter, settings and scopes, definition locators or operative inline content, and task baseline. Preserve explicit false/disabled values. Re-read project state; do not serialize memory into shared files or infer it from another agent. This skill installs no hooks or guaranteed cross-context persistence.

## Guardrails

- DO NOT infer activation from availability or silently replace unresolved state.
- DO NOT mutate files for memory, recall, ordinary application, or unsaved review.
- DO NOT overwrite ambiguous/unowned content or cancel memory overrides through project actions.
- DO NOT reconstruct lost memory by guessing or copy it between agents implicitly.
