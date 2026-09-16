# Brooks Selectors and Scope Binding

## Workflow

1. Resolve action and scope through [shared actions](../../../references/actions.md).
2. Normalize selectors below against [principles.md](principles.md); validate the whole request.
3. Execute with this family's IDs, preserving scope provenance and other families' state.

For other requests, use the native planning tool without inventing activation.

## Selector Resolution

| Selector | Meaning |
| --- | --- |
| `r1`–`r6` | Individual production rules. |
| `t1`–`t6` | Individual test rules. |
| Canonical name | Its corresponding rule. |
| `production` / `tests` | All six rules in that group. |
| `all` | All twelve rules. |

Accept case-insensitive IDs, canonical hyphenated names, and unambiguous natural variants. Expand groups, deduplicate, and report in catalog order. Foreign IDs or ambiguous/unknown selectors reject the whole request; list valid choices. Store canonical IDs, not aliases.

Use [shared defaults](../../../references/actions.md#enabledisable-decision-tree): omitted enable/disable scope means memory; omitted memory selectors mean all current IDs; project actions require selectors. Bare invocation and `none` change no selection.

Review uses the same selectors; omitted criteria mean effective rules, explicit criteria replace them for one review. Uppercase risk codes normalize to the same IDs. See [review.md](review.md).

## Scope Binding

- Catalog: `.imsight-arts/mentality/brooks-principles.md`.
- Family entry in the [unified section](../../../references/runtime-injection.md#unified-mentality-section) and memory namespace: `brooks`.
- Defaults: no selected rules or memory overrides; deployment enables nothing.

Use shared precedence and [definition retention](../../../references/runtime-injection.md#definition-retention). Absence of a memory override means inherit, not explicit disable.

## Guardrails

- DO NOT partially apply invalid selections or mutate another family's state.
- DO NOT infer activation from catalog availability or store aliases as canonical state.
