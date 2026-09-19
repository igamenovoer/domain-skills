# Design Profiling Campaign

Use this subcommand to create a performance profiling campaign directory structure with a checkbox-driven plan, logs directory for evidence and findings, and optional reports directory.

## Workflow

When this subcommand is invoked, execute these steps in order.

1. **Resolve the campaign output directory** using the **Campaign Output Directory** rules below.
2. **Capture the profiling intent** from the request and available context: the performance question being investigated (e.g., which stage dominates, source vs integrated comparison), the comparison arms, hypotheses to test, measurement boundaries, and what optimizations are explicitly not authorized.
3. **Create the campaign folder structure** with `logs/` and optional `reports/` subdirectories.
4. **Write the campaign README** at `<campaign-dir>/README.md` following **Campaign README Format**.
5. **Write the root plan document** at `<campaign-dir>/plan.md` following **Profiling Plan Format**.
6. **Report the scaffold**. List created directories and files, summarize the captured intent, and suggest defining hypotheses and execution steps.

If the task does not map cleanly to these steps, create the minimum safe skeleton and report what decisions are needed before proceeding.

## Campaign Output Directory

Resolve the campaign directory in this order:

1. Use an absolute or host-project-relative output location explicitly provided by the user.
2. If `IMSIGHT_SKILL_OUTPUT_DIR` is set, use `<IMSIGHT_SKILL_OUTPUT_DIR>/profiling/<YYYY-MM-DD-kebab-campaign-name>/`.
3. Otherwise, use `<host-project-dir>/context/campaigns/profiling/<YYYY-MM-DD-kebab-campaign-name>/` with the current local date.

If the user gives a campaign root and a campaign name, create `<campaign-root>/<YYYY-MM-DD-kebab-campaign-name>/` unless the root already names the intended campaign directory. If the task appears to continue an existing campaign, search the user-provided location, then `IMSIGHT_SKILL_OUTPUT_DIR`, then `context/campaigns/profiling/`, for matching directory names or plan titles before creating a new directory.

## Campaign README Format

The campaign README is a short index document explaining the directory structure:

```markdown
# <Campaign Name>

<One-sentence campaign purpose>

See [plan.md](plan.md) for the complete profiling plan.

## Directory Structure

- **plan.md** — Checkbox-driven profiling plan with hypotheses, execution steps, and completion audit
- **logs/** — Evidence, findings, execution details, traces, and measurements
- **reports/** — Optional synthesis documents and follow-up reports
```

## Profiling Plan Format

The profiling plan is a single checkbox-driven execution document with these sections:

```markdown
# <Campaign Title>

Status: <status>. <Links to related campaigns or features>

## Question and deliverables

- [ ] Primary question: what performance aspect to investigate
- [ ] Deliverables: what artifacts to produce
- [ ] Boundaries: what not to do

## Existing evidence and comparability

- [ ] What prior evidence to reuse
- [ ] What controls exist
- [ ] What limitations to note

## Hypotheses: <category>

- [ ] **H1 — <Hypothesis name>:** <Test description>. Support if <condition>; weaken if <alternative>.
- [ ] **H2 — <Hypothesis name>:** <Test description>. Support if <condition>; reject if <failure mode>.

## Minimum valid experiment

- [ ] Workload specification (model, batch, context, settings)
- [ ] Required arms (baseline, variants, controls)
- [ ] Timing boundaries (what to include/exclude)
- [ ] Environment requirements

## Instrumentation and placement

### Required before first run

- [ ] Instrumentation setup steps
- [ ] Validation checks

### Conditional instrumentation

- [ ] Optional probes (only when needed to discriminate alternatives)
- [ ] Stop conditions

## Preflight and execution record

- [ ] Resource verification (GPU, disk, environment)
- [ ] Exact commands with placeholders
- [ ] Execution checklist

## Readout, conditional follow-up and stopping

- [ ] Analysis steps
- [ ] Conditional branches based on results
- [ ] Stop conditions (when to halt investigation)

## Completion audit

- [ ] Scope verification
- [ ] Deliverables check
- [ ] Cleanup verification
```

Follow these plan-writing principles:

- **Use checkboxes liberally** throughout all sections for tracking progress
- State hypotheses as testable propositions with support/reject conditions
- Distinguish required steps from conditional steps clearly
- Include exact command templates with placeholders for reproduction
- Specify stop conditions explicitly (when to halt profiling work)
- Mark skipped conditional items with explicit reasons ("**Skipped X:** reason")
- Update status inline as work progresses

