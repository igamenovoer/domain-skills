---
name: imsight-paper-search
description: Use when the user wants to search, fetch, or bulk-collect academic papers, authors, citations, references, recommendations, or Semantic Scholar datasets through direct curl calls to the Semantic Scholar APIs.
---

# Imsight Paper Search

## Overview

This skill provides direct curl recipes for the Semantic Scholar Academic Graph, Recommendations, and Datasets APIs. It maps common research tasks to endpoints, builds curl requests, and handles pagination and field selection without requiring a client library.

## When to Use

- Use when the user asks to search papers, retrieve paper or author details, list citations or references, get paper recommendations, or list or download Semantic Scholar datasets.
- Use when the user explicitly wants to call the Semantic Scholar API directly or with curl.
- Do NOT use when a higher-level wrapper, SDK, or database is the better fit.

## Workflow

When this skill is invoked, execute the following steps in order.

1. **Identify the API and endpoint** that matches the user's task from the **API Overview** table below.
2. **Open the matching reference page** for parameter details and a copy-paste curl template.
3. **Build the curl request**:
   - Select the correct base URL from **Base URLs**.
   - Replace path placeholders such as `{paper_id}` with real IDs.
   - Add required query parameters and any desired optional filters.
   - Include `-H "x-api-key: $S2_API_KEY"` when an API key is available.
   - For POST endpoints, set `-H "Content-Type: application/json"` and pass the JSON body with `-d`.
4. **Run curl and parse the JSON response**. Use `jq` or another JSON formatter to inspect results.
5. **Paginate list endpoints** using `offset`/`limit` or the `next`/`token` fields returned in the response. Stop when there is no next page or the user has enough results.

If the user's task does not map cleanly to a documented endpoint, use your native planning tool to build a step-by-step curl-based plan using the reference pages and constraints in this skill, then execute the plan.

## API Overview

| Task | API | Method | Endpoint | Detail |
| --- | --- | --- | --- | --- |
| Get details for multiple authors at once | Academic Graph | POST | `/author/batch` | `references/academic-graph-api.md` |
| Search for authors by name | Academic Graph | GET | `/author/search` | `references/academic-graph-api.md` |
| Details about an author | Academic Graph | GET | `/author/{author_id}` | `references/academic-graph-api.md` |
| Details about an author's papers | Academic Graph | GET | `/author/{author_id}/papers` | `references/academic-graph-api.md` |
| Suggest paper query completions | Academic Graph | GET | `/paper/autocomplete` | `references/academic-graph-api.md` |
| Get details for multiple papers at once | Academic Graph | POST | `/paper/batch` | `references/academic-graph-api.md` |
| Paper relevance search | Academic Graph | GET | `/paper/search` | `references/academic-graph-api.md` |
| Paper bulk search | Academic Graph | GET | `/paper/search/bulk` | `references/academic-graph-api.md` |
| Paper title search | Academic Graph | GET | `/paper/search/match` | `references/academic-graph-api.md` |
| Details about a paper | Academic Graph | GET | `/paper/{paper_id}` | `references/academic-graph-api.md` |
| Details about a paper's authors | Academic Graph | GET | `/paper/{paper_id}/authors` | `references/academic-graph-api.md` |
| Details about a paper's citations | Academic Graph | GET | `/paper/{paper_id}/citations` | `references/academic-graph-api.md` |
| Details about a paper's references | Academic Graph | GET | `/paper/{paper_id}/references` | `references/academic-graph-api.md` |
| Text snippet search | Academic Graph | GET | `/snippet/search` | `references/academic-graph-api.md` |
| Get recommended papers for lists of positive and negative example papers | Recommendations | POST | `/papers/` | `references/recommendations-api.md` |
| Get recommended papers for a single positive example paper | Recommendations | GET | `/papers/forpaper/{paper_id}` | `references/recommendations-api.md` |
| Download links for incremental diffs | Datasets | GET | `/diffs/{start_release_id}/to/{end_release_id}/{dataset_name}` | `references/datasets-api.md` |
| List available releases | Datasets | GET | `/release/` | `references/datasets-api.md` |
| List datasets in a release | Datasets | GET | `/release/{release_id}` | `references/datasets-api.md` |
| Download links for a dataset | Datasets | GET | `/release/{release_id}/dataset/{dataset_name}` | `references/datasets-api.md` |

## Authentication

An API key is optional but provides higher rate limits. Pass it as a header:

```bash
-H "x-api-key: $S2_API_KEY"
```

Store keys in environment variables or secret managers. Never commit an API key.

## Base URLs

| API | Base URL | Reference |
| --- | --- | --- |
| Academic Graph API | `https://api.semanticscholar.org/graph/v1` | `references/academic-graph-api.md` |
| Recommendations API | `https://api.semanticscholar.org/recommendations/v1` | `references/recommendations-api.md` |
| Datasets API | `https://api.semanticscholar.org/datasets/v1` | `references/datasets-api.md` |

## Pagination and Field Selection

- Use the `fields` query parameter to request specific fields and reduce payload size. Subfields use dot notation, for example `authors.name` or `citations.title`.
- Most list endpoints support `offset` (default 0) and `limit` (up to 1000). The response includes a `next` offset when more pages exist.
- `/paper/search` (relevance search) returns up to 1,000 results total. For larger result sets, use `/paper/search/bulk` and follow the `token` field, or use the Datasets API.

## References

- `references/academic-graph-api.md` — paper, author, citation, reference, and snippet endpoints.
- `references/recommendations-api.md` — paper recommendation endpoints.
- `references/datasets-api.md` — release and dataset download endpoints.

## Guardrails

- DO NOT commit API keys or hardcode them into skill files, scripts, or example commands.
- DO NOT use `/paper/search` for result sets larger than 1,000; use bulk search or the Datasets API.
- DO NOT exceed documented per-request limits, such as 500 paper IDs in `/paper/batch` or 1,000 author IDs in `/author/batch`.
- DO NOT assume every response record contains every requested field; handle missing or null values gracefully.
