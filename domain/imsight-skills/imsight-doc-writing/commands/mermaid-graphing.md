# Mermaid Graphing

Create Mermaid diagrams that read well inside Markdown documents and survive common renderer differences. Optimize first for portable syntax, compact layout, and stable labels; use optional styling only after the diagram is structurally clean.

## Workflow

When this subskill is invoked, execute the following steps in order.

1. **Choose the diagram type**. Use the **Diagram Selection** table to map the user's documentation goal to a Mermaid diagram family.
2. **Draft the smallest useful diagram**. Include the main actors, states, entities, or steps needed for the reader's decision; split the diagram if one view becomes crowded.
3. **Apply the portable style rules**. See **Markdown Embedding**, **Layout Rules**, and the diagram-specific section for the selected type. For sequence diagrams, use the technical-plus-chat default unless the user explicitly requests technical-only messages.
4. **Check renderer risks**. Use **Troubleshooting Rules** before shipping, especially when labels include HTML breaks, punctuation, or quoted strings.
5. **Place the diagram in context**. Add or edit only the surrounding prose needed to make the diagram's purpose clear.
6. **Validate when feasible**. Preview in the target Markdown renderer or Mermaid Live Editor when syntax, theme support, or layout is uncertain.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the diagram types and style constraints below, then execute the plan.

## Diagram Selection

| Diagram Type | Use For | Preferred Direction |
| --- | --- | --- |
| `flowchart` | Workflows, decision trees, pipelines, architecture boxes, ownership boundaries | `TD` for layered flow; `LR` only when each column is short |
| `sequenceDiagram` | Calls, messages, request lifecycles, agent/tool interactions, handoffs over time | Native sequence layout |
| `stateDiagram-v2` | Lifecycle states, modes, transitions, allowed status changes | Native state layout |
| `classDiagram` | Type relationships, interfaces, implementation inheritance, conceptual object models | Native class layout |
| `erDiagram` | Data entities, table relationships, cardinality, schema sketches | Native ER layout |
| `timeline` | Historical milestones, release phases, project chronology | Native timeline layout |
| `gantt` | Date-bound schedules with dependencies | Native Gantt layout |

Prefer `flowchart` for explanatory architecture unless time ordering is the point. Prefer `sequenceDiagram` when the reader needs to see who does what in what order. Prefer splitting a crowded diagram into "overview" and "detail" diagrams over forcing every fact into one block.

## Markdown Embedding

Always use fenced Markdown with the `mermaid` info string and keep one Mermaid diagram per fence:

````markdown
```mermaid
flowchart TD
    Start["Receive request"] --> Route["Choose doc-writing<br/>subskill"]
    Route --> Write["Draft or edit<br/>the artifact"]
```
````

Do not mix Mermaid syntax with normal Markdown inside the same fence. Keep the Mermaid diagram keyword exact for the chosen diagram family; `sequenceDiagram` is case-sensitive in many renderers.

## Portable Styling

Use content and layout as the primary style. Optional Mermaid theme initialization can be used when the target renderer supports it, but the diagram must still work if the init block is removed.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'fontFamily': 'ui-sans-serif, system-ui, sans-serif', 'fontSize': '14px'}}}%%
flowchart TD
    A["Short label"] --> B["Wrapped label<br/>with detail"]
```

When compatibility matters, omit the init block and rely on short IDs, quoted labels, line breaks, and split diagrams. Avoid renderer-specific CSS tricks unless the target documentation system is known to support them.

## Layout Rules

- Keep IDs short and stable; put readable text in labels.
- Wrap labels with `<br/>`; do not use raw `\n` escapes for line breaks.
- Do not break class names, function names, command names, table names, or other identifiers across lines.
- Wrap around separators, arguments, or parenthetical context instead: `load_bundle<br/>(scene,camera,actors)` is acceptable; `load_bun<br/>dle` is not.
- Keep labels visually balanced: one to three short lines usually reads better than one long line or a stack of fragments.
- Split diagrams when a flow has more than roughly seven nodes in one row, more than two nested control blocks, or long repeated labels.
- Remove decorative detail that does not help the document's reader make a decision.

## Flowcharts

Use `flowchart TD` by default. Use `LR` only for short, linear pipelines or compact system boundary diagrams.

Quote node labels whenever a label contains `<br/>`, parentheses, colons, slashes, commas, quotes, or other punctuation:

```mermaid
flowchart TD
    Req["User request<br/>diagram needed"] --> Pick["Select diagram type"]
    Pick --> Draft["Draft compact graph"]
    Draft --> Check{"Renderer risk?"}
    Check -->|Yes| Fix["Quote labels<br/>and simplify syntax"]
    Check -->|No| Ship["Place in Markdown"]
```

Use subgraphs for meaningful boundaries, not decoration. Keep subgraph titles short and avoid placing too many nodes inside one subgraph.

```mermaid
flowchart TD
    subgraph Skill["Doc-writing skill"]
        Entry["Route task"] --> Mermaid["Mermaid graphing"]
    end
    subgraph Output["Documentation"]
        Mermaid --> Fence["Fenced mermaid block"]
    end
