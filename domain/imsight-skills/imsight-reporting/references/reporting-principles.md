# Reporting Mentality Principles

## Purpose

Write work reports that a busy manager, collaborator, or stakeholder can read effortlessly without opening the repository, while keeping every claim grounded in real evidence.

Remember these nine principles and apply them directly while selecting focus, weighing evidence, and writing. They express editorial judgment—not a rigid step-by-step recipe, mandatory paragraph count, or mechanical audit checklist. Prose structure, section order, and formatting remain governed by the user's request and the project's own report contract.

The Do / Don't comparisons below are illustrative teaching examples, not real project data or fixed phrasing templates. Learn the judgment behind each move rather than copying its wording.

## Principle Index

| Code | Canonical Name | Compact Reminder |
| --- | --- | --- |
| `r1` | `stakeholder-reader` | Write for a capable stakeholder who will never open the repo—omit unit tests, CI hygiene, and internal plumbing. |
| `r2` | `project-goal-priority` | Weight and filter work by how directly it advances this project's core goal, not by commit volume or chronology. |
| `r3` | `lead-with-what-is-done` | Center the summary and body on completed work and proven results; keep scope qualifiers brief and put unstarted work in Next Steps. |
| `r4` | `evidence-over-narrative` | Match every status verb to the strongest verified proof; never turn proposals, drafts, or filenames into verified results. |
| `r5` | `narrow-scope-honestly` | Separate low-level building blocks and local checks from the overarching research or product goal they serve. |
| `r6` | `outcomes-not-chronology` | Synthesize across commits, days, and repos by reader-facing outcome at its latest verified state; never concatenate daily logs. |
| `r7` | `numbers-with-conditions` | Pair every material metric with its baseline, unit, and measurement condition, distinguishing measured numbers from targets. |
| `r8` | `native-clear-prose` | Write directly in natural target-language prose; avoid translationese, stacked nominalizations, empty buzzwords, and forced translation of established English tech terms. |
| `r9` | `contract-and-safety` | Follow the project's own structure, section order, and terminology while never relaxing honesty or leaking secrets. |

## Reporting Principles

### r1 — stakeholder-reader

Assume the reader understands the technical domain (for example, LLM agents or GPU kernels) but has not followed the daily implementation and will never open the repository, diffs, or internal tracking files. Explain outcomes and value in self-contained terms without referencing repo paths, function names, commit hashes, issue numbers, or routine developer checks.

**Representative Do / Don't comparison.** A team finished integrating a new agent runtime and verified it end-to-end against a self-hosted model and a real email server.

**Don't:** "Merged PR #104, updated `self_manifest.py` and `hermes_tui.py`, archived 7 OpenSpec changes, and passed 6,077 unit tests, Ruff lint, strict mypy, and MkDocs builds (tech-debt score 68)."

**Do:** "Integrated Hermes Agent across service, terminal, and headless modes and verified unattended execution against our self-hosted Qwen 3.8 model, including signed two-agent email round trips on a live Stalwart server."

**Judgment:** Unit tests, test counts, lint, typecheck, doc builds, internal spec validation, and code-debt scores are table-stakes engineering hygiene—not progress items for leadership. Report verification only when it demonstrates real behavior: live end-to-end runs, external service checks, profiling, or benchmarks. Include internal identifiers only if the user explicitly asks for an engineering audit.

### r2 — project-goal-priority

Allocate space and prominence according to how directly each outcome advances *this project's* core goal, not by how many commits touched it or how recently it landed. Especially when tracking an upstream framework or dependency repository, filter aggressively through the lens of what unlocks the project's actual research or product milestones.

**Representative Do / Don't comparison.** During a week on a CUDA kernel optimization project, an upstream agent framework shipped a CLI refactor, README SVG fixes, a four-agent CUDA evaluation harness, and long-turn group-chat queues.

**Don't:** Give equal subsections to README diagrams, internal CLI refactoring, and the four-agent CUDA evaluation harness simply because all three were committed this week.

**Do:** Spotlight the four-agent CUDA evaluation harness and long-turn group-chat queues as the week's main deliverables, and either omit incidental upstream housekeeping or fold it into one brief milestone sentence.

