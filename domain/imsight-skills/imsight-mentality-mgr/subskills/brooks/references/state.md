# Brooks Selectors and Scope Binding

## Workflow

1. Resolve the caller's action and scope through the shared [actions](../../../references/actions.md) and [runtime contract](../../../references/runtime-injection.md), or the invocation-only criteria in [review](review.md).
2. Normalize every supplied Brooks selector using **Selector Resolution** and the canonical [principles](principles.md).
3. Validate the complete selection before changing either project scope or this agent's memory.
4. Execute the selected action using Brooks IDs only; for recall or application, preserve the project or agent-memory source of each effective principle. Review selectors name criteria without mutating either scope.
5. Report canonical IDs, affected scope, and any unresolved state without mutating sibling mentalities.

If the task does not map cleanly to these steps, use the native planning tool to preserve atomic selector validation, explicit scope, and independent agent memory.

## Selector Resolution

| Selector | Expansion |
| --- | --- |
| `r1` through `r6` | One production principle. |
| `t1` through `t6` | One test principle. |
| Canonical name | The corresponding principle, such as `dependency-direction`. |
| `production` | All six production principles. |
| `tests` | All six test principles. |
| `all` | All twelve Brooks principles. |

Selectors are case-insensitive and normalize to lowercase canonical IDs. Accept canonical hyphenated names and unambiguous natural variants. Resolve groups completely, remove duplicates, and retain catalog order for output. IDs are local to Brooks; a Docs Writer ID is invalid here.

Project enable/disable requires explicit selectors. Named memory enable/disable with omitted selectors expands to all current Brooks IDs under the shared action contract. A bare child invocation or `none` does not change selection. Unknown or ambiguous selectors reject the entire request; list valid codes, names, and groups without partial application.

Review accepts the same codes, names, and groups. Omitted review selectors use effective selection; explicit selectors replace review criteria for this invocation only. Uppercase upstream risk labels normalize to the same lowercase IDs and never create separate diagnostic state. Selection, applicability, and reporting details live in the review contract.

## Scope Binding

The shared runtime contract owns state transitions, precedence, and [definition retention](../../../references/runtime-injection.md#definition-retention). Brooks supplies these bindings:

- Project artifact: `.imsight-arts/mentality/brooks-principles.md`.
- Catalog discovery marker key: `imsight-skill:imsight-mentality-mgr/brooks-catalog`.
- Project-selection marker key: `imsight-skill:imsight-mentality-mgr/brooks-project`.
- Agent-memory namespace: `brooks`, with separate explicit enabled and disabled rule sets.
- Built-in selection: no project rules and no memory overrides; deployment never changes that default.

Do not resolve a shared mentality-wide activation flag. Each principle independently follows this agent's explicit override, otherwise the project setting, otherwise disabled. The same Brooks catalog can support different effective selections for several agents.

## Guardrails

- DO NOT partially apply a request containing an invalid selector.
- DO NOT store selector groups or aliases as canonical state.
- DO NOT default omitted project or review selectors to every Brooks principle.
- DO NOT read or mutate another mentality's private state entry.
- DO NOT treat a missing memory override as an explicit disabled override.
