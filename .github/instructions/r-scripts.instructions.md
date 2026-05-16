---
description: >
  Formatting and structural rules for all R scripts in the repository.
  Covers chunk naming, section markers, comment style, script preamble,
  package loading, and pipeline-script conventions. Applies to analysis,
  manipulation, scripts/, and root-level .R files.
applyTo: "**/*.R"
---

# R Script Style Rules

## Script Preamble

Every R script opens with this fixed sequence before the first chunk marker:

```r
rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run.
cat("\014") # Clear the console
cat("Working directory: ", getwd()) # Must be set to Project Directory
```

## Structural Markers

Two levels of structure are permitted. Nothing else.

### Chunks

Named with `# ---- chunk-name ----` (lowercase-hyphen, trailing dashes fill to column 80).
One chunk = one idea (data prep, one graph, or one table). Chunk names never change once assigned.

```r
# ---- load-packages -----------------------------------------------------------
# ---- declare-globals ---------------------------------------------------------
# ---- load-data ---------------------------------------------------------------
# ---- tweak-data-0 ------------------------------------------------------------
```

### Sections

Named with `# ---- SECTION: Title ----` (all-caps `SECTION:` prefix). Mark logical groups of
related chunks. A plain-comment description goes immediately below the marker.

```r
# ---- SECTION: Attrition Narration -------------------------------------------
# Two-stage reduction to the incident cohort.
# Stage 0 — SIN-linkable; Stage 1 — Left-truncation (first record >= 2013).

# ---- attrition-stage0 --------------------------------------------------------
```

## Forbidden Patterns

- **No decorative borders**: Never use `# ===...===`, `#' ===...===`, or any full-line ornamental
  comment block. These break collapsed-chunk navigation in RStudio and VS Code.
- **No `#'` for section headers**: Roxygen (`#'`) is for function documentation only, not
  script-level structure.
- **No `#+` spin-style headers** (e.g., `#+ echo=FALSE`): Use `#|` hashpipe options inside
  Quarto chunks instead.
- **No hardcoded magic numbers**: All constants belong in the `declare-globals` chunk or
  sourced from `config.yml`.

## Standard Chunk Sequences

For analysis scripts (`analysis/**/*.R`):

```r
# ---- load-packages -----------------------------------------------------------
# ---- httpgd ------------------------------------------------------------------
# ---- load-sources ------------------------------------------------------------
# ---- declare-globals ---------------------------------------------------------
# ---- declare-functions -------------------------------------------------------
# ---- load-data ---------------------------------------------------------------
# ---- tweak-data-0 ------------------------------------------------------------
```

For pipeline scripts (`manipulation/*.R`):

```r
# ---- setup -------------------------------------------------------------------
# ---- declare-globals ---------------------------------------------------------
# ---- load-data ---------------------------------------------------------------
# ---- tweak-data --------------------------------------------------------------
# ---- validate ----------------------------------------------------------------
# ---- save-to-disk ------------------------------------------------------------
```

## Package Loading

Load only what is needed. Use `requireNamespace()` for packages used in qualified form only.
Use defensive loading for optional packages:

```r
library(magrittr)
library(ggplot2)
requireNamespace("DBI")      # not attached; use DBI::dbConnect() etc.
requireNamespace("RSQLite")

if (requireNamespace("httpgd", quietly = TRUE)) {
  tryCatch({
    if (is.function(httpgd::hgd)) httpgd::hgd() else httpgd::httpgd()
    message("httpgd started.")
  }, error = function(e) message("httpgd failed: ", conditionMessage(e)))
} else {
  message("httpgd not installed.")
}
```

## Data Loading

Use `arrow::read_parquet()` for Ellis outputs. Pipeline scripts (`manipulation/*.R`) read
only Mint artifacts — never Ellis `.R` output directly.

```r
ds_client <- arrow::read_parquet("./data-private/derived/manipulation/client_roster.parquet")
```

## Graph Object Naming (analysis scripts)

- Objects: `g1_descriptive_name`, `g21_descriptive_name` (family number + underscore + topic)
- Every graph chunk ends with `print(object)` — required for interactive display and
  Quarto rendering via `read_chunk()`
- `ggsave()` immediately follows `print()` at 8.5 x 5.5 inches, 300 DPI, PNG

```r
print(g21_performance_bars)
ggsave(
  paste0(prints_folder, "g21_performance_bars.png"),
  g21_performance_bars, width = 8.5, height = 5.5, dpi = 300
)
```

## Directory Creation

Always idempotent — create only if absent:

```r
if (!fs::dir_exists(prints_folder)) { fs::dir_create(prints_folder) }
```