**Judgment:** When a weekly report or multi-repo day has many competing workstreams and the user has not yet picked a focus, rank candidate additions and live verifications by relevance to the project's goal and let the user choose which themes to highlight before writing.

### r3 — lead-with-what-is-done

Use the summary and body to report what was built, discovered, and proven. Readers come to a progress report to learn what moved forward, not to read a repeated inventory of what did not happen. When an important caveat or status qualifier is needed, state it once in a crisp inline clause and collect all unstarted or unverified work into the closing Next Steps section.

**Representative Do / Don't comparison.** A team built and validated a new model pool and drafted a four-agent GPU evaluation suite, but has not run the first live GPU experiment yet.

**Don't:** Open the summary and every body section with "No GPU benchmarks were run today; cloud APIs were not tested; the CUDA harness is unexecuted; cross-UID isolation remains unverified."

**Do:** Lead with the completed model pool, migrated test suites, and newly built four-agent CUDA evaluation suite (noting briefly inline: "currently a draft, ready for its first GPU run"), then place the first live GPU run and remaining checks cleanly in Next Steps.

**Judgment:** Focusing on completed work never excuses hiding a limitation that would change a decision or faking completion. The mistake to avoid is letting defensive disclaimers hijack the headline or repeat across three sections.

### r4 — evidence-over-narrative

Ground every status claim in the strongest available proof, following this authority order:

1. Verified live run, end-to-end qualification, benchmark, or approval records.
2. Implemented code and inspected diffs.
3. Committed history and completed task records.
4. Proposals, designs, and plans.
5. Filenames, timestamps, and memory.

Match verbs to what the evidence actually proves:

| Strongest Evidence | Appropriate Status Wording |
| --- | --- |
| Proposal, design, or plan only | proposed, designed, planned |
| Code or config written, not yet live-tested | implemented, added, built (draft) |
| Live end-to-end run, service check, or benchmark passed | verified, validated, passed live testing |
| Partial or blocked work | advanced, partially verified, blocked by X |

**Representative Do / Don't comparison.** A new four-agent CUDA benchmark harness defines a `3.0x` minimum speedup target and a `10.0x` stretch target in its manifest, but no live GPU run has occurred yet.

**Don't:** "Completed the four-agent CUDA cooperation benchmark, achieving 3x–10x speedup on GDN Prefill and Fused MoE."

**Do:** "Implemented the four-agent CUDA cooperation evaluation suite (draft) targeting 3.0x minimum and 10.0x stretch speedup with independent locked-driver verification; live GPU runs are scheduled next."

**Judgment:** Uncommitted and untracked files count as evidence once inspected. When a report relies on an external or nested checkout, check whether its revision covers the full period cutoff so recent upstream work is neither missed nor misdated. Never invent measurements to fill a template.

### r5 — narrow-scope-honestly

Keep an enabling mechanism strictly distinct from the overarching goal it serves, and keep component or local checks distinct from full-system claims. Do not inflate a working building block into a finished research breakthrough.

**Representative Do / Don't comparison.** Agents can now safely edit, version, publish, and hot-load skills and MCP declarations inside a restricted sandbox, verified in a two-agent live run; no multi-task self-improvement experiment has been run yet.

**Don't:** "Delivered recursive self-improvement (RSI) for sandboxed agents."

**Do:** "Implemented and live-tested runtime editing, versioned publishing, and hot-loading of skills and MCP declarations under sandbox restrictions, providing a runtime building block for future self-improvement experiments."

**Judgment:** Apply the same separation to numerical tolerance vs. strict output parity, single-kernel speedup vs. end-to-end workload speedup, and mock-server qualification vs. real-LLM qualification. Naming the exact boundary makes the real achievement more credible, not smaller.

### r6 — outcomes-not-chronology

Organize around reader-facing capabilities and answered questions, not the sequence of commits, debugging retries, or days of the week. Merge multi-day or multi-repo work serving one outcome into its latest verified state.

**Representative Do / Don't comparison.** Across Monday to Friday, an agent integration failed on Tuesday, was partially patched on Wednesday, broke on mail on Thursday, and passed end-to-end on Friday.

