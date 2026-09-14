# Mentality Actions

## Workflow

1. Resolve the action, target project, and named mentalities from the caller; use the action table in the parent entrypoint.
2. Load each selected child's entrypoint and selector contract. Validate every requested ID or name before changing any scope.
3. Read [runtime-injection.md](runtime-injection.md) and execute the matching detail section below.
4. Verify the action's file and state boundaries, then report canonical selections and actual effects. Preserve child settings during rule-only actions; include the child's settings in recall.

If the task does not map cleanly to these steps, use the native planning tool to build a bounded plan from the declared actions and explicit caller intent. Ambiguous scope does not authorize a mutation. Only named memory enable/disable actions treat omitted selectors as all current rules; project actions still require explicit selectors.

## Deploy

**Input:** one or more named mentalities and a target project. Naming particular principles identifies their owning mentality; deployment publishes that mentality's complete catalog.

1. Read the complete maintained catalog and its **Catalog Publication** contract in the child's entrypoint.
2. Publish any source bundle declared by the child using [Offline source bundles](runtime-injection.md#offline-source-bundles). Render all canonical principles with definitions, examples, judgment notes, applicability, and provenance into `.imsight-arts/mentality/<mentality>-principles.md`, rewriting source links to the project-local copy.
3. Add or refresh only the catalog discovery block in `AGENTS.md`, following **Managed Project Files** in the runtime reference.
4. Verify the complete catalog, source links, and discovery reference resolve within the project without network access or an installed skill. Confirm project selection and every agent's remembered overrides are unchanged.

**File effects:** the deployed catalog, any child-declared offline source bundle, and the catalog's `AGENTS.md` discovery block only. Deployment never creates a project-enabled selection, even when the caller names all principles. Refreshing a catalog does not enable newly added principles.

**Output:** mentality names, deployed canonical rule index, catalog and discovery paths, any source-bundle path, and whether catalogs were created or refreshed. State that deployment alone enables no rules.

## Enable Project

**Input:** named mentalities and explicit rule selectors, including `all` within a named mentality. Child intensity configuration is a separate replacement action, not an alias for this union operation.

1. Resolve selectors against each child's complete canonical catalog.
2. Verify that the requested principles have a valid deployed catalog and discovery reference. If missing or incomplete, explain that `deploy` is required; perform it only when deployment is also authorized by the request.
3. Read current project selections and union the resolved IDs into each affected set.
4. Update only the affected project-selection blocks in `AGENTS.md`, following the shared write protocol.
5. Verify the resulting project sets while preserving catalogs, discovery blocks, unrelated instructions, and all memory overrides.

**File effects:** `AGENTS.md` project-selection blocks only. These rules become project-wide requirements subject to agent-local overrides.

**Output:** newly enabled IDs, unchanged IDs, resulting project selection, and the instruction-file path. Do not claim that these are every agent's effective rules.

## Disable Project

**Input:** named mentalities and explicit rule selectors.

1. Validate all selectors using the child's canonical catalog; removing a known project rule does not require a deployed catalog to be repaired first.
2. Read current project selections and subtract the resolved IDs. An absent project selection is empty.
3. Update existing affected project-selection blocks, writing `none` when a selection becomes empty. If no block exists and the operation is already a no-op, create no file or block.
4. Verify that catalogs, discovery references, unrelated project rules, and memory overrides are unchanged.

**File effects:** existing project-selection blocks in `AGENTS.md` only. Disabling a project rule removes the shared requirement; it does not prohibit an agent from explicitly enabling that rule in memory.

**Output:** removed IDs, unchanged IDs, resulting project selection, and whether any file changed.

## Enable Memory

**Input:** named mentalities and optional rule selectors. Natural instructions such as “remember and apply Brooks r1” select this action. “Enable Agile Experimenter in memory” or a named `enable-memory` with no selectors selects all currently defined rules of that mentality.

1. Expand omitted selectors to the named child's current canonical IDs, or resolve the explicit subset. Validate the complete selection and read its meanings through [Definition Retention](runtime-injection.md#definition-retention); deployment is not required.
2. Remove each selected ID from this agent's remembered disabled set and add it to its remembered enabled set.
3. Keep the explicit enabled override even when the project already enables the same rule, so later project changes do not erase the caller's local intent.
4. Recompute effective selection and retain the overrides with each item's project-reference or inline-content in this agent's chat context only. Preserve independent child settings such as Ponytail edit scope.

**File effects:** none, including no catalog deployment, repair, instruction-file update, or session-state file.

**Output:** explicit memory-enabled IDs, remaining memory-disabled IDs, and effective selection. Follow [Memory Confirmation](runtime-injection.md#memory-confirmation) to summarize the meanings, retention sources, scope, and zero file effects.

## Disable Memory

**Input:** named mentalities and optional rule selectors. Natural instructions such as “do not apply Brooks r5 in your memory” select this action. A named `disable-memory` without selectors disables all currently defined rules of that mentality.

1. Expand omitted selectors or resolve the explicit subset, then validate the complete selection and read its meanings through [Definition Retention](runtime-injection.md#definition-retention); deployment is not required.
2. Remove each selected ID from this agent's remembered enabled set and add it to its remembered disabled set.
3. Retain that disabled override even if the project currently leaves the rule disabled; it must also mask a later project enable.
4. Recompute effective selection and retain each override with its definition reference or content, without changing child settings, project files, or another agent's context.

**File effects:** none. Disabling is an explicit negative override, not a request to inherit project defaults.

**Output:** explicit memory-disabled IDs, remaining memory-enabled IDs, and effective selection, with the same [Memory Confirmation](runtime-injection.md#memory-confirmation). Explain which guidance is suppressed, including when it was already disabled in project scope.

## Recall

**Input:** an optional mentality filter and optional task context. Without a filter, cover every registered mentality and report unresolved identifiers separately.

1. Read current project selections from `AGENTS.md` and this agent's explicit remembered overrides from its own context.
2. Resolve the effective selection using the shared per-rule precedence. Keep principle identity qualified by mentality when reporting across children.
3. Evaluate task applicability and material conflicts through [composition.md](composition.md). When no substantive task is available, report applicability as not evaluated rather than treating the recall request as the task being guided.
4. Report project-enabled rules, memory-enabled rules, memory-disabled rules, effective selection, and the applicable rules for the supplied task. Name the source of each effective rule and explain masked or conflicting guidance. For Ponytail, use its [recall extension](../subskills/ponytail/references/state.md#recall) to include both axes and their provenance.
5. Identify missing or inconsistent state/catalog evidence without repairing files or fabricating remembered selections.

**File effects:** none. Recall changes no selections or configured values; reading or recovering definition references/content follows the shared retention contract.

**Output:** identify canonical ID, name, project setting, memory override (`enabled`, `disabled`, or `inherit`), and effective setting. Include practical meanings and definition references or inline-content through [Memory Confirmation](runtime-injection.md#memory-confirmation); use a table only when it aids comparison. List applicable IDs separately when task context is known; otherwise label the result as configured selection. Show `none` explicitly for empty sets, and distinguish missing remembered context from a confirmed empty set.

### Example interaction

This user/AI exchange is illustrative. Learn its intent, scope semantics, and response shape; do not hardcode its IDs or wording.

Given project-enabled Brooks `r1` and `r5`, and this agent's remembered enabled `t2` and disabled `r5`:

```text
User: Recall the effective Imsight mentality for these test-only assertion changes.
Agent:
Brooks
Project enabled: r1, r5
Memory enabled: t2
Memory disabled: r5
Effective selection: r1 (project), t2 (memory)
Applicable to these test-only changes: t2
Not applicable here: r1 (production guidance)
Suppressed: r5, because the agent-memory disable overrides project enable.
Definitions: project-reference to .imsight-arts/mentality/brooks-principles.md
in this project, entries r1, r5, t2.
Meaning: r1 makes code structure understandable; r5 keeps dependencies
pointing toward stable policy; t2 checks behavior without tying tests to internals.
Docs Writer
Project enabled: none
Memory enabled: none
Memory disabled: none
Effective selection: none
No files written.
```

## Guardrails

- DO NOT partially apply a multi-selector request containing invalid or ambiguous selectors.
- DO NOT deploy or repair catalogs as a side effect of a memory action or recall.
- DO NOT enable rules merely because their catalog was deployed.
- DO NOT rewrite project selections during an agent-memory action.
- DO NOT describe an explicit memory disable as returning to project inheritance.
- DO NOT report selected rules as currently applicable without considering the task.
