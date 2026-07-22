# Help

## Workflow

When this subcommand is invoked, execute these steps in order.

1. **Summarize the skill**. Say that `imsight-project-design` creates staged Imsight feature-design planning artifacts at a user-specified location first, then inside an OpenSpec change directory when targeting one (`<openspec-change-dir>/imsight-design/`), then `IMSIGHT_SKILL_OUTPUT_DIR`, then `.imsight-arts/feature-design/`.
2. **List public subcommands**. Include `help`, `scaffold`, `define-feature`, `design-usecase`, `design-interface`, `design-skill`, `design-agent-task`, and `manual-refine` with one-line descriptions. Mention that `design-skill` is for agent-skill features, `design-interface` is for non-skill interfaces and contracts, and `manual-refine` records user-directed decisions as ADRs and propagates them into affected artifacts.
3. **Explain staging**. State that each procedural subcommand should complete one planning stage and pause for review unless the user explicitly requests a sequence. Explain that `manual-refine` is a cross-stage conversational command that yields while waiting and remains active across refinement turns until the user exits it.
4. **Suggest the next subcommand** based on the current request, if one is apparent.

If the task does not map cleanly to a subcommand, explain the available subcommands and ask which one to run.
