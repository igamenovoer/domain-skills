# Docs Writer Selectors and Scope Binding

## Workflow

1. Resolve action and scope through [shared actions](../../../references/actions.md).
2. Normalize selectors below against [principles.md](principles.md); validate the whole request.
3. Execute with this family's IDs, preserving scope provenance and other families' state.

For other requests, use the native planning tool without inventing activation.

## Selector Resolution

| Selector | Meaning |
| --- | --- |
| `d1` / `single-pass-revision` | The writing principle. |
| `all` | All current rules, currently `d1`. |

Accept case-insensitive IDs, canonical hyphenated names, and unambiguous natural variants. Expand groups, deduplicate, and report in catalog order. Foreign IDs or ambiguous/unknown selectors reject the whole request; list valid choices. Store canonical IDs, not aliases.

Use [shared defaults](../../../references/actions.md#enabledisable-decision-tree): omitted enable/disable scope means memory; omitted memory selectors mean all current IDs; project actions require selectors. Bare invocation and `none` change no selection.

This child has no additional configuration or review action.

## Scope Binding

- Catalog: `.imsight-arts/mentality/docs-writer-principles.md`.
- Family entry in the [unified section](../../../references/runtime-injection.md#unified-mentality-section) and memory namespace: `docs-writer`.
- Defaults: no selected rules or memory overrides; deployment enables nothing.

Use shared precedence and [definition retention](../../../references/runtime-injection.md#definition-retention). Absence of a memory override means inherit, not explicit disable.

## Guardrails

- DO NOT partially apply invalid selections or mutate another family's state.
- DO NOT infer activation from catalog availability or store aliases as canonical state.
