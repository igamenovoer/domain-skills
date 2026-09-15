# Mark-Life Style

## Workflow

1. **Bind the named flavor** to `human-speak/mark-life-style`. This command is an explicit flavor choice for the current invocation only.
2. **Resolve the shared action** from the arguments or pending request. With no action, recall this flavor and show concise help; do not enable it.
3. **Resolve selectors and scope** using [state.md](../references/state.md) and the manager's [decision tree](../../../references/actions.md#enabledisable-decision-tree). Validate the complete request before mutation.
4. **Execute the shared action**, using **Catalog Publication** for deployment. For ordinary output with effective rules, use **Applying the Flavor**.
5. **Report actual scope and effects** through shared [Memory Confirmation](../../../references/runtime-injection.md#memory-confirmation) or the requested action's output contract.

If the task does not map cleanly to these steps, use the native planning tool to preserve the chosen flavor, validated rules, and scope. This command supplies a communication pattern, not authorization for additional project work.

## Purpose

Mark-Life Style treats the reader's attention as scarce. Put the conclusion where it is easy to find, retain useful evidence and limits, and make the surrounding language easy to read.

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

Use the binding in [state.md](../references/state.md#flavor-bindings). Publish `.imsight-arts/mentality/human-speak-mark-life-style-principles.md` with the complete `Purpose`, `Principle Index`, `Communication Principles`, and `Applicability and Judgment` sections of [mark-life-style-principles.md](../references/mark-life-style-principles.md). Include every original Do / Don't comparison and judgment note. Add a title, the entrance skill name, flavor identity, and an availability-only statement. Exclude workflow, activation state, external reference tables, and third-party material.

The deployed catalog must work without this installed skill, `extern/orphan`, or network access. Publish no source directory or upstream files. Shared actions own project and agent-memory selection.

## References

These optional links identify conceptual background and the rules it concerns. Open them only for an explicit source or attribution request. Applying, enabling, recalling, and deploying this flavor use its maintained definitions alone. This section stays in the skill and is excluded from project catalogs.

| Reference | Rules concerned |
| --- | --- |
| [Mark-Life agent-to-human](https://github.com/Mark-Life/agent-skills/blob/0696ebb51867d4a89ce747527e4899f5306ed464/skills/communication/agent-to-human/SKILL.md) | h1–h8: answer priority, relevant detail, evidence status, language, sentence focus, actors, layout, and references. |

## Guardrails

- DO NOT claim tests, observations, or tool results that were not obtained.
- DO NOT treat sentence-length or list-size heuristics as fixed quotas.
- DO NOT remove requested depth or material uncertainty merely to shorten an answer.
- DO NOT enable this flavor through inspection or invocation without an action.
- DO NOT change another flavor's selections through this command.
