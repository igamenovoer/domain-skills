# Docs Writer Selectors and Scope Binding

## Workflow

1. Resolve the caller's action and scope through the shared [actions](../../../references/actions.md) and [runtime contract](../../../references/runtime-injection.md).
2. Normalize every supplied Docs Writer selector using **Selector Resolution** and the canonical [principles](principles.md).
3. Validate the complete selection before changing either project scope or this agent's memory.
4. Execute the shared action using Docs Writer IDs only; for recall or application, preserve the source scope of each effective principle.
5. Report canonical IDs, affected scope, and any unresolved state without mutating sibling mentalities.

If the task does not map cleanly to these steps, use the native planning tool to preserve atomic selector validation, explicit scope, and independent agent memory.

## Selector Resolution

| Selector | Expansion |
| --- | --- |
| `d1` | The `single-pass-revision` principle. |
| Canonical name | The corresponding principle, currently `single-pass-revision`. |
| `all` | Every canonical Docs Writer principle, currently `d1`. |

Selectors are case-insensitive and normalize to lowercase canonical IDs. Accept canonical hyphenated names and unambiguous natural variants. Expand selectors fully, remove duplicates, and retain catalog order for output. IDs are local to Docs Writer; a Brooks ID is invalid here.

Enable/disable actions require explicit selectors. Missing selectors do not mean `all`, and an empty request or `none` is not a selection mutation. Unknown or ambiguous selectors reject the entire request; list valid IDs and names without partial application. To disable every principle in a scope, use that scope's disable action with `all`.

## Scope Binding

The shared runtime contract defines state transitions and precedence once. Docs Writer supplies these bindings:

- Project artifact: `.imsight-arts/mentality/docs-writer-principles.md`.
- Catalog discovery marker key: `imsight-skill:imsight-mentality-mgr/docs-writer-catalog`.
- Project-selection marker key: `imsight-skill:imsight-mentality-mgr/docs-writer-project`.
- Agent-memory namespace: `docs-writer`, with separate explicit enabled and disabled rule sets.
- Built-in selection: no project rules and no memory overrides; deployment never changes that default.

Each principle independently follows this agent's explicit override, otherwise the project setting, otherwise disabled. A shared catalog does not impose one writing selection on every agent using the repository.

## Guardrails

- DO NOT partially apply a request containing an invalid selector.
- DO NOT store selector groups or aliases as canonical state.
- DO NOT default omitted selectors to every Docs Writer principle.
- DO NOT read or mutate another mentality's private state entry.
- DO NOT treat a missing memory override as an explicit disabled override.
