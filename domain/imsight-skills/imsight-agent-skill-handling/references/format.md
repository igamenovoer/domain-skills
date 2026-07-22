# Format Skill

## Workflow

Use this reference to revise a given skill so its structure conforms to the bundled style guide and its description is optimized for discovery. It applies to existing skills and to new skills created by `create`.

1. **Locate the target skill and entrypoint**. Resolve the skill folder from the user's request and select `SKILL.md` for a standalone skill or `SKILL-MAIN.md` for a parent-scoped subskill. Accept nested `SKILL.md` as legacy input only, and reject a folder that contains both candidates.
2. **Load the local style guide**. Read `references/imsight-skill-style-guide.md`; do not rely on any style guide outside this skill directory.
3. **Read target skill files**. Read the resolved target entrypoint, `agents/openai.yaml` when present, each direct subskill `SKILL-MAIN.md` or legacy nested `SKILL.md` and agent summary listed by the parent, and any directly linked subcommand, mode, workflow, primitive, or reference page that acts as an executable skill page.
4. **Identify style gaps**. Check **Formatting Checks** for the entrypoint and each subcommand-like page.
5. **Select the subcommand structure flavor** when the skill has subcommands. See **Subcommand Structure Checks**.
6. **Optimize the description**. Check **Description Optimization**.
7. **Revise structure in place**. Apply the smallest edits that make the target files conform while preserving skill meaning, public subcommands, trigger behavior, output contracts, and guardrails. See **Automatic Refactoring** for how to keep task-specific detail while conforming to the format.
8. **Synchronize links and metadata** when structural edits change subcommand labels, reference paths, or help text.
9. **Validate**. Run the available skill validator on the target skill and inspect changed files for remaining style gaps.
10. **Report results**. Summarize changed files, validations run, and any unresolved style issues.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the bundled style guide and the target skill's structure, then execute the plan.

## Formatting Checks

Apply these checks to the resolved target entrypoint and any subcommand-like Markdown page that another agent may execute as a workflow.

- The file has a `## Workflow` section near the top.
- The workflow is written as numbered steps.
- Each workflow step is concise and points to a detailed section when it needs more explanation.
- Steps with several internal branches or substeps use a nested list under the main step instead of a long paragraph. Keep the nesting depth to three levels or fewer.
- Multiple-choice steps tell the agent which table, mode list, subcommand list, or procedure set to choose from.
- Multiple-choice steps let the agent choose the option that fits the user's task; they do not hardcode one option without evidence.
- Freeform skills tell the agent to use its native planning tool to plan execution from the available tools, constraints, subcommands, and user request.
- The workflow ends with a fallback for tasks that do not map cleanly to the default steps.
- The skill entrypoint has a concise `## Guardrails` section in which every bullet starts with `DO NOT ...` and prevents a negative action specific to the skill.
- Guardrails do not contain positive requirements, operation steps, workflow repetitions, or a second procedural checklist; those instructions appear in substantive skill sections.
- If the skill bundles subskills under `subskills/`, each subskill has its own `SKILL-MAIN.md` entrypoint, has no sibling `SKILL.md`, follows the same structural rules as a top-level skill, and is listed in the parent's role-canonical entrypoint (in the `## Subcommands` table or a `## Subskills` section).
- Every direct subskill row has one substantive `When to Route Here` sentence that uses the parent context, distinguishes sibling routes, and is not copied verbatim from the child frontmatter description or agent short description.
- Any page that uses object-style invocation designators such as `X->Y`, `X->Y->cmd()`, or `X->parent()->child()` declares the `skill_invocation_notation` key in its YAML frontmatter.
- Skill and subskill entrypoint designators are bare object paths such as `X` or `X->Y`; they never use `X()` or `X->Y()`.
- Parentheses appear on every subcommand component, including intermediate object generators such as `parent()` in `X->parent()->child()`, and are never omitted from an object-style subcommand designator.
- Once a subcommand chain begins, every remaining component is a parenthesized subcommand declared by its immediate parent; the chain never returns to a bare skill or subskill component.
- A subcommand page that owns children lists them in `## Subcommands`, links their detail pages, defines what terminal invocation of the parent itself does, and keeps support resources under the containing skill or subskill.
- A capability with a private `scripts/`, `references/`, `commands/`, `assets/`, templates, runtime metadata, or other bundled-resource tree is represented as a skill or subskill rather than a subcommand.
- When a direct subskill and direct subcommand share a name, every designator preserves the bare subskill form or parenthesized subcommand form that identifies its declared kind.
- Skill-based use cases and chat-turn examples show the visible user prompt or user action and the expected final AI response shape; they do not include hidden reasoning, chain-of-thought, scratchpad notes, private tool-selection deliberation, or thinking process unless the user explicitly asks for that process to be documented. They also include a visible warning that the user/AI chat content is for example purposes only and that implementations should learn its style, intent, and semantics rather than hardcoding the example content.

## Subcommand Structure Checks

When a target skill has subcommands, choose the style guide's matching subcommand structure flavor.

Use the collection-of-routines flavor when subcommands are peer routines, tools, or functions with no normal calling order. Keep one plain `## Subcommands` table for this flavor.

Use the complex-procedure flavor when the skill describes a multi-step procedure, several steps have separate detail pages, predecessor artifacts matter, or shortcuts such as `fast-forward` and `step-by-step` are useful. For this flavor, split `## Subcommands` into:

- `### Procedural Subcommands` for user-facing workflow steps.
- `### Helper Subcommands` for lower-level implementation commands called by procedural subcommands.
- `### Misc Subcommands` for `help` and public shortcuts.

