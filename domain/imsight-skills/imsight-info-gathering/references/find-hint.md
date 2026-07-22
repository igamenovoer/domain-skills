# Find Hint

Use this subcommand to research a problem or topic and create a durable hint file that helps future agents or humans solve the same class of problem.

## Workflow

1. Resolve the output location and filename using the existing precedence and naming rules.
2. Follow **Research Workflow**, including Context7 and primary-source preferences where applicable.
3. Write the hint with **Hint Structure** and the applicable code and writing rules.
4. Keep sources with supported claims and preserve uncertainty or version caveats.

If the task does not map cleanly to these steps, plan only from this page's output, research, structure, and writing rules; ask for project context only when the destination would otherwise be unsafe.

## Output Location

Choose the output root in this order:

1. Use the output location explicitly provided by the user.
2. Otherwise, use `IMSIGHT_SKILL_OUTPUT_DIR` when set. Relative values are resolved from `<project-dir>`; absolute values are used as-is.
3. Otherwise, use `<project-dir>/.imsight-arts/info-gather/`.

Create a topic-specific hint file under the selected output root. If the project directory is ambiguous, infer it from the active repository or ask the smallest clarification needed.

## Filename

Choose one of these filename patterns unless the user specifies a name:

- `howto-<do-something>.md`: Specific task guidance with steps.
- `about-<some-topic>.md`: General information about a topic.
- `intro-<some-topic>.md`: Introductory information about a tool, library, framework, or concept.

Normalize names to lowercase kebab-case. Prefer descriptive names over short ambiguous names.

## Research Workflow

1. Clarify the problem or topic and the intended project context.
2. Search online for authoritative information, including official documentation and examples.
3. For third-party software, use Context7 documentation lookup when available before relying on secondary sources.
4. Prefer primary sources: official docs, standards, source repositories, release notes, examples maintained by the project, and relevant issue discussions.
5. Use secondary sources only when they add explanation, caveats, migration experience, or examples not covered by primary sources.
6. Keep source links with the claims or snippets they support.
7. Create the hint file at the selected output path.

## Hint Structure

Use this shape unless the topic calls for a smaller guide:

```markdown
# <Hint Title>

## Problem

<What this hint helps solve and when to use it.>

## Short Answer

<The concise guidance a future agent should try first.>

## Steps

1. <Step>
2. <Step>
3. <Step>

## Examples

<Concise examples or snippets, if applicable.>

## Sources

- <Source title>: <URL>
```

For general topic notes, replace `Steps` with `Key Points`. For introductory notes, include `What It Is`, `When To Use It`, and `Minimal Example` when useful.

## Code Snippet Rules

- Include example code snippets when they make the hint more actionable.
- Keep snippets concise and focused on the relevant part.
- Do not include complete runnable programs unless the complete program is genuinely the hint.
- Include source links to original documentation or relevant resources near the snippet or in `Sources`.

## Writing Rules

- Do not manually break long prose lines; let the editor or viewer wrap text.
- Write for future reuse: concrete enough to act on, short enough to scan.
- Separate facts from inference when sources do not directly state the conclusion.
- Preserve uncertainty and version/date caveats when relevant.
- Do not reference external instruction files; the hint should stand on its own.
