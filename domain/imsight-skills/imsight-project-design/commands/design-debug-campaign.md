# Design Debug Campaign

Use this subcommand to create a systematic debug investigation campaign directory structure with intent, key questions, iterations, evidences, and reports.

## Workflow

When this subcommand is invoked, execute these steps in order.

1. **Resolve the campaign output directory** using the **Campaign Output Directory** rules below.
2. **Capture the debug intent** from the request and available context: the problem being investigated, the divergence or bug being localized, the comparison arms (e.g., source vs maintained, A100 vs B200), success criteria, scope boundaries, and what product changes are explicitly not authorized.
3. **Create the campaign folder structure** with subdirectories for `key-questions/`, `iterations/`, `evidences/`, and `reports/`.
4. **Write the campaign README** at `<campaign-dir>/README.md` following **Campaign README Format**.
5. **Write the root intent document** at `<campaign-dir>/debug-intent.md` following **Debug Intent Format**.
6. **Report the scaffold**. List created directories and files, summarize the captured intent, and suggest starting with the first key question or iteration plan.

If the task does not map cleanly to these steps, create the minimum safe skeleton and report what decisions are needed before proceeding.

## Campaign Output Directory

Resolve the campaign directory in this order:

1. Use an absolute or host-project-relative output location explicitly provided by the user.
2. If `IMSIGHT_SKILL_OUTPUT_DIR` is set, use `<IMSIGHT_SKILL_OUTPUT_DIR>/debug/<YYYY-MM-DD-kebab-campaign-name>/`.
3. Otherwise, use `<host-project-dir>/context/campaigns/debug/<YYYY-MM-DD-kebab-campaign-name>/` with the current local date.

If the user gives a campaign root and a campaign name, create `<campaign-root>/<YYYY-MM-DD-kebab-campaign-name>/` unless the root already names the intended campaign directory. If the task appears to continue an existing campaign, search the user-provided location, then `IMSIGHT_SKILL_OUTPUT_DIR`, then `context/campaigns/debug/`, for matching directory names or debug-intent titles before creating a new directory.

## Campaign README Format

The campaign README is a short index document explaining the purpose of each subdirectory:

```markdown
# <Campaign Name>

<One-sentence campaign purpose>

See [debug-intent.md](debug-intent.md) for the complete campaign description.

## Directory Structure

- **debug-intent.md** — Root campaign document with problem statement, scope, boundaries, and status updates
- **key-questions/** — Testable questions with propositions, answers, and scope declarations (KQ-N-<slug>.md)
- **iterations/** — Execution plans with frozen workload, predeclared arms, gates, and checklists (YYYY-MM-DD-plan-N-<slug>.md)
- **evidences/** — Raw measurement data from experiments with tables, commands, and hardware identity (YYYY-MM-DD-<observation>.md)
- **reports/** — Theory synthesis and evaluation across multiple evidences (YYYY-MM-DD-<topic>.md)
```

## Debug Intent Format

The root intent document must contain:

- **Title**: `# Debug Intent: <Campaign Name>`
- **Date and Status**: Line showing creation date, last update, current status (planned, active, iteration N planned/complete, resolved, abandoned)
- **Problem Statement**: What divergence, bug, or correctness question is being investigated
- **Comparison Arms**: What implementations, environments, or configurations are being compared (e.g., paper source vs maintained implementation, different hardware, different settings)
- **Starting Evidence**: Initial observations, measurements, or failures that motivated the campaign
- **Scope and Implementation Boundary**: What's in scope, what tools/harnesses can be used, what source trees remain read-only, what's out of scope
- **Success Criteria**: What dispositions count as resolution (e.g., selection mismatch identified, bug confirmed, numerical issue characterized)
- **No-Product-Change Declaration**: Explicit statement when the campaign is diagnostic only and does not authorize changing production code, kernels, or bundles
- **Campaign Directory Reference**: Relative path to the campaign directory itself for discoverability
- **Links**: References to key questions and iterations as they are created

Follow these intent-writing principles:

- State the problem precisely with exact artifacts, versions, configurations, and measurements
- Distinguish observation (what differs) from causality (what causes it) from quality impact (semantic or correctness consequence)
- Declare boundaries explicitly: which devices/environments, which frozen inputs, which code remains read-only
- Update the intent document as iterations progress; add outcome summaries and preserve the reasoning evolution with dated corrections
- Link bidirectionally: intent links to iterations/questions, they link back to intent

## Campaign Directory Structure

Create these subdirectories:

- **`key-questions/`**: One `KQ-N-<slug>.md` file per key question with testable propositions, answer sections, and scope declarations
- **`iterations/`**: One `YYYY-MM-DD-plan-N-<slug>.md` file per investigation cycle with frozen workload, predeclared arms, gates, measurements, and execution checklists
- **`evidences/`**: One `YYYY-MM-DD-<specific-observation>.md` file per experiment with raw data, tables, hashes, commands, and hardware identity
- **`reports/`**: One `YYYY-MM-DD-<theory-or-synthesis>.md` file per synthesis document evaluating theories across multiple evidences

