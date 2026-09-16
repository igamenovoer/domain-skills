# Han Style

## Workflow

1. Bind this explicit choice to `human-speak/han-style` for this invocation.
2. Resolve the shared action from arguments or a pending request; absent action means recall/help, not enable.
3. Validate selectors and scope through [state.md](../references/state.md), then execute the relevant shared action or apply effective rules below.
4. Report action effects using [Memory Confirmation](../../../references/runtime-injection.md#memory-confirmation) when applicable.

For other requests, use the native planning tool without widening communication scope or task authority.

## Purpose

Help readers understand without reconstructing the agent’s context: clear answers, connected ideas, explained technical meaning, and precision.

## Arguments

Accept the parent's shared actions with normal scope/selector defaults. Example: `imsight-mentality-mgr->human-speak->han-style()` with `enable-memory h1 h5`. `disable-project all` leaves a reference-only entry with no family priority. Actions are arguments, not nested commands.

## Applying the Flavor

Resolve effective h1–h5 and retain only needed [definitions, comparisons, and judgment](../references/han-style-principles.md) through [Definition Retention](../../../references/runtime-injection.md#definition-retention). Apply them during ordinary human-facing writing. Leave headings, paragraphs, lists, sentence lengths, voice, and reference placement to the agent and user requirements. Do not impose a fixed response sequence.

Examples teach judgment, not templates. These rules create no extra research, testing, review, mandatory editing pass, or code-edit authority; they may shape an independently authorized review's presentation.

## Catalog Publication

Publish `.imsight-arts/mentality/human-speak-han-style-principles.md` using [flavor bindings](../references/state.md#flavor-bindings) and the shared [catalog contract](../../../references/runtime-injection.md#catalog-artifact). Copy complete `Purpose`, `Principle Index`, `Communication Principles`, and `Applicability and Judgment` from [the catalog](../references/han-style-principles.md), including every original comparison and judgment note. Exclude workflow, activation state, and References.

## References

Optional attribution/background only; open on explicit request. Excluded from deployed catalogs.

| Reference | Rules concerned |
| --- | --- |
| [Han readability rule](https://github.com/testdouble/han/blob/a86259a348dd0ec8a04b0357dd33753a36f38c2d/han-communication/references/readability-rule.md) | h1–h5: reader context, answer clarity, connected ideas, technical meaning, and precision. |
| [Han writing voice](https://github.com/testdouble/han/blob/a86259a348dd0ec8a04b0357dd33753a36f38c2d/han-communication/references/writing-voice.md) | h1, h3, h4: audience awareness, connected explanation, and concrete language; no persona or layout requirement is imported. |

## Guardrails

- DO NOT remove material conditions, uncertainty, or required detail for brevity.
- DO NOT turn writing guidance into extra work or treat examples as mandatory layouts.
- DO NOT alter another flavor or enable this one through bare invocation.
