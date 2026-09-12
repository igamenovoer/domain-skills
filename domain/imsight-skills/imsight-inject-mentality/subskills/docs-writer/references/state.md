# Docs Writer State and Selectors

## Workflow

1. Resolve current state from explicit current instructions, a managed `AGENTS.md` directive, a host record, visible conversation state, then the built-in unset state.
2. Normalize rule selectors according to **Selector Resolution**.
3. Validate the entire requested change before applying any transition.
4. Apply the transition and derive the effective rules.
5. Persist through the resolved application mode according to `../../../references/runtime-injection.md`; default to the managed `AGENTS.md` directive and synchronized Docs Writer rules artifact.
6. Report changed fields, effective rule IDs, persistence destination, and both project files when applicable.

If the task does not map cleanly to these steps, use the native planning tool to preserve atomic updates, independent enabled state and selection, and honest persistence scope.

## State Shape

The host-facing state envelope may contain multiple mentality namespaces. Docs Writer owns only its value:

```json
{
  "schema_version": 2,
  "mentalities": {
    "docs-writer": {
      "enabled": true,
      "rules": ["d1"]
    }
  }
}
```

The parent treats the Docs Writer value as opaque. Docs Writer must not inspect or modify sibling keys.

## Built-In State

When no state has ever been established:

- `enabled` is `false`;
- the retained selection is all canonical rules (currently `d1`);
- effective rules are empty because Docs Writer is disabled.

Enabled state and selection are independent:

```text
effective rules = selected rules when enabled; otherwise none
```

Disabling Docs Writer retains the selection. Editing rules while Docs Writer is disabled updates what the next enable operation will inject. `enable-all` and `disable-all` change selection only; they do not implicitly enable or disable Docs Writer.

## Selector Resolution

Selectors are case-insensitive and normalize to lowercase canonical codes.

| Selector | Expansion |
| --- | --- |
| `d1` | The `single-pass-revision` rule. |
| A canonical rule name | The corresponding single rule. |
| `all` | All canonical rules (currently `d1`). |
| `none` | Empty set; valid only for `edit set`. |

Canonical names are defined in [principles.md](principles.md). Accept hyphenated names and unambiguous natural variants, but report the canonical code in state and output.

Resolve all selectors before mutation. If any selector is unknown or ambiguous, make no change and list the valid codes and names. Duplicate selectors are idempotent.

## State Transitions

| Operation | Enabled | Retained selection |
| --- | --- | --- |
| Enable | Set to `true`. | Keep it; if absent, initialize to all rules. |
| Disable | Set to `false`. | Keep it unchanged. |
| Enable all | Unchanged. | Add all canonical rules. |
| Disable all | Unchanged. | Remove all canonical rules. |
| Edit add | Unchanged. | Union with resolved selectors. |
| Edit remove | Unchanged. | Subtract resolved selectors. |
| Edit set | Unchanged. | Replace with exactly the resolved selectors. |
| Edit reset | Unchanged. | Restore all canonical rules. |
| Status/list | Unchanged. | Unchanged. |

## Persistence Scope

Use the current turn's explicit instruction first. Otherwise resolve Docs Writer state from these sources in order:

1. A managed project-root `AGENTS.md` directive.
2. A valid state record supplied by a runtime adapter.
3. A prior explicit Docs Writer state established in visible conversation context.
4. The built-in unset state.

Project persistence and conversation persistence follow `../../../references/runtime-injection.md`. Use these labels:

- `project-rule-reference` for the default `AGENTS.md` directive plus referenced rules artifact;
- `project-rule-inline` for compact rules copied into `AGENTS.md` plus the same referenced rules artifact;
- `host-persisted` for an adapter-backed conversation record;
- `conversation-scoped` for visible-context-only state;
- `unset` when no state has been established.

A state-changing control command defaults to `project-rule-reference`, even when the user does not mention persistence. This representation consists of `<project>/AGENTS.md` and `<project>/.imsight-arts/mentality/docs-writer-rules.md`. Use `project-rule-inline` only for an explicit detail/copy request; it still maintains and references the rules artifact. "Remember" and "keep in memory" explicitly select conversation persistence instead of the default project files.

## Guardrails

- DO NOT partially apply a multi-selector request containing an invalid selector.
- DO NOT couple enabled state to `enable-all`, `disable-all`, or `edit` operations.
- DO NOT store aliases or groups in canonical state; store expanded rule codes.
- DO NOT mutate another mentality's namespace.
