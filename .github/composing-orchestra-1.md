# Composing Orchestra — Design Document v1

> **Status**: v1 — Initial design  
> **Created**: 2026-03-19  
> **Scope**: Single-agent system for bootstrapping and iteratively developing analytical reports (EDA or Presentation Report) in `./analysis/`

---

## Overview

The **Composing Orchestra** is a single-agent system that helps researchers quickly start and develop analytical reports after Ellis lane processing is complete. It scaffolds a working directory, populates a per-report Data Context section for reader orientation, and iteratively refines the report through adaptive conversation.

The system recognizes three output types: **EDA**, **Report**, and **Data Primer** — the latter being a dedicated, human-verified reference report composed once and shared by all subsequent EDAs and Reports.

### Relationship to Publishing Orchestra

| Concern | Composing Orchestra | Publishing Orchestra |
|---------|---------------------|----------------------|
| **Creates** | Raw analytical content in `analysis/` | Curated static website in `_frontend-N/` |
| **Agent count** | 1 (Report Composer) | 2 (Interviewer + Writer) |
| **Contract** | `report-contract.prompt.md` — structured brief | `publishing-contract.prompt.md` — page-level spec |
| **Trigger** | Human says "compose eda-N" or "compose report-N" | Human says "publish frontend-N" |
| **Output** | `.R` + `.qmd` pair + rendered HTML/PDF | `edited_content/` + `_site/` |

The two systems are **complementary**: Composing creates content that Publishing later curates for a website. They share no artifacts and can operate independently.

---

## Core Concepts

### Report Artifacts

Every EDA or Report produced by the Composing Orchestra generates two artifacts:

1. **`report-contract.prompt.md`** — A structured brief capturing: mission, data sources, research questions (3–5), target graph families, output format, scope boundaries. Created during scaffolding, refined via adaptive interview.

2. **`.R` + `.qmd` pair** — The report itself, following the dual-file pattern from `analysis/eda-1/eda-style-guide.md`. The `.R` script is the analytical laboratory; the `.qmd` is the publication layer sourcing chunks via `read_chunk()`. The `.qmd` contains a **Data Context** section (see below).

### Centralized Data Primer

The data primer lives at `analysis/data-primer-1/` and is itself composed via `@report-composer` like any other analysis — with its own contract, `.R` + `.qmd` pair, and adaptive interview. It is the canonical, human-verified reference covering:

