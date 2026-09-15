# Han Style

## Workflow

1. **Bind the named flavor** to `human-speak/han-style`. This command is an explicit flavor choice for the current invocation only.
2. **Resolve the shared action** from the arguments or pending request. With no action, recall this flavor and show concise help; do not enable it.
3. **Resolve selectors and scope** using [state.md](../references/state.md) and the manager's [decision tree](../../../references/actions.md#enabledisable-decision-tree). Validate the complete request before mutation.
4. **Execute the shared action**, using **Catalog Publication** for deployment. For ordinary output with effective rules, use **Applying the Flavor**.
5. **Report actual scope and effects** through shared [Memory Confirmation](../../../references/runtime-injection.md#memory-confirmation) or the requested action's output contract.

If the task does not map cleanly to these steps, use the native planning tool to preserve the chosen flavor, validated rules, and scope, then execute the plan. This command supplies a communication pattern, not authorization for additional project work.

## Purpose and Origin

Han Style helps a capable reader understand an answer without reconstructing the agent's context. It adapts five essential mentalities from Test Double's Han readability guidance, leaving prose structure and personal writing voice to the agent. The original guidance and license are in the [local source bundle](../references/sources/han-style/index.md).

## Arguments

Supply an optional shared action followed by its normal arguments. Accepted actions are `deploy`, `enable-project`, `disable-project`, `enable-memory`, `disable-memory`, `recall`, and `help`. Natural `enable` and `disable` use the manager's agent-memory default unless project scope is explicit. Project rule actions require explicit selectors or `all`; memory rule actions with no selectors select all five current rules of this flavor.

For example, `imsight-mentality-mgr->human-speak->han-style()` with arguments `enable-memory h1 h5` remembers reader-context and preserve-precision for this agent. With `disable-project all`, it ensures deployment and removes this flavor's application block. The peer action `imsight-mentality-mgr->human-speak->enable-memory()` with arguments `han-style h1 h5` resolves identically. Actions are arguments to the flavor command, not nested subcommands.

## Applying the Flavor

Resolve effective `h1`–`h5` selections and read and retain their [definitions, comparisons, and judgment notes](../references/han-style-principles.md) through shared [Definition Retention](../../../references/runtime-injection.md#definition-retention). Use selected rules to consider the reader's context, the answer they need, the connections they must understand, and the precision they need to act.

Apply those considerations during the task's ordinary writing. The agent chooses headings, paragraphs, lists, tables, sentence lengths, voice, and placement of technical references subject to the user's request and existing instructions. These rules supply no fixed response sequence, mandatory self-check, rewrite pass, review agent, or additional testing or research phase. Examples teach meaning and judgment; their arrangement is not an output template.

This flavor adds no review, configuration, intensity, or code-edit action. It can guide a separately authorized review's presentation without performing that review itself. Reading the bundled Han originals does not import their vocabulary blocklist, writing persona, configuration probes, or editor workflow.

## Catalog Publication

Use the binding in [state.md](../references/state.md#flavor-bindings). Publish `.imsight-arts/mentality/human-speak-han-style-principles.md` with the complete `Purpose`, `Principle Index`, `Communication Principles`, `Applicability and Judgment`, and `Provenance` sections of [han-style-principles.md](../references/han-style-principles.md). Include every Do / Don't comparison, judgment note, and the full license notice. Add a title, the entrance skill name, flavor identity, and an availability-only statement. Exclude workflow and activation state.

The declared source bundle is the entire Human Speak directory `references/sources/han-style/`, excluding other flavors' sources. Copy it under `.imsight-arts/mentality/sources/human-speak-han-style/<bundle-id>/` through the shared [offline publication contract](../../../references/runtime-injection.md#offline-source-bundles). Rewrite catalog links beginning `sources/han-style/` to that deployed bundle, preserving fragments; links inside the bundle remain relative.

The deployed catalog and sources must work without this installed skill, `extern/orphan`, or network access. Publishing the flavor provides definitions only; shared actions own project and agent-memory selection.

## Guardrails

- DO NOT prescribe a prose layout, sentence or paragraph quota, fixed response sequence, or personal writing voice through this flavor.
- DO NOT remove material conditions or uncertainty to make an explanation sound simpler.
- DO NOT turn these communication principles into extra investigation, testing, or a mandatory editing workflow.
- DO NOT activate upstream instructions by reading the source bundle.
- DO NOT enable this flavor through bare invocation or alter another flavor's state.
