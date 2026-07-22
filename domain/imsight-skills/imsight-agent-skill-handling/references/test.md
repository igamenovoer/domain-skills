# Test Skill

## Workflow

Use this reference to run pressure scenarios with subagents to baseline or verify a skill.

1. **Locate the target skill and entrypoint**. Resolve the skill folder from the user's request and resolve one unambiguous `SKILL.md` or `SKILL-MAIN.md` runtime entrypoint according to its standalone or parent-scoped role.
2. **Determine the test mode**. See **Test Mode**.
3. **Design or load pressure scenarios**. See **Pressure Scenarios**.
4. **Run the scenarios** with subagents. See **Running Scenarios**.
5. **Capture results** verbatim. See **Capture Results**.
6. **Report findings** and recommend skill edits. See **Output Contract**.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the available testing guidance and the user's request, then execute the plan.

## Test Mode

Choose the mode based on what the user wants:

| Mode | When to Use |
| --- | --- |
| Baseline | Run scenarios **without** the skill to document natural failure. This is the RED phase. Use this when creating a new skill or adding a new rule. |
| Verify | Run scenarios **with** the skill to confirm compliance. This is the GREEN phase. Use this after writing or editing a skill. |

`create` no longer runs these phases automatically. Invoke `test` explicitly when the user wants a failing baseline, a compliance verification, or both.

## Pressure Scenarios

A good pressure scenario:

- Presents a realistic situation with concrete constraints (paths, times, consequences).
- Forces the agent to choose or act, not just describe.
- Combines 2-3 pressures for discipline skills: time, sunk cost, authority, economic, exhaustion, social, pragmatic.
- Targets the exact failure the skill must prevent.

Example combined-pressure scenario:

```markdown
You spent 3 hours and 200 lines on a feature. It works and you manually tested it.
It's 6pm, dinner at 6:30pm, code review tomorrow at 9am. You just realized you
forgot to write tests first.

Options:
A) Delete the 200 lines, start fresh tomorrow with TDD.
B) Commit now and add tests tomorrow.
C) Write tests now (30 min delay), then commit.

Choose A, B, or C and act.
```

## Running Scenarios

1. Spawn a fresh-context subagent for each scenario.
2. Provide the scenario prompt.
3. For verify mode, make the skill available to the subagent.
4. For baseline mode, do not give the subagent the skill.
5. Run 3+ scenarios for discipline skills; 1-2 may be enough for technique or reference skills.

## Capture Results

For each scenario, record:

- The scenario text.
- The agent's choice or action.
- Verbatim rationalizations.
- Whether the agent complied with the skill's rule (verify mode) or violated it (baseline mode).
- Any new rationalizations that the skill does not yet address.

## Output Contract

By default, `test` writes a Markdown test report under `<output-dir>` and returns a brief in-chat summary.

Resolve `<output-dir>` in this order:

1. Use the output location explicitly provided by the user.
2. Otherwise, use `AGENT_SKILL_OUTPUT_DIR` when set; relative values are resolved from the current project directory and absolute values are used as-is.
3. Otherwise, use `<project-dir>/.imsight-arts/agent-skill-handling/testing/<target-skill-name>/`.

Write the report as `<output-dir>/TEST-REPORT.md`.

The report must include:

- Test mode (baseline or verify).
- Scenarios run.
- Results per scenario.
- Rationalizations captured.
- Recommended skill edits, if any.

The chat summary must include:

- The skill tested.
- Number of scenarios run.
- High-level pass/fail summary.
- Path to the test report.
