---
description: >
  Formatting and structural rules for all Quarto documents (.qmd) in the repository.
  Covers YAML frontmatter, chunk options syntax, section structure, the empty-body
  dual-file pattern, and the Data Context section requirement.
applyTo: "**/*.qmd"
---

# Quarto Document Style Rules

## YAML Frontmatter

Every `.qmd` uses this standard block for HTML output:

```yaml
---
title: "{Title}"
subtitle: "{Name} — {Type} Report"
author: "Analysis Team"
date: last-modified
format:
  html:
    page-layout: full
    toc: true
    toc-location: right
    code-fold: show
    theme: yeti
    highlight-style: breeze
    code-line-numbers: true
    self-contained: true
    embed-resources: true
    keep-md: false
editor: visual
editor_options:
  chunk_output_type: console
---
```

## First Two Chunks (always present)

**Chunk 1** — working directory reconciliation. Must be kept isolated from all other setup:

```qmd
```{r}
#| code-summary: Reconciles working directory between execution modes
#| echo: false
#| results: hide
#| message: false
#| warning: false
cat("Working directory: ", getwd())
library(knitr)
opts_knit$set(root.dir='../../') # keep this chunk isolated
```
```

**Chunk 2** — global chunk options and `.R` script registration:

```qmd
```{r}
#| label: set_options
#| code-summary: Report-wide formatting options
#| echo: false
#| results: hide
#| message: false
report_render_start_time <- Sys.time()
opts_chunk$set(
  results      = 'show',
  message      = FALSE,
  warning      = FALSE,
  comment      = NA,
  tidy         = FALSE,
  fig.path     = 'figure-png-iso/'
)
echo_chunks    <- FALSE
message_chunks <- FALSE
options(width = 100)
ggplot2::theme_set(ggplot2::theme_minimal())
read_chunk("analysis/{name}/{name}.R")
```
```

## Empty-Body Pattern

All analytical chunks **must have empty bodies**. Code and `print()` live in the companion `.R`
script; the `.qmd` chunk provides only `#|` options. Quarto executes the sourced R chunk code
(including `print()`) automatically during rendering.

```qmd
```{r g21}
#| label: g21-performance-comparison
#| code-summary: "Average performance by transmission type"
#| echo: true
#| message: false
#| warning: false
#| cache: true
#| fig-cap: "Performance varies significantly across transmission types"
#| fig-width: 8.5
#| fig-height: 5.5
```
```

## Chunk Options

Use `#|` (hashpipe) syntax only. Never use inline header syntax (e.g., `` ```{r echo=FALSE} ``).

Key options:

- `#| label:` — must match the chunk name in the companion `.R` script exactly
- `#| code-summary:` — brief description shown on hover in rendered output
- `#| fig-cap:` — descriptive caption explaining the insight, not just labeling the graph
- `#| fig-width: 8.5` and `#| fig-height: 5.5` — must match `ggsave()` dimensions in the `.R` script
- `#| cache: true` — use for computationally expensive chunks

## Standard Section Sequence

```
# Mission
# Definition of Terms    ← environment chunks (load-packages, set_options)
# Data Context           ← data-loading chunks + primer link
# Analysis               ← graph and table chunks
# Appendix               ← optional
```

## Data Context Section

Every EDA or Report `.qmd` contains a **Data Context** section placed after the data-loading
chunks and before the Analysis section. It must include:

1. Link to the data primer:
   `For complete data documentation, see the [Data Primer](../data-primer-1/data-primer-1.html).`
2. Which Ellis parquet tables this analysis draws on and why
3. Grain proof — a chunk showing the unit of analysis (e.g., `person_oid x year`)
4. Single-record illustrative view (1–2 representative individuals or records)
5. Distributions of the key variables that appear in this report's graphs

The Data Context section is curated to THIS analysis — not a copy of the data primer.

## Forbidden Patterns

- **No filled chunk bodies** in analytical sections — code belongs in the `.R` script
- **No inline chunk option syntax** (```` ```{r echo=FALSE} ````) — use `#|` hashpipe exclusively
- **No `echo=TRUE`** on environment/setup chunks (load-packages, declare-globals) —
  these are implementation detail, not narrative
- **No decorative comment borders** inside chunk bodies (mirrors the R script rule)
