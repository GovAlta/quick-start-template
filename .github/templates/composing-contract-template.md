# Composing Orchestra — Report Contract Template

> **Purpose**: Schema and documentation for `report-contract.prompt.md` files created by the Composing Orchestra system. Each `analysis/eda-N/` or `analysis/report-N/` directory contains one contract file that serves as the structured brief guiding report development.

---

## Contract Schema

Copy the block below into `report-contract.prompt.md` and fill in the fields:

```markdown
# Report Contract: {NAME}

## Type
{EDA | Report}

## Date
{YYYY-MM-DD created} | Last updated: {YYYY-MM-DD}

## Status
{draft | active | complete}

## Mission
{1–2 sentences describing what this report investigates or synthesizes.
For EDA: what aspect of the data are we exploring?
For Report: what story or argument are we presenting?}

## Data Sources

### Primary
{List the Ellis parquet table(s) this report uses. E.g.:
- `data-private/derived/manipulation/support_by_year.parquet` — person-year financial support
- `data-private/derived/manipulation/client_roster.parquet` — person-level demographics}

### Supporting
{List other data, documents, or references:
- `data-public/metadata/CACHE-manifest.md` — variable definitions
- `ai/project/glossary.md` — domain terminology
- External documents, OSI scripts, etc.}

## Research Questions
1. {First question — the most important}
2. {Second question}
3. {Third question}
4. {Optional: fourth question}
5. {Optional: fifth question}

## Target Graph Families
- g1: {Brief description of first graph family and its analytical focus}
- g2: {Brief description of second graph family}
- g3: {Brief description of third graph family}
{Add more as needed. These are initial targets; the list evolves during development.}

## Output Format
{HTML | PDF | Both}
{For EDA: typically HTML with code-fold and table of contents}
{For Report: typically PDF with polished aesthetics, or HTML for interactive content}

## Upstream EDAs
{For Reports only. List the EDAs this report synthesizes:
- `analysis/eda-2/` — Person-level view: service reach & combinations
- `analysis/eda-3/` — Linkage evaluation: SIN coverage & demographics
Leave blank or remove this section for EDAs.}

## Scope Boundaries

### Included
{What this report covers:
- Specific populations, time periods, program types
- Analytical approaches (descriptive, comparative, etc.)}

### Excluded
{What is explicitly out of scope:
- Populations or programs not covered
- Analyses deferred to other EDAs or reports}

## Notes
{Any additional context, known issues, or reminders for the developer.
Delete this section if empty.}
```

---

## Field Reference

| Field | Required | Producer | Notes |
|-------|----------|----------|-------|
| Type | Yes | Composer | `EDA` or `Report` |
| Date | Yes | Composer | Auto-populated at creation |
| Status | Yes | Composer/Human | Updated as work progresses |
| Mission | Yes | Human (via interview) | 1–2 sentences |
| Data Sources | Yes | Composer + Human | Primary = Ellis tables; Supporting = everything else |
| Research Questions | Yes | Human (via interview) | 3–5 questions; drives graph families |
| Target Graph Families | Yes | Composer + Human | Initial targets from interview; evolves |
| Output Format | Yes | Human | Default: HTML (EDA), PDF (Report) |
| Upstream EDAs | Report only | Human | Explicit list of source EDAs |
| Scope Boundaries | Recommended | Human | Prevents scope creep |
| Notes | Optional | Human | Free-form working notes |

## Status Lifecycle

```
draft → active → complete
```

- **draft**: Scaffolded, interview in progress, contract being refined
- **active**: Research questions defined, development underway
- **complete**: All research questions addressed, report renders cleanly

## Conventions

- The contract is a **living document** — update it as scope evolves
- Research questions drive graph families; graph families drive `.R` chunks
- If a research question is dropped, mark it ~~strikethrough~~ rather than deleting
- The contract lives alongside the report at `analysis/{target}/report-contract.prompt.md`
- The Composing Orchestra agent reads this file to understand report context when continuing work
