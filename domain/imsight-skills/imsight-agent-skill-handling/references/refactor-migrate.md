# Refactor Migrate Skill

## Overview

Use `refactor-migrate` to migrate or refactor skill logic from a user-chosen source skill path into a user-chosen target skill path. Preserve the source skill's essential logic, constraints, assumptions, inputs, outputs, gates, evidence handoffs, and stop conditions, but rewrite the target runtime files in native Imsight style.

This command is source-neutral. Do not assume a particular upstream project, harness, storage layout, environment manager, or domain vocabulary unless the user names it or the source and target skill files require it.

## Workflow

When `refactor-migrate` is invoked, execute the following steps in order.

1. **Resolve the source and target skills**. See **Source and Target Resolution**.
2. **Create migration provenance** under `<target-skill-dir>/org/`. See **Provenance Layout**.
3. **Copy source files into provenance** without editing them. See **Source Copy Rules**.
4. **Deep-inspect the source skill** with `$imsight-agent-skill-handling deep-inspect`. See **Source Analysis**.
5. **Write the migration plan** at `<target-skill-dir>/migrate/migration-plan.md`. See **Migration Plan**.
6. **Create the placeholder registry** at `<target-skill-dir>/migrate/placeholders.md` when unresolved artifacts, routes, terms, tools, storage, or environment assumptions remain. See **Placeholder Rules**.
7. **Rewrite the target runtime files** from the source analysis and migration plan. See **Native Rewrite** and **Step Support Pattern**.
8. **Validate semantic preservation and skill format**. See **Validation**.
9. **Report the migration result** using **Output Contract**.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from this page, the source skill, the target skill, and the user's request, then execute the plan.

## Source and Target Resolution

Use explicit user-provided paths whenever possible. A source or target runtime skill directory must contain exactly one applicable entrypoint: `SKILL.md` for a standalone skill or `SKILL-MAIN.md` for a parent-scoped subskill. Accept nested `SKILL.md` as legacy source input, but stop when a directory contains both candidates.

Supported forms:

- `$imsight-agent-skill-handling use refactor-migrate to migrate <source-skill-dir> into <target-skill-dir>`
- `$imsight-agent-skill-handling use refactor-migrate to refactor <target-skill-dir> into itself`
- `$imsight-agent-skill-handling use refactor-migrate to migrate <source-skill-dir> to <target-skill-dir>`

For a normal migration, `<source-skill-dir>` and `<target-skill-dir>` are different directories. The source owns the behavior to preserve; the target owns the final name, metadata, local style, and installed runtime shape.

For self-migration, set `<source-skill-dir>` and `<target-skill-dir>` to the same directory, snapshot the current target files into `<target-skill-dir>/org/src/`, inspect the explicit `<target-skill-dir>/org/src/SKILL-SOURCE.md` snapshot, then rewrite the runtime files in place. Treat files under `org/src/` as the source of truth for the pre-refactor behavior.

If the user provides only one path and asks to "refactor", "clean up", "migrate into itself", or "make this native", use self-migration. If the user provides only one path and asks to migrate from another skill, stop and ask for the missing source path.

## Provenance Layout

Create `<target-skill-dir>/org/` as the migration provenance area. It must contain:

- `<target-skill-dir>/org/src/...`: the untouched source skill copied with relative paths preserved.
- `<target-skill-dir>/org/analysis/analysis-of-<source-skill-name>.md`: deep inspection of source runtime behavior.
- `<target-skill-dir>/org/README.md`: a short inventory that explains what was copied, what was analyzed, what was excluded, and why.

Create `<target-skill-dir>/migrate/` as the migration working area. It should contain:

- `<target-skill-dir>/migrate/migration-plan.md`: the planned mapping from source behavior to target runtime files.
- `<target-skill-dir>/migrate/placeholders.md`: unresolved semantic placeholders, when any exist.

Do not edit files under `<target-skill-dir>/org/src/` after copying them. They are the audit copy of the source behavior.

## Source Copy Rules

Inspect the source and target before editing, and preserve unrelated user changes in the target. Inventory every file in `<source-skill-dir>/`, including entrypoints, agent metadata, references, commands, subskills, scripts, templates, assets, and examples.

Copy every source file into `<target-skill-dir>/org/src/` while preserving paths relative to `<source-skill-dir>/`, except for the source entrypoint filename. Preserve its bytes at `<target-skill-dir>/org/src/SKILL-SOURCE.md` so provenance remains readable without creating a recursively discoverable runtime skill.

Do not copy the source entrypoint or source `agents/openai.yaml` directly over the target runtime files. The target entrypoint and metadata must be rewritten from the migration plan so the target keeps its selected name, description, routing posture, and local style.

Copy source support files into the target runtime tree only when they should remain executable support, templates, scripts, assets, or examples after migration. If a source file is not copied into runtime, record the reason in `<target-skill-dir>/migrate/migration-plan.md`.

## Source Analysis

Invoke `$imsight-agent-skill-handling deep-inspect` on the source behavior before planning or rewriting. For self-migration, explicitly deep-inspect `<target-skill-dir>/org/src/SKILL-SOURCE.md`, not the mutable target runtime tree. The snapshot filename signals provenance and does not make `org/src/` a runtime skill.

