# Migration Plan: `llm-wiki-all-in-one` → `imsight-llm-wiki`

## Scope

- **Source skill**: `extern/orphan/tool-skills/misc/llm-wiki-all-in-one`
- **Target skill**: `extern/orphan/houmao-agents/skillset/imsight-skills/imsight-llm-wiki`
- **Migration mode**: source-to-target
- **Goal**: preserve all wiki-building behavior, but expose it through an Imsight-style subcommand interface with concise `SKILL.md`, `agents/openai.yaml`, and `commands/` detail pages.

## Source Behavior to Preserve

1. **Entrypoint trigger**: build/maintain Karpathy-style LLM knowledge base; deploy bundled viewer.
2. **Five operations**: `compile`, `ingest`, `query`, `lint`, `audit`.
3. **Scaffold**: create a new wiki directory tree.
4. **Viewer deploy**: copy, install, and launch the Node.js web viewer.
5. **Core principles**: divide-and-conquer, mermaid/KaTeX, raw file policy, audit as human feedback surface.
6. **Directory layout**: `README.md`, `log/`, `audit/`, `raw/`, `wiki/`, `outputs/`.
7. **Log format**: one file per day, H2 per operation.
8. **Audit format**: YAML frontmatter + text anchors + `# Resolution` section.
9. **Wikilink convention**: vault-root targets with short aliases.
10. **Scripts**: `scaffold.py`, `lint_wiki.py`, `audit_review.py`, `deploy_viewer.py`.
11. **Viewer assets**: `viewer/audit-shared/` and `viewer/web/`.
12. **Reference guides**: schema, article, audit, log, tooling tips, vault-root resolver.

## Target Runtime Shape

```text
imsight-llm-wiki/
├── SKILL.md                         # Imsight-style entrypoint
├── agents/
│   └── openai.yaml                  # UI metadata
├── commands/
│   ├── compile.md
│   ├── ingest.md
│   ├── query.md
│   ├── lint.md
│   ├── audit.md
│   ├── deploy-viewer.md
│   └── scaffold.md
├── references/                      # Migrated + style-aligned guides
│   ├── schema-guide.md
│   ├── article-guide.md
│   ├── audit-guide.md
│   ├── log-guide.md
│   ├── tooling-tips.md
│   └── vault-root-link-resolver.md
├── scripts/                         # Runtime Python helpers
│   ├── scaffold.py
│   ├── lint_wiki.py
│   ├── audit_review.py
│   └── deploy_viewer.py
├── viewer/                          # Bundled web viewer
│   ├── audit-shared/
│   └── web/
├── org/                             # Migration provenance (untouched source)
│   ├── src/
│   ├── analysis/
│   └── README.md
└── migrate/                         # Migration working artifacts
    ├── migration-plan.md
    └── placeholders.md
```

## Term Adaptations

| Source term | Target term | Notes |
|---|---|---|
| `llm-wiki-all-in-one` | `imsight-llm-wiki` | Skill name |
| "The five operations" | subcommands: `compile`, `ingest`, `query`, `lint`, `audit` | Exposed as named subcommands |
| `subskills/viewer-deploy.md` | `commands/deploy-viewer.md` | Imsight uses `commands/` for subcommand detail |
| `references/*.md` | `references/*.md` | Kept with minor style alignment |
| `scripts/*.py` | `scripts/*.py` | Kept unchanged; invocation paths updated |
| `viewer/` | `viewer/` | Kept unchanged |

## Tool and Harness Adaptations

- Python scripts keep the same CLI and behavior.
- Invocation from the target skill uses `python3 scripts/<script>.py <args>` from the skill root.
- Node.js/npm/bun requirements for the viewer remain unchanged.
- No tool substitutions are required.

## Artifact and Storage Adaptations

- The target skill itself does not own wiki content; it operates on a user-supplied `<wiki-root>`.
- The target skill does not introduce new artifact directories beyond the Imsight output contract.
- Skill-owned migration artifacts live under `org/` and `migrate/`.

## External Skill Route Adaptations

- The source skill has no external skill routes.
- The target skill will not introduce any unless needed for validation; none are needed.

## Step Support Mapping

The source entrypoint preserved as `org/src/SKILL-SOURCE.md` embeds step logic for each operation. The target maps each operation to a subcommand detail page under `commands/`:

| Source section | Target file | Support blocks |
|---|---|---|
| `compile` | `commands/compile.md` | Workflow, Constraints, Quality Gates |
| `ingest` | `commands/ingest.md` | Workflow, Constraints, Quality Gates |
| `query` | `commands/query.md` | Workflow, Constraints, Quality Gates |
| `lint` | `commands/lint.md` | Workflow, Constraints, Quality Gates |
| `audit` | `commands/audit.md` | Workflow, Constraints, Quality Gates |
| viewer deploy | `commands/deploy-viewer.md` | Workflow, Constraints, Quality Gates |
| scaffold | `commands/scaffold.md` | Workflow, Constraints, Quality Gates |

Each detail page will use the Imsight **Step Support Pattern** (Guidance, Preferences, Constraints, Quality Gates) where meaningful.

## Semantic Match Checks

### Must preserve

- All five operations and their step sequences.
- Wiki directory layout and file formats.
- Audit file format and anchor strategy.
- Log format.
- Wikilink canonical form.
- Raw file policy.
- Script CLIs.
- Viewer deploy behavior.

### Intentionally changed

- Skill frontmatter description rewritten to Imsight "Use when..." form.
- Operations exposed as explicit subcommands with `commands/` detail pages.
- `SKILL.md` reduced to a router; long prose moved to detail/reference pages.
- `subskills/viewer-deploy.md` moved to `commands/deploy-viewer.md`.
- Source `SKILL-SOURCE.md` author credit preserved in a migration note, not frontmatter.

## Validation Plan

1. Confirm `org/src/` contains all source files with paths preserved.
2. Confirm `SKILL.md` frontmatter uses `name: imsight-llm-wiki` and a "Use when..." description.
3. Confirm `agents/openai.yaml` exists and matches `SKILL.md`.
4. Confirm all subcommands are listed in `## Subcommands` and have matching `commands/*.md` files.
5. Confirm every `commands/*.md` has a `## Workflow` section.
6. Confirm references are linked and contain no stale source-specific paths.
7. Confirm scripts and viewer assets are copied into runtime tree.
8. Run `ls` and `head` checks; no Python/MyPy validation is required for Markdown skill files.
