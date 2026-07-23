# Set Up Project Rules

Use this command to inspect a repository and add only relevant shared rules to coding-agent project instruction files such as `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, or `.github/copilot-instructions.md`. The command is self-contained: **Rule Catalog** is its complete runtime source.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Resolve the project root**. Use the user-provided project directory or the current repository root; do not operate from a mega-workspace parent.
2. **Select the mode** from **Modes**. Honor an explicit mode and otherwise use `automatic`.
3. **Discover target files**. Follow **Target Files**, preserving any user-provided target list.
4. **Inspect the project**. Gather concrete language, tooling, lifecycle, and existing-rule evidence using **Project Evidence**.
5. **Evaluate the rules**. Assess every item in **Rule Catalog** independently against the evidence.
6. **Approve the rules**. In `automatic` mode, select only clearly relevant rules. In `interactive` mode, follow **Interactive Review** and wait for a separate user decision on each relevant rule.
7. **Update the target files**. Follow **Managed Update**, preserving all unrelated content.
8. **Verify and report**. Apply **Verification** and report the mode, evidence, selected and skipped rules, and each changed or created file.

If the user's task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the modes, target-selection rules, embedded rule catalog, preservation constraints, and verification requirements in this command, then execute the plan.

## Modes

| Mode | Behavior |
| --- | --- |
| `automatic` | Inspect the repository, select every rule with clear supporting evidence, skip ambiguous or unsupported rules, and update the targets without asking for rule-level approval. This is the default. |
| `interactive` | Inspect the repository, identify the relevant candidate rules, and ask the user to accept or reject one candidate at a time before editing any target. |

A request for review, confirmation, or rule-by-rule choice selects `interactive`. A request to set up rules without an explicit review requirement selects `automatic`.

## Target Files

1. Update exactly the files named by the user when the request provides a target list.
2. Otherwise, update every existing repository-level coding-agent instruction file among `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and `.github/copilot-instructions.md`.
3. Include another repository file only when its contents or project documentation clearly identify it as an AI-agent project instruction file.
4. If no target exists, create the native project file for the active agent when clear; otherwise create `AGENTS.md`.
5. Keep the operation inside the resolved project. Do not update user-level or global agent configuration.

## Project Evidence

Read existing instruction files, top-level documentation, manifests, build files, lint and type-check configuration, CI workflows, and representative source paths before selecting rules. Use observable evidence:

- Markdown documentation or maintained Markdown files support the documentation rule.
- Python manifests, configuration, or source files support the general Python typing and docstring rules.
- A mypy dependency, configuration file, task, or CI command supports the mypy rule. Python alone does not imply that mypy is adopted.
- C++ source, headers, build configuration, or documentation supports the C++ docstring rule.
- Explicit wording such as experimental, testbed, prototype, work in progress, or active development supports the feature-design rules. A pre-1.0 version may support that conclusion but is not sufficient by itself when compatibility policy says otherwise.
- Existing project rules may satisfy a catalog item already. Treat semantically equivalent guidance as present and do not duplicate it.

Record the file or configuration that supports each selected rule. When evidence conflicts, prefer explicit repository policy over inference.

## Rule Catalog

The following text is the complete rule catalog. Evaluate and render rules individually; do not load their wording from another file or repository.

| ID | Category | Rule | Relevant When |
| --- | --- | --- | --- |
| `R1` | Documentation | When writing Markdown, do not hard-wrap normal paragraphs. Let Markdown viewers and editors handle line wrapping. | The project maintains Markdown. |
| `R2` | Python | Write Python in a strongly typed style. Tighter types are preferred over vague ones. | The project owns Python code. |
| `R3` | Python | Repo-owned Python should pass `mypy` after edits. | The project has adopted mypy. |
| `R4` | Python | Use NumPy-style docstrings for all public-facing Python functions, classes, and data models. | The project owns Python code with public-facing interfaces. |
| `R5` | C++ | Use Doxygen-style docstrings for all public-facing C++ functions, classes, and data models or structs. | The project owns C++ code with public-facing interfaces. |
| `R6` | Feature Design | This project is in active development and accepts breaking changes. | Repository policy clearly permits breaking changes during active development. |
| `R7` | Feature Design | When designing new features, do not spend effort on compatibility with previous iterations or external users unless explicitly requested. | The evidence for `R6` applies and no stronger compatibility policy conflicts. |
| `R8` | Feature Design | Favor a clear internal design over compatibility layers. | The evidence for `R6` applies and no stronger compatibility policy conflicts. |
| `R9` | Feature Design | If a change breaks another part of this repository, fix the dependent code in the same change so repository workflows continue to work together. | The evidence for `R6` applies and the repository contains dependent code or workflows. |

## Interactive Review

Build the relevant candidate list before asking questions. For each candidate, in catalog order:

1. Present exactly one rule ID and its full text.
2. Cite the concrete repository evidence that made it relevant.
3. Name the target files that would receive it.
4. Ask the user to accept or reject that rule, then wait for the answer before presenting the next candidate.
5. Record the decision without editing files.

After every candidate has an explicit decision, update the targets once with the accepted set. Do not ask about rules that lack relevance evidence. If the user changes the mode or explicitly decides the remaining rules as a group, honor that new instruction.

## Managed Update

Preserve project-specific guidance, headings, and ordering. Render the selected rules under category headings inside one managed block:

```markdown
<!-- BEGIN IMSIGHT PROJECT RULES -->
## Project Rules

### Documentation

- When writing Markdown, do not hard-wrap normal paragraphs. Let Markdown viewers and editors handle line wrapping.
<!-- END IMSIGHT PROJECT RULES -->
```

Adjust heading depth to fit the target document. Place a new block near general coding guidance or append it when no clear location exists. Replace an existing marked block in place so reruns are idempotent. Render exactly the currently selected rules, excluding any semantically equivalent rule already stated outside the block. Remove the block when no selected rule remains to render. Never claim or replace an unmarked section merely because it has a similar title.

Apply the same selected set to every target unless the user explicitly requests file-specific differences. Keep Markdown prose on logical lines without hard wrapping.

## Verification

For every target file, confirm:

- At most one managed block exists, with balanced begin and end markers.
- Every rendered rule belongs to the selected or accepted set.
- Rejected, ambiguous, and irrelevant rules are absent from the managed block.
- No rule duplicates semantically equivalent guidance elsewhere in the file.
- Content outside the managed block remains unchanged.
- Repeating the same mode with the same evidence and decisions produces no diff.

## Guardrails

- DO NOT load rule text from another file or repository; use only **Rule Catalog**.
- DO NOT overwrite or broadly rewrite existing project-specific instructions.
- DO NOT select a rule in `automatic` mode without concrete repository evidence.
- DO NOT batch separate rule prompts in `interactive` mode unless the user explicitly changes the review contract.
- DO NOT update user-level or global agent configuration.

## Example Prompts

- `Use $imsight-project-mgr setup-project-rules in automatic mode for this repository.`
- `Use $imsight-project-mgr setup-project-rules in interactive mode and update AGENTS.md and CLAUDE.md.`
