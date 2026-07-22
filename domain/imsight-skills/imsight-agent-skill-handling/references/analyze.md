# Analyze Agent Skill

## Workflow

Use this reference to analyze a given agent skill from the skill files themselves and produce a Markdown report set under `<output-dir>`.

1. **Locate the skill folder and entrypoint**. Resolve the target folder from the user's request, then resolve its role-canonical runtime entrypoint: `SKILL.md` for a standalone skill or `SKILL-MAIN.md` for a parent-scoped subskill. Accept nested `SKILL.md` only as legacy input, and reject a folder that contains both candidates. When the user explicitly selects a provenance snapshot, read `SKILL-SOURCE.md` as source evidence rather than a runtime entrypoint.
2. **Resolve `<output-dir>`** using **Output Contract**.
3. **Read the entrypoint completely**. Read the resolved entrypoint from start to finish.
4. **Inspect runtime metadata**. Read `agents/openai.yaml` when present.
5. **Map linked resources and inventory files**. Identify directly linked `references/`, `commands/`, `subskills/`, `scripts/`, `assets/`, and workflow pages, then produce a table that lists every file in the target skill directory with its relative path, category (entrypoint, reference, agent config, subcommand, subskill, script, asset, or other), resource owner, and a one-sentence explanation of its purpose. Treat the containing skill or subskill as the resource owner for every direct or nested subcommand. Include this inventory table in the entrypoint report.
6. **Choose report units**. Always create an entrypoint report for the resolved `SKILL.md` or `SKILL-MAIN.md`. For multi-part skills, choose one report unit for each public direct or nested subcommand, mode, workflow, or primitive page that has distinct workflow logic.
7. **Load workflow-critical resources** for each report unit. Read the linked pages needed to reconstruct execution flow and output artifacts. Do not load unrelated references just because they exist.
8. **Infer workflow logic**. Build a step model from frontmatter, invocation contract, workflow sections, subcommands, routing rules, guardrails, output contracts, and linked task pages.
9. **Map skill routing**. Identify calls to subskills, direct and nested subcommands, modes, and external skills. Record the caller, callee, trigger condition, full invocation chain, immediate parent, resource owner, and whether the call is explicit (e.g., `$skill-name use <subskill>` or an object-style designator such as `X->parent()->child()`) or implicit (e.g., routed by task type or mode table). For a nested chain, distinguish intermediate object-generator commands from the terminal invoked command and do not infer that an intermediate command's standalone action runs. Include skill-owned references and linked workflow pages only when they are invoked as runtime routing targets, not when they are merely read for context.
10. **Infer durable outputs**. Extract explicit artifact paths, reports, manifests, generated files, modified files, branches, worktrees, messages, or other durable side effects. Label inferred outputs as inferred when no explicit path is stated.
11. **Load shared Mermaid style**. Read `references/mermaid-style.md` before drafting Markdown workflow diagrams or skill routing callgraphs.
12. **Fill the Markdown output template**. Use `references/md-output-template.md` for every report file.
13. **Write report files** using **Report Files** and **Output Formats**.
14. **Return a brief in-chat response** using `references/chat-response-template.md`.

If a skill has multiple subcommands or modes, write `ENTRYPOINT.md` for the top-level routing flow, then write one Markdown file for each analyzed direct or nested subcommand or mode. If no specific subcommand is requested, analyze all public subcommands at a concise level while preserving their parent-child hierarchy.

## Output Contract

By default, `analyze` writes Markdown report files under `<output-dir>` and returns a brief in-chat response using `references/chat-response-template.md`.

Resolve `<output-dir>` in this order:

1. Use the output location explicitly provided by the user.
2. Otherwise, use `AGENT_SKILL_OUTPUT_DIR` when set; relative values are resolved from the current project directory and absolute values are used as-is.
3. Otherwise, use `<project-dir>/.imsight-arts/agent-skill-handling/analysis/<target-skill-name>/`.

Write reports using these names:

- Primary resolved-entrypoint report: `<output-dir>/ENTRYPOINT.md`.
- Multi-part skill reports: `<output-dir>/<scoped-part-name>.md` for each public subcommand, mode, workflow, or primitive page that deserves its own analysis. For a nested subcommand, derive the scoped part name from its command chain, such as `parent-child.md` for `parent()->child()`.

Normalize non-entrypoint report file names to lowercase hyphen-case. `ENTRYPOINT.md` is the fixed uppercase filename for the primary resolved-entrypoint report. Prefer the public subcommand name over the source file stem when they differ.

## Evidence Rules

- Treat the resolved `SKILL.md` or `SKILL-MAIN.md` as authoritative for trigger behavior and top-level workflow.
- Treat linked reference, subcommand, workflow, mode, and primitive files as authoritative for their owned steps.
- Treat a skill or subskill as the resource owner for its direct and nested subcommands. A subcommand may own child routes but does not introduce a private bundled-resource root.
- Use `agents/openai.yaml` for UI metadata and implicit-invocation policy only.
- Distinguish explicit behavior from inferred behavior.
- Cite file paths and line numbers for important claims when practical.
- Report missing linked files, ambiguous routing, or absent output contracts as analysis gaps, not as assumed behavior.

## Report Files

Write these files under `<output-dir>`:

