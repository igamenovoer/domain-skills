# Chat Response Template

Use this template for the brief in-chat response after `analyze` writes Markdown report files. Keep it concise. Focus on workflow, step explanation, and durable outputs. Use ASCII for the diagram. Do not call the workflow section `Mermaid UML Workflow`.

````md
## Workflow Overview

<!--
Fill with a compact ASCII diagram of the analyzed skill's main workflow.
Show the entrypoint flow and, if useful, one compressed branch for important subcommands.
Keep this brief; the Markdown report files hold the detailed analysis.
-->

```text
+-------------------------+
| Start: {{START_EVENT}}   |
+-------------------------+
             |
             v
+-------------------------+
| {{STEP_1_NAME}}          |
+-------------------------+
             |
             v
+-------------------------+
| {{STEP_2_NAME}}          |
+-------------------------+
             |
             v
+-------------------------+
| End: {{END_STATE}}       |
+-------------------------+
```

## Step Explanation

<!--
Fill 3-6 bullets or table rows. Explain the major steps in plain language.
Do not include implementation-only detail unless it changes the workflow.
-->

- `{{STEP_1_NAME}}`: {{BRIEF_MEANING}}
- `{{STEP_2_NAME}}`: {{BRIEF_MEANING}}

## Durable Outputs

<!--
List the analyzed skill's durable outputs, not the analysis report files.
If the analyzed skill produces no durable output, say so directly.
After that, briefly list the analysis files written.
-->

- {{DURABLE_OUTPUT_OR_NONE}}
- Analysis files written: {{REPORT_FILE_LIST}}
````
