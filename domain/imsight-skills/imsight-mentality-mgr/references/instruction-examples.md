# Adjusting the Unified Mentality Section

## Workflow

1. Resolve the action, current selections, settings, priorities, and target instruction files through [actions.md](actions.md) and the [unified-section contract](runtime-injection.md#unified-mentality-section).
2. Choose the relevant state transition below. Learn the resulting meaning and presentation choices; do not paste the example's rules, priorities, or wording mechanically.
3. Recompose the existing section as current guidance. Combine each family's selection and catalog reference, remove superseded instructions, and keep shared explanations once.
4. Verify the actual IDs, priorities, settings, counter, relative links, and preserved state in every selected file. Explain operation history in chat rather than adding it to the section.

If the request does not match an example, use the native planning tool to derive the resulting state and a concise presentation from the shared contracts, then execute the plan.

## Reading These Examples

The first six examples form a sequence in a fresh project. Their snippets show the resulting section or identified portion, never additional blocks to append. Later examples are variations. Wording, headings, paragraphs, and lists may adapt to the surrounding document; the selection and scope semantics must remain explicit.

For readability, ownership markers and the priority counter are omitted from the snippets. Actual edits retain one outer marker pair and the known counter once inside it, following [Priority Storage](priorities.md#storage). Catalog links here assume a root-level instruction file; adjust them for other locations. These are instruction-file examples, not content for deployed principle catalogs.

## Deploy Without Enabling

Request: deploy Brooks. Publish the complete catalog, then introduce only its availability:

```markdown
## Mentality

Brooks is available as [a principle catalog](.imsight-arts/mentality/brooks-principles.md). No Brooks rules are selected for this project. Read its definitions only when rules are explicitly selected in your chat or the user requests them.
```

There is no active selection, family priority, or separate discovery section. This fresh scope has no allocated priority and needs no stored counter yet. If Brooks were already enabled, deployment would preserve its active entry instead of replacing it with this reference-only text.

## Enable Selected Rules

Request: enable Brooks `r1` and `r5` in project scope. Replace the previous prose with current application guidance:

```markdown
## Mentality

**Follow the mentality rules selected below whenever they are relevant to the task** — they are **working instructions** for how you plan, execute, and reply, **on par with the other rules in this file**. Rules explicitly enabled in your chat memory also apply, and explicit chat-memory rule and setting overrides take precedence over project selections. Within either scope, higher family priority wins conflicts. **Apply only selected, task-relevant rules**; read catalog details only for selected rules or when requested.

**Brooks, priority 0:** apply `r1` (comprehension) and `r5` (dependency-direction). Consult their [definitions and examples](.imsight-arts/mentality/brooks-principles.md).
```

The catalog link now supports the selected rules directly. Introduce the next-priority counter with value `1`. The shared paragraph states that memory overrides apply; individual agents still retain their actual overrides only in their own chat context.

## Add Another Family

Request: enable Ponytail `p1` and `p2` in project scope. Prepare its catalog if needed. Keep the common guidance once, and replace the family portion with a list:

```markdown
- **Brooks, priority 0:** apply `r1` (comprehension) and `r5` (dependency-direction). [Definitions](.imsight-arts/mentality/brooks-principles.md).
- **Ponytail, priority 1:** apply `p1` (reuse-existing) and `p2` (prefer-proven-primitives). [Definitions](.imsight-arts/mentality/ponytail-principles.md).
```

The counter becomes `2`. Do not add another mentality heading, repeat the shared paragraph, or copy a second catalog-discovery template. Changing the layout from a paragraph to a list does not change Brooks's selection or priority. No edit-scope setting was requested, so Ponytail retains its default `new-code-only` boundary.

## Disable Some Rules

Request: disable Brooks `r5` in project scope. The resulting entries are:

```markdown
- **Brooks, priority 0:** apply `r1` (comprehension). [Definition](.imsight-arts/mentality/brooks-principles.md).
- **Ponytail, priority 1:** apply `p1` (reuse-existing) and `p2` (prefer-proven-primitives). [Definitions](.imsight-arts/mentality/ponytail-principles.md).
```

Remove `r5` directly; do not append a disabled flag or retain its old application sentence. Brooks keeps priority `0`, and the counter stays `2`. Preserve the existing shared guidance because project rules remain active.

## Disable a Family's Last Rule

Request: disable all remaining Brooks project rules. Keep active guidance ahead of reference-only material:

```markdown
**Ponytail, priority 1:** apply `p1` (reuse-existing) and `p2` (prefer-proven-primitives). [Definitions](.imsight-arts/mentality/ponytail-principles.md).

Reference only: [Brooks catalog](.imsight-arts/mentality/brooks-principles.md), with no project rules selected.
```

Brooks loses its application text and family priority. Its catalog remains discoverable in one short entry, without an empty application heading or a disabled-rule inventory. The shared guidance still serves Ponytail, and the counter stays `2`.

## Re-enable a Family

Request: enable Brooks `r5` in project scope. Replace its reference-only entry and adapt the family portion again:

```markdown
- **Brooks, priority 2:** apply `r5` (dependency-direction). [Definition](.imsight-arts/mentality/brooks-principles.md).
- **Ponytail, priority 1:** apply `p1` (reuse-existing) and `p2` (prefer-proven-primitives). [Definitions](.imsight-arts/mentality/ponytail-principles.md).
```

Brooks receives the next fresh priority and the counter becomes `3`. Previously removed `r1` stays absent. Entry order is a presentation choice, not the source of priority; do not infer activation order from the list.

## Retain an Independent Setting

Starting after the preceding sequence, suppose the user explicitly configures Ponytail's project edit scope as `destructive`, then disables all Ponytail project rules. Neither operation allocates a priority because the configuration changes only edit scope. The resulting family portion could read:

```markdown
**Brooks, priority 2:** apply `r5` (dependency-direction). [Definition](.imsight-arts/mentality/brooks-principles.md).

**Ponytail — reference only:** no project rules are selected. If rules are selected, the project edit scope is `destructive`: minimize impact and revise only existing infrastructure related to the assigned task. This setting enables no rules. [Catalog](.imsight-arts/mentality/ponytail-principles.md).
```

Retain the explicit setting with its task boundary, remove Ponytail's family priority, and keep the counter at `3`. A rule-only operation does not reset the setting, broaden task authority, or change any agent's memory override.

## Other Adjustments

| Situation | Resulting adjustment |
| --- | --- |
| Refresh an enabled family's catalog | Preserve selected IDs, priority, settings, and counter. Keep the existing coherent section unchanged when its link and meaning already fit. |
| Disable every remaining project rule | Retain concise reference-only entries and explicit settings; shorten the shared prose to availability and selective reading. Preserve the known counter, with no general instruction to apply the catalogs. |
| Enable an already selected rule again | Keep the resulting IDs, assign the family a fresh priority, and update its existing entry and the counter. Do not append a second entry or an operation log. |
| Manage a Human Speak flavor | Identify the entry as, for example, `Human Speak / han-style`, with that flavor's own selected IDs, priority, and catalog. Do not merge different flavors' `h1` rules into one selection. |
| Update multiple instruction files | Keep equivalent state in all selected files. Adapt prose to their surrounding text and links to their directories; allocate priority once per family, not once per file. |
| Encounter older separate owned blocks | Resolve their state, then consolidate availability, selection, settings, and counter into one section during the authorized file-writing action. Preserve other families and remove duplicate old instructions. |
| Enable or disable rules in memory, or recall them | Leave every instruction file unchanged; report remembered or effective state in chat. |

## Guardrails

- DO NOT treat these examples as mandatory wording, fixed layouts, or a source of actual project state.
- DO NOT append new operation-specific text while leaving superseded application instructions in place.
- DO NOT turn a reference-only catalog or a retained setting into an instruction to apply rules.
- DO NOT lose family identity, explicit settings, or priority history when shortening the section.
