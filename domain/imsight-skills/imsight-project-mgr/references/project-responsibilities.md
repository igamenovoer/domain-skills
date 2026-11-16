# Project Responsibility Contract

## Ownership

A **realwork** is the functional project at a selected revision. A **metaproj** is its non-publishable development workspace. In the standard arrangement the same remote repository provides a `metaproj` branch and functional `main`/feature branches. Each realwork is an independent clone registered as a submodule, not a linked Git worktree. Preserve an established alternative remote arrangement when the user requests it.

| Content | Owner |
| --- | --- |
| Product algorithms, services, plugins, frontend, schemas, build metadata, runtime dependencies, package resources | Realwork |
| Usable experiments, optional monkeypatch features, functional scripts and operational entrypoints | Realwork |
| Feature tests, verifiers, manual harnesses, fixtures, demos and executable documentation | Realwork |
| Usage, public APIs, formats, operating requirements and acquisition controls | Realwork |
| Design, planning, ADRs, development reports, agent workflows and all OpenSpec records | Metaproj |
| Shared development environments, CI orchestration, lint/type policy, build/release orchestration, repository governance | Metaproj |
| Tests of meta tools and policies | Metaproj |
| Shared payloads, local external references, historical material, disposable outputs | Metaproj resource locations with explicit bindings |

Classify by purpose, not directory name, maturity, language, or inclusion in a wheel. Split mixed files: keep public/functional contracts and verification beside the product while lifting internal design or repository-policy checks. Do not relocate all `scripts/`, `docs/`, or `tests/` wholesale. Functional dependency submodules remain pinned and independently obtainable from the realwork; meta reference clones do not satisfy product dependencies.

## Standard Layout

```text
project/                         branch: metaproj
|-- AGENTS.md                    development and routing guidance
|-- README.md                    workspace setup and manual standalone attachment
|-- .gitmodules                  branch mappings and exact gitlinks
|-- pixi.toml or pyproject.toml   shared development environment
|-- pixi.lock
|-- meta_src/                    maintained development tools; own tests below it
|-- meta_scripts/                experimental development tooling
|-- meta_configs/                tooling policy, task definitions, environment templates
|-- context/                     plans, designs, decisions, reports
|-- docs/                        engineering documentation
|-- openspec/                    specs, changes, archives with implementation targets
|-- skillset/                    project-specific agent skills
|-- history/                     superseded material
|-- extern/                      documented development references
|-- data/                        shared payloads, normally ignored
|-- tmp/                         ignored; checkout key then purpose/run
`-- realworks/
    |-- main/                    functional main branch submodule
    `-- feature/example/         independent feature branch submodule
```

The layout illustrates a selection containing main and a feature branch. Initialization can take an explicit branch set, which need not include `main`; only an omitted selection defaults to it. Create only useful directories and control documents. Do not copy this repository's package names, dependency set, host aliases, credentials, model caches, or lifecycle inventories into another project. Metaproj has no root `src/` and is not a package to publish. Product `src/` always refers to the selected realwork. Existing language-specific product layouts remain valid.

## Agent and Environment Boundaries

Meta `AGENTS.md` establishes routing, coordination, engineering policy, and explicit checkout selection. Realwork `AGENTS.md` explains functionality, directories, tests, resource prerequisites and how to attach full development support. It does not pretend a functional clone includes the complete development environment.

Share compatible meta environments. Add a separate named meta environment when dependencies conflict. Keep source selection per process; never repoint a shared editable product install or mutate a shared environment beneath running work. An inherited `PYTHONPATH`, old checkout cwd, or linked dependency source must not select another realwork accidentally. Check initialized functional dependency sources as well as the product package.

Use a project-specific `<PREFIX>_DEV_<PURPOSE>` environment contract. Realworks track `env.example` and ignore `.env`. Explicit process values override realwork `.env`, then meta `.env`, then defaults. Resolve relative resource values against the selected realwork root, regardless of cwd or the file that supplied them; do not evaluate shell expressions. Prefer portable relative defaults: `../../` from `realworks/main/`, `../../../` from `realworks/feature/example/`.

`<PREFIX>_DEV_TMP_ROOT` defaults to `<meta>/tmp/<complete-checkout-key>/`. Each invocation uses distinct purpose/run subdirectories. Shared inputs may be read-only; caches or outputs requiring mutation need explicit isolation. Preserve standalone local defaults where already supported. Missing required external inputs produce an actionable error; they do not trigger automatic downloads or silent test exclusion. Keep manual standalone setup instructions and optional environment templates in metaproj.

## Coordination

Each task records its checkout, branch/base revision, scope, spec/change, environment, resource requirements, and verification. Parallel agents work in separate selected realworks. Meta files are shared: coordinate edits to `.gitmodules`, shared environment/lock, common specs, and tooling before concurrent mutation. One owner integrates overlapping changes. A directory name alone is neither a lock nor proof of branch identity.

Distinguish three operations: restoring a recorded gitlink; integrating committed feature code into a functional branch; and recording a new gitlink. Branch mappings do not update pins. When publication is authorized, publish runtime commits and required dependency commits first, then the matching meta records/pins. No automatic commit, push, release, or removal follows ordinary implementation.
