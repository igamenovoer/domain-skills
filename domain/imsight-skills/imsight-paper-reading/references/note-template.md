# Reading Note Template

This reference defines the structure, formatting, and citation rules for the reading note produced by `make-note`. The note is `main-note.md` inside the resolved note directory, with images in the sibling `figures/` directory.

## Formatting Guide

### Section Structure

- Use the numbered sections (0-19) shown in the template below.
- Create nested subsections (for example 2.1, 2.2, 4.1, 4.2) when detailed breakdowns are needed.
- Give subsections descriptive titles that clarify the content (for example "2.1 Why previous YOLOs are not enough").
- Drop a section only when the paper genuinely does not cover it; say so in one line instead of inventing content.

### Bulleted Lists

- Always format as `- **Item**: description`.
- Use bold for the key term or concept, followed by a colon and the explanation.
- Example: `- **Local aggregation (CNNs)**: Convolutions aggregate locally and are bounded by receptive field.`

### Citations and Blockquotes

- Ground the note with blockquote snippets from the paper.
- Format: `> "Direct quote from paper" (Section name; <actual-paper-source-path>)`.
- Place citations immediately after the claim they support.
- Use blockquotes liberally as evidence for key points.
- Example:

  ```markdown
  - **Problem**: Prior YOLOs capture local or pairwise relations; miss global many-to-many correlations.
    > "[B]oth the convolutional architectures... are limited to local information aggregation..." (Abstract; papers/yolo13/sections/1_abstract.tex)
  ```

### Code and Pseudocode

- Explain algorithms with Python-like pseudocode rather than prose where possible.
- Show tensor shapes in comments: `# X: (B, N, C)`.
- Use fenced code blocks with language tags: ` ```python ` or ` ```text `.
- State in the lead-in whether the pseudocode derives from the paper's algorithmic descriptions or from reference code.
- Cite reference code with the actual resolved path and line number, and only when reference code was provided or located:
  `> "def forward(self, x): out = x[0] + self.gate * x[1]" (extern/tracked/yolov13/ultralytics/nn/modules/block.py:1914)`
- Example pseudocode block:

  ```python
  # Inputs: [x0, x1, x2] ~ [P3, P4, P5]
  x1_ds = AvgPool2d(2)(x0)    # -> (B,C,H,W)
  x_fused = Conv1x1(x_cat)    # -> (B,C,H,W)
  ```

### Diagrams

- Use Mermaid diagrams extensively for architecture, data flow, and component interactions.
- Use flowcharts for pipelines: ` ```mermaid flowchart LR ... ``` `.
- Label nodes clearly and use subgraphs for complex modules.
- Example structure:

  ```mermaid
  flowchart LR
    subgraph ModuleName["Module Name"]
      direction LR
      X([Input]) --> OP1["Operation 1"] --> OP2["Operation 2"]
      OP2 --> Y([Output])
    end
  ```

### Figures and Images

- Embed images with descriptive alt text: `![Figure 2: Architecture](figures/framework.png)`.
- Follow each image with a blockquote caption from the paper, citing the actual paper source path.
- Explain what the figure shows after the image.
- Keep all image paths relative to `main-note.md`.

### Detailed Technical Subsections

- Create "How X works" subsections to dive deep into mechanisms.
- Include both high-level explanations and code-level detail.
- Use a nested structure: concept, then diagram, then pseudocode, then implementation notes.

### Notation and Symbols

- Define mathematical notation inline or in the glossary section.
- Use proper formatting: `R^{N×C}` for matrices, `∈` for membership.
- Explain dimensions: "(B, N, C) where B=batch, N=nodes, C=channels".

## Citation Guide

To ground the note in the actual paper content:

1. After every key claim or concept, add a supporting blockquote from the paper.
2. Use `>` blockquote syntax with the source reference in parentheses.
3. Include the actual file path from the resolved paper source when the source is a file tree; cite the PDF page or section when only a PDF exists.

### Paper Citations (Always Required)

Cite from the paper's LaTeX/Markdown source, PDF, or sections:

