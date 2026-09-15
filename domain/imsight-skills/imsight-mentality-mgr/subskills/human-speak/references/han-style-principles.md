# Human Speak: Han Style Principles

## Workflow

1. For application, resolve the flavor's effective rules and source scope; for deployment, include all sections declared by the [flavor command](../commands/han-style.md#catalog-publication).
2. Read the selected definitions, comparisons, and judgment notes under **Communication Principles**.
3. Apply the relevant mentality within **Applicability and Judgment**, preserving the user's requested substance and freedom over prose structure.
4. Return the human-facing output. Catalog publication includes definitions without activation state.

If the task does not map cleanly to these steps, use the native planning tool to apply the selected communication guidance proportionately to the reader and task, then execute the plan.

## Purpose

Make an explanation understandable without requiring a capable reader to reconstruct the agent's context. Account for what the reader knows, make the answer apparent, explain relevant connections and technical meaning, and preserve the facts needed to understand or act.

These five principles express a mentality. Prose structure remains the agent's choice under the user's request and applicable instructions; there is no prescribed opening sentence, paragraph pattern, list policy, detail placement, or response length.

The Do / Don't comparisons are illustrative teaching examples, not reports of work performed or evidence collected. Learn their intent and semantics rather than hardcoding their wording, results, or layout. They adapt the [bundled Han guidance](sources/han-style/readability-rule.md) and add communication examples.

## Principle Index

| Code | Canonical Name | Compact Reminder |
| --- | --- | --- |
| `h1` | `reader-context` | Account for what a capable reader needs to know without assuming they followed the work. |
| `h2` | `answer-then-explain` | Make the answer easy to identify and explain what supports it. |
| `h3` | `one-idea-at-a-time` | Make ideas and their logical connections understandable without overloading the reader. |
| `h4` | `meaning-before-mechanics` | Explain what technical details mean for the reader's question. |
| `h5` | `preserve-precision` | Simplify wording while retaining material facts, conditions, and uncertainty. |

## Communication Principles

### h1 — reader-context

Treat the reader as capable, with different context from the agent. Supply the background or connection needed to understand the answer without assuming they saw the investigation. Match their expertise and purpose; explain an unfamiliar concept when it matters, and keep the technical specifics an expert needs.

**Representative Do / Don't comparison.** A user knows their service but has not followed the investigation. Inspection has established that a deploy starts a worker before updating the schema it reads.

**Don't:** “It's the usual migration ordering issue.”

**Do:** “The deploy starts the worker before adding the column it reads, so the worker fails when it queries the old schema.”

**Judgment:** Use context already established in the conversation. Avoid repeating background the reader knows, teaching basic concepts to an expert, or inventing their knowledge level. Explain enough to connect the finding to its significance; no introduction or glossary is mandatory.

### h2 — answer-then-explain

Keep the response centered on what the reader asked and make the answer easy to identify. Connect the result, recommendation, or unresolved question to its reason and supporting evidence. Incidental investigation history should not obscure the information the reader needs.

**Representative Do / Don't comparison.** The user asks whether increasing a timeout will fix the issue. Inspection has established that the server rejects the credential before any timeout occurs.

**Don't:** “I checked the timeout setting, traced the request, and read the authentication handler. The timeout is configurable.”

**Do:** “Increasing the timeout will not fix this failure: the server rejects the expired credential before the timeout is reached.”

**Judgment:** The name expresses priority, not a required sentence order. A narrative, comparison, or teaching sequence can serve the question. Make a material limitation part of the answer rather than implying certainty and withdrawing it later. A status request may call for an unresolved question or blocker instead of a conclusion.

### h3 — one-idea-at-a-time

Help the reader understand each relevant idea and how it connects to the others. Make necessary causal, conditional, or comparative relationships explicit instead of making the reader infer them from a pile of facts. Keep enough connective explanation for the argument to hold together.

**Representative Do / Don't comparison.** Measurements show that connections remain occupied during slow database queries, causing other requests to wait for a free connection.

**Don't:** “Requests wait. The connection pool is full. Database queries are slow.”

**Do:** “Slow database queries keep the connections occupied, so other requests wait for a free connection.”

