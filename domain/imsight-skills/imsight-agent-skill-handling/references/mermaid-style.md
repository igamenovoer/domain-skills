# Mermaid Style

Use this reference whenever an `imsight-agent-skill-handling` subcommand writes Mermaid diagrams in Markdown reports or design documents.

## Core Rules

- Use one fenced `mermaid` block per diagram.
- Prefer portable Mermaid syntax; do not add theme or init blocks unless the user requests them.
- Keep node IDs short and stable; put readable text inside quoted labels.
- Use `<br/>` for deliberate label wrapping.
- Quote labels when they contain punctuation, slashes, parentheses, or `<br/>`.
- Keep each diagram focused on one purpose.

## Sequence Diagrams

Use `sequenceDiagram` for reader-facing process flow.

- Declare participants with short IDs and readable labels.
- Keep calls and returns as natural-language single sentences.
- Wrap long message labels with `<br/>`.
- Avoid semicolons in message labels.
- Prefer broad handoffs over minor validation steps.

Example:

```mermaid
sequenceDiagram
    autonumber
    actor U as User
    participant S as target-skill
    participant R as routed-subcommand

    U->>S: Ask the skill to inspect<br/>a target skill.
    S->>R: Build a self-contained<br/>design view.
    R-->>S: Return concepts, process,<br/>call graph, and evidence.
    S-->>U: Return the generated<br/>document path.
```

## Workflow Diagrams

Use `stateDiagram-v2` for lifecycle or control flow. Use `flowchart TD` when routing, handoffs, or caller-to-callee relationships matter more than state.

Do not overdraw every minor validation step. The diagram should make the major control flow clear.

Example:

```mermaid
stateDiagram-v2
    [*] --> Resolve_Input
    Resolve_Input --> Select_Path
    Select_Path --> Execute_Workflow
    Execute_Workflow --> Produce_Durable_Outputs
    Produce_Durable_Outputs --> [*]
```

## Skill Call Graphs

Use `flowchart TD` for skill call graphs.

- Use the primary analyzed skill or inspected skill as the root node.
- Represent public subcommands, modes, or external skills as skill nodes.
- Place a nested subcommand below its immediate parent command, label the edge with the full parenthesized invocation chain, and distinguish intermediate object generators from the terminal invoked command.
- Use route nodes when the route condition is important enough to name.
- Label edges with the trigger condition or explicit invocation form when that label helps the reader.
- Keep passive context files out of the graph unless they are runtime routing targets.
- Split the graph when it has more than roughly seven nodes in one row or more than two nested groups.

Use these classes when a subcommand needs styled callgraph nodes:

```mermaid
flowchart TD
    classDef skill fill:#eef6ff,stroke:#2563eb,stroke-width:1.5px,color:#111827
    classDef route fill:#f8fafc,stroke:#94a3b8,stroke-width:1px,color:#334155

    Entry["target<br/>skill"]:::skill
    Sub["public<br/>subcommand"]:::skill
    Ext["external<br/>skill"]:::skill
    RouteA["S1<br/>route name"]:::route
    RouteB["S2<br/>route name"]:::route

    Entry --> RouteA --> Sub
    Entry --> RouteB --> Ext
```

## Validation

- Check that every Mermaid fence opens and closes correctly.
- Check that sequence message labels do not contain semicolons.
- Check that flowchart labels with punctuation, slashes, parentheses, or `<br/>` are quoted.
- Check that nested command nodes preserve immediate-parent ownership and do not imply that an intermediate generator executes its standalone terminal action.
- Check that the diagram matches the surrounding step table or explanation.