```markdown
- **Problem**: Convolutions are limited by receptive field.
  > "Convolutional operations inherently perform local information aggregation within a fixed receptive field." (Introduction; papers/yolov13/sections/2_introduction.tex)
```

### Code Citations (Only When Reference Code Exists)

Do not assume code exists. Include code citations only when the user provided reference code or the agent located it under the parent skill's **Input Resolution**.

- Format: `(<actual-code-path>:<line_number>)`.
- Example: `> "def forward(self, x): out = x[0] + self.gate * x[1]" (extern/tracked/yolov13/ultralytics/nn/modules/block.py:1914)`
- Without reference code, focus on paper citations, derive pseudocode from the paper's algorithmic descriptions, and reference the paper's equations, algorithms, and figures.

### Citation Frequency

- Aim for 2-4 citations per major section at minimum.
- Paper citations are mandatory; code citations are conditional.

## Note Template

````markdown
# [Paper Title]

## 0. Metadata
- **Full Title**:
- **Authors**:
- **Venue / Year**:
- **Links**: PDF | Project Page | Code | Dataset | ArXiv/DOI
- **Keywords**:
- **Paper ID (short handle)**:
- **Paper source**: [resolved path or URL used for this note]
- **Reference code root**: [resolved path, or "none"]

## 1. TL;DR (3–5 bullets)
- **Problem**: [One-line problem statement]
- **Idea**: [Core insight or approach]
- **System**: [Main architectural or methodological contribution]
- **Efficiency**: [Performance or efficiency gains, if applicable]
- **Result**: [Headline results with numbers]

## 2. Problem & Motivation
### 2.1 [Descriptive title for limitation/gap]
- What problem is being solved? Why now? Prior limitations/gaps, with blockquote citations.
### 2.2 [How this paper addresses it]
- How the proposed approach tackles each limitation, with blockquote citations.

## 3. Key Ideas & Contributions (Condensed)
-
-
-

## 4. Method Overview
One-paragraph summary of the approach and how components interact, with a high-level data-flow description.
### 4.1 [Component/Module A]
- **Goal**: What this component achieves
- **Mechanism**: How it works (high-level)
- Figure or diagram when available, with a blockquote caption.
- Pseudocode when applicable.
### 4.2 [Component/Module B]
- Similar structure for each major component.

## 5. Interface / Contract (Inputs & Outputs)
- Inputs (types, shapes, modalities, constraints):
- Outputs (types, interpretations, constraints):
- Control/conditioning signals (if any):
- Required pre/post-processing steps:

## 6. Architecture / Components
- Components and their responsibilities, each with:
  - **Description**: what it does and why it matters, with a blockquote citation.
  - **Source reference** (only when reference code exists): actual path with line number.
  - **Mermaid diagram** of the component's data flow.
  - **Pseudocode** with shape annotations.

## 7. Algorithm / Pseudocode (Optional)
Detailed pseudocode for key algorithms with shape annotations and per-step comments, based on the paper's algorithmic descriptions or the reference code when available.

## 8. Training Setup
- Data: sources, size, splits, preprocessing:
- Objective(s) / loss functions:
- Model sizes / parameters:
- Hyperparameters & schedules:
- Compute budget (GPUs, hours):
- Training tricks & stabilization notes:

## 9. Inference / Runtime Behavior
- Inputs required at inference and their formats:
- Control knobs (temperature, steps, search, actions):
- Latency / throughput notes:
- Failure modes observed at inference:

## 10. Experiments & Results
- **Benchmarks & datasets**: evaluation datasets and tasks
- **Metrics**: primary and secondary metrics
- **Baselines**: models compared against
- **Headline results** with table/figure pointers, for example:
  - "Model X achieves 42.3 mAP (+3.0 over Baseline-N) at 8.2 GFLOPs (Table 1)"
  > "Supporting quote from results" (Experiments; <actual-paper-source-path>)
- **Key takeaways**: most important findings, each with a blockquote citation.

## 11. Ablations & Analysis
- What design choices matter most:
- Scaling trends:
- Sensitivity analyses:

