---
description: >
  Rules for developing analytical reports (EDA and presentation Reports) within analysis/ directories.
  Covers the dual-file pattern (.R + .qmd), graph family conventions, data provenance, directory
  structure, and quality standards established by the Composing Orchestra system.
applyTo: "analysis/**"
---

# Report Composition Rules

These rules apply to all analytical content in `analysis/`. They codify the conventions from `analysis/eda-1/eda-style-guide.md` and the Composing Orchestra design (`.github/composing-orchestra-1.md`).

## Dual-File Discipline

Every analysis consists of an `.R` script and a `.qmd` document:

- **`.R` script** = analytical laboratory. All exploration, data wrangling, and visualization development happens here. Use `ggsave()` to save plots. No `print()` statements for display.
- **`.qmd` document** = publication layer. Sources chunks from the `.R` script via `read_chunk()`. Uses `print(plot_object)` for HTML rendering. Provides narrative context around visualizations.
- **Synchronization**: When creating a new chunk in `.R`, create the corresponding `.qmd` chunk reference. Chunk names must match exactly between files.

```r
# In .R script setup, register chunks:
read_chunk("analysis/eda-N/eda-N.R")
```

## Graph Family Protocol

A **graph family** is a collection of visualizations sharing a common data-preparation ancestor.

### Structure
```
g2-data-prep  →  g2  (primary view)
                  g21 (alternative view / different metric)
                  g22 (alternative view / different breakdown)
```

### Rules
- **One idea = one graph = one chunk**. Never combine unrelated analyses in a single chunk.
- **Data prep chunks** named `gN-data-prep` create the shared ancestor dataset.
- **Family members** named `gN1`, `gN2`, `gN3`… explore different facets of the same ancestor.
- **Graph numbering never changes** once assigned, even if a graph is later removed from the script.

### Naming Convention
- `g1`, `g2`, `g3`… — Individual graphs or family identifiers
- `g21`, `g22`, `g23`… — Members of family g2
- `t1`, `t2`… — Tables and summaries
- `m1`, `m2`… — Models and statistical analyses
- Objects: `g1_descriptive_name`, `g21_descriptive_name` (e.g., `g2_cylinder_performance`)

## Print Optimization

All visualizations default to:
- **Dimensions**: 8.5 × 5.5 inches (letter-size half-page portrait)
- **Resolution**: 300 DPI
- **Format**: PNG

```r
ggsave(paste0(prints_folder, "g1_descriptive_name.png"),
       g1_plot, width = 8.5, height = 5.5, dpi = 300)
```

## Directory Structure

Every `analysis/eda-N/` or `analysis/report-N/` directory follows this layout:

```
analysis/eda-N/
├── report-contract.prompt.md    # Structured brief
├── eda-N.R                      # Analytical laboratory (includes data-context chunks)
├── eda-N.qmd                    # Publication layer (includes Data Context section)
├── data-local/                  # Intermediate processing files
├── prints/                      # High-quality plot exports
├── figure-png-iso/              # Quarto-generated figures
└── local-functions.R            # Analysis-specific helpers (created on demand)
```

The centralized data primer lives at `analysis/data-primer-1/` (its own `data-primer-1.R` + `data-primer-1.qmd`).
Private derived outputs go to `data-private/derived/eda-N/`.

## Data Provenance

Every `ds*` dataset and `g*` graph object must trace back through:

```
Ellis output (data-private/derived/manipulation/*.parquet)
  → CACHE database (data-public/metadata/CACHE-manifest.md)
    → Batch-91 source data
```

When loading data, use `arrow::read_parquet()` for Ellis outputs. Document which table(s) each dataset derives from.

## Data Context Section

Every EDA or Report `.qmd` contains a **Data Context** section placed after the data-loading chunks and before the Analysis section. This section orients the reader to the data *for this specific analysis*:

- **Link to the data primer**: `For complete data documentation, see the [Data Primer](../data-primer-1/data-primer-1.html).`
- **Tables used**: Which Ellis parquet tables this analysis draws on and why (from the contract's Data Sources field)
- **Grain proof**: Code showing the unit of analysis (e.g., `person_oid × year`) and confirming it holds
- **Single-person view**: What the data looks like for a representative individual (1–2 people)
- **Key variable distributions**: Distributions of variables that appear in this report's graphs

The Data Context section must be **analysis-specific** — tailored to what the reader needs for THIS report, not a copy of the primer. It is always present, always brief, always grounded in the data at hand.

Corresponding R chunks in the `.R` script: `data-context-tables`, `data-context-person`, `data-context-distributions`.

## Contract Fidelity

The `.R` script and `.qmd` document should address all research questions listed in `report-contract.prompt.md`. If scope changes during development, update the contract.

## Alberta Corporate Visual Identity

Use color palettes from `scripts/graphing/graph-presets.R`:
- `abcol` — Corporate palette (grey, magenta, brown, green, blue, yellow)
- `binary_colors` — High contrast, colorblind-safe
- `acru_colors_9` — Qualitative 9-category palette

## Package Loading

Follow the greedy loading pattern — load only what's needed:

```r
library(magrittr)    # pipes
library(ggplot2)     # graphs
library(dplyr)       # data wrangling
library(tidyr)       # data reshaping
library(arrow)       # parquet I/O
```

Use defensive loading for optional packages:
```r
if (requireNamespace("pkg", quietly = TRUE)) { library(pkg) }
```

## Quarto Chunk Standards

```qmd
{r g21}
#| code-summary: "Brief description of what this chunk shows"
#| echo: true
#| message: false
#| warning: false
#| cache: true
#| fig-cap: "Caption describing the visualization"
#| code-fold: true
print(g21_plot)
```

## Quality Standards

- **Descriptive default**: Prefer descriptive statistics; prompt human before inferential analysis
- **No superlatives**: Avoid "brilliant", "revolutionary" — let evidence speak
- **No hallucination**: Never fabricate data patterns. If uncertain, document the uncertainty.
- **Humble epistemology**: Present findings as current best evidence, not absolute truth
- **Reproducibility**: All code must run in a fresh R session with documented dependencies
- **Transparency**: Document analytical decisions and their rationale