The inspection must cover:

- The resolved source `SKILL.md` or `SKILL-MAIN.md`, copied into provenance as `SKILL-SOURCE.md`.
- `agents/openai.yaml` when it affects routing or invocation posture.
- Every directly linked page that defines a public direct or nested subcommand, mode, workflow, primitive, routing behavior, or executable procedure.
- Any additional source page that represents runtime behavior even if it is not linked cleanly from the entrypoint.

Write the analysis to `<target-skill-dir>/org/analysis/analysis-of-<source-skill-name>.md`. After inspection, write `<target-skill-dir>/org/README.md` with the copied file inventory and analysis coverage.

## Migration Plan

Write `<target-skill-dir>/migrate/migration-plan.md` before rewriting runtime files. The plan is the contract between source behavior and target style.

Include these sections:

- **Scope**: source skill, target skill, migration mode, and whether this is self-migration.
- **Source Behavior to Preserve**: essential triggers, workflows, direct and nested subcommands, parent-child command chains, object-generator context, inputs, outputs, gates, blockers, evidence handoffs, resource ownership, and side effects.
- **Target Runtime Shape**: target entrypoint, target metadata, reference pages, commands, subskills, scripts, assets, resource owners, and files to remove from runtime. Use subcommands for procedures that consume containing-skill resources and subskills for capabilities that need private bundled resources.
- **Term Adaptations**: source terms mapped to target terms, with unresolved terms listed as placeholders.
- **Tool and Harness Adaptations**: source tool calls, CLIs, runtimes, service assumptions, or unavailable dependencies mapped to target equivalents or placeholders.
- **Artifact and Storage Adaptations**: source artifacts, paths, state files, outputs, and handoffs mapped to target semantics or placeholders.
- **External Skill Route Adaptations**: source calls to other skills mapped to target skills or missing-route placeholders.
- **Step Support Mapping**: source guidance, preferences, constraints, quality gates, stop conditions, and output requirements mapped to target workflow steps.
- **Semantic Match Checks**: behavior that must be preserved and behavior that is intentionally changed.

Keep the plan concise, but make every intentional behavior change explicit.

## Placeholder Rules

Use placeholders for unresolved semantic objects instead of binding them to guessed paths, tools, or skills. Placeholders are required when a source artifact, route, term, storage binding, tool, environment assumption, or handoff matters to behavior but has no confirmed target equivalent.

Use angle-bracket names such as `<SOURCE_ANALYSIS_REPORT>`, `<TARGET_RUNTIME_SUPPORT_PAGE>`, `<MISSING_REVIEW_SKILL_ROUTE>`, `<UNRESOLVED_STORAGE_BINDING>`, or `<EXTERNAL_TOOL_EQUIVALENT>`.

Define placeholders in `<target-skill-dir>/migrate/placeholders.md` with this shape:

```markdown
# Migration Placeholders

| Placeholder | Source Text or Route | Meaning | Producer or Caller | Consumer or Callee | Kind | Status |
| --- | --- | --- | --- | --- | --- | --- |
| `<PLACEHOLDER_NAME>` | `<source text, path, tool, or route>` | <Semantic meaning.> | <Source stage or caller.> | <Target stage or callee.> | <artifact, storage, term, tool, environment, route, output, input, evidence, or blocker> | <unresolved, mapped, waived, or needs-user-decision> |
```

Add a short reference to `migrate/placeholders.md` in every rewritten runtime page that uses one or more placeholders. Keep concrete source paths inside `org/` provenance material unless the user explicitly asks for a storage-binding pass.

## Native Rewrite

Rewrite target runtime files so they read like Imsight skills, not lightly edited source files. Preserve source behavior through the analysis and migration plan, but use the target skill's name, trigger posture, local vocabulary, and reference layout.

The rewritten target should:

- Keep the target's role-canonical entrypoint concise: `SKILL.md` for a standalone target or `SKILL-MAIN.md` for a parent-scoped target. Include YAML frontmatter, `## Overview`, `## Workflow`, `## Subcommands` when needed, and a short common-mistake or maintenance section when useful.
- Keep long executable detail in `references/<name>.md` or the target's established detail-page directory.
- Use the target's subcommand structure flavor from `references/imsight-skill-style-guide.md`.
- Preserve nested subcommand ownership and full parenthesized chains. Treat intermediate parent commands as object generators, keep their descendants inside the containing skill or subskill's resource boundary, and make any capability that needs a private bundled-resource tree a subskill.
- Preserve source inputs, outputs, decision gates, blockers, quality gates, evidence handoffs, and stop conditions.
- Reference the support page or section needed by every main workflow step.
- Preserve passive templates, examples, scripts, assets, and data files only when they remain useful to target runtime behavior.
- Keep `org/src/` as the untouched source copy.

Use `$imsight-agent-skill-handling format` as the format reference after the rewrite when the target needs a structure pass.

## Step Support Pattern

