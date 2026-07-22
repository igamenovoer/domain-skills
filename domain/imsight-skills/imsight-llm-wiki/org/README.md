# Migration Provenance

This directory preserves the source skill `llm-wiki-all-in-one` as it existed before migration into `imsight-llm-wiki`.

## What was copied

All files from `extern/orphan/tool-skills/misc/llm-wiki-all-in-one/` were copied into `org/src/` with relative paths preserved:

- `SKILL-SOURCE.md` — original entrypoint preserved under a non-discoverable provenance filename.
- `subskills/viewer-deploy.md` — viewer deployment subskill.
- `references/schema-guide.md` — README.md schema guide.
- `references/article-guide.md` — wiki article writing guide.
- `references/audit-guide.md` — audit file format and workflow.
- `references/log-guide.md` — log folder convention.
- `references/tooling-tips.md` — Obsidian, web viewer, qmd, Marp setup.
- `references/vault-root-link-resolver.md` — canonical wikilink resolver.
- `scripts/scaffold.py` — bootstrap new wiki.
- `scripts/lint_wiki.py` — wiki health check.
- `scripts/audit_review.py` — list/group audits.
- `scripts/deploy_viewer.py` — deploy/launch web viewer.
- `viewer/audit-shared/` — shared TypeScript audit library.
- `viewer/web/` — Node.js web viewer.

## What was analyzed

`org/analysis/analysis-of-llm-wiki-all-in-one.md` contains a deep inspection of the source runtime behavior, including:

- purpose and core concepts,
- high-level process and skill call graph,
- the five operations (`compile`, `ingest`, `query`, `lint`, `audit`),
- viewer deploy and scaffold workflows,
- artifacts, storage, scripts, external dependencies, and assumptions.

## What was excluded from runtime

No source files were omitted from the `org/` provenance copy. Decisions about which files are promoted to the target runtime tree are recorded in `../migrate/migration-plan.md`.

## Migration mode

Source-to-target migration. The target skill name is `imsight-llm-wiki`.