- Pipeline architecture (Ellis → parquet assets)
- Data asset inventory (table, grain, row count, column count)
- Grain demonstration (code proving uniqueness at the stated grain)
- Single-person view (one individual's data across all tables)
- Full variable reference (column types, key distributions)
- Program taxonomy quick reference

The data primer is composed **once** and updated deliberately. New EDAs and Reports check for its existence before starting, and link to it for deep data context.

### Per-Report Data Context Section

Every EDA or Report `.qmd` contains a **Data Context** section immediately after the data-loading chunks. This section gives the reader what they need to know about the data *for this specific analysis*:

- **Link to the data primer** for full documentation
- **Tables and variables used** — which Ellis outputs this report draws on and why
- **Grain proof** — code demonstrating the unit of analysis (e.g., person-year)
- **Single-person view** — what the data looks like for a representative individual
- **Key variable distributions** — distributions of the variables most relevant to this report's research questions

The Data Context section is **analysis-specific** and lightweight. It orients the reader locally without duplicating the primer.

### Two Modes

| Aspect | EDA (Exploration Layer) | Report (Presentation Layer) |
|--------|------------------------|-----------------------------|
| **Goal** | Discover patterns with open mind | Synthesize evidence into narrative |
| **Graph density** | 3–5 graph families, with exploration variants (g21, g22…) | Curated selection from upstream EDAs + new graphs |
| **Narrative weight** | Light — annotations on what the graph shows | Heavy — guided story with evidence |
| **Upstream sources** | Ellis output directly | One or more EDAs + other documents |
| **Default output** | HTML (interactive, code-fold) | PDF (polished aesthetics) or HTML |
| **Directory pattern** | `analysis/eda-N/` | `analysis/report-N/` |
| **Research questions** | Exploratory — "what does X look like?" | Focused — "does X support claim Y?" |
| **Template variation** | Header comments emphasize exploration | Header comments emphasize synthesis |

### Single-Agent Design

Unlike Publishing Orchestra (which separates conversation from execution), Composing Orchestra uses **one agent** that both interviews and builds. This is deliberate:

- Analytical work is **iterative** — the researcher and agent refine together
- The interview is **lightweight** (3–5 adaptive questions), not a full contract negotiation
- Scaffolding happens **immediately**, then refinement follows
- The same agent that understands the data context also writes the code

---

## Workflow

### Phase 0: Bootstrap

Triggered by the human (via `composing-new.prompt.md` or direct invocation of `@report-composer`).

1. **Determine type**: EDA, Report, or Data Primer (ask if ambiguous)
2. **Find next N**: Scan `analysis/eda-*/`, `analysis/report-*/`, or `analysis/data-primer-*/` for next available number
3. **Check existence**: If target directory exists, prompt human before overwriting
4. **Check data primer prerequisite** *(EDA and Report only)*: Verify `analysis/data-primer-1/` exists with a composed report. If absent, inform the human and suggest composing the data primer first. Proceed only with explicit human approval.
5. **Scaffold**: Create directory with template files (contract, .R, .qmd from `composing-template.*`; or `.qmd` from `data-primer-template.qmd` for Data Primer type)
6. **Register in flow.R**: Add commented-out entry to `ds_rail`

### Phase 1: Adaptive Interview

After scaffolding, the agent asks 3–5 focused questions to refine the contract. Questions are adaptive — each answer influences the next question.

**Example question sequence for an EDA:**
1. "What aspect of the data are you most curious about?" → establishes mission
2. "Which Ellis tables are most relevant?" → narrows data sources
3. "What comparisons or breakdowns would be most informative?" → suggests graph families
4. "Are there specific variables or subgroups to focus on?" → refines scope
5. "Any known patterns or hypotheses to explore?" → seeds initial graphs

**Example question sequence for a Report:**
1. "Which EDAs or documents should this report synthesize?" → establishes upstream sources
2. "Who is the primary audience?" → sets narrative tone and detail level
3. "What is the key message or finding?" → establishes thesis
4. "What evidence from the EDAs best supports this message?" → curates content
5. "PDF, HTML, or both?" → sets output format

After the interview, the agent updates `report-contract.prompt.md` and refines the `.R` file with initial graph family stubs.

### Phase 2: Iterative Development

The agent and human collaborate to build the report:

- Agent proposes graph families based on contract research questions
- Human reviews, adjusts, requests alternatives
- Agent maintains dual-file synchronization (.R ↔ .qmd)
- Agent follows `eda-style-guide.md` conventions throughout
- Agent can render intermediate versions for review

### Phase 3: Completion

- Human activates the `ds_rail` entry in `flow.R` (uncomments the line)
- Report renders cleanly via `quarto render`
- The report is now available for Publishing Orchestra to discover and curate

---

## File Inventory

### Framework Files (in `.github/`)

| File | Purpose |
|------|---------|
| `composing-orchestra-1.md` | This design document |
| `agents/report-composer.agent.md` | Agent definition |
| `instructions/report-composition.instructions.md` | Stable rules for `analysis/**` |
| `prompts/composing-new.prompt.md` | Bootstrap prompt |
| `templates/composing-contract-template.md` | Contract schema |
| `templates/composing-template.R` | Shared R template (EDA + Report) |
| `templates/composing-template.qmd` | Shared Quarto template (EDA + Report) |
| `templates/data-primer-template.qmd` | Data primer template (used for `analysis/data-primer-1/`) |
| `copilot/composing-orchestra-SKILL.md` | Skill discovery |

### Per-Report Files (in `analysis/eda-N/` or `analysis/report-N/`)

| File | Purpose |
|------|---------||
| `report-contract.prompt.md` | Structured brief for this report |
| `{name}.R` | Analytical laboratory (includes data-context chunks) |
| `{name}.qmd` | Publication layer (includes Data Context section) |
| `data-local/` | Intermediate processing files |
| `prints/` | High-quality plot exports |
| `local-functions.R` | Analysis-specific helper functions (created on demand) |

### Data Primer Files (in `analysis/data-primer-1/`)

| File | Purpose |
|------|---------||
| `report-contract.prompt.md` | Structured brief for the data primer |
| `data-primer-1.R` | Data profiling code |
| `data-primer-1.qmd` | Canonical rendered knowledge base (standalone HTML) |

---

## Conventions

### EDA-1 Exclusion

`analysis/eda-1/` is a **style reference only** (mtcars scaffold). It is never produced by the Composing Orchestra and never modified. All new EDAs start from `eda-2` onward. The `eda-style-guide.md` in `eda-1/` is the canonical source for all styling rules.

### Graph Naming

From `eda-style-guide.md`:
- `g1`, `g2`, `g3`… — Individual graphs or family identifiers
- `g21`, `g22`, `g23`… — Members of family g2 (sharing `g2-data-prep` ancestor)
- `g2-data-prep` — Data preparation chunk for family g2
- `t1`, `t2`… — Tables and summaries
- `m1`, `m2`… — Models and statistical analyses
- Numbering **never changes** even if graphs are removed

### Print Optimization

Default: 8.5 × 5.5 inches at 300 DPI (letter-size half-page portrait). Use both `print()` and `ggsave()` in R scripts; Quarto chunk bodies remain empty as `print()` executes automatically via `read_chunk()`.

### Alberta Corporate Visual Identity

Reference `scripts/graphing/graph-presets.R` for `abcol`, `binary_colors`, `acru_colors_9` palettes.

### Data Provenance

Every `ds*` and `g*` object must trace back to:
- Ellis output (`data-private/derived/manipulation/*.parquet`) →
- CACHE database tables (`data-public/metadata/CACHE-manifest.md`) →
- Batch-91 source data

### Descriptive Default

Default to descriptive statistics. Prompt the human before using inferential approaches.

---

## Integration Points

### flow.R

New reports are registered as **commented-out** entries in `ds_rail`:

```r
ds_rail <- tibble::tribble(
  ~fx, ~path,
  # ... existing entries ...
  # "run_qmd", "analysis/eda-7/eda-7.qmd",  # {mission summary} (composed, not yet active)
)
```

The human uncomments the line when the report is ready for batch rendering.

### Publishing Orchestra

When Publishing Orchestra scans the repo for publishable content, Composing Orchestra reports appear naturally in `analysis/`. No special integration is needed — the publishing contract maps them via standard protocols (typically Direct Line REDIRECTED for rendered HTML reports).

### Persona System

The `report-composer` agent is **not** a persona in the `ai/personas/` system. It is a VS Code agent (`.agent.md`) that can be invoked with `@report-composer`. It synthesizes the Grapher and Reporter personas internally but operates as an independent tool-using agent.

---

## Philosophical Foundations

### Tukey (Exploratory Data Analysis)
- Approach data with an open mind — let patterns emerge
- Use robust statistics resistant to outliers
- "The greatest value of a picture is when it forces us to notice what we never expected to see"
- Question assumptions; expect the unexpected

### Tufte (Visual Clarity)
- Maximize data-ink ratio — remove chartjunk
- Show the data clearly and honestly
- Use small multiples for comparisons
- "Above all else, show the data"

### Wickham (Tidy Toolchain)
- Tidy data: variables in columns, observations in rows
- Grammar of graphics: layer aesthetics, geometries, scales systematically
- Pipe-based workflows for readability
- Reproducible code that others can understand and verify

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| v1 | 2026-03-19 | Initial design |
