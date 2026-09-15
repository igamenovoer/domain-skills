# Human Speak: STE Style Principles

## Workflow

1. For application, resolve the flavor's effective rules and source scope; for deployment, include all sections declared by the [flavor command](../commands/ste-style.md#catalog-publication).
2. Read the selected definitions, comparisons, and judgment notes under **Communication Principles**.
3. Apply the relevant mentality within **Applicability and Judgment**, preserving meaning and the user's freedom over prose structure.
4. Return the human-facing output. Catalog publication includes definitions without activation state.

If the task does not map cleanly to these steps, use the native planning tool to apply the selected communication guidance proportionately to the reader and task, then execute the plan.

## Purpose

Reduce ambiguity while preserving the meaning of the original statement. Help readers identify the same concepts consistently, understand who does what under which conditions, and distinguish facts, possibilities, recommendations, and requirements.

These five principles adapt the [bundled STE-inspired skill](sources/ste-style/skill.md) into a readability mentality. They do not enforce the full ASD-STE100 standard or its controlled dictionary. Prose structure, sentence lengths, punctuation, and personal writing voice remain the agent's choice under the user's request and applicable instructions.

The Do / Don't comparisons are illustrative teaching examples, not reports of work performed or evidence collected. Learn their intent and semantics rather than hardcoding their wording or layout. Context supplied with an example establishes its facts; a real rewrite must obtain those facts from the supplied material or existing context.

## Principle Index

| Code | Canonical Name | Compact Reminder |
| --- | --- | --- |
| `h1` | `stable-terminology` | Use a consistent name for each concept and preserve meaningful distinctions. |
| `h2` | `explicit-relationships` | Make relevant actors, targets, references, conditions, and dependencies clear. |
| `h3` | `direct-literal-language` | Prefer familiar wording and direct verbs when they make meaning easier to identify. |
| `h4` | `preserve-claim-strength` | Preserve uncertainty, obligation, timing, conditions, and exceptions without adding facts or work. |
| `h5` | `clarity-before-brevity` | Keep enough wording for clear interpretation and stop before compression obscures meaning. |

## Communication Principles

### h1 — stable-terminology

Give a concept a consistent name within the relevant explanation. Avoid changing names merely for variety when the reader could infer a different entity or operation. Keep distinct names when they express a real distinction, and explain an unfamiliar technical term when needed for understanding.

**Representative Do / Don't comparison.** In this example, “job” and “task” refer to the same queued object, whose established name is “job.”

**Don't:** “Start the job. Check the task status.”

**Do:** “Start the job. Check the job status.”

**Judgment:** Consistency follows meaning and audience, not a universal approved-word list. If jobs contain tasks, preserve both terms. Established identifiers and quoted wording keep their exact spelling. A clear pronoun is acceptable, and no glossary, code rename, or repetition of the full name in every sentence is required.

### h2 — explicit-relationships

Make the actor, action, target, reference, condition, or dependency explicit wherever guessing could change the reader's interpretation. Clarify what a condition governs and what happens in each relevant branch. Use the information already established; unresolved relationships remain uncertain rather than being filled in for fluency.

**Representative Do / Don't comparison.** The preceding context establishes that the worker should restart after the migration completes, but several processes and completion events have been mentioned.

**Don't:** “It should restart after completion.”

**Do:** “The worker should restart after the migration completes.”

**Judgment:** Clear references need no expansion. Passive voice is useful when the actor is irrelevant or unknown. State an ordering, cause, or fallback only when the source supports it; otherwise identify the ambiguity or ask when resolving it is necessary. This rule imposes no one-instruction-per-sentence requirement or mandatory list structure.

### h3 — direct-literal-language

Prefer familiar words and direct verbs that make the intended action or meaning easy to identify. Expand idioms, inflated action nouns, or dense noun strings when interpreting them would burden the reader. Retain technical terms when they carry needed precision.

**Representative Do / Don't comparison.** Adapting the upstream action-noun example, both sentences request the same inspection of a configuration.

**Don't:** “Perform an inspection of the configuration.”

**Do:** “Inspect the configuration.”

