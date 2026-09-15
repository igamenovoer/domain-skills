# STE Style Source Bundle

These sources come from [Dustin Yuchen Teng's asd-ste100-skill](https://github.com/danyuchn/asd-ste100-skill/tree/7d4a135a199a5d7447c4886bcd7ffe742a627bc9), revision `7d4a135a199a5d7447c4886bcd7ffe742a627bc9`, skill version `0.4.0`. The original skill, its writing-rule summary and examples, and the repository MIT license are bundled for offline reference.

| Record | Content |
| --- | --- |
| [skill.md](skill.md) | Complete upstream skill definition, original source URL, revision, and original-file SHA-256. |
| [references/writing-rules.md](references/writing-rules.md) | Complete upstream summary of rule categories and its citations; this is not the official standard or dictionary. |
| [examples/before-after.md](examples/before-after.md) | Complete upstream comparisons and their explanations, including caveats about changed or added meaning. |
| [license.md](license.md) | Complete repository license and copyright notice, original source URL, and original-file SHA-256. |

These are historical source records, not runtime instructions or activation state. Only selected maintained STE Style definitions govern application. The original entrypoint is named `skill.md` here so it is not discovered as an installed skill. References to the upstream linter and its fixtures describe historical tooling; that tooling is not bundled or required by this flavor. Origin URLs provide optional attribution, and no application or deployment step requires network access or the official ASD dictionary.

## Adaptation Map

| Maintained Rule | Original Grounding | Adaptation |
| --- | --- | --- |
| `h1` stable-terminology | One word, one meaning; synonym-rotation scan. | Use consistent names within the explanation while preserving domain distinctions, exact identifiers, and clear pronouns. |
| `h2` explicit-relationships | Active voice, no ellipsis, explicit conditions, and the conflict-resolution fallback example. | Clarify relevant actors and relationships without mandatory sentence structure or invented dependencies. |
| `h3` direct-literal-language | Plain words, direct verbs, noun-cluster and phrasal-verb guidance. | Prefer wording the reader can interpret directly, without a word list or blanket grammar bans. |
| `h4` preserve-claim-strength | Keep modality; preserve facts, conditions, and scope; error-message example and tense exception. | Preserve uncertainty and requirement strength, and add no facts or work under a readability preference. |
| `h5` clarity-before-brevity | Preserve precision when shortening; no ellipsis; stop before compression makes the reader reconstruct meaning. | Retain enough grammar and context for clarity, with no word caps or mandatory editing pass. |

The terminology comparison adapts the source's synonym-rotation concern. The inspection comparison adapts its filter-inspection example to a configuration. The uncertainty comparison retains the source's error-message wording and deliberately keeps an already clear sentence unchanged. The worker-restart and policy-label comparisons are illustrative cases authored for this adaptation. None reports real observations or establishes a required output layout.

## Source Limits and Deliberate Departures

The upstream skill supplies an STE-inspired adaptation and does not claim to verify full ASD-STE100 compliance. STE Style further omits its strict/flavored modes, fixed vocabulary discipline, length limits, structural prescriptions, tense and punctuation restrictions, and linter/rewrite workflow. Human Speak's human-facing scope remains in force despite the source's emphasis on inter-agent text.

Read the upstream examples critically. Example C changes a recommendation into an imperative and adds an artifact-completeness check; Example D adds a claim that data stays inside the user's stack. Those transformations do not establish permission to change obligations, add work, or invent facts in a faithful rewrite. The maintained rules and examples preserve meaning instead. The source's paraphrased STE illustrations do not constitute authoritative standard text, and its complete dictionary is absent.

The full repository license notice accompanies the maintained catalog so offline publication retains attribution. The original records preserve upstream bytes and formatting; their directions remain inactive.
