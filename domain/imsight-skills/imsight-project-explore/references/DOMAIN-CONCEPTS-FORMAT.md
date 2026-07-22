# CONTEXT.md Format

Use this format when the target project needs or already has a single project `CONTEXT.md`.

## Structure

```md
# {Context Name}

{One or two sentence description of what this context is and why it exists.}

## Language

**Order**:
{A one or two sentence description of the term.}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account

## Relationships

- An **Order** may produce one or more **Invoices**.
- A **Customer** may place many **Orders**.

## Flagged Ambiguities

- "Account" was previously used to mean both **Customer** and **User**. Use the precise term instead.
```

## Rules

- Be opinionated. When multiple words exist for the same concept, pick the best one and list the others under `_Avoid_`.
- Keep definitions tight. One or two sentences max. Define what the term is, not every operation that can happen to it.
- Include only project-specific domain terms. General programming concepts, library names, helper patterns, and implementation mechanisms do not belong here.
- Prefer terms that domain experts would recognize. Put implementation decisions in specs or ADRs instead.
- Group terms under subheadings only when natural clusters emerge. If all terms belong to one cohesive area, keep a flat list.
- Add `Relationships` only for durable conceptual relationships that clarify the domain.
- Add `Flagged Ambiguities` when a resolved naming conflict is likely to recur.

## Editing Discipline

- Create `CONTEXT.md` lazily only when the first durable term is resolved.
- Update it immediately when a term is resolved; do not batch a long list of inferred terms.
- If a proposed term conflicts with the existing glossary, surface the conflict before editing.
- Do not use `CONTEXT.md` as a spec, implementation plan, issue list, or scratchpad.