| Report Unit | File Name |
| --- | --- |
| Primary resolved entrypoint | `ENTRYPOINT.md` |
| Public subcommand | `<subcommand-name>.md` |
| Nested public subcommand | `<parent-command>-<child-command>.md`, extended with each additional ancestor |
| Public mode, workflow, or primitive page | `<public-name>.md` |

Normalize non-entrypoint report file names to lowercase hyphen-case. `ENTRYPOINT.md` is the fixed uppercase filename for the primary resolved-entrypoint report. Prefer public names from the subcommand table, mode table, or invocation contract over source file stems. Preserve the full ancestor chain in nested-subcommand report names. If two other report units normalize to the same file name, add a short disambiguating suffix from the parent folder, such as `deploy-workflow.md` or `deploy-mode.md`.

For single-part skills, write only `ENTRYPOINT.md` unless the user requests deeper resource-level analysis.

The entrypoint report should summarize the whole skill and link to each per-part report with relative Markdown links. Each per-part report should focus on that part's workflow and artifacts, while noting its parent entrypoint.

## Output Formats

Use two templates:

- `references/chat-response-template.md` for the final chat response.
- `references/md-output-template.md` for each Markdown report file.

The chat response is brief and contains only `Workflow Overview`, `Step Explanation`, and `Durable Outputs`. Use an ASCII diagram in `Workflow Overview`.

The Markdown report files use the same core section names: `Workflow Overview`, `Step Explanation`, and `Durable Outputs`. They also include `Inner Workings` and `Key Constraints`. Use Mermaid diagrams in Markdown report files, follow `references/mermaid-style.md`, but do not name the section `Mermaid UML Workflow`.

For `ENTRYPOINT.md`, add the Markdown template's `## Per-Part Reports` section when additional report files exist. Prefer exact paths and command names over broad descriptions.

When the analyzed skill routes work to subskills, subcommands, modes, or external skills, also include a `Skill Routing Callgraph` section. See **Skill Routing Callgraph** for what the graph must represent.

## Workflow Diagrams

Use different diagram formats for chat and Markdown output:

- Chat response: ASCII boxes and arrows.
- Markdown report files: Mermaid state diagrams or flowcharts.

Use this ASCII style for chat:

```text
+---------------------+
| Start: invoked skill |
+---------------------+
          |
          v
+----------------------+
| Resolve target input |
+----------------------+
          |
          v
+----------------------+
| Select subcommand    |
+----------------------+
          |
          v
+----------------------+
| Execute workflow     |
+----------------------+
          |
          v
+----------------------+
| Produce artifacts    |
+----------------------+
          |
          v
+---------------------+
| End: final response |
+---------------------+
```

For branching, use compact decision boxes:

```text
+----------------------+
| Decision: subcommand? |
+----------------------+
      | help
      v
+--------------+
| Show help    |
+--------------+
      |
      | analyze
      v
+--------------+
| Analyze skill |
+--------------+
```

For Markdown output, follow `references/mermaid-style.md`. Prefer `stateDiagram-v2` for lifecycle or control flow and `flowchart TD` when routing or handoffs matter more than state.

## Skill Routing Callgraph

When the analyzed skill routes work to subskills, subcommands, modes, or external skills, produce a Mermaid callgraph in the report. Use the callgraph to show which skill or subcommand calls which other skill or subcommand, and under what condition. Follow `references/mermaid-style.md` for graph syntax and styling.

Represent:

- The primary analyzed skill entrypoint as the root node.
- Each direct public subcommand or mode as a direct child of the entrypoint.
- Each nested subcommand as a child of its immediate parent command, with the edge labeled by the full parenthesized invocation chain.
- Each invoked subskill as a child of the caller that routes to it.
- Each external skill as a separate node, grouped visually by caller when helpful.
- Edges labeled with the trigger condition or explicit invocation form.

When a subskill is invoked from multiple callers, draw one node per subskill and multiple edges. When a parent command generates a child command context, draw the child below that parent and identify the terminal child as the invoked workflow. When a call is conditional, label the edge with the condition. When a call is explicit (e.g., `$skill-name subcommand`), include the invocation form in the label. When a call is implicit (e.g., routed by task type), label the edge with the routing rule.

Keep the callgraph focused on runtime routing relationships. Do not include files that are only read for context, such as templates or style guides, unless the skill explicitly loads them as a routing step. Split the callgraph into an overview and a detail view when it has more than roughly seven nodes in one row or more than two nested groups.

## Step Explanation

After the diagram, list each major step with a short introduction:

```md
1. **Resolve target skill**: Finds the skill folder and resolves one unambiguous `SKILL.md` or `SKILL-MAIN.md` runtime entrypoint.
2. **Read entrypoint**: Loads the top-level contract and workflow.
```

Use the analyzed skill's own terms when it defines subcommands, modes, phases, or artifacts.

## Durable Outputs

List artifacts the analyzed skill would create, modify, or emit during normal execution.

Use this table:

| Artifact | Path or Destination | Triggering Step | Evidence | Certainty |
| --- | --- | --- | --- | --- |
| Chat report | Chat session | Final response | Resolved entrypoint output contract | Explicit |

Include non-file artifacts such as chat reports, mailbox messages, branches, worktrees, PRs, service units, downloaded source packs, or generated commands when the analyzed skill would produce them. If a skill only modifies existing files, list those as modified artifacts. If no generated artifacts are described, say so directly.

Do not confuse the analysis report files with the analyzed skill's durable outputs. The report files are this skill's output; this section describes what the analyzed skill would output when used.
