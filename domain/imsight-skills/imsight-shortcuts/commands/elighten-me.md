---
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

# Elighten Me

## Workflow

1. Resolve the subject and mentality using **Inputs and Defaults**.
2. Load [imsight-mentality-mgr](../../imsight-mentality-mgr/SKILL.md) and resolve the guidance through **Mentality Selection**.
3. Explain the resolved subject in the current reply using that guidance and the user's requested depth, language, and format.

For other explanation requests, use your native planning tool to build and execute a plan using the available subject, chosen mentality, and scope of this shortcut.

## Inputs and Defaults

- **Subject.** Explain the topic, question, or material the user supplies. When the subject is omitted, explain the most recent substantive assistant reply before the invocation. If there is no such reply, ask what to explain.
- **Mentality.** An explicit request to use a mentality or flavor takes precedence for this reply. Use Han Style (`human-speak/han-style`) by default. A request that supplies only a mentality still uses the previous reply as the subject.

## Mentality Selection

For Han Style, load the [Human Speak subskill](../../imsight-mentality-mgr/subskills/human-speak/SKILL-MAIN.md). Read the maintained principles linked from the application section of [`imsight-mentality-mgr->human-speak->han-style()`](../../imsight-mentality-mgr/subskills/human-speak/commands/han-style.md#applying-the-flavor) and apply them to this reply.

For another requested mentality, use the [manager's subskill inventory](../../imsight-mentality-mgr/SKILL.md#subskills) to load the named subskill and the applicable flavor command, if any. Read and apply the relevant principles for this reply. Ask which mentality or flavor the user meant if the explicit request remains unresolved.

## Guardrails

- DO NOT execute the selected mentality's management, recall, or review actions as part of the explanation.
- DO NOT persist the shortcut's mentality selection.
