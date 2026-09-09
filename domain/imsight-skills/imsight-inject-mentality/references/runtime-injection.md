# Runtime Injection and Persistence

## Application Order

Resolve each state-changing mentality command with this application order. Start with the first representation and move to the second or third only when the user explicitly requests that variant:

1. **Project summary and rule index — default:** update one applicable project instruction file with a short mentality summary, the selected canonical rule IDs and names, and a directive to load the mentality skill for their definitions.
2. **Detailed project rules — explicit variant:** when the user explicitly asks for details, copied rules, embedded rules, or inline rules, write the selected compact rule text into that project instruction file.
3. **Conversation memory — explicit variant:** when the user says “remember,” “keep in memory,” “for this chat,” or “for this conversation,” retain state in conversation context and do not write a file.

No persistence wording selects the first mode, not conversation memory. A host-provided state record may preserve the conversation variant across compaction, but it does not change this default order.

| Example request | Representation |
| --- | --- |
| “Enable all Brooks rules.” | Project summary and complete rule index. |
| “Enable all Brooks rules and put their details in the project instructions.” | Detailed project rules. |
| “Remember all Brooks rules for this conversation.” | Conversation memory. |

## Workflow

1. Identify the named mentality and requested state change, then resolve its representation with **Application Order**.
2. Resolve current state from explicit current instructions, the applicable project rule directive, a valid host record, then visible conversation context.
3. Validate the complete state change using the selected mentality's private contract.
4. Apply it through exactly one representation: compact project index, detailed project rules, or conversation memory.
5. For an applicable task, inject the compact rendering before planning or editing and keep it in force through verification.
6. Report the effective rule IDs, destination, and whether the project representation is a skill reference or an inline copy.

If the task does not map cleanly to these steps, use the native planning tool to preserve the user's requested scope without inventing durable storage.

## Project Rule Persistence

Treat `AGENTS.md` and `CLAUDE.md` as examples, not fixed destinations. Inspect the project's current structure and conventions for purpose-created agent or contributor instruction files, then choose the one whose scope matches the user's request. Prefer an existing applicable file; when none exists, use the repository's established convention or a root `AGENTS.md`. Do not update several agent-specific files unless the user asks for that duplication.

Preserve unrelated instructions and add or update one clearly named mentality section. Store enough state to distinguish enabled from disabled and to retain the selected canonical rule IDs. State-changing commands use this project path by default; they do not require separate “save” or “for this project” wording.

### Default: summary and rule index

Unless the user explicitly selects another representation, persist a compact directive like this:

```markdown
## Imsight mentalities

- `brooks` is enabled — preventive coding and test-design guidance for resisting structural decay.
  - Rule index: `r1` (`comprehension`), `r5` (`dependency-direction`), `t1` (`test-intent`).
  - Before applicable work, load `imsight-inject-mentality->brooks`, find these rules in its catalog by canonical ID, and apply them. Preserve and state the IDs when carrying the selection into a task.
```

Adapt the mentality name, enabled state, applicability wording, and selected IDs from validated state. The directive points the agent to the installed skill; it does not assume this source repository is present in the target project.

### Explicit variant: detailed project rules

Only when the user explicitly asks for details or to copy, embed, or inline the rules, write each selected canonical ID and its compact constructive reminder directly in the project instruction file:

```markdown
## Imsight mentalities

- `brooks` is enabled with these rules:
  - `r1` — Keep the concepts a reader must hold manageable with precise names, cohesive flow, and consistent abstraction levels.
  - `t1` — Make the scenario, action, and expected outcome obvious in the test name and visible setup.
```

Copy the maintained compact reminder, not the long examples, provenance, or lint-report material. Keep the rule ID beside its text so later edits can identify it unambiguously.

For a disabled mentality, retain its state and selected IDs but state plainly that the rules are not currently applied. For an empty selection, state `none`; do not omit the mentality entry and thereby lose the distinction between unset and explicitly empty.

## Explicit Variant: Conversation Memory

Use this representation only when requested. Record the validated enabled state and selected canonical IDs in visible conversation context. If a host adapter offers a session record, it may store the same child-owned state namespace and reinject it after compaction. Otherwise describe the result as `conversation-scoped`, not durable.

“Remember” and “keep in memory” select this variant; they are persistence instructions, not aliases for adding a rule. Infer any accompanying state edit from the rest of the request, and ask only when that edit is materially ambiguous.

## Host Adapter Contract

A reliable runtime adapter may:

- store independent state namespaces for each mentality within the conversation lane;
- route control operations to the named mentality;
- provide the current task to each child for applicability checks;
- request and inject fresh compact renderings on applicable turns;
- restore conversation state and reinject guidance after context compaction.

The adapter owns storage and lifecycle hooks. The skill owns meaning, routing, state transitions, project-rule representation, and rendering.

## Guardrails

- DO NOT default a state-changing command to conversation memory.
- DO NOT write a repository, home, or global file for an explicit conversation-memory request.
- DO NOT copy complete rule text into project instructions without an explicit inline-copy request.
- DO NOT treat example filenames as mandatory when the project has an applicable purpose-created instruction file.
- DO NOT imply that a skill invocation alone installs lifecycle hooks.
- DO NOT reconstruct missing conversation state from guesses after context loss.