## Artifact Contracts

**`README.md`**: Campaign index with one-sentence purpose, link to plan, and directory structure explanation. Written once during scaffold.

**`plan.md`**: Single checkbox-driven profiling plan with question, hypotheses, execution steps, and completion audit. Living document that gets updated with inline status as work progresses. Checkboxes track completed vs pending work.

**`logs/`**: Directory for all evidence, findings, and execution artifacts:
- `findings.md` — Main results, recommendations, ranked next steps
- `evidence.md` — Detailed measurements, commands, artifact hashes, locations
- `execution.md` — Execution log with timestamps, decisions, observed issues
- `trace-queries.md` — Direct timeline inspection results (when applicable)
- `code-contrast.md` — Code comparison between arms (when applicable)
- JSON files for partial results, progress tracking, decisions
- Monitor logs, HTML summaries, traces (typically ignored/external)

**`reports/`** (optional): Synthesis documents, termination reports, follow-up analyses. Created lazily when needed.

## Writing Principles for Profiling Campaigns

Follow these patterns observed in systematic profiling campaigns:

### Checkbox-driven execution
- Every action gets a checkbox, checked when verified
- Conditional items explicitly marked when skipped ("**Skipped fresh dense arm:** reason")
- Status updates happen inline as work progresses, not deferred to final report

### Hypotheses not questions
- Label as H1, H2, H3... not KQ-1, KQ-2...
- State testable propositions with support/reject conditions
- Disposition recorded inline in the hypothesis checkbox

### Single-shot with branches
- One plan document with conditional paths, not multiple iteration files
- Branches marked as "Conditional X: only when Y" sections
- Stop conditions prevent unnecessary profiling work

### Exact reproduction
- Command templates with exact paths and placeholders
- Hash verification for all artifacts
- Environment classification (stable/degraded/unstable)

### Evidence in logs/
- All findings, evidence, execution in logs/ directory
- No separate evidences/ subdirectory
- findings.md is the main result; evidence.md has raw data

### Performance focus
- Timing measurements with margins (e.g., 3% relative parity)
- Stage attribution (which kernel/operation dominates)
- Source-relative comparisons when applicable
- Perturbed vs unprofiled measurements distinguished

## Templates

Templates at `assets/templates/profiling/` are **suggestive, not enforced**:

- `README.md`: Campaign index with directory purposes
- `plan.md`: Checkbox-driven profiling plan
- `logs/findings.md`: Results and recommendations template
- `logs/evidence.md`: Measurements and artifacts template
- `logs/execution.md`: Execution log template

**Template flexibility**: These templates indicate what information is preferred in each document type, not mandatory structure. Agents may adjust sections, add domain-specific hypotheses, or reorganize based on the profiling task. The plan structure benefits from consistency for checkbox tracking; logs vary naturally by measurement type.

Use these templates when creating profiling artifacts.

## Campaign Directory Structure

Create these subdirectories:

- **`logs/`**: All evidence, findings, execution details, measurements, and trace queries
- **`reports/`** (optional): Created lazily when synthesis documents or follow-up reports are needed

Do not create subdirectories for `key-questions/`, `iterations/`, `evidences/`, or `goal/`. Profiling campaigns use a simpler, flatter structure than debug campaigns.

## Guardrails

- DO NOT overwrite an existing campaign directory during scaffold unless the user explicitly asks.
- DO NOT assume the host project's profiling workflow; infer conventions from existing `context/campaigns/profiling/` if present.
- DO NOT create campaign artifacts outside the resolved campaign directory without explicit user direction.
- DO NOT fill in measurement results during scaffold; keep the plan and structure separate from execution data.
- DO NOT treat templates as rigid requirements; adapt structure to fit the profiling task while preserving checkbox tracking and hypothesis testing.
- DO NOT create iteration or key-question subdirectories; profiling campaigns use a single plan with conditional branches.

## Next Steps

After scaffolding, suggest:
1. Defining hypotheses (H1, H2, H3...) in the plan with testable conditions
2. Specifying the minimum valid experiment (arms, workload, timing boundaries)
3. Adding exact command templates for reproduction
4. Reading existing profiling campaigns in the project for local conventions
