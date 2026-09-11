# Runtime Injection and Persistence

## Workflow

1. Identify the named mentality and requested state change, then resolve its representation with **Application Order**.
2. Resolve current state from explicit current instructions, the managed `AGENTS.md` directive, a valid host record, then visible conversation context.
3. Validate the complete state change using the selected mentality's private contract.
4. Apply exactly one representation: the default project directive and synchronized rules artifact, the explicit inline project variant with the same artifact, or conversation memory.
5. For an applicable task, inject the compact rendering before planning or editing and keep it in force through verification.
6. Report the effective rule IDs, persistence scope, and both project paths when project persistence applies.

If the task does not map cleanly to these steps, use the native planning tool to preserve the user's requested scope without inventing durable storage.

## Application Order

Resolve each state-changing mentality command with this application order. Start with the first representation and move to the second or third only when the user explicitly requests that variant:

1. **Project directive and rules artifact — default:** update `<project>/AGENTS.md` with a short mentality summary, selected canonical rule IDs and names, installed entrance skill name, and a reference to `<project>/.imsight-arts/mentality/<mentality>-rules.md`; write the selected compact rules to that artifact.
2. **Inline project rules and rules artifact — explicit variant:** when the user explicitly asks for details, copied rules, embedded rules, or inline rules, also write the selected compact rule text into `AGENTS.md` while maintaining and referencing the same rules artifact.
3. **Conversation memory — explicit variant:** when the user says “remember,” “keep in memory,” “for this chat,” or “for this conversation,” retain state in conversation context and do not write `AGENTS.md` or the rules artifact.

No persistence wording selects the first mode, not conversation memory. A host-provided state record may preserve the conversation variant across compaction, but it does not change this default order.

| Example request | Representation |
| --- | --- |
| “Enable all Brooks rules.” | Project `AGENTS.md` directive plus complete `.imsight-arts/mentality/brooks-rules.md`. |
| “Enable all Brooks rules and put their details in the project instructions.” | Rules copied into `AGENTS.md` plus synchronized `.imsight-arts/mentality/brooks-rules.md`. |
| “Remember all Brooks rules for this conversation.” | Conversation memory only. |

## Project Persistence

Resolve `<project>` from the user-provided project directory, otherwise the current version-control root, otherwise the current working directory. Use the project-root `AGENTS.md`; create it when it does not exist. Preserve unrelated instructions and add or update one clearly named mentality section. Store enough state to distinguish enabled from disabled and to retain the selected canonical rule IDs.

Project persistence is one logical representation made of two synchronized files:

- `<project>/AGENTS.md` is the authoritative project state and agent-facing directive.
- `<project>/.imsight-arts/mentality/<mentality>-rules.md` is the referenced, human-readable rendering of the selected compact rules.

State-changing commands use this project representation by default; they do not require separate “save” or “for this project” wording. Validate both rendered outputs before writing either file, create `.imsight-arts/mentality/` when needed, and leave the pair consistent after every project-persisted state change.

### `AGENTS.md` managed fence

Wrap every project-persisted mentality directive in this exact source-only fence, replacing `<mentality>` with the child's canonical name:

```markdown
<!-- imsight-skill:imsight-inject-mentality/<mentality>:start -->
...managed project instructions...
<!-- imsight-skill:imsight-inject-mentality/<mentality>:end -->
```

The HTML comments are invisible in standard Markdown previews while identifying the entry skill and the owner of the managed block. Keep the markers exact, on their own lines, and outside any code fence.

Before inserting a block, search `AGENTS.md` for its exact start and end markers. Replace one well-formed existing block in place. If neither marker exists, add one block in the location that best fits the file's structure. If only one marker exists, the markers are reversed or nested, or several blocks exist for the same mentality, report the malformed or ambiguous state instead of adding another block.

### Default `AGENTS.md` directive

Unless the user explicitly selects the inline variant, use this structure. Substitute only the validated state, applicability summary, selected rule index, and mentality-specific artifact path:

```markdown
<!-- imsight-skill:imsight-inject-mentality/brooks:start -->
## Project Engineering Rules

### Brooks Code and Test Rules

- State: enabled.
- Purpose: preventive coding and test-design guidance for resisting structural decay.
- Selected rule index: `r1` (`comprehension`), `r5` (`dependency-direction`), `t1` (`test-intent`).
- Rules artifact: [.imsight-arts/mentality/brooks-rules.md](.imsight-arts/mentality/brooks-rules.md).
- Required use: load the installed entrance skill `imsight-inject-mentality`, read the referenced Brooks rules artifact, and apply the selected rules throughout planning, implementation, and verification.
<!-- imsight-skill:imsight-inject-mentality/brooks:end -->
```

This is a required information template, not fixed prose. Adapt the visible headings and wording when needed, but do not alter the invisible fence or omit or obscure the entrance skill name, selected canonical IDs and names, artifact reference, or application instruction. Before writing the directive, load the selected mentality's entrypoint and rule catalog so its canonical index comes from maintained resources. Do not expose internal child entrypoint or catalog paths in `AGENTS.md`; the entrance skill owns that routing.

