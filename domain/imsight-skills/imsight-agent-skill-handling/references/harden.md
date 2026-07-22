# Harden Skill

## Workflow

Use this reference to harden a discipline-enforcing skill against rationalization. This is the REFACTOR phase of test-driven skill authoring.

1. **Locate the target skill and entrypoint**. Resolve the skill folder from the user's request and resolve one unambiguous `SKILL.md` or `SKILL-MAIN.md` runtime entrypoint according to its standalone or parent-scoped role.
2. **Confirm the skill type**. Hardening applies primarily to discipline-enforcing skills. For technique, pattern, or reference skills, use `format` instead.
3. **Identify rationalizations**. Read test reports, run `test` in baseline mode, or ask the user for excuses agents have used.
4. **Add a foundational principle** early in the skill. See **Foundational Principle**.
5. **Close loopholes explicitly**. See **Close Loopholes**.
6. **Build a rationalization table**. See **Rationalization Table**.
7. **Create a red flags list**. See **Red Flags**.
8. **Update the description** to include symptoms of an impending violation.
9. **Re-test** the skill under pressure. See **Re-Verify**.
10. **Report results**. Summarize changes made and remaining gaps.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the available hardening guidance and the user's request, then execute the plan.

## Foundational Principle

Add a bright-line principle near the top of the skill, after the overview:

```markdown
**Violating the letter of the rules is violating the spirit of the rules.**
```

This cuts off "spirit vs letter" rationalizations.

## Close Loopholes

For each rule, forbid specific workarounds explicitly.

Before:

```markdown
Write code before test? Delete it.
```

After:

```markdown
Write code before test? Delete it. Start over.

**No exceptions:**
- Don't keep it as "reference".
- Don't "adapt" it while writing tests.
- Don't look at it.
- Delete means delete.
```

## Rationalization Table

Add a table that pairs common excuses with reality checks:

```markdown
| Excuse | Reality |
| --- | --- |
| "Too simple to test" | Simple code breaks. Testing takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing. |
| "Tests after achieve same goals" | Tests-after asks "what does this do?" Tests-first asks "what should this do?" |
```

Populate the table with excuses observed during testing or provided by the user.

## Red Flags

Add a self-check list agents can use when they feel tempted to violate the rule:

```markdown
## Red Flags - STOP and Start Over

- Code before test
- "I already manually tested it"
- "Tests after achieve the same purpose"
- "It's about spirit not ritual"
- "This is different because..."

**All of these mean: Delete code. Start over with TDD.**
```

## Update Description

Add symptoms of an impending violation to the skill's frontmatter description:

```yaml
---
name: example-skill
description: Use when you wrote code before tests, when tempted to test after, or when manually testing seems faster
---
```

The description must still start with "Use when..." and remain under 1024 characters.

## Re-Verify

After hardening, run the skill through pressure scenarios again using `test` in verify mode. Confirm:

- The agent chooses the correct option.
- The agent cites the new sections.
- The agent acknowledges temptation but follows the rule.

If new rationalizations appear, repeat the hardening cycle.

## Output Contract

By default, `harden` edits the target skill files in place and writes no analysis report. It returns a brief chat summary with changed files, rationalizations addressed, and any remaining gaps.
