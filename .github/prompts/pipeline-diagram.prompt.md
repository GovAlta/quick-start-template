---
description: Create or update the pipeline diagram (Mermaid + PNG) for a manipulation/analysis project.
---

# Pipeline Diagram — Create or Update

You are helping the user maintain the canonical pipeline diagram for a data analytics project.

## Canonical source

The Mermaid diagram is embedded in `manipulation/pipeline.md` as a standard ` ```mermaid ` fenced
block. The line immediately before the fence must be the marker comment:

```markdown
<!-- PIPELINE-DIAGRAM-SOURCE -->
```mermaid
flowchart LR
    ...
```
```

The render script locates the diagram by this marker — other mermaid blocks can exist in
`pipeline.md` without conflict.

After any edit the user must regenerate the image. Remind them to run:

- **VS Code task**: `Render Pipeline Diagram` (Command Palette → Run Task)
- **Terminal**: `Rscript utility/render-pipeline-diagram.R`

This produces:

- `libs/images/pipeline-architecture.jpg` — the single rendered output (Markdown and Quarto)

## Insertion site convention

Every file that embeds the diagram image must have this HTML comment on the line immediately above
the image reference:

```
<!-- PIPELINE-DIAGRAM -->
![Pipeline Architecture](libs/images/pipeline-architecture.jpg)
```

Note: adjust the path relative to the embedding file's location (e.g.,
`../libs/images/pipeline-architecture.jpg` for files one level deep).

The render script scans for `<!-- PIPELINE-DIAGRAM -->` and prints all tagged files after each run,
so the user always knows which files need a manual refresh.

## Color conventions (keep consistent across repos)

| Color | Hex | Stage type |
|---|---|---|
| Blue | `#4a90d9` | Sequential flow — Ingestion, Transformation |
| Orange | `#f5a623` | Advisory / EDA — nonflow, out-of-sequence |
| Purple | `#7b68ee` | Modeling — Mint, Train, Forecast |
| Green | `#50c878` | Delivery — Report |

## Diagram structure rules

- Layout: `flowchart LR` (left to right)
- Group related scripts into named `subgraph` blocks
- Sequential pipeline scripts connect with solid arrows (`-->`)
- Advisory / EDA nodes connect with a **dashed arrow** (`-.->|informs|`) from the last sequential
  node that precedes them; they do **not** have a solid output arrow — they produce insight, not
  data artifacts consumed downstream
- Every node gets a `style` directive using the hex codes above; no node is left unstyled

---

## Mode 1 — Update existing diagram

**When to use**: The user has changed, added, renamed, or removed scripts in `manipulation/` or
`analysis/` and needs the diagram updated to match.

**Steps**:

1. Read the current `manipulation/pipeline/pipeline.mmd`
2. Ask the user what changed (if not already stated):
   - Which scripts were added, removed, or renamed?
   - Did any script's role change (e.g., flow → nonflow, or sequential → advisory)?
   - Are there new subgraph groupings?
3. Produce the revised `.mmd` content in a code block
4. Remind the user to paste it into `manipulation/pipeline/pipeline.mmd` and run the render task

---

## Mode 2 — Create from scratch

**When to use**: A new repo has no `manipulation/pipeline/pipeline.mmd` yet. Use the template at
`.github/templates/pipeline-diagram-template.mmd` as a starting point.

**Interview the user** — ask these questions before drafting (can be combined into one message):

1. List all scripts in `manipulation/` (names and brief purpose). Which ones are in the main
   sequential flow vs. `nonflow/` (one-time setup, ad-hoc)?
2. Are there any scripts in `analysis/` that run on raw or intermediate data out of sequence
   (advisory/EDA pattern)? If so, which Ellis/Ferry output do they consume?
3. What are the natural grouping names for the pipeline stages in this project
   (e.g., "Data Ingestion", "Transformation", "Modeling", "Delivery")?
4. Are there multiple output report files, or a single one?

**Then draft** the mermaid diagram following the structure rules and color conventions above.
Present the full diagram content in a fenced ` ```mermaid ` code block. Instruct the user to:

1. Open `manipulation/pipeline.md` and locate (or create) the Pipeline Architecture section
2. Add `<!-- PIPELINE-DIAGRAM-SOURCE -->` on the line immediately before the ` ```mermaid ` fence
3. Paste the diagram code inside the fence
4. Run the **Render Pipeline Diagram** VS Code task
5. Add `<!-- PIPELINE-DIAGRAM -->` markers above each image embed in other files
