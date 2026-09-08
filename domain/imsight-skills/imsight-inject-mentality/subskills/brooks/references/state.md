# Brooks State and Selectors

## Workflow

1. Resolve the current state from a host record, then visible conversation state, then the built-in unset state.
2. Normalize rule selectors according to **Selector Resolution**.
3. Validate the entire requested change before applying any state transition.
4. Apply the transition and derive the effective rules.
5. Report the changed fields and the actual persistence scope.

If the task does not map cleanly to these steps, use the native planning tool to preserve atomic updates, independent activation and selection, and honest persistence scope.

## State Shape

The host-facing state envelope may contain multiple mentality namespaces. Brooks owns only its value:

```json
{
  "schema_version": 1,
  "mentalities": {
    "brooks": {
      "active": true,
      "rules": ["r1", "r2", "r3", "r5", "r6", "t1", "t2"]
    }
  }
}
```

The parent treats the Brooks value as opaque. Brooks must not inspect or modify sibling keys.

## Built-In State

When no state has ever been established:

- `active` is `false`;
- the retained selection is all twelve canonical rules;
- effective rules are empty because Brooks is inactive.

Activation and selection are independent:

```text
effective rules = selected rules when active; otherwise none
```

Turning Brooks off retains the selection. Changing rules while Brooks is off updates what the next activation will inject.

## Selector Resolution

Selectors are case-insensitive and normalize to lowercase canonical codes.

| Selector | Expansion |
| --- | --- |
| `r1` through `r6` | One production rule. |
| `t1` through `t6` | One test rule. |
| A canonical rule name | The corresponding single rule. |
| `production` | `r1` through `r6`. |
| `tests` | `t1` through `t6`. |
| `all` | All twelve rules. |
| `none` | Empty set; valid only for the set operation. |

Canonical names are defined in [principles.md](principles.md). Accept hyphenated names and unambiguous natural variants, but report the canonical code in state and output.

Resolve all selectors before mutation. If any selector is unknown or ambiguous, make no change and list the valid codes, names, and groups. Duplicate selectors are idempotent.

## State Transitions

| Operation | Active | Retained selection |
| --- | --- | --- |
| On | Set to `true`. | Keep it; if absent, initialize to all rules. |
| Off | Set to `false`. | Keep it unchanged. |
| Rules add | Unchanged. | Union with resolved selectors. |
| Rules remove | Unchanged. | Subtract resolved selectors. |
| Rules set | Unchanged. | Replace with exactly the resolved selectors. |
| Rules reset | Unchanged. | Restore all twelve rules. |
| Status/list | Unchanged. | Unchanged. |

## Persistence Scope

Use these state sources in order:

1. A valid state record supplied by a runtime adapter.
2. A prior explicit Brooks state established in visible conversation context.
3. The built-in unset state.

Label state as `host-persisted` only when the host supplied it. Otherwise label it `session-scoped`. Never write a state file merely because a control command was invoked.

## Guardrails

- DO NOT partially apply a multi-selector request containing an invalid selector.
- DO NOT couple activation to add, remove, set, or reset operations.
- DO NOT store aliases or groups in canonical state; store expanded rule codes.
- DO NOT mutate another mentality's namespace.
