# Brooks State and Selectors

## Workflow

1. Resolve current state from explicit current instructions, an applicable project-rule directive, a host record, visible conversation state, then the built-in unset state.
2. Normalize rule selectors according to **Selector Resolution**.
3. Validate the entire requested change before applying any transition.
4. Apply the transition and derive the effective rules.
5. Persist through the resolved application mode according to `../../../references/runtime-injection.md`; default to the compact project index.
6. Report changed fields, effective rule IDs, persistence destination, and project representation when applicable.

If the task does not map cleanly to these steps, use the native planning tool to preserve atomic updates, independent enabled state and selection, and honest persistence scope.

## State Shape

The host-facing state envelope may contain multiple mentality namespaces. Brooks owns only its value:

```json
{
  "schema_version": 2,
  "mentalities": {
    "brooks": {
      "enabled": true,
      "rules": ["r1", "r2", "r3", "r5", "r6", "t1", "t2"]
    }
  }
}
```

The parent treats the Brooks value as opaque. Brooks must not inspect or modify sibling keys. A legacy schema-version-1 Brooks value may be migrated by mapping `active` to `enabled` and preserving its canonical `rules`; write only schema version 2 afterward.

## Built-In State

When no state has ever been established:

- `enabled` is `false`;
- the retained selection is all twelve canonical rules;
- effective rules are empty because Brooks is disabled.

Enabled state and selection are independent:

```text
effective rules = selected rules when enabled; otherwise none
```

Disabling Brooks retains the selection. Editing rules while Brooks is disabled updates what the next enable operation will inject. `enable-all` and `disable-all` change selection only; they do not implicitly enable or disable Brooks.

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
| `none` | Empty set; valid only for `edit set`. |

Canonical names are defined in [principles.md](principles.md). Accept hyphenated names and unambiguous natural variants, but report the canonical code in state and output.

Resolve all selectors before mutation. If any selector is unknown or ambiguous, make no change and list the valid codes, names, and groups. Duplicate selectors are idempotent.

## State Transitions

| Operation | Enabled | Retained selection |
| --- | --- | --- |
| Enable | Set to `true`. | Keep it; if absent, initialize to all rules. |
| Disable | Set to `false`. | Keep it unchanged. |
| Enable all | Unchanged. | Add all twelve canonical rules. |
| Disable all | Unchanged. | Remove all canonical rules. |
| Edit add | Unchanged. | Union with resolved selectors. |
| Edit remove | Unchanged. | Subtract resolved selectors. |
| Edit set | Unchanged. | Replace with exactly the resolved selectors. |
| Edit reset | Unchanged. | Restore all twelve rules. |
| Status/list | Unchanged. | Unchanged. |

## Persistence Scope

Use the current turn's explicit instruction first. Otherwise resolve Brooks state from these sources in order:

1. An applicable project-rule directive.
2. A valid state record supplied by a runtime adapter.
3. A prior explicit Brooks state established in visible conversation context.
4. The built-in unset state.

Project persistence and conversation persistence follow `../../../references/runtime-injection.md`. Use these labels:

- `project-rule-reference` for the default skill-and-ID directive;
- `project-rule-inline` for explicitly copied compact rules;
- `host-persisted` for an adapter-backed conversation record;
- `conversation-scoped` for visible-context-only state;
- `unset` when no state has been established.

A state-changing control command defaults to `project-rule-reference`, even when the user does not mention persistence. Use `project-rule-inline` only for an explicit detail/copy request. “Remember” and “keep in memory” explicitly select conversation persistence instead of the default project file.

## Guardrails

- DO NOT partially apply a multi-selector request containing an invalid selector.
- DO NOT couple enabled state to `enable-all`, `disable-all`, or `edit` operations.
- DO NOT store aliases or groups in canonical state; store expanded rule codes.
- DO NOT mutate another mentality's namespace.
- DO NOT treat a legacy `on`, `off`, or nested `rules` invocation as a current command.