**Judgment:** Choose wording for this reader. A familiar phrasal verb or established noun can be the clearest expression; there is no vocabulary blocklist, part-of-speech restriction, tense restriction, or ban on personal voice. A simpler word must preserve the technical meaning. Replacing an unsupported adjective with a measurement requires that the measurement already exists; readability does not authorize inventing or gathering evidence.

### h4 — preserve-claim-strength

Preserve what a statement commits to: certainty, possibility, obligation, recommendation, timing, conditions, and exceptions. A clearer rewrite must not turn a suspected event into a fact, a recommendation into a requirement, or permission to try into a promise of success. Keep quantities and scope that affect the claim. Add no cause, frequency, mechanism, or task step simply to make the text sound more complete.

**Representative Do / Don't comparison.** The source says, “An error may have occurred while processing your request.” It does not establish that the request failed.

**Don't:** “Your request failed.”

**Do:** “An error may have occurred while processing your request.”

**Judgment:** Keeping already clear wording is a valid result. Retain “may have” when it expresses uncertainty; keep “should,” “must,” and “can” distinct when they mean recommendation, requirement, and capability. Remove empty filler without deleting meaningful qualifications. A requested summary may omit detail while preserving material conditions and confidence. New advice belongs only to separately authorized substantive work and must be identifiable as advice, rather than silently becoming part of a faithful rewrite.

### h5 — clarity-before-brevity

Use enough wording for the reader to understand the intended meaning without reconstructing omitted grammar or compressed relationships. Shorten when it reduces reading effort, and keep or add connective words when they prevent misreading. Stop when the wording is clear; the shortest available sentence is not an independent goal.

**Representative Do / Don't comparison.** The text names a policy that governs recovery when a worker fails to start.

**Don't:** “Worker startup failure recovery policy.”

**Do:** “The policy for recovering when a worker fails to start.”

**Judgment:** A short established label can be sufficient in a familiar interface; expand it when the reader needs the relationship explained. Do not rename an exact identifier to improve its prose or turn a concise answer into a tutorial. No word cap, minimum length, noun-count limit, or sentence and paragraph pattern applies. Already clear text needs no further editing pass.

## Applicability and Judgment

Apply selected rules to human-facing replies, explanations, status updates, summaries, handoffs, reports, and PR, issue, or commit messages. They may also guide explicitly targeted human-facing documents alongside Docs Writer. Honor the reader's requested depth, language, and format. This flavor's short IDs identify `human-speak/ste-style`, independently of other flavors' IDs.

Leave headings, lists, tables, paragraph divisions, sentence lengths, punctuation, opening and closing patterns, and technical-reference placement to the agent. The principles guide interpretation rather than prescribing a prose template or writing persona. They define no strict/flavored modes, fixed dictionary, grammatical prohibitions, mandatory linting, or compliance claim. Separately enabled guidance retains its own scope and does not become part of STE Style.

Apply the mentality within ordinary writing; no separate self-check, rewrite agent, scoring rubric, or editing pass is required. These rules do not authorize additional research, implementation, or testing, and they do not reduce the work or evidence required by the task. Preserve meaning when a stylistic preference would otherwise change it.

Machine-readable schemas, exact quotations, code syntax, and executable instructions for other agents keep their own contracts. The upstream skill's agent-to-agent use cases do not expand this flavor's human-facing scope. The bundled originals are historical references; their structural rules, modes, linter workflow, and example-added behavior are not inherited as active guidance.

## Provenance

Adapted from Dustin Yuchen Teng's `asd-ste100` skill, version `0.4.0`, at revision `7d4a135a199a5d7447c4886bcd7ffe742a627bc9`. The [source index](sources/ste-style/index.md) records the original skill, summarized writing rules, examples, adaptation mapping, and [license](sources/ste-style/license.md). Online origin links appear only inside the source bundle; the maintained definitions and examples are self-contained.

The upstream skill already adapts ASD-STE100 and explicitly disclaims guaranteed compliance. This flavor further selects five readability principles without the source's hard structural restrictions. Its comparisons adapt terminology consistency, direct action wording, and preservation of uncertainty, with additional illustrative cases. Source examples that add an artifact check or an unsupported data-storage claim do not authorize equivalent additions here. The bundle contains the upstream author's summary, not the official ASD dictionary or a complete copy of the standard.

### License

MIT License

Copyright (c) 2026 Dustin Yuchen Teng

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