Do not create a `goal/` subdirectory; success criteria belong in the root intent document.

## Artifact Contracts

**`README.md`**: Campaign index with one-sentence purpose, link to debug-intent, and directory structure explanation. Written once during scaffold.

**`debug-intent.md`**: Root campaign document with problem, scope, boundaries, status updates, and links to all key questions and iterations. Living document that gets updated as the campaign progresses.

**`key-questions/KQ-N-<slug>.md`**: One testable question with opening statement, critical propositions (numbered subsections), answer/resolution section, scope section, status line, iteration owner, and evidence links. Gets updated as evidence arrives; corrections are dated and preserved.

**`iterations/YYYY-MM-DD-plan-N-<slug>.md`**: Execution plan for one investigation cycle with status line, question/answer sought, frozen workload (exact hashes/settings/hardware), predeclared arms (experimental conditions in tables), gates (pass/fail criteria before execution), measurements and decision rules, execution checklist (checkboxes), and result section added after completion. Everything declared before execution; corrections noted but original preserved.

**`evidences/YYYY-MM-DD-<specific-observation>.md`**: Raw observational data from one experiment with tables of measurements, hashes, tensor comparisons, exact commands, hardware identity, environment classification (stable/degraded/unstable). Factual only, minimal interpretation, reproducible. Multiple iterations/KQs can reference the same evidence.

**`reports/YYYY-MM-DD-<theory-or-synthesis>.md`**: Synthesis across multiple evidences; theory evaluation with what survived/failed testing, mechanisms, implications, and updated interpretations. Living documents with dated corrections/qualifications. Claims backed by evidence links; explicit about what remains unresolved.

## Writing Principles for Campaign Documents

Follow these patterns observed in systematic debug campaigns:

### Precision over brevity
- Every claim cites its evidence or declares itself unproven
- Use exact hashes, measurements, tensor identities, not approximations
- Distinguish "observed at this checkpoint" from "true for all cases"

### Correction discipline
- Errors are noted with dates but original text preserved to show reasoning evolution
- Use phrases like "Correction: [date]" or "Updated: [date]" inline
- Preserve failed hypotheses to show what was tested

### Explicit boundaries
- State what's tested, what's not, what can't be claimed from this data
- Separate mechanism (what differs) from causality (what causes change) from quality (semantic impact)
- Name missing controls explicitly rather than omitting them

### No speculation
- Prefer "unresolved" over guessing
- Missing controls are named
- Hypotheses are clearly marked as hypotheses before testing

### Quality gates
- Criteria written before experiments run (predeclared)
- Reproducibility: exact hashes, commands, hardware identity, two runs minimum
- Stability classification: stable/degraded/unstable environment labels
- Exact vs diagnostic: what must be bitwise identical vs what's informative

### Linking strategy
- Use relative links between documents
- Bidirectional: iterations link to KQs, KQs link back to owning iteration
- Evidence flows up: evidences ← iterations ← KQs ← reports ← intent

### Tables over prose
- Comparison tables for arms, measurements, boundaries
- Checklists for execution steps
- Tensor summaries with digest prefixes

## Templates

Templates at `assets/templates/campaign/` are **suggestive, not enforced**:

- `README.md`: Campaign index with subdirectory purposes
- `debug-intent.md`: Root intent with problem, scope, status
- `key-questions/key-question.md`: Question template with propositions, answer, scope
- `iterations/iteration-plan.md`: Iteration template with workload, arms, gates, checklist
- `evidences/evidence.md`: Evidence template with measurements, commands, hardware
- `reports/report.md`: Report template with synthesis, theory evaluation

**Template flexibility**: These templates indicate what information is preferred in each document type, not mandatory structure. Agents may adjust sections, add domain-specific content, or reorganize based on the assigned task. Planning-stage artifacts (intent, key questions, iterations) benefit from more structure; produced artifacts (evidences, reports) vary naturally by experiment type and findings.

Use these templates when creating campaign artifacts through follow-up subcommands or helper workflows.

## Guardrails

- DO NOT overwrite an existing campaign directory during scaffold unless the user explicitly asks.
- DO NOT assume the host project's debug workflow; infer conventions from existing `context/campaigns/` if present.
- DO NOT create campaign artifacts outside the resolved campaign directory without explicit user direction.
- DO NOT fill in experiment results during scaffold; keep the intent and structure separate from execution data.
- DO NOT treat templates as rigid requirements; adapt structure to fit the investigation while preserving the core information each document type should contain.

## Next Steps

After scaffolding, suggest:
1. Defining the first key question in `key-questions/KQ-1-<slug>.md`
2. Creating the first iteration plan in `iterations/<date>-plan-1-<slug>.md`
3. Reading existing campaign directories in the project for local style guidance
