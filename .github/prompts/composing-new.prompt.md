---
description: >
  Bootstrap a new EDA, Report, or Data Primer via the Composing Orchestra. Scaffolds the
  analysis directory, creates report contract, populates the Data Context section (for EDA/Report),
  and begins adaptive interview.
agent: Report Composer
---

# Compose New Report

Bootstrap a new analytical report (EDA or Presentation Report) using the Composing Orchestra system.

## Process

### Step 1: Determine Report Type

Ask the human if this is an **EDA** (exploratory data analysis), a **Report** (presentation-layer synthesis), or a **Data Primer** (canonical data documentation). If ambiguous, ask:

> "Is this an **EDA** (exploring data with open mind), a **Report** (synthesizing findings into narrative), or a **Data Primer** (the shared data reference for this project)?"

### Step 2: Find Next Available N

Scan existing directories to determine the next available number:

- For EDA: scan `analysis/eda-*/` directories → next N after highest existing
- For Report: scan `analysis/report-*/` directories → next N (or 1 if none exist)
- For Data Primer: scan `analysis/data-primer-*/` directories → next N (typically 1 for the first)

**Important**: `analysis/eda-1/` is a style reference (mtcars scaffold) and does NOT count as a composed EDA. The first composed EDA is `eda-2`.

### Step 3: Check for Conflicts

If the target directory already exists:
- List its contents
- Ask: "Directory `analysis/{target}/` already exists with these files. Should I continue developing this report, or create a new one?"
- If continuing: read `report-contract.prompt.md` and resume from Phase 1 or Phase 2

### Step 3b: Check Data Primer Prerequisite *(EDA and Report only)*

For EDA or Report types, check if `analysis/data-primer-1/` exists and contains a `.qmd` file:

- **If it exists**: Note it in the contract's Supporting field; the `.qmd` Data Context section will link to `../data-primer-1/data-primer-1.html`
- **If it does NOT exist**: Inform the human:
  > "No data primer found at `analysis/data-primer-1/`. The data primer is the canonical data reference that all EDAs and Reports link to. I recommend composing it first. Shall I compose `data-primer-1` now instead?"
  Wait for explicit direction before proceeding.

### Step 4: Scaffold

Create the target directory and populate it from templates in `.github/templates/`:

**For EDA or Report:**

| Template Source | Target File |
|----------------|-------------|
| `composing-contract-template.md` | `analysis/{target}/report-contract.prompt.md` |
| `composing-template.R` | `analysis/{target}/{name}.R` |
| `composing-template.qmd` | `analysis/{target}/{name}.qmd` |

**For Data Primer:**

| Template Source | Target File |
|----------------|-------------|
| `composing-contract-template.md` | `analysis/{target}/report-contract.prompt.md` |
| `composing-template.R` | `analysis/{target}/{name}.R` |
| `data-primer-template.qmd` | `analysis/{target}/{name}.qmd` |

Also create:
- `analysis/{target}/data-local/` directory
- `analysis/{target}/prints/` directory

Replace all `{PLACEHOLDERS}` in templates:
- `{NAME}` → e.g., `eda-7`, `report-1`, `data-primer-1`
- `{TITLE}` → descriptive title (ask if not provided)
- `{DATE}` → current date
- `{TYPE}` → `EDA`, `Report`, or `Data Primer`
- `{LOCAL_ROOT}` → `./analysis/{target}/`

### Step 5: Register in flow.R

Add a **commented-out** entry to the `ds_rail` tibble in `flow.R`:

```r
# "run_qmd", "analysis/{target}/{name}.qmd",  # {mission} (composed, not yet active)
```

Place it after existing entries in the PHASE 2 section, maintaining the comment alignment style.

### Step 6: Begin Adaptive Interview

Ask 3–5 focused questions to refine `report-contract.prompt.md`. Questions are adaptive — each answer influences the next.

After the interview:
- Update `report-contract.prompt.md` with mission, research questions, target graph families
- Add initial graph family stubs to the `.R` file (g1-data-prep, g1, etc.)
- For EDA/Report: populate the `data-context-tables`, `data-context-person`, and `data-context-distributions` chunks in both `.R` and `.qmd`
- For Data Primer: populate the primer sections from Ellis metadata and CACHE manifest

## Default Section Mapping

### EDA Default Sources
| Contract Field | Typical Source |
|---------------|---------------|
| Primary Data | `data-private/derived/manipulation/*.parquet` |
| Supporting | `data-public/metadata/CACHE-manifest.md`, `ai/project/glossary.md` |
| Graph families | 3–5, driven by interview answers |

### Report Default Sources
| Contract Field | Typical Source |
|---------------|---------------|
| Upstream EDAs | `analysis/eda-2/`, `analysis/eda-3/`, etc. (explicit list) |
| Supporting | `ai/project/mission.md`, memo documents, external reports |
| Graph families | Curated from upstream EDAs + 1–2 new synthesis graphs |

## Reference Files

Read these before scaffolding:
- `.github/composing-orchestra-1.md` — Design document
- `analysis/eda-1/eda-style-guide.md` — Canonical style conventions
- `data-public/metadata/CACHE-manifest.md` — Data dictionary
- `flow.R` — Pipeline registration (for ds_rail entry)
