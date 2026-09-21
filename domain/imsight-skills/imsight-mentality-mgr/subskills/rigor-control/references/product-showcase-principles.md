# Rigor Control: Product Showcase Principles

## Workflow

1. For application, resolve the flavor's effective rules and source scope; for deployment, include all sections declared by the [flavor command](../commands/product-showcase.md#catalog-publication).
2. Read the selected definitions, comparisons, and judgment notes under **Product Showcase Principles**.
3. Apply them to the current design, implementation, and verification decision within **Applicability**.
4. Report scoped readiness, material limits, and any explicit requirement that demands stronger assurance; catalog publication includes definitions without activation state.

If the task does not map cleanly to these steps, use the native planning tool to match effort to the selected product-showcase rigor level without weakening explicit requirements, then execute the plan.

## Purpose

Make a product reliable enough for ordinary users to use through ordinary use cases for roughly ten minutes at a product showcase. Protect the core feature against the plausible concentration of that ordinary use and support presented numbers with claim-relevant evidence, without imposing rigor whose purpose is massive sustained usage or standardized committee-like inspection.

## Principle Index

| Code | Canonical Name | Compact Reminder |
| --- | --- | --- |
| `rc1` | `ordinary-session-reliability` | Make ordinary use reliable for an ordinary user's roughly ten-minute hands-on session. |
| `rc2` | `core-feature-showcase-pressure` | Protect the core feature under the strongest plausible ordinary-use pressure at the showcase. |
| `rc3` | `experience-level-equivalence` | Judge correctness by differences that materially affect the showcase experience, not unjustified internal parity. |
| `rc4` | `claim-relevant-evidence` | Keep showcased numbers valid for their claims without invalidating evidence for immaterial changes. |
| `rc5` | `defer-industrial-rigor` | Do not add rigor intended for massive sustained use or standardized committee-like inspection. |

## Product Showcase Principles

The comparisons below are original teaching examples. They illustrate judgment rather than mandatory features, test counts, or implementation layouts; learn their intent and semantics rather than hardcoding the example content.

### rc1 — ordinary-session-reliability

Calibrate reliability to a bounded ordinary-user hands-on session.

**Underdone:** The product can fail or materially degrade during an ordinary user's short hands-on session.

**Overdone:** The product must endure prolonged operation, every environment, or every possible use pattern before the showcase.

**Preferred rigor:** Make ordinary use reliable for an ordinary user's roughly ten-minute session, with implementation and verification sufficient for that bounded experience.

> **Example.** At an event kiosk, an attendee spends about ten minutes uploading photos, generating captions, changing the caption style, and downloading a result.
>
> **Don't (underdone):** Accept a flow that commonly stalls after the second upload or loses the result when the attendee changes styles.
>
> **Don't (overdone):** Require the kiosk to survive a week-long unattended run across every possible file format and device before the event.
>
> **Do:** Make the ordinary interactions work reliably throughout the attendee's session, including repeated uploads and style changes.

**Judgment:** Ten minutes is an approximate rigor boundary, not a literal timeout. “Ordinary” refers to the intended product use, not every possible input, environment, or operating condition. Explicit task requirements remain authoritative.

### rc2 — core-feature-showcase-pressure

Calibrate core-feature robustness to the strongest plausible ordinary-use pressure at the event.

**Underdone:** The core feature is checked only through a simplified or unrepresentative path that ignores plausible event concurrency, bursts, varied inputs, or user-visible latency.

**Overdone:** The core feature must handle every theoretical schedule, input, load, or adversarial pattern before the showcase.

**Preferred rigor:** Protect the actual core feature under the strongest plausible ordinary-use pressure at the event, including concentrated attention and obvious edge cases users may spontaneously try.

> **Example.** A team optimizes SGLang to serve its model efficiently on a specific hardware platform. At the showcase, around ten attendees submit prompts with different lengths in quick succession.
>
> **Don't (underdone):** Validate only three pre-batched requests while debug-oriented D2H checks remain in the serving path. Correct output alone is insufficient when ordinary interactive use is visibly slow.
>
> **Don't (overdone):** Require every possible request arrival and scheduling order to produce bitwise-identical output for every request.
>
> **Do:** Exercise the actual serving path with approximately the expected concurrency, mixed prompt and generation lengths, and short request bursts. Require reasonable model output and user-visible latency for the showcase.

**Judgment:** Ordinary users are not adversarial testers, but their combined activity and spontaneous experiments can pressure the core feature. Cover plausible event behavior, not every theoretically possible schedule, input, or load. The expected attendance and interaction pattern determine the pressure; ten users is an example, not a universal limit.