For the complex-procedure flavor, keep helper subcommands out of help output unless they are promoted to public workflow steps. If no helper subcommands exist, write `No helper subcommands are currently exposed.`

When a subcommand owns child subcommands, preserve that hierarchy rather than flattening it during formatting. Treat each intermediate parent as an object generator, require it to declare its direct children, and verify that the complete parenthesized chain resolves to the terminal child. Keep independent peer operations at the skill or subskill level, and keep nested command resources owned by that containing skill or subskill.

## Description Optimization

The `description` field in the resolved entrypoint frontmatter controls routing metadata and, for top-level `SKILL.md`, host discovery. Apply these rules:

- Start with "Use when...".
- Describe triggering conditions and symptoms only.
- Do NOT summarize the skill's workflow or process.
- Write in third person.
- Include keywords agents would search for: error messages, symptoms, tools, library names.
- Keep under 500 characters if possible, 1024 maximum.

Examples:

```yaml
# ❌ BAD: Summarizes workflow
description: Use when executing plans - dispatches subagent per task with code review between tasks

# ✅ GOOD: Triggering conditions only
description: Use when executing implementation plans with independent tasks in the current session
```

If the current description violates these rules, rewrite it.

## Automatic Refactoring

When `create` or `format` edits a skill, task-specific detail is welcome but must live in the right place:

- Keep the `## Workflow` as a concise numbered list of steps.
- If a main step has several internal branches or substeps, present them as a nested list under that step instead of a long paragraph. Keep the nesting depth to three levels or fewer.
- Move task-specific procedures, examples, edge cases, and configuration notes into dedicated detail sections.
- If the skill has multiple modes, subcommands, or variants, create `references/<subcommand>.md` detail pages when the routines have their own executable workflows, then link them from the workflow or subcommand table.
- If the skill is a collection of peer routines, keep one plain `## Subcommands` table. If the skill is a complex procedure, use the three-type split from **Subcommand Structure Checks**.
- Preserve all domain-specific content: examples, guardrails, success criteria, and output templates. Only the structure should change, not the substance.
- Normalize guardrails into negative-action prevention: rewrite each retained prohibition as one `DO NOT ...` bullet, and move positive requirements or operation steps into the workflow, procedure, contract, or another substantive section without changing their meaning.
- Repair parent subskill inventories that lack usable routing guidance: add one `When to Route Here` sentence per direct child, and rewrite phrase-only, parent-redundant, stale, or directly copied descriptions from the parent entrypoint's selection context while preserving the child's authoritative trigger boundary.
- Normalize a parent-scoped child from legacy `SKILL.md` to `SKILL-MAIN.md`, update direct local links, and do not leave a nested compatibility copy. Stop if both filenames exist.
- Normalize object designators using the declared route kind: rewrite a skill or subskill entrypoint to its bare path, add `()` to every command component, preserve intermediate generator commands, and reject a command chain that returns to a bare component.
- When examples expose hidden reasoning or thinking process, revise them into observable response contracts: decisions, commands, diagnostics, files, validation, or next-step guidance.

The goal is a skill that is both well-formatted and rich enough to execute the user's task correctly.

## Editing Rules

- Preserve frontmatter `name` and `description` unless they are invalid or stale because of structural edits.
- Do not broaden trigger behavior while formatting.
- Do not rename public subcommands, files, or output paths unless the user explicitly asks, the current name is broken, or a parent-scoped entrypoint must be normalized from legacy `SKILL.md` to `SKILL-MAIN.md`.
- Do not silently promote a subcommand to a subskill or move its resources when that would change invocation or loading behavior; report the resource-ownership conflict unless the requested format work authorizes that structural change.
- Do not remove domain-specific guardrails, approval rules, or output contracts.
- Move long procedural detail out of the workflow into existing sections when possible.
- Add a new detail section only when no suitable section exists.
- Keep references one level from the resolved entrypoint when it needs them.
- Do not create auxiliary docs such as README, changelog, installation guide, or quick reference files inside the target skill.

## Validation

Run the platform validator when available. If a local skill validator such as `skill-creator/scripts/quick_validate.py` is present, use it:

```bash
python /path/to/skill-creator/scripts/quick_validate.py <target-skill-folder>
```

If the current Python environment lacks validator dependencies, try the repository's managed Python environment before giving up.

## Output Contract

By default, `format` edits the target skill files in place and writes no analysis report. It returns a brief chat summary with changed files, validations run, and any unresolved style issues.

After validation, inspect changed files for:

- stale links to moved or renamed files,
- a subcommand structure flavor that does not match the skill functionality,
- missing `## Workflow` sections in subcommand-like pages,
- workflows without numbered steps,
- workflows without a freeform fallback,
- guardrails that do not start with `DO NOT ...`,
- positive requirements or operation steps presented as guardrails,
- accidental changes to trigger or output semantics,
- missing, phrase-only, parent-redundant, stale, multi-sentence, or directly copied `When to Route Here` guidance for any direct subskill,
- a parent-scoped child that lacks `SKILL-MAIN.md`, retains nested `SKILL.md`, or contains both entrypoint candidates,
- skill or subskill entrypoints written with `()`, any subcommand component written without `()`, undeclared parent-to-child command edges, command chains that return to bare components, same-name subskill and subcommand routes that use the wrong component form, or subcommands that claim private bundled-resource roots,
- AI response examples that expose hidden reasoning or thinking process without an explicit user request,
- AI response examples that omit the example-content warning when the skill includes user/AI chat examples.
