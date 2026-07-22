# Markdown Output Template

Use this template for every Markdown report file written by `analyze`. Keep the section names below. Use Mermaid for the workflow diagram, follow `references/mermaid-style.md`, but name the section `Workflow Overview`, not `Mermaid UML Workflow`.

````md
# {{REPORT_UNIT_TITLE}} Skill Analysis

Source skill: [{{SOURCE_LABEL}}]({{RELATIVE_SOURCE_PATH}})

Parent skill: {{PARENT_SKILL_NAME_OR_NONE}}

Parent command: {{PARENT_COMMAND_CHAIN_OR_NONE}}

Invocation designator: {{FULL_OBJECT_INVOCATION_OR_NONE}}

Resource owner: {{OWNING_SKILL_OR_SUBSKILL}}

Report unit: {{entrypoint | subcommand | mode | workflow | primitive}}

Role: {{ROLE_IN_SKILL}}

Purpose: {{ONE_SENTENCE_PURPOSE}}

## Workflow Overview

<!--
Fill with a Mermaid state diagram or flowchart for the report unit's workflow.
Use the analyzed skill's own terminology for nodes and transitions.
Show major decisions, loops, handoffs, and terminal states.
Follow references/mermaid-style.md for diagram syntax and styling.
Do not title this section "Mermaid UML Workflow".
-->

```mermaid
stateDiagram-v2
    [*] --> {{STEP_1_NAME}}
    {{STEP_1_NAME}} --> {{STEP_2_NAME}}
    {{STEP_2_NAME}} --> {{END_STATE}}
    {{END_STATE}} --> [*]
```

## Step Explanation

<!--
Fill one row per major workflow step from the Mermaid diagram.
Use "Meaning" for the step's job, not a restatement of the step name.
Use "Evidence" for the source file, section, line number, or inferred marker.
-->

| Step | Meaning | Evidence |
| --- | --- | --- |
| `{{STEP_1_NAME}}` | {{WHAT_THIS_STEP_DOES}} | {{FILE_OR_SECTION}} |
| `{{STEP_2_NAME}}` | {{WHAT_THIS_STEP_DOES}} | {{FILE_OR_SECTION}} |

## Durable Outputs

<!--
List artifacts the analyzed skill would create, modify, send, or emit during normal execution.
Do not list this analysis report itself.
Include non-file outputs such as chat reports, mailbox messages, branches, worktrees, PRs, service units, downloaded packs, or generated commands.
Use "Explicit" when the skill states the artifact directly and "Inferred" when the artifact follows from workflow logic.
-->

| Artifact | Path or Destination | Triggering Step | Evidence | Certainty |
| --- | --- | --- | --- | --- |
| {{ARTIFACT_NAME}} | {{PATH_OR_DESTINATION}} | {{STEP_NAME}} | {{FILE_OR_SECTION}} | {{Explicit | Inferred}} |

## Skill Routing Callgraph

<!--
Include this section when the analyzed skill routes work to subskills, subcommands, modes, or external skills.
Use a Mermaid flowchart TD diagram to show caller-to-callee relationships.
Place nested subcommands below their immediate parent command and label the edge with the full parenthesized invocation chain.
Treat intermediate commands as object generators and the final command as the invoked leaf.
Follow references/mermaid-style.md for callgraph syntax and styling.
Label edges with the trigger condition or explicit invocation form.
Omit this section entirely when the report unit has no runtime skill routing.
-->

```mermaid
flowchart TD
    {{CALLER_NODE_ID}}["{{CALLER_LABEL}}"] --> {{CALLEE_NODE_ID}}["{{CALLEE_LABEL}}"]
```

## Inner Workings

<!--
Explain how the report unit works internally:
- how the agent chooses this path,
- what context it reads,
- which decisions route execution,
- which guardrails constrain behavior,
- how it hands off or terminates.
Prefer 2-5 concise paragraphs.
-->

{{INNER_WORKINGS_EXPLANATION}}

## Key Constraints

<!--
List negative-action guardrails, ordering constraints, approval rules, and other exclusions. Keep positive operation steps in the process description rather than presenting them as guardrails.
If none are explicit, say "No explicit constraints found."
-->

- {{CONSTRAINT_OR_GUARDRAIL}}
````

For `ENTRYPOINT.md`, add this section after `Purpose` when additional report files exist:

```md
## Per-Part Reports

<!-- Link every generated per-part report with a one-line description. -->

- [{{REPORT_FILE_STEM}}]({{REPORT_FILE_NAME}}): {{WHAT_THIS_PART_COVERS}}
```