When source behavior contains detailed step logic, extract it into standardized support blocks instead of burying it in long workflow prose. Use only the blocks that have meaningful source material.

Each emitted `Guidance`, `Preferences`, `Constraints`, and `Quality Gates` section must start with a short interpretive paragraph of one to three sentences. The paragraph tells the future agent how much authority the section has and when to revise, route, block, or ask instead of treating the list as decorative text.

### Guidance

`Guidance` is the local execution procedure for one workflow step. Write ordered substeps that produce named intermediate outputs.

```markdown
## Guidance

Read this section as the local execution procedure for this workflow step. Follow the substeps in order unless a substep explicitly routes to a blocker or another skill; each substep should leave the named intermediate output.

1. **<Substep name>**. <Concrete action and expected intermediate output.>
2. **<Substep name>**. <Concrete action and expected intermediate output.>
```

### Preferences

`Preferences` list route-shaping defaults. Each item should begin with `Prefer` and include the condition or fallback when useful.

```markdown
## Preferences

Read these preferences as defaults, not hard requirements. Apply the preferred path when its condition holds, and record a reason when the condition does not hold.

- Prefer <preferred approach> (if <condition>, otherwise <fallback>).
```

### Constraints

`Constraints` list hard or strong requirements. Use `must`, `must not`, `should`, and `should not` deliberately.

```markdown
## Constraints

Read these constraints as the boundaries that make the step valid. Treat `must` and `must not` as hard requirements, and treat `should` and `should not` as strong defaults that need an explicit reason to override.

- <Subject> must <required behavior>.
- <Subject> should not <discouraged behavior when not absolute>.
```

### Quality Gates

`Quality Gates` assess step output. Split measurable direction from pass/fail checks.

```markdown
## Quality Gates

Read these gates after producing the step output and before handing off or claiming completion. Use `Metrics` as directional quality signals and `Checks` as inspectable pass/fail conditions; weak metrics or failed checks should trigger revision, blocker recording, or route change.

### Metrics

- <Metric name>: <definition>; <higher, lower, more complete, or less frequent> is better.

### Checks

- <Check name>: <condition that should be satisfied>.
```

If `Quality Gates` exists, include both `Metrics` and `Checks`. If the source has no meaningful material for one subsection after a careful search, write `None` under that subsection.

## Validation

Before finishing, validate both structure and semantic preservation.

1. Confirm `<target-skill-dir>/org/src/`, `<target-skill-dir>/org/analysis/analysis-of-<source-skill-name>.md`, `<target-skill-dir>/org/README.md`, and `<target-skill-dir>/migrate/migration-plan.md` exist.
2. Confirm every source file was copied under `<target-skill-dir>/org/src/` with paths preserved except that the source entrypoint is named `SKILL-SOURCE.md`.
3. Confirm every runtime source file omitted from the target runtime tree has a reason in the migration plan.
4. Confirm the rewritten role-canonical target entrypoint and rewritten runtime pages match the source process analysis, not merely the source wording.
5. Confirm every main workflow step references the support section or support page that carries its extracted guidance, preferences, constraints, quality gates, stop conditions, and output requirements.
6. Confirm extracted step support uses the standard support block shapes when those support types are present.
7. Confirm substitutions in the migration plan are reflected in rewritten pages.
8. Confirm every unresolved source artifact, route, term, tool, storage binding, or environment assumption outside `org/` has a placeholder in `migrate/placeholders.md`.
9. Confirm every rewritten runtime page that uses placeholders references `migrate/placeholders.md`.
10. Confirm every nested subcommand retains its immediate parent, full parenthesized invocation chain, generator-context contract, and containing skill or subskill resource owner.
11. Confirm every capability that needs private bundled resources is represented as a skill or subskill rather than a subcommand.
12. Run the available skill validator or repository skillset validation command when present.
13. Inspect leftovers outside provenance material for stale source-specific paths, tool calls, metadata, or trigger language that the migration plan did not intentionally preserve.

## Output Contract

Return a concise chat summary with:

- source skill path,
- target skill path,
- migration mode, either source-to-target or self-migration,
- files written or changed,
- analysis and migration artifacts created,
- validation performed,
- unresolved placeholders or blockers.

## Guardrails

- DO NOT treat refactor migration as a cosmetic rewrite that changes or drops source behavior.
- DO NOT rewrite from intuition or without grounding the target in deep-inspection output.
- DO NOT inspect mutable runtime files during self-migration or treat them as source evidence.
- DO NOT overwrite the target runtime entrypoint or `agents/openai.yaml` with source files.
- DO NOT edit files under `org/src/` after copying them.
- DO NOT drop source gates, blockers, evidence handoffs, assumptions, inputs, or outputs because they do not fit the target's first draft.
- DO NOT bind unresolved storage, tools, routes, or environment assumptions to guessed concrete values.
- DO NOT leave workflow steps dependent on hidden source knowledge that is absent from the target runtime files.
- DO NOT mix guidance, preferences, constraints, and quality gates into one prose block.
- DO NOT flatten nested subcommand chains, execute an intermediate generator's standalone action implicitly, or assign private bundled resources to a subcommand.