## 12. Limitations, Risks, Ethics
- Stated limitations:
- Observed failure cases:
- Safety, bias, and ethical considerations:

## 13. Applicability & Integration Notes (Project-Focused)
- Where this could fit in our stack:
- Minimal viable integration / prototype plan:
- Dependencies or blockers:

## 14. Reproducibility Plan
- Checklist: data availability, code, configs, seeds:
- Reproduction steps at high level:
- Known gaps vs paper setup:

## 15. Related Work
- Closest prior work and how this differs:
- Historical context:

## 16. Open Questions & Follow-Ups
-
-

## 17. Glossary / Notation
- Symbols and their meanings:
- Important terms defined:

## 18. Figures & Diagrams (Optional)
- Overview figure path:
- Architecture diagram path:
- Activity/flow diagram path:

## 19. BibTeX / Citation
```bibtex
@article{<key>,
  title={...},
  author={...},
  journal={...},
  year={...}
}
```
````

## Additional Tips

### Content Depth

- Be comprehensive but concise: include key technical detail without unnecessary verbosity.
- Prefer pseudocode with comments over prose when explaining algorithms.
- Prefer Mermaid diagrams over text when showing architecture, data flow, and relationships.
- Ground every significant claim with a supporting blockquote.

### Technical Accuracy

- Preserve mathematical notation with proper Unicode symbols (∈, ×, →) or LaTeX-style formatting.
- Annotate shapes everywhere in pseudocode comments.
- Explain non-obvious details: when a figure or code snippet is complex, add explanatory text after it.
- Cite real resolved paths only; never emit placeholder paths in the final note.

### Organization

- Use nested subsections liberally (3.1, 3.2, 3.3, and so on).
- Keep each "How X works" subsection next to the main explanation of X.
- Start high-level, then dive deep with subsections.
- Cross-reference between sections when concepts relate (for example "See Section 3.2 for details").

### Common Patterns

Pattern 1: Introduce → Cite → Diagram → Code

````markdown
### 3.1 ComponentName
- **Goal**: What it achieves
  > "Quote from paper explaining the goal" (Introduction; <actual-paper-source-path>)
- **Mechanism**: How it works

![Figure: Component](figures/component.png)
> "Figure caption from paper" (<actual-paper-source-path>)

```python
# Pseudocode with shapes (based on the paper, or on reference code when available)
output = Component(input)  # (B,C,H,W) -> (B,C',H',W')
```

Only when reference code exists:
> "Code snippet" (<actual-code-path>:<line>)
````

Pattern 2: Problem → Solutions with citations

```markdown
### 2.1 Limitations of prior work
- **Issue A**: Description
  > "Quote showing the issue" (Related Work; <actual-paper-source-path>)

### 2.2 How this work addresses it
- **Solution A**: How the paper solves Issue A
  > "Quote explaining solution" (Method; <actual-paper-source-path>)
```

Pattern 3: Results with evidence

```markdown
- **Headline result**: Model X achieves Y metric = Z value (+Δ improvement)
  - Reference: Table N, Figure M
  > "The proposed model achieves..." (Experiments; <actual-paper-source-path>)
```

## Quality Checklist

Before finalizing the note, verify:

- [ ] The metadata section records the resolved paper source and the reference-code root (or "none").
- [ ] Every major section (2-10) has at least 2-4 blockquote citations from the paper.
- [ ] All diagrams use Mermaid syntax, except paper figures saved as images.
- [ ] Pseudocode includes shape annotations such as `# X: (B, N, C)`.
- [ ] Pseudocode states whether it derives from the paper or from reference code.
- [ ] Figures have descriptive alt text and blockquote captions.
- [ ] Nested subsections (X.1, X.2) are used for complex topics.
- [ ] Bold formatting is consistent: `- **Term**: description`.
- [ ] Code citations, when present, use actual resolved paths with line numbers; none exist without resolved reference code.
- [ ] Paper citations name the section and the actual source path or PDF page.
- [ ] Mathematical notation is properly formatted.
- [ ] Sections cross-reference each other where appropriate.
- [ ] All image paths are relative to `main-note.md` and every referenced file exists in `figures/`.
