# Han Style

## Workflow

1. **Bind the named flavor** to `human-speak/han-style`. This command is an explicit flavor choice for the current invocation only.
2. **Resolve the shared action** from the arguments or pending request. With no action, recall this flavor and show concise help; do not enable it.
3. **Resolve selectors and scope** using [state.md](../references/state.md) and the manager's [decision tree](../../../references/actions.md#enabledisable-decision-tree). Validate the complete request before mutation.
4. **Execute the shared action**, using **Catalog Publication** for deployment. For ordinary output with effective rules, use **Applying the Flavor**.
5. **Report actual scope and effects** through shared [Memory Confirmation](../../../references/runtime-injection.md#memory-confirmation) or the requested action's output contract.

If the task does not map cleanly to these steps, use the native planning tool to preserve the chosen flavor, validated rules, and scope, then execute the plan. This command supplies a communication pattern, not authorization for additional project work.

## Purpose

Han Style helps a capable reader understand an answer without reconstructing the agent's context. Its five principles leave prose structure and personal writing voice to the agent.

## Arguments

Supply an optional shared action followed by its normal arguments. Accepted actions are `deploy`, `enable-project`, `disable-project`, `enable-memory`, `disable-memory`, `recall`, and `help`. Natural `enable` and `disable` use the manager's agent-memory default unless project scope is explicit. Project rule actions require explicit selectors or `all`; memory rule actions with no selectors select all five current rules of this flavor.

For example, `imsight-mentality-mgr->human-speak->han-style()` with arguments `enable-memory h1 h5` remembers reader-context and preserve-precision for this agent. With `disable-project all`, it ensures deployment and removes this flavor's application block. The peer action `imsight-mentality-mgr->human-speak->enable-memory()` with arguments `han-style h1 h5` resolves identically. Actions are arguments to the flavor command, not nested subcommands.

## Applying the Flavor

Resolve effective `h1`–`h5` selections and read and retain their [definitions, comparisons, and judgment notes](../references/han-style-principles.md) through shared [Definition Retention](../../../references/runtime-injection.md#definition-retention). Use selected rules to consider the reader's context, the answer they need, the connections they must understand, and the precision they need to act.

Apply those considerations during the task's ordinary writing. The agent chooses headings, paragraphs, lists, tables, sentence lengths, voice, and placement of technical references subject to the user's request and existing instructions. These rules supply no fixed response sequence, mandatory self-check, rewrite pass, review agent, or additional testing or research phase. Examples teach meaning and judgment; their arrangement is not an output template.

This flavor adds no review, configuration, intensity, or code-edit action. It can guide a separately authorized review's presentation without performing that review itself.

## Catalog Publication

Use the binding in [state.md](../references/state.md#flavor-bindings). Publish `.imsight-arts/mentality/human-speak-han-style-principles.md` with the complete `Purpose`, `Principle Index`, `Communication Principles`, and `Applicability and Judgment` sections of [han-style-principles.md](../references/han-style-principles.md). Include every original Do / Don't comparison and judgment note. Add a title, the entrance skill name, flavor identity, and an availability-only statement. Exclude workflow, activation state, external reference tables, and third-party material.

The deployed catalog must work without this installed skill, `extern/orphan`, or network access. Publish no source directory or upstream files. Shared actions own project and agent-memory selection.

## References

These optional links identify conceptual background and the rules it concerns. Open them only for an explicit source or attribution request. Applying, enabling, recalling, and deploying this flavor use its maintained definitions alone. This section stays in the skill and is excluded from project catalogs.

| Reference | Rules concerned |
| --- | --- |
| [Han readability rule](https://github.com/testdouble/han/blob/a86259a348dd0ec8a04b0357dd33753a36f38c2d/han-communication/references/readability-rule.md) | h1–h5: reader context, answer clarity, connected ideas, technical meaning, and precision. |
| [Han writing voice](https://github.com/testdouble/han/blob/a86259a348dd0ec8a04b0357dd33753a36f38c2d/han-communication/references/writing-voice.md) | h1, h3, h4: audience awareness, connected explanation, and concrete language; no persona or layout requirement is imported. |

## Guardrails

- DO NOT prescribe a prose layout, sentence or paragraph quota, fixed response sequence, or personal writing voice through this flavor.
- DO NOT remove material conditions or uncertainty to make an explanation sound simpler.
- DO NOT turn these communication principles into extra investigation, testing, or a mandatory editing workflow.
- DO NOT enable this flavor through bare invocation or alter another flavor's state.
