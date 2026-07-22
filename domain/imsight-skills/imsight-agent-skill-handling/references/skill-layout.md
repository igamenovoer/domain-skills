# Agent Skill Layout

This page documents the standard skill directory layout, based on the OpenAI skill-creator guide, plus the local Imsight conventions used by skills in this repository.

## Standard Layout

A skill is a self-contained folder. A standalone or host-discoverable skill root must contain `SKILL.md`. A parent-scoped subskill must contain `SKILL-MAIN.md` instead. Everything else is optional and should only be created when the skill actually needs it.

```text
<skill-name>/
├── SKILL.md          # Required. YAML frontmatter + Markdown instructions.
├── agents/           # Recommended. Runtime UI metadata.
│   └── openai.yaml
└── Bundled Resources # Optional. Only create directories the skill needs.
    ├── scripts/      # Executable code (Python, Bash, etc.)
    ├── references/   # Documentation loaded into context as needed
    └── assets/       # Files used in output (templates, icons, fonts, etc.)
```

### `SKILL.md` (required for a top-level skill)

- **Frontmatter** (YAML): `name` and `description`. These are the only fields Codex reads to decide whether to trigger the skill. Imsight skills may add optional keys such as `skill_invocation_notation`; see **Skill Invocation Notation** under **Imsight Local Conventions**.
- **Body** (Markdown): Instructions and guidance. Loaded only after the skill triggers.

### `agents/openai.yaml` (recommended)

UI-facing metadata for skill lists and chips. Contains:

- `interface`: `display_name`, `short_description`, `default_prompt`
- `policy`: e.g., `allow_implicit_invocation`

Generate this file from the skill content rather than hardcoding it. Do not include optional interface fields (icons, brand color, etc.) unless explicitly provided.

Template:

```yaml
interface:
  display_name: "<Human-readable skill name>"
  short_description: "<One-line summary of what the skill does>"
  default_prompt: "Use $<skill-name> use help to see available subcommands, or use a specific subcommand to <do the thing>."
policy:
  allow_implicit_invocation: false
```

### `scripts/` (optional)

Executable code for tasks that require deterministic reliability or are repeatedly rewritten. Example: `scripts/rotate_pdf.py`.

Only create this directory when the skill actually bundles executable code.

### `references/` (optional)

Documentation intended to be loaded into context as needed. Examples: schemas, API docs, policies, detailed workflow guides.

Keep the role-canonical entrypoint lean by moving detailed reference material here. Avoid duplication: information should live in either the entrypoint or a references file, not both.

### `assets/` (optional)

Files used in the output Codex produces, not loaded into context. Examples: templates, images, fonts, boilerplate code.

## What Not to Include

Do not create extraneous documentation or auxiliary files such as:

- `README.md`
- `INSTALLATION_GUIDE.md`
- `QUICK_REFERENCE.md`
- `CHANGELOG.md`

A skill should contain only the files needed for an AI agent to do its job.

## Imsight Local Conventions

In addition to the standard layout, Imsight skills in this repository organize subcommand detail pages under:

- `commands/`

Link these pages from the `## Subcommands` table in the containing skill's role-canonical entrypoint.

A subcommand page may define its own `## Subcommands` table. That page becomes the immediate routing owner and object generator for its child subcommands. Link each child detail page from the parent command page; command ownership comes from the declared routing table and full invocation chain, not from an inferred filesystem shape. A repository may use flat or nested detail-page paths as long as every parent-to-child route is explicit and unambiguous.

Subcommands do not create resource-ownership roots. Their detail pages, child pages, scripts, references, assets, templates, and other support files remain owned by the containing skill or subskill. If one command family needs a private bundled-resource tree that should be maintained, loaded, validated, or distributed independently from sibling commands, model that family as a subskill instead.

### `subskills/` (optional)

Imsight skills add one more hierarchy level to the standard layout: a skill may bundle nested skills under `subskills/`. Each subskill is a self-contained skill folder with its own required `SKILL-MAIN.md` and the same optional bundled resources (`agents/`, `references/`, `commands/`, `scripts/`, `assets/`). The distinct filename prevents recursive exact-`SKILL.md` scanners from registering the child as an independent top-level skill.

```text
<skill-name>/
├── SKILL.md
└── subskills/
    └── <subskill-name>/
        ├── SKILL-MAIN.md     # Required. The parent-scoped subskill entrypoint.
        └── ...               # Optional. Same bundled resources as a top-level skill.
```

Read the structure with object semantics: treat the main skill as an object and its role-canonical entrypoint as the object's entrypoint. A subskill is an inner object of the main skill: a member capability scoped to and owned by the parent skill, not independently installed or discovered. Use a subskill when a capability needs its own private bundled-resource boundary while remaining meaningful as part of the parent. Private means scoped ownership, not secrecy. Keep procedures that use the containing skill's resources as direct or nested subcommands on `commands/` or `references/` detail pages.

The parent skill owns routing to its subskills. List bundled subskills in the `## Subcommands` table or a dedicated `## Subskills` section of the parent's role-canonical entrypoint so it can resolve invocation designators. Give every direct subskill one `When to Route Here` sentence that lets the parent distinguish it before explicitly loading only the selected child's `SKILL-MAIN.md` and required local resources. Derive the sentence from the child's trigger metadata and `## When to Use` guidance, remove context already supplied by the parent, and do not copy the child description or agent short description verbatim. Apply the rule recursively when a subskill owns further subskills.

For legacy input, inspection and migration may read a nested `SKILL.md` when `SKILL-MAIN.md` is absent. New creation and formatting normalize the child to `SKILL-MAIN.md` without leaving a compatibility copy. A folder containing both files is invalid. Preserve an upstream entrypoint under `org/src/` as `SKILL-SOURCE.md`, not `SKILL.md`.

### Skill Invocation Notation

Skills designate skill, subskill, and subcommand invocations with object-style notation. Bare components form a skill or subskill path, while one or more parenthesized components form a subcommand chain:

```text
skill-path := skill-name ("->" subskill-name)*
subcommand-chain := subcommand-name "()" ("->" subcommand-name "()")*
invocation := skill-path | skill-path "->" subcommand-chain
relative-subcommand-invocation := subcommand-chain
```

- Skill and subskill entrypoint invocation: write "invoke skill `X`" or "invoke skill `X->Y->Z`". The former resolves top-level `SKILL.md`; a terminal child resolves `SKILL-MAIN.md` through its parent. Never write `X()` or `X->Y()` for an entrypoint.
- Skill-to-subcommand invocation: write "invoke skill subcommand `X->cmd()`" for a direct subcommand of skill `X`, "invoke skill subcommand `X->Y->cmd()`" for a direct subcommand of subskill `Y`, and "invoke subcommand `cmd()`" for a direct subcommand of the current skill or command context.
- Nested-subcommand invocation: write `X->parent()->child()` for child subcommand `child` defined by parent subcommand `parent`. Every command component includes `()`, and each intermediate command acts as an object generator for its declared children.
- Same-name routing: a direct subskill and direct subcommand may share a name because the bare or parenthesized component form determines the capability kind.

Under this grammar, `X->Y` invokes subskill `Y`, `X->Y()` invokes subcommand `Y` of skill `X`, and `X->parent()->child()` invokes child subcommand `child` of parent subcommand `parent`. Once the first subcommand component appears, every remaining component must also be a parenthesized subcommand.

Any skill or subcommand page that uses these designators must declare the notation in its YAML frontmatter with the `skill_invocation_notation` key. See [imsight-skill-style-guide.md](imsight-skill-style-guide.md) for the rule and the standard frontmatter value.