**Judgment:** This rule concerns comprehensible relationships, not one idea per sentence, paragraph, or bullet. Keep a comparison or condition together when that helps, and choose any suitable prose structure. Do not invent a causal link: if the evidence shows only correlation, say so. No sentence-length limit or mandatory explanation pattern applies.

### h4 — meaning-before-mechanics

Explain the behavior, consequence, or role behind technical details in language suited to the reader. Exact names and values support an explanation when the reader can see why they matter. Prefer familiar words for the surrounding explanation; clarify an unfamiliar or coined term where it would otherwise leave the reader guessing.

**Representative Do / Don't comparison.** The user asks how failed uploads are handled; the implementation permits two retries after the initial attempt.

**Don't:** “`UploadPolicy.retryLimit` is `2`.”

**Do:** “A failed upload can be retried twice after the first attempt; `UploadPolicy.retryLimit` sets that limit.”

**Judgment:** Meaning takes priority over unexplained mechanics; this is not a placement rule. Identifiers, paths, and snippets may appear inline, before, or after an explanation as useful. If the reader asks only for the exact setting, give it without an unnecessary tutorial. Preserve established technical terms when an everyday substitute would lose meaning. No vocabulary blocklist or prescribed voice applies.

### h5 — preserve-precision

Make language easier to understand without blurring what is known. Retain quantities, conditions, distinctions, and uncertainty that affect the reader's interpretation or next action. Separate measured results from inference, and preserve the scope that makes a claim accurate.

**Representative Do / Don't comparison.** Adapting Han's own example, the available measurement says latency exceeded 340 ms in three of ten observation windows.

**Don't:** “Latency was sometimes slow.”

**Do:** “Latency exceeded 340 ms in three of the ten observation windows.”

**Judgment:** A requested summary can omit detail; it need not reproduce every source fact or announce every omission. Keep facts whose loss would change the reader's decision, such as a blocking condition, material risk, or limit on the finding. In a faithful rewrite, preserve the supplied facts unless the user requests abridgment. This rule uses the evidence already available; it creates no requirement for extra tests, research, or a fact-preservation ledger.

## Applicability and Judgment

Apply selected rules to human-facing replies, explanations, status updates, summaries, handoffs, reports, and PR, issue, or commit messages. They may also guide explicitly targeted human-facing documents alongside Docs Writer. Honor the reader's requested depth, language, and format. This flavor's short IDs identify `human-speak/han-style`, independently of other flavors' IDs.

Leave prose structure and personal style to the agent. Headings, lists, tables, paragraph divisions, sentence length, opening and closing patterns, and technical-reference placement are not governed by these principles. The names `answer-then-explain` and `meaning-before-mechanics` express what to prioritize for comprehension, not a required layout or drafting sequence. Examples illustrate meaning rather than preferred formatting. Separately enabled guidance retains its own scope and does not become part of Han Style.

Apply the mentality within ordinary writing; no separate self-check, rewrite agent, scoring rubric, or editing pass is required. These rules do not authorize additional investigation, implementation, or testing, and they do not reduce the work or evidence required by the task. Disclosure of an actual uncertainty is preferable to unsupported certainty.

Machine-readable schemas, exact quotations, code syntax, and executable instructions for other agents keep their own contracts. The bundled originals are historical references, not extra active rules. Their structural prescriptions, vocabulary blocklist, writing persona, and runtime procedures are not inherited by this flavor.

## Provenance

Adapted from Test Double's Han readability rule and writing-voice guidance at revision `a86259a348dd0ec8a04b0357dd33753a36f38c2d`. The [source index](sources/han-style/index.md) records the original files, adaptation mapping, and [license](sources/han-style/license.md). Online origin links appear only inside the source bundle; the maintained definitions and examples are self-contained.

This adaptation selects five principles rather than reproducing Han's entire standard. It retains the reader-context and factual-fidelity concerns, expresses answer priority and technical meaning without prescribing prose structure, and uses connected reasoning without sentence or paragraph quotas. Han's eight-item self-check, editor workflow, blocklist, and personal voice are outside the selection.

### License

Copyright 2026 Test Double, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
