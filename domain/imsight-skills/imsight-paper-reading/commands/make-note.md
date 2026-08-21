# Make Note

## Workflow

When this subcommand is invoked, execute the following steps in order.

1. **Resolve inputs**. Confirm the paper source and, when applicable, the reference-code root following the parent skill's **Input Resolution**. State the resolved paths before reading.
2. **Read the paper in full**. Prefer the LaTeX or Markdown source when available so quotes carry exact section and file provenance; otherwise extract text from the PDF. Read every section, including appendices that carry method or experiment detail.
3. **Extract figures**. Save paper figures and result tables that the note will embed into the note's `figures/` subdirectory. See **Figure Extraction**.
4. **Resolve the output directory** following the parent skill's **Output Contract**.
5. **Draft the note**. Apply [../references/note-template.md](../references/note-template.md): the fixed section template, the formatting rules, and the citation discipline.
6. **Ground every claim**. Add paper blockquote citations after every key claim (2-4 minimum per major section). Add code citations only when reference code was resolved in step 1; use the actual resolved paths with line numbers. See **Citation Discipline**.
7. **Write the artifacts**. Save `main-note.md` and the `figures/` images, keeping all image paths relative to the note file.
8. **Verify against the quality checklist** in [../references/note-template.md](../references/note-template.md) and fix every gap before finishing.
9. **Report the result**. State the note path, the figure count, the resolved inputs, and any sections left thin because the paper does not cover them.

If the paper is an unusual format (talk slides, workshop extended abstract, multi-part technical report), use the native planning tool to build a bounded reading and note plan from this workflow, then execute the plan.

## Figure Extraction

- Pull figures from the paper source when possible: LaTeX projects usually keep them as image files referenced by `\includegraphics`; copy the referenced files directly.
- When only a PDF is available, render or crop the relevant pages at sufficient resolution that embedded text and diagram labels stay legible, then read the extracted images back to confirm they show the intended content.
- Name files descriptively, for example `figures/architecture.png` or `figures/main-results-table.png`, and embed them with descriptive alt text plus a blockquote caption from the paper.

## Citation Discipline

Paper citations are mandatory; code citations are conditional.

- **Paper citations (always required)**: after every key claim or concept, add a supporting blockquote with the section name and the actual source path, for example `> "Direct quote from paper" (Introduction; papers/yolov13/sections/1_abstract.tex)`. Use the real resolved paper path, never a placeholder.
- **Code citations (only when reference code exists)**: cite the actual resolved file path with a line number, for example `> "def forward(self, x): ..." (extern/tracked/yolov13/ultralytics/nn/modules/block.py:1914)`. Never invent a path or line number.
- **Without reference code**: cite only the paper; base pseudocode on the paper's equations, algorithms, and prose descriptions, and say so in the pseudocode's lead-in.

## Completion Check

Before delivery, confirm that:

- The resolved paper path and reference-code root (when present) appear in the note's metadata section.
- Every major section carries at least 2-4 paper blockquote citations.
- No code citation exists without resolved reference code behind it.
- All diagrams use Mermaid syntax except embedded paper figures.
- Pseudocode carries tensor-shape annotations and states whether it derives from the paper or from reference code.
- All image paths are relative to `main-note.md` and every embedded figure file exists in `figures/`.
- The note directory follows the parent skill's **Output Contract**.