### Brooks rules artifact

For Brooks, write `.imsight-arts/mentality/brooks-rules.md` with this structure and replace the example selection with the complete validated selection:

```markdown
<!-- imsight-skill:imsight-inject-mentality/brooks-rules:start -->
# Brooks Code and Test Rules

- State: enabled.
- Purpose: preventive coding and test-design guidance for resisting structural decay.
- Selected rule index: `r1` (`comprehension`), `r5` (`dependency-direction`), `t1` (`test-intent`).
- Entrance skill: `imsight-inject-mentality`.

## Selected Rules

### Production Rules

- `r1` (`comprehension`) — Keep the concepts a reader must hold manageable with precise names, cohesive flow, and consistent abstraction levels.
- `r5` (`dependency-direction`) — Keep policy independent of concrete infrastructure, avoid cycles, and introduce interfaces only at real boundaries.

### Test Rules

- `t1` (`test-intent`) — Make the scenario, action, and expected outcome obvious in the test name and visible setup.

Apply these rules only while Brooks is enabled and the current task is applicable.
<!-- imsight-skill:imsight-inject-mentality/brooks-rules:end -->
```

Render each selected rule with its canonical ID, canonical name, and maintained compact reminder from the selected mentality's catalog. Do not copy long examples, provenance, scoring, severity, or lint-report material. Preserve production and test group headings when they contain selected rules; omit an empty group. For an empty selection, write `none` under **Selected Rules**.

Treat the rules artifact as a managed rendering, not an independent state authority. Before writing it, replace one well-formed matching managed block or create the file with one block when the path is absent. Preserve unrelated content outside a valid block. If the file exists without matching markers, has malformed markers, or contains several matching blocks, report the conflict instead of overwriting it.

For a disabled mentality, retain its selected IDs and rendered compact reminders in both files but state plainly that the rules are not currently applied. For an empty selection, state `none`; do not omit the mentality entry and thereby lose the distinction between unset and explicitly empty. A legacy valid `AGENTS.md` Brooks block without a rules-artifact reference remains readable as project state; the next project-persisted state change upgrades it by writing the artifact and adding the reference.

### Explicit inline variant

Only when the user explicitly asks for details or to copy, embed, or inline the rules, add each selected canonical ID and compact constructive reminder directly to `AGENTS.md`. Keep the rules artifact reference and write the same selected reminders to the artifact:

```markdown
<!-- imsight-skill:imsight-inject-mentality/brooks:start -->
## Project Engineering Rules

### Brooks Code and Test Rules

- State: enabled.
- Entrance skill: `imsight-inject-mentality`.
- Rules artifact: [.imsight-arts/mentality/brooks-rules.md](.imsight-arts/mentality/brooks-rules.md).
- Embedded rules:
  - `r1` (`comprehension`) — Keep the concepts a reader must hold manageable with precise names, cohesive flow, and consistent abstraction levels.
  - `r5` (`dependency-direction`) — Keep policy independent of concrete infrastructure, avoid cycles, and introduce interfaces only at real boundaries.
  - `t1` (`test-intent`) — Make the scenario, action, and expected outcome obvious in the test name and visible setup.
<!-- imsight-skill:imsight-inject-mentality/brooks:end -->
```

Keep each rule ID beside its text so later edits can identify it unambiguously. The artifact remains the complete project-owned Brooks rules document even when `AGENTS.md` also embeds the rules.

## Explicit Variant: Conversation Memory

Use this representation only when requested. Record the validated enabled state and selected canonical IDs in visible conversation context. If a host adapter offers a session record, it may store the same child-owned state namespace and reinject it after compaction. Otherwise describe the result as `conversation-scoped`, not durable.

“Remember” and “keep in memory” select this variant; they are persistence instructions, not aliases for adding a rule. Infer any accompanying state edit from the rest of the request, and ask only when that edit is materially ambiguous. Do not create or update either project file for this variant.

## Host Adapter Contract

A reliable runtime adapter may:

- store independent state namespaces for each mentality within the conversation lane;
- route control operations to the named mentality;
- provide the current task to each child for applicability checks;
- request and inject fresh compact renderings on applicable turns;
- restore conversation state and reinject guidance after context compaction.

The adapter owns storage and lifecycle hooks. The skill owns meaning, routing, state transitions, project representation, and rendering.

## Guardrails

- DO NOT default a state-changing command to conversation memory.
- DO NOT write `AGENTS.md` or a rules artifact for an explicit conversation-memory request.
- DO NOT copy complete rule text into `AGENTS.md` without an explicit inline-copy request.
- DO NOT persist a project directive that omits the installed entrance skill name, selected canonical rule index, or rules artifact reference.
- DO NOT omit, alter, nest, or duplicate the invisible managed fences in `AGENTS.md` or the rules artifact.
- DO NOT treat the rules artifact as an independent state source when its `AGENTS.md` directive is missing or inconsistent.
- DO NOT expose child entrypoint or catalog paths in the project directive when the entrance skill can route internally.
- DO NOT imply that a skill invocation alone installs lifecycle hooks.
- DO NOT reconstruct missing conversation state from guesses after context loss.
