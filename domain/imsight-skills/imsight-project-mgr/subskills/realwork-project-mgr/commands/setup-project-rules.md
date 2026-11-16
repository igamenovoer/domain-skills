# Set Up Project Rules

## Workflow

1. **Resolve target files and owners.** Honor explicit targets. Otherwise inspect existing agent instructions and the parent responsibility contract. Development policy belongs in meta `AGENTS.md`; product usage, test prerequisites and attachment instructions belong in realwork `AGENTS.md`.
2. **Choose mode.** Use automatic relevance selection unless the user requests interactive rule-by-rule review. Collect evidence from manifests, code, testing, and existing policy before proposing a rule.
3. **Select relevant rules.** Use **Rule Catalog**; preserve stronger existing policy and skip unsupported or duplicate rules. A Python file alone does not establish MyPy or a breaking-change policy.
4. **Apply once.** In interactive mode first collect the requested approvals without editing. Then reconcile one `BEGIN IMSIGHT PROJECT RULES` / `END IMSIGHT PROJECT RULES` block per target, preserving unowned content.
5. **Verify.** Check ownership, balanced markers, semantic duplication, and idempotency. Report evidence, selected/skipped rules, and targets.

For a cross-owner request, plan both instruction files together rather than copying the same rule block into every checkout.

## Rule Catalog

| ID | Rule | Evidence |
| --- | --- | --- |
| R1 | Keep Markdown prose on logical lines without hard wrapping. | Maintained Markdown. |
| R2 | Use precise Python types and NumPy-style public docstrings. | Python development with public interfaces. |
| R3 | Run the adopted type checker for changed Python scope. | Existing MyPy or equivalent configuration. |
| R4 | Use Doxygen-style public C++ documentation. | Public C++ source. |
| R5 | Prefer direct current design over compatibility layers only where the project permits breaking changes. | Explicit compatibility policy; pre-1.0 alone is insufficient. |
| R6 | Repair affected callers when changing a contract; preserve unrelated work. | Existing dependent code or workflows. |
| R7 | Implement features and feature tests in the selected realwork; keep development policy, plans, skills, and OpenSpec in meta. | Meta/realwork arrangement. |
| R8 | Name the target checkout and environment for product commands; isolate outputs and coordinate shared meta edits. | Parallel development workspace. |

R1–R6 are engineering guidance when installed for development; keep them in the meta owner's file when attached. R7–R8 may appear as concise routing guidance in both files, tailored to the reader. Do not create extra host-specific instruction files when one shared `AGENTS.md` is sufficient.

## Interactive and Managed Updates

For interactive review, present one relevant rule at a time with its complete proposed text, supporting evidence, and intended target file. Wait for that decision before the next rule unless the user explicitly asks to decide a group. Gather decisions without editing, then update once. Automatic mode selects only rules whose relevance is established; ambiguous compatibility or tool adoption stays unchanged.

Reuse a managed block in place, render only selected rules not already stated elsewhere, and remove an empty owned block rather than leaving duplicate headings. Content outside the owned block remains unchanged. A user request for a concrete rewrite can authorize wider edits; ordinary rule setup does not.
