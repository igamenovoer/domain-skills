# ADR Format

ADRs live in `<output-dir>/adrs/` and use sequential numbering: `0001-slug.md`, `0002-slug.md`, and so on.

Create `<output-dir>/adrs/` lazily, only when the first ADR is needed.

## Template

```md
# {Short title of the decision}

{1-3 sentences: what context forced the decision, what was decided, and why.}
```

That is enough for many ADRs. The value is recording that a decision was made and why, not filling out a long template.

## Optional Sections

Only include these when they add genuine value:

- `Status`: `proposed`, `accepted`, `deprecated`, or `superseded by ADR-NNNN`.
- `Considered Options`: include only rejected alternatives worth remembering.
- `Consequences`: include only non-obvious downstream effects.

## Numbering

Scan `<output-dir>/adrs/` for the highest existing number and increment by one.

## When To Offer An ADR

All three must be true:

1. Hard to reverse: the cost of changing the decision later is meaningful.
2. Surprising without context: a future reader will wonder why the project works this way.
3. Real trade-off: there were genuine alternatives and one was chosen for specific reasons.

Skip the ADR if any criterion is missing.

## Good ADR Subjects

- Architecture shape: monorepo, event sourcing, modular boundaries, API gateway, plugin model.
- Integration patterns: events instead of synchronous HTTP, polling instead of webhooks, local cache instead of direct reads.
- Technology choices with meaningful lock-in: database, queue, auth provider, deployment target.
- Boundary and scope decisions: ownership of data, explicit no-go areas, compatibility guarantees.
- Deliberate deviations from the obvious path: manual SQL over ORM, local files over database, sync operation over async job.
- Constraints invisible in code: compliance, partner contracts, latency targets, data residency.
