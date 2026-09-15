# Mark-Life Style

## Workflow

1. **Bind the named flavor** to `human-speak/mark-life-style`. This command is an explicit flavor choice for the current invocation only.
2. **Resolve the shared action** from the arguments or pending request. With no action, recall this flavor and show concise help; do not enable it.
3. **Resolve selectors and scope** using [state.md](../references/state.md) and the manager's [decision tree](../../../references/actions.md#enabledisable-decision-tree). Validate the complete request before mutation.
4. **Execute the shared action**, using **Catalog Publication** for deployment. For ordinary output with effective rules, use **Applying the Flavor**.
5. **Report actual scope and effects** through shared [Memory Confirmation](../../../references/runtime-injection.md#memory-confirmation) or the requested action's output contract.

If the task does not map cleanly to these steps, use the native planning tool to preserve the chosen flavor, validated rules, and scope. This command supplies a communication pattern, not authorization for additional project work.

## Purpose and Origin

Mark-Life Style treats the reader's attention as scarce. Put the conclusion where it is easy to find, retain useful evidence and limits, and make the surrounding language easy to read. It adapts Mark-Life's `agent-to-human`; provenance and the original text are available in the [local source bundle](../references/sources/mark-life-style/index.md).

## Arguments

Supply an optional shared action followed by its normal arguments. Accepted actions are `deploy`, `enable-project`, `disable-project`, `enable-memory`, `disable-memory`, `recall`, and `help`. The natural verbs `enable` and `disable` follow the manager's agent-memory default unless project scope is explicit. Project rule actions require explicit selectors or `all`; memory rule actions with no selectors select all current rules of this flavor.

For example, `imsight-mentality-mgr->human-speak->mark-life-style()` with `enable-memory h1 h4` enables those two rules in chat context. The same command with `disable-project all` ensures deployment and removes this flavor's application block. These actions are arguments to the flavor command, not nested subcommands. `agent-to-human` is the upstream title, not another registered flavor or invocation alias.

## Applying the Flavor

1. Resolve effective `h1`–`h8` selections and their scope, then read and retain the selected [principles](../references/mark-life-style-principles.md) through shared [Definition Retention](../../../references/runtime-injection.md#definition-retention).
2. Identify the reader's requested result, needed level of detail, and any required output format. Preserve the work and evidence needed to support the answer.
3. Draft the human-facing result using only applicable selected rules. Existing rule state can guide subsequent replies without a fresh management invocation or flavor choice.
4. Remove repetition and unnecessary reading effort while preserving requested explanation, material limitations, and accurate evidence status. No sentence count, word count, or bullet count is mandatory.
5. Return the output. Reuse the task's actual validation evidence; these writing rules do not create an obligation to run additional tests, investigate unrelated questions, or audit every sentence mechanically.

This flavor adds no review, configuration, intensity, or code-edit action. It can guide the presentation of a separately authorized review without performing that review itself.

## Catalog Publication

Use the binding in [state.md](../references/state.md#flavor-bindings). Publish `.imsight-arts/mentality/human-speak-mark-life-style-principles.md` with the complete `Purpose`, `Principle Index`, `Communication Principles`, `Applicability and Judgment`, and `Provenance` sections of [mark-life-style-principles.md](../references/mark-life-style-principles.md). Include every Do / Don't comparison, judgment note, and the full license notice. Add a title, the entrance skill name, flavor identity, and an availability-only statement. Exclude workflow and activation state.

The declared source bundle is the entire Human Speak directory `references/sources/mark-life-style/`, not other flavors' sources. Copy it under `.imsight-arts/mentality/sources/human-speak-mark-life-style/<bundle-id>/` through the shared [offline publication contract](../../../references/runtime-injection.md#offline-source-bundles). Rewrite catalog links beginning `sources/mark-life-style/` to that deployed bundle, preserving fragments; links inside the bundle remain relative.

The deployed catalog and sources must work without this installed skill, `extern/orphan`, or network access. Publishing the flavor provides definitions only; shared actions own project and agent-memory selection.

## Guardrails

- DO NOT claim tests, observations, or tool results that were not obtained.
- DO NOT treat sentence-length or list-size heuristics as fixed quotas.
- DO NOT remove requested depth or material uncertainty merely to shorten an answer.
- DO NOT enable this flavor by inspecting its source or invoking it without an action.
- DO NOT change another flavor's selections through this command.
