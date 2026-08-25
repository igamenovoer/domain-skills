# Forget Hindsight Memory

Remove an explicitly identified Hindsight fact or data scope.

## Workflow

1. Resolve the exact Hindsight bank and requested forgetting scope.
2. Inspect candidate memories or documents without changing them.
3. Prefer reversible invalidation for one raw fact unless permanent erasure is required.
4. Obtain explicit authorization before any irreversible document, memory-set, bank, or volume deletion.
5. Execute only the chosen endpoint and verify the data no longer appears in recall.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step forgetting plan from the bank, memory, document, and deletion contracts below, then execute the plan without broadening the requested scope.

## Resolve the Bank

Hermes normally derives:

```text
hermes-{profile}-{platform}-{user}
```

List banks and identify the exact target:

```bash
curl -fsS http://127.0.0.1:18888/v1/default/banks
```

Do not assume the fallback bank `hermes` contains a platform user's memory.

## Inspect Candidate Facts

```bash
curl -fsS \
  'http://127.0.0.1:18888/v1/default/banks/<bank-id>/memories/list?limit=100'
```

Use the returned memory ID or source document ID. Avoid copying unrelated memory content into logs or chat.

## Reversible Single-Fact Forgetting

For a raw `world` or `experience` fact, invalidate it:

```bash
curl -fsS -X PATCH \
  -H 'Content-Type: application/json' \
  -d '{"state":"invalidated","reason":"explicit user forget request"}' \
  'http://127.0.0.1:18888/v1/default/banks/<bank-id>/memories/<memory-id>'
```

Invalidated facts are excluded from recall and consolidation, while retained in the audit archive and reversible with `{"state":"valid"}`. Their derived links and observations are pruned.

## Permanent Erasure

Delete one source document and all facts extracted from it:

```bash
curl -fsS -X DELETE \
  'http://127.0.0.1:18888/v1/default/banks/<bank-id>/documents/<document-id>'
```

Clear all memory units while preserving the bank profile:

```bash
curl -fsS -X DELETE \
  'http://127.0.0.1:18888/v1/default/banks/<bank-id>/memories'
```

Delete an entire bank:

```bash
curl -fsS -X DELETE \
  'http://127.0.0.1:18888/v1/default/banks/<bank-id>'
```

These operations cannot be undone. Confirm the resolved ID and requested scope immediately before issuing them.

`hermes memory reset` is not a Hindsight forgetting command; it erases Hermes' built-in `MEMORY.md` and `USER.md` instead.

## Verification

Recall the forgotten subject from the same bank and confirm it is absent:

```bash
curl -fsS -X POST \
  -H 'Content-Type: application/json' \
  -d '{"query":"<forgotten-subject>","types":["world","experience","observation"],"budget":"mid"}' \
  'http://127.0.0.1:18888/v1/default/banks/<bank-id>/memories/recall'
```

## Guardrails

- DO NOT delete a bank, document, memory set, or Docker volume based on a guessed identifier.
- DO NOT use `hermes memory reset` when the request concerns Hindsight data.
- DO NOT treat reversible invalidation as permanent privacy erasure.
- DO NOT delete the Docker volume unless the user explicitly requests destruction of every Hindsight bank and persistent database record.
