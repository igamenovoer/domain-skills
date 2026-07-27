# Modify Skill

## Workflow

Use this reference to amend the behavior, content, resources, metadata, or public interface of an existing skill. `modify` applies the requested amendment only after the target conforms to the bundled Imsight format.

1. **Locate the target skill and entrypoint**. Resolve the skill folder from the user's request and select one unambiguous `SKILL.md` or `SKILL-MAIN.md` runtime entrypoint according to **Target Resolution**.
2. **Capture the modification contract**. Record the requested outcome, affected capability, explicit constraints, approval boundaries, and any wording that delegates unattended judgment. See **Modification Scope** and **Consent Policy**.
3. **Load the format contract**. Read `references/imsight-skill-style-guide.md` and `references/format.md` from this skill directory.
4. **Inspect the target surface**. Read the runtime entrypoint, relevant executable pages and bundled resources, `agents/openai.yaml` when present, repository instructions, and existing local changes.
5. **Evaluate format conformance without editing**. Apply **Conformance Gate** to the target's complete executable surface.
6. **Resolve a failed conformance gate** according to **Consent Policy**.
   - If prior user wording authorizes formatting, run the complete `format` workflow first.
   - If prior user wording delegates unattended judgment, decide whether to format; a target that remains nonconforming cannot proceed to modification.
   - Otherwise, report the specific gaps, ask whether to format first, and wait for the user's answer.
   - After formatting, re-read the target and repeat the conformance gate.
7. **Plan the smallest complete amendment**. Use the native planning tool when the change spans several files or behaviors, and preserve unrelated local changes.
8. **Apply the requested modification**. Follow **Editing Rules**, updating every affected route, instruction, resource, example, and metadata field needed for a coherent result.
9. **Validate the amended skill**. Follow **Validation**, including the platform skill validator and artifact-specific checks when available.
10. **Report the result**. Follow **Output Contract**, distinguishing any prerequisite formatting from the requested modification.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the modification contract, bundled format rules, target skill, and user constraints, then execute the plan without bypassing the conformance gate.

## Target Resolution

Use the target folder explicitly provided by the user. Otherwise, apply the entrypoint's **Target Skill Folder** rules.

- A standalone or host-discoverable skill uses `SKILL.md`.
- A parent-scoped subskill uses `SKILL-MAIN.md`.
- A folder containing both runtime entrypoint candidates is ambiguous and fails the gate.
- `SKILL-SOURCE.md` is provenance and cannot be the mutation target.
- A suite-level request must identify which member skills may be amended unless the user explicitly authorizes a suite-wide operation.

## Modification Scope

Use `modify` for focused changes to an existing skill, including:

- adding, changing, or removing a capability or subcommand;
- correcting workflow behavior, instructions, examples, or output contracts;
- updating bundled scripts, references, commands, assets, or templates;
- synchronizing routing, metadata, and documentation after a requested behavioral change;
- fixing a defect that spans skill prose and its bundled resources.

Choose another subcommand when its specialized contract is the actual task:

| Task | Subcommand |
| --- | --- |
| Create a new skill | `create` |
| Make only structural or description-format corrections | `format` |
| Migrate or refactor source skill logic with provenance | `refactor-migrate` |
| Add rationalization defenses to a discipline skill | `harden` |
| Run pressure scenarios | `test` |

The modification contract is limited to the user's requested outcome. Permission to amend a skill does not by itself authorize prerequisite formatting, destructive cleanup, migration, publication, or unrelated improvements.

## Conformance Gate

Evaluate conformance before making any modification. Inspection is read-only. A validator passing by itself is not sufficient.

The target passes only when all applicable bundled format rules hold:

1. The runtime entrypoint role and filename are unambiguous.
2. The entrypoint and every executable subcommand-like page have a `## Workflow` near the top, concise numbered steps, and the required freeform fallback.
3. The entrypoint has concise skill-specific guardrails whose bullets begin with `DO NOT ...`.
4. The frontmatter description follows **Description Optimization** in `references/format.md`.
5. The subcommand structure flavor, nested routes, subskills, invocation notation, resource ownership, links, and runtime metadata follow the bundled style guide.
6. Direct subskills use `SKILL-MAIN.md`, have no sibling `SKILL.md`, are listed by their parent, and have usable routing guidance.
7. The available skill validator succeeds, and inspection finds no unresolved structural style gaps.

If any applicable item fails, classify the target as nonconforming and use **Consent Policy**. Do not partially modify the target while deciding whether to format it.

## Consent Policy

Interpret the user's wording by intent, not by requiring an exact phrase.

| User signal | Required action |
| --- | --- |
| Explicitly authorizes formatting when needed, such as "format it first if necessary" | Run `format`, re-check conformance, then modify |
| Delegates the decision or requests unattended completion, such as "decide on your own", "use your judgment", or "handle it unattended" | Decide without pausing; when format gaps block modification and formatting stays within scope, run `format`, re-check, then modify |
| Requests modification without addressing prerequisite formatting | If the target is nonconforming, explain the gaps and ask whether to run `format` first; wait for consent |
| Explicitly refuses formatting | Do not modify a nonconforming target; report that the prerequisite was declined |

Consent must precede formatting unless it was already granted or delegated. Silence and an ordinary request to modify are not consent to format. Delegated judgment covers the prerequisite decision only; it does not waive approval for destructive, external, privileged, or materially out-of-scope actions.

After `format` completes, run the conformance gate again. If the target still fails, stop and report the remaining gaps rather than applying the requested amendment.

## Editing Rules

- Preserve the target's trigger boundary, public interface, output contracts, and domain guardrails unless the requested outcome requires a specific change.
- Make the smallest complete set of edits that implements the modification contract.
- Preserve unrelated tracked and untracked user changes; inspect diffs before and after editing.
- Keep the runtime entrypoint concise and place detailed executable procedures in linked pages.
- Synchronize the entrypoint, help text, routes, agent metadata, bundled resources, and examples when the changed behavior affects them.
- Do not create provenance artifacts for an ordinary modification.
- Do not perform publication, installation, deployment, or system mutation unless the user requests it or it is an ordinary in-scope implementation step with the required authority.

## Validation

Run checks proportional to the amended skill:

1. Run the available platform skill validator against the complete target folder.
2. Re-run the **Conformance Gate** against the final executable surface.
3. Check links, subcommand inventories, help text, and `agents/openai.yaml` for stale behavior or names.
4. Run syntax checks and focused tests for changed scripts or other executable resources.
5. Inspect the final diff for accidental reformatting, unrelated edits, stale references, and omitted files.

Pressure testing remains the responsibility of the explicit `test` subcommand unless the user includes it in the modification request.

## Guardrails

- DO NOT edit a target before it passes the conformance gate.
- DO NOT treat an ordinary modification request or user silence as consent to format.
- DO NOT continue modifying a nonconforming target after the user declines prerequisite formatting.
- DO NOT let delegated unattended judgment expand the requested modification or authorize destructive or external actions.
- DO NOT overwrite unrelated local changes while amending the target skill.
- DO NOT substitute `modify` for a provenance-preserving migration.

## Output Contract

When the conformance gate requires consent, return a concise pause report containing:

- the target skill and entrypoint;
- the specific conformance gaps;
- the proposed use of `format`;
- one direct question asking for consent.

Do not report the requested modification as started or completed at that point.

After successful modification, return a brief chat summary containing:

- the requested behavior that changed;
- the files changed;
- whether prerequisite formatting ran and why it was authorized;
- validation and focused tests run;
- any unresolved issue or explicit next step.

By default, `modify` edits the target skill in place and creates no analysis, provenance, migration, or changelog artifacts.