```

## Sequence Diagrams

Declare participants at the top with short IDs and readable labels. Wrap the label, not the ID.

### Default: technical operation plus chat

For every message between distinct actors, including calls, replies, and asynchronous notifications, put the technical operation in literal square brackets, followed by a rendered newline and a double-quoted conversational message. Use `<br/>` for the newline and keep the Mermaid message on one source line:

```text
A->>B: [Technical operation]<br/>"Plain-language message from A to B."
```

Write the quoted line as something the sender would say to the receiver, not as a third-person description. Explain the request, handoff, or result in everyday language while preserving the technical meaning in the first line. Name the relevant data or action instead of relying on unclear pronouns such as "these". The quote is an explanatory paraphrase, not a literal wire payload or log entry.

Preserve direction, ordering, identifiers, arguments, and conditions. In particular, a request to queue work must not become a claim that the work has completed, and an acknowledgment must not invent a guarantee absent from the source. Self-messages may use the same format as self-talk, but the two-part requirement applies to messages between actors; participant names, notes, and control-block titles do not need dialogue.

```mermaid
sequenceDiagram
    participant U as User
    participant D as Doc-writing<br/>skill
    participant M as Mermaid<br/>subskill
    U->>D: [Diagram insertion request]<br/>"Add a diagram to this document."
    D->>M: [Diagram construction]<br/>"Show who calls whom."
    M-->>D: [Mermaid source]<br/>"Here is the sequence diagram."
    D-->>U: [Document update]<br/>"The diagram is in your document."
```

Keep arrow text concise, ideally under about 40 characters per visual line. Wrap either part with additional `<br/>` breaks when needed, while keeping identifiers intact. Shorten paraphrases or split crowded diagrams instead of dropping the conversational line. A call can retain its exact identifier and arguments:

```mermaid
sequenceDiagram
    participant A as Agent
    participant T as Tool
    A->>T: [render_diagram(type, labels)]<br/>"Render this sequence for me."
    T-->>A: [Preview result]<br/>"The preview is ready."
```

### Explicit opt-out: technical-only messages

Use ordinary technical-only sequence messages only when the user explicitly requests that style, for example "no chat style in seq diagram", "use normal seq diagram", or "use only technical representation in seq diagram". Equivalent requests count; exact wording is not required. Apply the opt-out to the diagrams or task the user specifies, keeping the technical content and omitting the explanatory quotes and style-only brackets.

A request for a "sequence diagram" or "UML diagram", a technical audience, brevity, or an existing diagram with bare technical labels is not by itself an opt-out. Do not switch styles on those grounds. With an explicit technical-only request, the preceding tool exchange becomes:

```mermaid
sequenceDiagram
    participant A as Agent
    participant T as Tool
    A->>T: render_diagram(type, labels)
    T-->>A: Preview result
```

Use `alt`, `else`, `opt`, `loop`, and `par` for control flow, but keep block titles short. If a sequence needs more than two nested control blocks, split it into a high-level diagram and a focused detail diagram.

## State Diagrams

Use state diagrams when the doc explains allowed transitions. Keep state names noun-like and transitions verb-like.

```mermaid
stateDiagram-v2
    [*] --> Draft
    Draft --> Reviewed: request review
    Reviewed --> Revised: changes needed
    Reviewed --> Published: approved
    Revised --> Reviewed: resubmit
```

If a state label needs detail, use an alias and a quoted label:

```mermaid
stateDiagram-v2
    state "Draft<br/>not validated" as Draft
    state "Published<br/>reader-ready" as Published
    Draft --> Published: approve
```

## Class And ER Diagrams

Use `classDiagram` for type relationships and `erDiagram` for data relationships. These diagram types get unreadable quickly, so show only the relationships relevant to the surrounding prose.

```mermaid
classDiagram
    class Skill {
        +name
        +description
    }
    class Subskill {
        +workflow
    }
    Skill "1" --> "*" Subskill : routes to
```

```mermaid
erDiagram
    DOCUMENT ||--o{ DIAGRAM : contains
    DIAGRAM }o--|| STYLE_RULE : follows
```

Avoid long method lists, full database schemas, and incidental fields. If the reader needs a complete schema, write a table and use the diagram only for relationships.

## Timeline And Gantt Diagrams

Use `timeline` for narrative chronology and `gantt` for actual schedules. Do not invent dates. If the user provides relative dates, convert them to explicit dates before writing a Gantt chart when the document depends on calendar accuracy.

```mermaid
timeline
    title Documentation Rollout
    Drafting : Outline and diagrams
    Review : Technical accuracy pass
    Publish : Merge into docs
```

```mermaid
gantt
    title Documentation Rollout
    dateFormat  YYYY-MM-DD
    section Docs
    Draft outline      :a1, 2026-06-22, 2d
    Review diagrams    :after a1, 1d
    Publish update     :after a1, 1d
```

## Troubleshooting Rules

- If a flowchart parse error points at `end`, inspect the node line above the subgraph boundary first.
- If a flowchart label uses `<br/>` or punctuation, quote the label as `ID["Label<br/>detail"]`.
- If a diagram becomes too wide, shorten IDs, wrap labels, and split the diagram before trying theme tweaks.
- If a sequence diagram fails, check the exact `sequenceDiagram` keyword, participant declarations, and control block endings.
- If a renderer ignores the init block, remove it and keep the portable syntax.
- If Mermaid Live Editor accepts a diagram but the target Markdown renderer fails, simplify syntax to the lowest-common-denominator form and avoid advanced theming.

## Shipping Checklist

- The diagram is in a fenced `mermaid` block.
- The diagram has one clear purpose and is split if it tries to explain multiple concerns.
- Long labels use `<br/>`, not raw newline escapes.
- Identifiers remain intact across visual line breaks.
- Between-actor sequence messages include a bracketed technical operation and quoted chat line, unless the user explicitly requested technical-only messages.
- Flowchart labels with special characters are quoted.
- The diagram should fit without horizontal scrolling in the target Markdown page.
