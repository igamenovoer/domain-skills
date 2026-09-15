# Agile Experimenter Selectors and Scope Binding

## Workflow

1. Resolve the action and scope through the shared [actions](../../../references/actions.md) and [runtime contract](../../../references/runtime-injection.md).
2. Normalize every supplied selector using **Selector Resolution** and the canonical [principle index](principles.md#principle-index).
3. Validate the complete selection before changing project scope or this agent's memory.
4. Execute the shared action using Agile Experimenter IDs only, or resolve task applicability for ordinary work.
5. Report canonical IDs and their source scope without mutating sibling mentalities or experiment plans.

If the task does not map cleanly to these steps, use the native planning tool to preserve the requested scope, validated selectors, and independent agent memory without inventing state changes.

## Selector Resolution

| Selector | Expansion |
| --- | --- |
| `e1` through `e6` | One experiment principle from the canonical index. |
| Canonical name | The corresponding principle, such as `decision-scale-precision`. |
| `all` | All six Agile Experimenter principles in catalog order. |

Selectors are case-insensitive and normalize to lowercase canonical IDs. Accept canonical hyphenated names and unambiguous natural variants. Expand completely, remove duplicates, and preserve catalog order. IDs belong to this mentality; another child's IDs are invalid here.

Use the shared [enable/disable decision tree](../../../references/actions.md#enabledisable-decision-tree): omitted scope means agent memory, and omitted memory selectors expand to all current Agile Experimenter IDs. Project enable/disable requires explicit selectors and includes required deployment and `AGENTS.md` updates. A bare child invocation or `none` does not change selection. Unknown or ambiguous selectors reject the entire request without partial changes. List the valid IDs and names when correction is needed.

## Scope Binding

The shared runtime owns state transitions, precedence, and [definition retention](../../../references/runtime-injection.md#definition-retention). This child supplies only these bindings:

- Project artifact: `.imsight-arts/mentality/agile-experimenter-principles.md`.
- Catalog discovery marker key: `imsight-skill:imsight-mentality-mgr/agile-experimenter-catalog`.
- Project-selection marker key: `imsight-skill:imsight-mentality-mgr/agile-experimenter-project`.
- Agent-memory namespace: `agile-experimenter`, with separate explicit enabled and disabled rule sets.
- Built-in selection: no project rules and no memory overrides; deployment enables nothing.

No child settings or intensity presets are defined. Experiment-specific resolution and preparation budgets belong to the current task, not a new persistent configuration layer. Preserve agent-memory overrides across project actions; effective selection never authorizes a new experiment or changes another agent's memory.

## Guardrails

- DO NOT partially apply invalid or ambiguous selections.
- DO NOT store selector aliases or groups as canonical state.
- DO NOT infer selection or experiment authority from catalog availability.
- DO NOT copy one agent's effective rules into project selection or another agent's memory.
