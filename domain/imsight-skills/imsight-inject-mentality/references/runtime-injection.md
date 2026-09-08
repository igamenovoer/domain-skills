# Runtime Injection and Persistence

## Workflow

1. Resolve state from a host-provided session record when one is available.
2. Otherwise, use only valid state established in the visible conversation and mark it session-scoped.
3. Ask each active mentality whether it applies to the current task.
4. Inject the compact rendering before the agent plans or edits, and keep it in force through verification.
5. After context compaction, ask the host for state and render the active mentalities again.

If the task does not map cleanly to these steps, use the native planning tool to preserve honest state scope and avoid fabricating persistence.

## Host Adapter Contract

A reliable Ponytail-like integration needs a host adapter that can:

- store independent state namespaces for each mentality;
- route state operations to the named mentality;
- provide the current task to each child for applicability checks;
- request and inject fresh compact renderings on applicable turns;
- restore state and reinject guidance after context compaction;
- distinguish session state from optional durable user defaults.

The adapter owns storage and lifecycle hooks. The skill owns meaning, routing, state transitions, and rendering.

## Standalone Behavior

Without an adapter, the agent may honor an activation and rule selection while that state remains available in conversation context. It must describe that state as conversation- or session-scoped, not durable. If the prior state is missing or ambiguous, report it as unset rather than assuming that a mentality is active.

## Guardrails

- DO NOT write state into a repository, user home, or global configuration unless the user separately requests that storage behavior.
- DO NOT imply that a skill invocation alone installs lifecycle hooks.
- DO NOT reconstruct missing state from guesses after context loss.
