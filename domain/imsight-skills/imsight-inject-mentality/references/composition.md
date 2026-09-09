# Mentality Composition

## Workflow

1. Obtain the registered mentality children from the parent entrypoint.
2. Ask each child for enabled state and current-task applicability without inspecting its private state schema.
3. Request a compact rendering only from children that are both enabled and applicable.
4. Combine the named renderings in registration order and apply **Conflict Resolution**.
5. Return the composition to the requesting host or use it for the current task.

If the task does not map cleanly to these steps, use the native planning tool to compose only the available child renderings while preserving the contracts on this page.

## Child Rendering Contract

Each mentality rendering contains:

- the mentality name;
- a compact set of actionable reminders derived from its current private state;
- no state mutation;
- no claim of authority over the user's task.

The parent may add headings and remove exact duplicate lines, but it does not rewrite a child's meaning or infer guidance for a disabled child.

## Conflict Resolution

Resolve conflicts in this order:

1. System, developer, user, repository, safety, permission, and tool instructions.
2. Explicit requirements of the current task.
3. The compatible subset of enabled mentality guidance.

When two mentalities remain materially incompatible, preserve their named boundaries, choose the result that best satisfies the task, and state the tradeoff. Do not invent numeric priority in the absence of a configured policy.

## Guardrails

- DO NOT enable, disable, or reconfigure a mentality while composing it.
- DO NOT include disabled or inapplicable mentality guidance.
- DO NOT merge private state schemas into a parent-wide rule model.
