# Rendering an HTML Report from a .qmd + .R Pair

This guide walks you through rendering an HTML document from the dual-file pattern used in this project. If you are new to Quarto or R Markdown, start here.

## Prerequisites

- **R** installed ([https://cran.r-project.org/](https://cran.r-project.org/))
- **Quarto** installed ([https://quarto.org/docs/get-started/](https://quarto.org/docs/get-started/))
- Required R packages installed (each `.R` script declares its own dependencies via `library()` calls)

## The Dual-File Pattern

Every analysis in `analysis/` consists of two files that work together:

| File | Role |
|------|------|
| `.R` script | **Analytical laboratory.** All code lives here — data loading, wrangling, plotting. Chunks are delimited by `# ---- chunk-name ---` comments. |
| `.qmd` document | **Publication layer.** Contains YAML front matter, narrative text, and empty code chunks that pull code from the `.R` script via `read_chunk()`. |

The `.qmd` file calls `read_chunk()` in its setup chunk to register all named chunks from the `.R` script. Each subsequent chunk in `.qmd` has a matching `label:` but an **empty body** — the code executes automatically from the sourced `.R` file.

For a deeper treatment of R Markdown and Quarto workflows, see [R for Data Science — Quarto chapter](https://r4ds.hadley.nz/quarto).

## Rendering Step by Step

### 1. Open a terminal at the project root

All paths in the scripts are relative to the project root (`quick-start-template/`). Make sure your working directory is set there.

### 2. Render with Quarto CLI

```powershell
quarto render analysis/eda-1/eda-1.qmd
```

This single command:

1. Starts an R session
2. Executes the `.qmd`, which calls `read_chunk("analysis/eda-1/eda-1.R")` to load the chunk definitions
3. Runs each named chunk in order
4. Produces a self-contained HTML file in the same directory (`analysis/eda-1/eda-1.html`)

### 3. Open the output

Open `analysis/eda-1/eda-1.html` in any browser. The report includes an interactive table of contents, collapsible code blocks, and inline figures.

## Rendering from VS Code

This project includes a pre-configured VS Code task. Open the Command Palette (`Ctrl+Shift+P`), select **Tasks: Run Task**, then choose **Render EDA-1 Quarto Report**.

## Common Issues

| Problem | Solution |
|---------|----------|
| `Error: package 'X' not found` | Install the missing package: `install.packages("X")` |
| Working directory errors | Ensure your terminal is at the project root, not inside `analysis/eda-1/` |
| `read_chunk()` fails to find the `.R` file | The path in `read_chunk()` is relative to the project root — check that it matches the actual file location |
| Plots not rendering | Verify `ggplot2` and other graphing packages are installed |

## How It Works Under the Hood

```
analysis/eda-1/
├── eda-1.R          # All code, organized into named chunks
├── eda-1.qmd        # Narrative + empty chunk references
├── eda-1.html        # Output (generated, not version-controlled)
└── figure-png-iso/  # Plot files (generated)
```

The `.qmd` setup chunk contains:

```r
read_chunk("analysis/eda-1/eda-1.R")
```

This tells `knitr` to scan the `.R` file for lines like `# ---- load-packages ---` and register each section as a named chunk. When the `.qmd` encounters a chunk with a matching `label`, it executes the corresponding code from the `.R` file.

For the theory behind this approach, see:

- [Quarto documentation](https://quarto.org/docs/guide/)
- [R for Data Science (2e) — Quarto basics](https://r4ds.hadley.nz/quarto)
- [knitr::read_chunk() documentation](https://bookdown.org/yihui/rmarkdown-cookbook/read-chunk.html)

## Next Steps

- Read `analysis/eda-1/eda-style-guide.md` for conventions on chunk naming and graph families
- See `guides/flow-usage.md` for how analysis fits into the broader project pipeline
- Try modifying a chunk in the `.R` file and re-rendering to see changes reflected in the HTML