### rc3 — experience-level-equivalence

Calibrate equivalence to material showcase outcomes rather than internal identity.

**Underdone:** Differences that materially change the showcase user's result or experience are accepted merely because the implementation runs.

**Overdone:** Exact internal, numerical, or implementation parity is required even when the difference has no material product effect.

**Preferred rigor:** Judge correctness at the level that matters to the showcase experience, using stricter equivalence only when a relevant outcome or explicit requirement depends on it.

> **Example.** An object detector is ported from x64 to ARM64; its bounding boxes look equivalent in ordinary use, but raw outputs differ by more than `1e-5`.
>
> **Don't (underdone):** Accept an ARM64 detector that visibly misses objects or draws materially misplaced boxes merely because it completes without crashing.
>
> **Don't (overdone):** Keep refactoring until every raw output matches within `1e-5` when that tolerance has no user-visible or stated product meaning.
>
> **Do:** Verify that the ARM64 detector produces the expected detections and visually equivalent bounding boxes; require stricter numerical agreement only when the showcase or a downstream behavior depends on it.

**Judgment:** Choose an acceptance criterion tied to material product behavior. Human observation is sufficient only when the showcase experience itself is visual; use an appropriate task-level measure when small numerical differences can change a relevant outcome.

### rc4 — claim-relevant-evidence

Calibrate evidence refresh to changes that can materially affect each showcased claim.

**Underdone:** Stale, selectively favorable, or incomplete evidence is used after a material change, so a showcased number no longer supports its claim.

**Overdone:** Every result is invalidated by any artifact change, even when the change cannot affect the claim.

**Preferred rigor:** Trace each claim to its material dependencies, re-run affected evidence, reuse unaffected evidence, and disclose the evaluated scope.

> **Example.** A team presents latency, throughput, and model-quality numbers for an optimized LLM inference system. It later fine-tunes the model with a new dataset and makes unrelated source changes.
>
> **Don't (underdone):** After fine-tuning, run only a convenient or favorable quality dataset and omit other relevant evaluations because they may regress or take longer.
>
> **Don't (overdone):** Invalidate every result whenever any repository or model artifact gets a new SHA-256 hash, even when the only source change is a comment or changed weights cannot affect the particular speed claim.
>
> **Do:** Identify what can materially affect each claim. Re-run speed measurements when serving code, model structure, precision, workload, configuration, or hardware changes could affect speed. Re-run representative quality evaluations when model weights or training change. Reuse unaffected evidence and disclose its scope.

**Judgment:** Fingerprints identify what was measured; they are not an automatic invalidation policy. Quality numbers usually depend on model weights and evaluation coverage. Performance numbers usually depend on executable code, model structure and precision, workload, runtime configuration, and hardware. Comments and unrelated files affect neither. A change may invalidate one class of numbers without invalidating the others.

### rc5 — defer-industrial-rigor

Stop at showcase-grade assurance instead of importing production-scale or formal-inspection rigor.

**Underdone:** “It is only a demo” is used to skip the ordinary reliability, core-feature pressure, equivalence, or evidence needed for the showcase.

**Overdone:** Massive sustained usage, exhaustive conditions, or standardized committee-like inspection become prerequisites for the event build.

**Preferred rigor:** Satisfy the product-showcase rules for the intended event and defer stronger industrial assurance until the intended use or an explicit requirement calls for it.

> **Example.** A product configurator will run on event tablets for one attendee at a time, but the team proposes a week-long soak test, support for thousands of simultaneous users, and a formal audit package before the showcase.
>
> **Don't (underdone):** Skip testing the ordinary tablet session on the event build because it is “only a demo.”
>
> **Don't (overdone):** Make the week-long, production-scale, and formal-inspection exercises prerequisites for the event build.
>
> **Do:** Qualify the ordinary ten-minute tablet session and defer the large-scale and formal-assurance work until the product is prepared for that use.

**Judgment:** This rule excludes extra rigor for a different assurance target; it does not override explicit task requirements. Work needed for ordinary short-session reliability, core-feature showcase pressure, experience-level equivalence, or claim-relevant evidence remains governed by `rc1`–`rc4`.

## Applicability

Apply selected rules when deciding implementation robustness, core-feature pressure, verification depth, evidence validity, and completion criteria for a product showcase. They define a bounded rigor level and do not grant authority to change the requested product or ignore higher-priority requirements.
