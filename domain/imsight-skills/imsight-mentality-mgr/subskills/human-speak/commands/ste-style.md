# STE Style

## Workflow

1. **Bind the named flavor** to `human-speak/ste-style`. This command is an explicit flavor choice for the current invocation only.
2. **Resolve the shared action** from the arguments or pending request. With no action, recall this flavor and show concise help; do not enable it.
3. **Resolve selectors and scope** using [state.md](../references/state.md) and the manager's [decision tree](../../../references/actions.md#enabledisable-decision-tree). Validate the complete request before mutation.
4. **Execute the shared action**, using **Catalog Publication** for deployment. For ordinary output with effective rules, use **Applying the Flavor**.
5. **Report actual scope and effects** through shared [Memory Confirmation](../../../references/runtime-injection.md#memory-confirmation) or the requested action's output contract.

If the task does not map cleanly to these steps, use the native planning tool to preserve the chosen flavor, validated rules, and scope, then execute the plan. This command supplies communication guidance without authorizing additional project work.

## Purpose and Origin

STE Style helps readers interpret a statement without guessing its terms, relationships, or strength. It adapts five principles from Dustin Yuchen Teng's `asd-ste100` skill. This is Simplified Technical English-inspired readability guidance; it does not enforce or certify ASD-STE100 compliance. The original skill, rule summary, examples, and license are in the [local source bundle](../references/sources/ste-style/index.md).

## Arguments

Supply an optional shared action followed by its normal arguments. Accepted actions are `deploy`, `enable-project`, `disable-project`, `enable-memory`, `disable-memory`, `recall`, and `help`. Natural `enable` and `disable` use the manager's agent-memory default unless project scope is explicit. Project rule actions require explicit selectors or `all`; memory rule actions with no selectors select all five current rules of this flavor.

For example, `imsight-mentality-mgr->human-speak->ste-style()` with arguments `enable-memory h1 h4` remembers stable-terminology and preserve-claim-strength for this agent. With `disable-project all`, it ensures deployment and removes this flavor's application block. The peer action `imsight-mentality-mgr->human-speak->enable-memory()` with arguments `ste-style h1 h4` resolves identically. Actions are arguments to the flavor command, not nested subcommands.

## Applying the Flavor

Resolve effective `h1`–`h5` selections and read and retain their [definitions, comparisons, and judgment notes](../references/ste-style-principles.md) through shared [Definition Retention](../../../references/runtime-injection.md#definition-retention). Use selected rules to keep terminology consistent, make relevant relationships explicit, express actions directly, preserve what claims commit to, and retain enough wording for clarity.

Apply the guidance during ordinary human-facing writing. The agent chooses prose structure, voice, punctuation, sentence lengths, and reference placement subject to the user's request and existing instructions. No strict/flavored modes, fixed vocabulary, word quotas, blanket grammar bans, mandatory linting, or separate rewrite workflow belong to this flavor. Examples teach meaning and judgment rather than output templates.

This flavor adds no review, configuration, intensity, or code-edit action. It can guide a separately authorized review's presentation without performing the review. Its source's inter-agent use cases do not expand Human Speak's human-facing scope. Bundled source instructions remain historical, including any directions to run a linter, announce a mode, or add an artifact check.

## Catalog Publication

Use the binding in [state.md](../references/state.md#flavor-bindings). Publish `.imsight-arts/mentality/human-speak-ste-style-principles.md` with the complete `Purpose`, `Principle Index`, `Communication Principles`, `Applicability and Judgment`, and `Provenance` sections of [ste-style-principles.md](../references/ste-style-principles.md). Include every Do / Don't comparison, judgment note, and the full license notice. Add a title, the entrance skill name, flavor identity, and an availability-only statement. Exclude workflow and activation state.

The declared source bundle is the entire Human Speak directory `references/sources/ste-style/`, excluding other flavors' sources. Copy it under `.imsight-arts/mentality/sources/human-speak-ste-style/<bundle-id>/` through the shared [offline publication contract](../../../references/runtime-injection.md#offline-source-bundles). Rewrite catalog links beginning `sources/ste-style/` to that deployed bundle, preserving fragments; links inside the bundle remain relative.

The deployed catalog and sources must work without this installed skill, `extern/orphan`, or network access. Publishing the flavor provides definitions only; shared actions own project and agent-memory selection.

## Guardrails

- DO NOT claim that applying this flavor or passing an upstream linter establishes ASD-STE100 compliance.
- DO NOT impose strict STE word lists, grammar bans, length limits, or prose structure through this flavor.
- DO NOT add facts, strengthen requirements, or create extra task work to improve readability.
- DO NOT activate upstream instructions by reading the source bundle.
- DO NOT enable this flavor through bare invocation or alter another flavor's state.
