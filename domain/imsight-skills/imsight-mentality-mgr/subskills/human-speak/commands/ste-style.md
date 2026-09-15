# STE Style

## Workflow

1. **Bind the named flavor** to `human-speak/ste-style`. This command is an explicit flavor choice for the current invocation only.
2. **Resolve the shared action** from the arguments or pending request. With no action, recall this flavor and show concise help; do not enable it.
3. **Resolve selectors and scope** using [state.md](../references/state.md) and the manager's [decision tree](../../../references/actions.md#enabledisable-decision-tree). Validate the complete request before mutation.
4. **Execute the shared action**, using **Catalog Publication** for deployment. For ordinary output with effective rules, use **Applying the Flavor**.
5. **Report actual scope and effects** through shared [Memory Confirmation](../../../references/runtime-injection.md#memory-confirmation) or the requested action's output contract.

If the task does not map cleanly to these steps, use the native planning tool to preserve the chosen flavor, validated rules, and scope, then execute the plan. This command supplies communication guidance without authorizing additional project work.

## Purpose

STE Style helps readers interpret a statement without guessing its terms, relationships, or strength. Its five readability principles do not enforce or certify ASD-STE100 compliance.

## Arguments

Supply an optional shared action followed by its normal arguments. Accepted actions are `deploy`, `enable-project`, `disable-project`, `enable-memory`, `disable-memory`, `recall`, and `help`. Natural `enable` and `disable` use the manager's agent-memory default unless project scope is explicit. Project rule actions require explicit selectors or `all`; memory rule actions with no selectors select all five current rules of this flavor.

For example, `imsight-mentality-mgr->human-speak->ste-style()` with arguments `enable-memory h1 h4` remembers stable-terminology and preserve-claim-strength for this agent. With `disable-project all`, it ensures deployment and reduces this flavor's entry to a reference-only catalog link, removing application text and family priority. The peer action `imsight-mentality-mgr->human-speak->enable-memory()` with arguments `ste-style h1 h4` resolves identically. Actions are arguments to the flavor command, not nested subcommands.

## Applying the Flavor

Resolve effective `h1`–`h5` selections and read and retain their [definitions, comparisons, and judgment notes](../references/ste-style-principles.md) through shared [Definition Retention](../../../references/runtime-injection.md#definition-retention). Use selected rules to keep terminology consistent, make relevant relationships explicit, express actions directly, preserve what claims commit to, and retain enough wording for clarity.

Apply the guidance during ordinary human-facing writing. The agent chooses prose structure, voice, punctuation, sentence lengths, and reference placement subject to the user's request and existing instructions. No strict/flavored modes, fixed vocabulary, word quotas, blanket grammar bans, mandatory linting, or separate rewrite workflow belong to this flavor. Examples teach meaning and judgment rather than output templates.

This flavor adds no review, configuration, intensity, or code-edit action. It can guide a separately authorized review's presentation without performing the review. Human Speak's human-facing scope remains in force.

## Catalog Publication

Use the binding in [state.md](../references/state.md#flavor-bindings). Publish `.imsight-arts/mentality/human-speak-ste-style-principles.md` with the complete `Purpose`, `Principle Index`, `Communication Principles`, and `Applicability and Judgment` sections of [ste-style-principles.md](../references/ste-style-principles.md). Include every original Do / Don't comparison and judgment note. Add a title, the entrance skill name, flavor identity, and an availability-only statement. Exclude workflow, activation state, external reference tables, and third-party material.

The deployed catalog must work without this installed skill, `extern/orphan`, or network access. Publish no source directory or upstream files. Shared actions own project and agent-memory selection.

## References

These optional links identify conceptual background and the rules it concerns. Open them only for an explicit source or attribution request. Applying, enabling, recalling, and deploying this flavor use its maintained definitions alone. This section stays in the skill and is excluded from project catalogs.

| Reference | Rules concerned |
| --- | --- |
| [Dustin Yuchen Teng asd-ste100 skill](https://github.com/danyuchn/asd-ste100-skill/blob/7d4a135a199a5d7447c4886bcd7ffe742a627bc9/SKILL.md) | h1–h5: consistent terminology, explicit relationships, direct language, claim strength, and clarity. |
| [Writing-rule summary](https://github.com/danyuchn/asd-ste100-skill/blob/7d4a135a199a5d7447c4886bcd7ffe742a627bc9/references/writing-rules.md) | h1–h5: ambiguity-reduction concepts; strict structural requirements are outside this flavor. |
| [Before/after discussions](https://github.com/danyuchn/asd-ste100-skill/blob/7d4a135a199a5d7447c4886bcd7ffe742a627bc9/examples/before-after.md) | h2, h4, h5: conditions, uncertainty, and preserving meaning. These examples are not bundled or reused. |

## Guardrails

- DO NOT claim that applying this flavor or passing an upstream linter establishes ASD-STE100 compliance.
- DO NOT impose strict STE word lists, grammar bans, length limits, or prose structure through this flavor.
- DO NOT add facts, strengthen requirements, or create extra task work to improve readability.
- DO NOT enable this flavor through bare invocation or alter another flavor's state.
