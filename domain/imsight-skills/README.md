# Imsight Skills

This directory collects engineering automation skills written in the Imsight style.

These skills encode Imsight's taste in software engineering practice: standard operating procedures, artifact naming, project structure, architecture preferences, preferred libraries, favored implementation patterns, and the conventions used to keep repeated development work consistent.

Use these skills when a task should follow Imsight-authored workflows rather than generic defaults. They are intended to make automation behave like a reusable engineering playbook: explicit about process, consistent about outputs, and opinionated where consistency matters.

The skills in this directory are designed to work as a suite. Individual skills may route to, invoke, or rely on other Imsight skills for sub-workflows. Installing only part of the suite can leave some functionality unavailable or incomplete.

## Contracts

- Invocation by Imsight context: `imsight-*` skills are eligible when `imsight` is mentioned in the prompt or surrounding context and the task is relevant to one of the covered workflows. Examples include `use imsight skills`, `in imsight's style`, `follow imsight SOP`, or a request for an Imsight-authored process.
- Invocation by routing or name: these skills may also be invoked by internal routing from another Imsight skill, or when the user explicitly names the skill.
- Default triggering posture: outside explicit naming, internal routing, or relevant prompts that mention `imsight`, these skills normally should not trigger automatically for generic tasks.
- Skill-specific trigger restrictions override that suite default. In particular, `imsight-project-mgr` is available only through explicit user invocation or routing from another loaded skill; Imsight context alone does not activate it.
- Command shape: organize each `imsight-*` skill like a main command with many subcommands. The preferred invocation style is `$imsight-<what> use <subcommand-name> to do <task>`.
- Task-only invocation: invoking a skill with a task prompt, such as `$imsight-<what> <task prompt>`, asks the agent to inspect the task and select the applicable subcommand.
- Universal `help` subcommand: every `imsight-*` skill should support `help`. `help` explains what the skill does and lists available subcommands with short explanations.
- Default subcommand: invoking an `imsight-*` skill without a subcommand means `help` by default.
- Output directory discovery: when an `imsight-*` skill writes artifacts, first respect an output location explicitly provided by the user. If none is provided, check `IMSIGHT_SKILL_OUTPUT_DIR` and use the relative or absolute directory named there. If that variable is unset, write under `<project-dir>/.imsight-arts/<subdir>`, where `<subdir>` is chosen by the skill or subcommand.
- Implementation style: most Imsight skills use `SKILL.md` as a compact entrypoint, command router, and subcommand index. `SKILL.md` should describe what each subcommand does, and its entrypoint workflow should tell the agent to choose the right subcommand or sequence of subcommands based on the given task. Detailed workflows, subcommands, references, and reusable procedures should live in `commands/` or `references/` files linked from that entrypoint.

## Skill Index

- [`imsight-agent-skill-handling`](imsight-agent-skill-handling/SKILL.md): Manual-only skill lifecycle entrypoint for analyzing, deep-inspecting, designing, creating, refactor-migrating, testing, hardening, and formatting agent skills.
- [`imsight-autodev-master`](imsight-autodev-master/SKILL.md): Master-agent dispatch entrypoint for sending OpenSpec-oriented development requests to Houmao-managed slave agents. It chooses maintained workflows, raw OpenSpec invocations, or slave-skill invocations and then dispatches without taking over the slave's work.
- [`imsight-autodev-slave`](imsight-autodev-slave/SKILL.md): Slave-agent automation entrypoint for Houmao-managed agents that receive explicit master requests. It owns maintained request-processing workflows such as OpenSpec initialization and one-pass OpenSpec explore/propose/apply/sync/archive flows.
- [`imsight-dev-box-init`](imsight-dev-box-init/SKILL.md): Development host setup and installation index for Imsight-preferred tooling. It covers software installs, development packages, CLI tooling, Houmao tooling, Tavily setup, `claude-kimi`, and related dev-box bootstrap work.
- [`imsight-dev-box-network`](imsight-dev-box-network/SKILL.md): Development box networking guide for Imsight machines. It covers proxy setup and repair, SSH forward and reverse tunnels, relay access, exposed ports, systemd user tunnel services, and host-to-host access patterns.
- [`imsight-doc-writing`](imsight-doc-writing/SKILL.md): Documentation-writing router for technical Markdown, project notes, design and architecture documents, usage guides, reviews, and Mermaid diagram creation or formatting.
- [`imsight-info-gathering`](imsight-info-gathering/SKILL.md): Online information gathering workflow for searching, extracting, downloading, source-ledger building, and synthesizing cited reports from multiple sources.
- [`imsight-llm-wiki`](imsight-llm-wiki/SKILL.md): Build and maintain a compiled, cross-linked LLM knowledge base from raw sources, query and audit its wiki content, and run the bundled local viewer.
- [`imsight-project-automation`](imsight-project-automation/SKILL.md): Run maintained project automation routines, including a full OpenSpec lifecycle and evidence-led testing with OpenSpec-based bug fixes.
- [`imsight-project-design`](imsight-project-design/SKILL.md): Stage feature planning through scaffolding, feature definition, use-case design, interface or skill design, ADR-backed manual refinement, and compact implementation handoffs.
- [`imsight-project-explore`](imsight-project-explore/SKILL.md): Explore project requirements, scope, terminology, use cases, decisions, risks, and contradictions against repository evidence before implementation.
- [`imsight-project-mgr`](imsight-project-mgr/SKILL.md): Manual-or-routed project manager with Project Foundation commands for Pixi/Python initialization and structure plus universal rules, and Project Development commands for clean worktrees and isolated implementation.
- [`imsight-project-misc`](imsight-project-misc/SKILL.md): Route miscellaneous project-support work that lacks a more specific Imsight owner, currently including project-local Docker service setup.
- [`imsight-reporting`](imsight-reporting/SKILL.md): Produce concise daily work reports from same-day Git history, uncommitted changes, nested repositories, and authoritative project materials for readers outside the repository.
