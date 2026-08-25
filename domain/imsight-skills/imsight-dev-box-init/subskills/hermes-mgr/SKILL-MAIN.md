---
name: hermes-mgr
description: Use when an Imsight dev-box task configures Hermes Agent with Kimi Coding Plan or Feishu, repairs Feishu approval callbacks, deploys a local Hindsight memory server backed by the Kimi API, connects Hermes to Hindsight, verifies the stack, or removes retained memories.
metadata:
  skill_invocation_notation: >
    Top-level skill entrypoints use SKILL.md. Parent-scoped subskill entrypoints use
    SKILL-MAIN.md and are loaded explicitly through their parent; nested SKILL.md is
    accepted only as legacy input when SKILL-MAIN.md is absent.
    Skill and subskill entrypoints use bare object paths: `X` invokes skill X and
    `X->Y->Z` invokes subskill Z. Subcommands use parenthesized components:
    `X->cmd()` invokes a direct subcommand, `X->Y->cmd()` invokes a subcommand of
    subskill Y, and `X->parent()->child()` invokes child subcommand child exposed
    by parent subcommand parent. Intermediate subcommands act as object generators.
    Forms such as `X()` and `X->Y()` are invalid for skill or subskill entrypoints.
---

# Hermes Manager

## Overview

Use this subskill to manage the supported Hermes Agent, Feishu gateway integration, and local Hindsight stack. Hermes and Hindsight both call Kimi Coding Plan through its API; no local LLM is deployed.

## Workflow

1. Select a command from **Subcommands** based on the requested stage or operation.
2. Load `references/verified-defaults.md` and the selected command page.
3. Check the command's prerequisites and refuse any missing predecessor state it declares.
4. Execute the command while preserving credentials, unrelated Hermes configuration, and persistent Hindsight data.
5. Run the command's verification and report changed state and remaining user action.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this subskill's commands, verified defaults, resources, constraints, and user request, then execute the plan.

## Invocation Contract

- Invoke `imsight-dev-box-init->hermes-mgr` to summarize the supported stack and command order.
- Invoke a command as `imsight-dev-box-init->hermes-mgr-><subcommand>()`.
- Invoke `imsight-dev-box-init->hermes-mgr->full-setup()` to run the complete setup sequence.
- Invoke `imsight-dev-box-init->hermes-mgr->help()` to list the commands below.

## Subcommands

### Procedural Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `configure-kimi` | Configure Hermes Agent to use Kimi Coding Plan with `k3-256k`. | `commands/configure-kimi.md` |
| `deploy-hindsight` | Deploy the local persistent Hindsight server with Kimi as its remote LLM. | `commands/deploy-hindsight.md` |
| `connect-hindsight` | Connect Hermes to the running Hindsight API in `local_external` mode. | `commands/connect-hindsight.md` |
| `verify-stack` | Verify Hermes, Kimi routing, Hindsight health, persistence, loopback ports, and gateway state. | `commands/verify-stack.md` |

### Helper Subcommands

No helper subcommands are currently exposed.

### Misc Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `configure-feishu` | Configure or verify the Hermes Feishu gateway, including the paired-user allowlist workaround for approval buttons that do not resume the agent. | `commands/configure-feishu.md` |
| `full-setup` | Run all procedural commands in the required order. | `commands/full-setup.md` |
| `operate-hindsight` | Start, stop, restart, inspect, or deliberately upgrade the Hindsight container. | `commands/operate-hindsight.md` |
| `forget-memory` | Soft-invalidate one fact or permanently delete an explicitly scoped Hindsight document, memory set, or bank. | `commands/forget-memory.md` |
| `help` | Explain this subskill and list its public commands. | This entrypoint |

## Shared Defaults

- Hermes provider: `kimi-coding`
- Hermes default model: `k3-256k`
- Hermes Kimi endpoint: `https://api.kimi.com/coding`
- Hermes reasoning effort: `high`
- Hindsight image: `ghcr.io/vectorize-io/hindsight:0.8.5`
- Hindsight Kimi endpoint: `https://api.kimi.com/coding/v1`
- Hindsight model: `k3-256k`
- Hindsight API: `http://127.0.0.1:18888`
- Hindsight UI: `http://127.0.0.1:19999`
- Hindsight volume: `hermes-hindsight-data`
- Hermes Hindsight mode: `local_external`
- Memory mode: `hybrid`
- Bank template: `hermes-{profile}-{platform}-{user}`

Treat these as the maintained snapshot, not timeless upstream defaults. Verify current releases and provider documentation before intentionally changing versions, model identifiers, or endpoint contracts.

## Resource Ownership

This subskill owns its command pages, verified Hermes/Hindsight defaults, Compose asset, credential updater, Feishu pairing-to-allowlist synchronizer, Hindsight config updater, and non-mutating stack verifier.

## Guardrails

- DO NOT print, commit, or embed Kimi credentials in Compose files, skill artifacts, logs, or final responses.
- DO NOT bind the unauthenticated Hindsight API or UI to a non-loopback interface unless the user explicitly requests and secures remote access.
- DO NOT deploy a local LLM when the requested design uses Kimi API inference.
- DO NOT delete Hindsight volumes, banks, documents, or memories without resolving the exact scope and obtaining explicit authorization.
- DO NOT overwrite unrelated Hermes configuration or replace the protected `~/.hermes/.env` file wholesale.
- DO NOT enable unrestricted Feishu access to repair approval callbacks; mirror only already approved paired users into the static allowlist.