**Don't:** "Monday: started integration. Tuesday: hit parser bug. Wednesday: fixed parser bug. Thursday: mail failed on self-identity. Friday: fixed self-identity and mail passed."

**Do:** "Integrated Hermes Agent across service, terminal, and headless modes and verified end-to-end execution with self-hosted Qwen 3.8 (`xhigh`) and live Stalwart two-agent mail after resolving initial TUI readiness, background self-identity, and unattended approval issues."

**Judgment:** For weekly reports, never concatenate daily reports. Drop superseded intermediate failures or numbers unless the before/after delta itself is a meaningful finding (for example, fixing self-lookup cut single-turn handling time from ~3 min to ~43 s).

### r7 — numbers-with-conditions

Every material number should stand on its own with its unit, comparison baseline, and the conditions that bound it (hardware, model, workload shape, or whether it is a measured result versus a configured target).

**Representative Do / Don't comparison.** A speculative decoding test measured 64-token greedy generation on 8 × H20 with FA3 and FP8 KV cache, dropping from 0.61 s to 0.31 s.

**Don't:** "Achieved 2x speedup with fast generation latency."

**Do:** "On 8 × H20 (TP8 × EP8, FA3, FP8 KV cache), enabling DFlash 2 reduced 64-token greedy generation latency from 0.61 s to 0.31 s (mean acceptance length 3.2 tokens)."

**Judgment:** Use a Markdown table only when at least two rows or columns compare parallel dimensions cleanly; prefer crisp bullets or prose for single observations. Avoid cramming unrelated numbers into one cell.

### r8 — native-clear-prose

Write directly in natural, breathable prose in the target language—translating meaning, never English syntax. Break 120-character nested clauses into clear subject-verb sentences, replace bureaucratic or inflated phrasing with plain accurate verbs, and keep established English technical terms untranslated when a literal translation feels awkward or ambiguous.

**Representative Do / Don't comparison (Chinese report from English specs/commits).**

**Don't:** “依托版本化文件挂载，基于当前受管运行记录与进程归属核验的不依赖终端自身身份证明能力已交付，有效赋能技能闭环。”

**Do:** “后台运行的 Hermes 守护进程不挂在终端里，现在改为核对运行记录和进程归属来验证自身身份；同时实现了运行期修改和热加载 skill 与 MCP 的能力。”

**Judgment:** Prefer plain verbs (“已实现”, “支持”, “实测通过”) over empty corporate filler (“已交付”, “赋能”, “闭环”, “紧密围绕”, “显著进展”). Preserve domain-standard English terms (such as `skill`, `kernel`, `MCP`, `ACP`, `latency`, `baseline`) and match the project's preferred lexicon. Clarity must never dilute technical precision.

### r9 — contract-and-safety

Re-read the project's reporting guide on every run and adopt its exact filename, title format, body language, section labels, section order, numbering, and terminology. Never expose credentials, private endpoints, tokens, or personal data.

**Representative Do / Don't comparison.** A project's reporting guide requires `1 实验调查` before `2 功能实现` and prefers keeping `skill` in English.

**Don't:** Force a generic `Capability → Investigation` section order, translate `skill` to “技能”, or paste an internal `http://192.168.x.x` endpoint into the prose.

**Do:** Follow `1 实验调查 → 2 功能实现 → 3 下一步` verbatim, keep `skill` in English, and refer to services by role and release version rather than private endpoints or secrets.

**Judgment:** A project contract governs structure, ordering, and style; it never overrides evidence honesty (`r4`), scope accuracy (`r5`), or secret redaction.

## Composing With Other Mentalities

When a project or agent also has `imsight-mentality-mgr` mentalities active (such as `human-speak`, `docs-writer`, or `agile-experimenter`), compose cleanly without duplicating effort: `human-speak` reinforces reader-centered clarity (`r1`, `r8`), `docs-writer` reinforces current-state revision without narrating edit history (`r6`), and `agile-experimenter` reinforces bounded experimental claims (`r4`, `r5`, `r7`). No separate scoring rubric or audit dump is needed during ordinary reporting.
