# Render Invocation

Use this primitive whenever the master must render a command for a slave's native skill invocation syntax.

## Workflow

1. Gather the tool lane, invocation family, operation, and request body from **Inputs**.
2. Choose the matching command from **Raw OpenSpec Commands** or **Slave Skill Commands**.
3. Preserve the request, target, change identifier, and constraints in the rendered command.
4. Validate the result against **Rules** before delivery.

If the task does not map cleanly to these steps, plan only from the listed command families and rules; ask for an unknown tool lane or operation instead of guessing.

## Inputs

- Slave tool lane from [inspect-slave.md](inspect-slave.md), especially `codex` or `claude`.
- Invocation family: raw OpenSpec skill or `imsight-autodev-slave` skill.
- Operation name and request body to preserve.

## Raw OpenSpec Commands

| Operation | Codex slave | Claude slave |
| --- | --- | --- |
| Explore | `$openspec-explore <request>` | `/openspec-explore <request>` |
| Propose | `$openspec-propose <request>` | `/openspec-propose <request>` |
| Apply change | `$openspec-apply-change <change-or-request>` | `/openspec-apply-change <change-or-request>` |
| Sync specs | `$openspec-sync-specs <change-or-request>` | `/openspec-sync-specs <change-or-request>` |
| Archive change | `$openspec-archive-change <change-or-request>` | `/openspec-archive-change <change-or-request>` |

Raw OpenSpec commands target skills that live on the slave. Use them for one bounded OpenSpec phase when the master already knows the right phase.

## Slave Skill Commands

| Operation | Codex slave | Claude slave |
| --- | --- | --- |
| Initialize OpenSpec | `$imsight-autodev-slave init-openspec <request>` | `/imsight-autodev-slave init-openspec <request>` |
| One-pass lifecycle | `$imsight-autodev-slave openspec-one-pass <master request>` | `/imsight-autodev-slave openspec-one-pass <master request>` |

Slave skill commands target predefined operations owned by `imsight-autodev-slave`. Use them when the master wants the slave skill to select and perform its maintained workflow.

## Rules

- Preserve the user's request text, target repository/workspace, change id, and constraints in the rendered command.
- If the tool lane is unknown, ask for clarification instead of guessing.

## Guardrails

- DO NOT mix Codex `$...` syntax with Claude `/...` syntax.
- DO NOT render raw OpenSpec commands for predefined slave-skill operations such as `init-openspec`.
- DO NOT render `imsight-autodev-slave` commands when the intent is a direct single OpenSpec phase unless the workflow explicitly selects the slave mega-skill.
