---
name: imsight-llm-wiki
description: Use when building or maintaining a Karpathy-style LLM knowledge base inside the current project, or when deploying the bundled local web viewer for that wiki. Triggers on requests to scaffold, compile, ingest, research, collect, inventory, project, query, lint, audit, or launch an LLM Wiki.
---

# Imsight LLM Wiki

## Overview

This skill manages a compiled, cross-linked LLM knowledge base. It treats `raw/` sources as read-only input and `wiki/` as the agent-written artifact. The core wiki operations (`compile`, `ingest`, `query`, `lint`, `audit`) plus research, collection, inventory, project output grouping, and viewer deployment are exposed as subcommands.

## When to Use

Use this skill when the user asks to:

- scaffold a new LLM Wiki,
- compile or restructure wiki content from existing `raw/` material,
- ingest an article, paper, PDF, note, or web page into the wiki,
- research a topic on the web and ingest discovered sources,
- collect and catalog a bounded set of external artifacts,
- manage an inventory of ingest candidates,
- create or manage a project folder for grouped outputs,
- answer a question grounded in the wiki,
- run a lint pass for dead links, orphan pages, missing index entries, audit shape, or quality issues,
- process human feedback from `audit/`,
- deploy or launch the bundled local web viewer.

Do not use it for general note-taking, daily journals, or non-wiki Obsidian use.

## Workflow

1. **Read the request** and identify the requested subcommand; handle `help` when none is present.
2. **Resolve the wiki root** for operations that need one. See **Wiki Root Resolution**.
3. **Load the selected command page** from `commands/<subcommand>.md`.
4. **Execute its workflow** with the specified tools and scripts.
5. **Append a daily log entry** to `log/YYYYMMDD.md` when the operation mutates the wiki.
6. **Report the result**, including touched files, issues, or viewer URL.

If the task does not map cleanly to these steps, use your native planning tool with the existing subcommands, wiki contracts, and constraints; do not invent wiki operations or mutations.

## Invocation Contract

- Preferred explicit form: `$imsight-llm-wiki use <subcommand> to do <task>`.
- Task-only form: `$imsight-llm-wiki <task prompt>` means choose the applicable subcommand from the task.
- No subcommand and no task means `help`.
- `help` summarizes this skill and lists the subcommands below.

## Output Contract

This skill operates on a user-provided wiki root. It does not write skill-owned auxiliary artifacts under `.imsight-arts/` for normal wiki operations. Migration provenance under `org/` and `migrate/` is not part of the runtime interface.

## Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `help` | Explain this skill and list public subcommands | This entrypoint |
| `scaffold` | Create a new LLM Wiki directory tree | `commands/scaffold.md` |
| `compile` | Restructure wiki content and rebuild `wiki/index.md` | `commands/compile.md` |
| `ingest` | Add a new source to `raw/` and update the wiki | `commands/ingest.md` |
| `research` | Research a topic on the web and ingest discovered sources | `commands/research.md` |
| `collect` | Catalog a bounded set of external artifacts | `commands/collect.md` |
| `inventory` | Manage a backlog of ingest candidates | `commands/inventory.md` |
| `project` | Group related outputs into a deliverable folder | `commands/project.md` |
| `query` | Answer a question grounded in the wiki | `commands/query.md` |
| `lint` | Run health checks and propose fixes | `commands/lint.md` |
| `audit` | Process human feedback from `audit/` | `commands/audit.md` |
| `deploy-viewer` | Deploy or launch the bundled web viewer | `commands/deploy-viewer.md` |

## Wiki Root Resolution

- Use the wiki root explicitly provided by the user.
- If the current working directory contains `README.md`, `wiki/index.md`, and `audit/`, treat it as the wiki root.
- If exactly one candidate wiki root exists nearby (for example, a sibling directory named `<topic>-wiki`), use it.
- Otherwise, ask the user for the wiki root.

## Guardrails

- DO NOT use general knowledge instead of wiki content for `query`.
- DO NOT run `compile` splits or merges without user confirmation.
- DO NOT silently ignore open `audit/*.md` files.
- DO NOT create non-canonical wikilinks such as `[[concepts/foo|Foo]]`.
- DO NOT copy large binaries into `raw/`.

## References

- `references/schema-guide.md` — what to put in `README.md`.
- `references/article-guide.md` — how to write wiki articles.
- `references/audit-guide.md` — audit file format and processing workflow.
- `references/log-guide.md` — the `log/` folder convention.
- `references/tooling-tips.md` — Obsidian, web viewer, qmd, and Marp setup.
- `references/vault-root-link-resolver.md` — canonical wikilink resolver contract.

## Maintenance

This skill was migrated from `llm-wiki-all-in-one` and rewritten in Imsight style. The original source is preserved under `org/src/` for audit.
