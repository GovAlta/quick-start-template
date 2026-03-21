# Orchestra Migration Guides

How to lift orchestration systems from source repositories into a target repository that does not have them yet. Each section covers one orchestra — listing the exact files to copy, prerequisites, and steps to follow. An agent in the target repository can use this file as the authoritative import guide.

---

## Publishing Orchestra — Migration Guide

How to lift the publishing orchestra from `caseload-forecast-demo` into another repository that does not have it yet.

---

### What You Are Migrating

The publishing orchestra is a **two-agent system** (Interviewer + Writer) that turns an analytics repository into a static Quarto website. It lives entirely in `.github/` and works without touching any of the repo's existing code.

**Files to copy** (7 files across `.github/`):

```text
.github/
├── publishing-orchestra-3.md                   ← Design doc (read-only reference)
├── agents/
│   ├── publishing-interviewer.agent.md          ← Interviewer agent
│   └── publishing-writer.agent.md               ← Writer agent
├── instructions/
│   └── publishing-rules.instructions.md         ← Writer rules (applyTo: _frontend-*/**)
├── templates/
│   └── publishing-contract-template.md          ← Contract schema
├── copilot/
│   └── publishing-orchestra-SKILL.md            ← Skill for discoverability
└── prompts/
    └── publishing-new.prompt.md                 ← Bootstrap new frontend
```

---

### Prerequisites in the Target Repo

Before migrating, verify:

- [ ] [Quarto](https://quarto.org/) is installed (`quarto --version`)
- [ ] R is available (`Rscript --version`) — needed for post-render hooks
- [ ] The target repo has at least one EDA report beyond EDA-1 (e.g., `analysis/eda-2/`)
- [ ] The target repo has at least one non-exploratory report (e.g., `analysis/report-1/`)
- [ ] VS Code with GitHub Copilot (agent mode) is available

---

### Migration Steps

#### Step 1 — Copy the framework files

Copy all 7 files listed above from `caseload-forecast-demo/.github/` into the target repo's `.github/`. Preserve the directory structure exactly.

```bash
# From a workspace containing both repos, e.g.:
cp -r caseload-forecast-demo/.github/agents target-repo/.github/
cp -r caseload-forecast-demo/.github/instructions target-repo/.github/
cp -r caseload-forecast-demo/.github/templates target-repo/.github/
cp -r caseload-forecast-demo/.github/copilot target-repo/.github/
cp -r caseload-forecast-demo/.github/prompts target-repo/.github/
cp caseload-forecast-demo/.github/publishing-orchestra-3.md target-repo/.github/
```

Or on Windows (PowerShell):

```powershell
$src = "path\to\caseload-forecast-demo\.github"
$dst = "path\to\target-repo\.github"
Copy-Item "$src\publishing-orchestra-3.md" $dst
Copy-Item "$src\agents" $dst -Recurse
Copy-Item "$src\instructions" $dst -Recurse
Copy-Item "$src\templates" $dst -Recurse
Copy-Item "$src\copilot" $dst -Recurse
Copy-Item "$src\prompts" $dst -Recurse
```

#### Step 2 — Verify VS Code picks up the agents

Open the target repo in VS Code. In the Copilot chat panel, type `@` and confirm that **Publishing Interviewer** and **Publishing Writer** appear in the agent list.

If they do not appear:

- Check that `.github/agents/publishing-interviewer.agent.md` and `publishing-writer.agent.md` exist
- Reload VS Code window (`Ctrl+Shift+P` → "Developer: Reload Window")

#### Step 3 — Adapt `copilot-instructions.md` (if target repo has one)

If the target repo has a `.github/copilot-instructions.md`, add a reference to the publishing orchestra so the default agent knows it exists:

```markdown
## Publishing Orchestra

This repo includes a two-agent publishing system for generating static Quarto websites from analytics content.
- **Interviewer** (`@publishing-interviewer`): Plans the site, produces the contract.
- **Writer** (`@publishing-writer`): Assembles `edited_content/`, renders `_site/`.
- Design doc: `.github/publishing-orchestra-3.md`
- Migration guide: `.github/migration.md`
```

#### Step 4 — Adapt the `applyTo` pattern (if needed)

The `publishing-rules.instructions.md` file has a frontmatter directive:

```yaml
applyTo: "_frontend-*/**"
```

This tells VS Code to apply the rules only to files in `_frontend-N/` folders. If the target repo uses a different naming convention for frontend workspaces (e.g., `_site-N/`), update the `applyTo` pattern to match.

#### Step 5 — Create the first frontend

Follow the standard workflow:

1. Create `analysis/frontend-N/initial.prompt.md` — fill in your intent.
2. Invoke `@publishing-interviewer` — it will scan the repo, interview you, and produce `_frontend-N/publishing-contract.prompt.md`.
3. Review and confirm the contract.
4. Invoke `@publishing-writer` — it will assemble `edited_content/`, generate `_quarto.yml`, and render `_site/`.

Or use the bootstrap prompt if available:

```text
@publishing-interviewer #file:.github/prompts/publishing-new.prompt.md
```

---

### What Does NOT Transfer Automatically

- **`ai/` directory**: The persona system, dynamic context builder, and project-specific AI config are repo-specific. Do not copy them unless the target repo has the same structure.
- **`analysis/` content**: EDA and report files are repo-specific. The orchestra reads them from the target repo.
- **`data-public/` manifests**: These are produced by the target repo's own pipeline.
- **`llms.txt`**: Repo-specific LLM context file, if present.

---

### Minimal Viable Target Repo Structure

For the orchestra to function, the target repo needs:

```text
target-repo/
├── .github/
│   ├── publishing-orchestra-3.md
│   ├── agents/
│   │   ├── publishing-interviewer.agent.md
│   │   └── publishing-writer.agent.md
│   ├── instructions/
│   │   └── publishing-rules.instructions.md
│   ├── templates/
│   │   └── publishing-contract-template.md
│   ├── copilot/
│   │   └── publishing-orchestra-SKILL.md
│   └── prompts/
│       └── publishing-new.prompt.md
├── analysis/
│   ├── eda-2/          ← Must exist (EDA beyond EDA-1)
│   │   └── eda-2.html
│   └── report-1/       ← Must exist (non-exploratory report)
│       └── report-1.html
└── README.md           ← Used by Interviewer for project context
```

---

### Publishing Orchestra Troubleshooting

| Issue | Fix |
| --- | --- |
| Agents not visible in VS Code | Reload window; verify `.agent.md` files are in `.github/agents/` |
| `publishing-rules` not applying | Check `applyTo` frontmatter matches `_frontend-*/**` pattern |
| Interviewer refuses to proceed | Verify `analysis/eda-2/` and `analysis/report-1/` exist with rendered HTML |
| Post-render hook fails | Verify R is on PATH; check paths in `scripts/copy-analysis-html.R` match your repo structure |
| Mermaid diagram not rendering | Ensure `_quarto.yml` includes `format: html: mermaid: theme: neutral` |

---

### Publishing Orchestra Version

This migration guide is written against **Publishing Orchestra v3** (`publishing-orchestra-3.md`, March 2026).
If you encounter a newer design doc in `caseload-forecast-demo/.github/`, check whether a newer migration guide supersedes this one.

---

## Composing Orchestra — Migration Guide

How to lift the composing orchestra from `sda-fiesta-29` into another repository that does not have it yet.

---

### Composing Orchestra Assets

The composing orchestra is a **single-agent system** (`@report-composer`) that scaffolds, interviews, and iteratively develops analytical EDA and Report files in `analysis/`. It lives entirely in `.github/` and works alongside any existing repo pipeline without touching it.

**Files to copy** (9 files across `.github/`):

```text
.github/
├── composing-orchestra-1.md                    ← Design doc (read-only reference)
├── agents/
│   └── report-composer.agent.md                ← Composer agent
├── instructions/
│   └── report-composition.instructions.md      ← Stable rules (applyTo: analysis/**)
├── templates/
│   ├── composing-contract-template.md          ← Contract schema
│   ├── composing-template.R                    ← Shared R template
│   ├── composing-template.qmd                  ← Shared Quarto template
│   └── data-primer-template.qmd                ← Data primer template
├── copilot/
│   └── composing-orchestra-SKILL.md            ← Skill for discoverability
└── prompts/
    └── composing-new.prompt.md                 ← Bootstrap new EDA / Report
```

---

### Composing Orchestra Prerequisites

Before migrating, verify:

- [ ] [Quarto](https://quarto.org/) is installed (`quarto --version`)
- [ ] R is available (`Rscript --version`) with `tidyverse`, `arrow`, `ggplot2`, `scales`
- [ ] The target repo has a data processing pipeline whose outputs live in a known location (e.g., parquet files from an Ellis lane)
- [ ] VS Code with GitHub Copilot (agent mode) is available
- [ ] `analysis/` directory exists (even if empty beyond EDA-1)

---

### Composing Orchestra Steps

#### Step 1 — Copy the Composing Orchestra Files

Copy all 9 files listed above from `sda-fiesta-29/.github/` into the target repo's `.github/`. Preserve the directory structure exactly.

```powershell
$src = "path\to\sda-fiesta-29\.github"
$dst = "path\to\target-repo\.github"

Copy-Item "$src\composing-orchestra-1.md" $dst
Copy-Item "$src\agents\report-composer.agent.md" "$dst\agents\"
Copy-Item "$src\instructions\report-composition.instructions.md" "$dst\instructions\"
Copy-Item "$src\templates\composing-contract-template.md" "$dst\templates\"
Copy-Item "$src\templates\composing-template.R" "$dst\templates\"
Copy-Item "$src\templates\composing-template.qmd" "$dst\templates\"
Copy-Item "$src\templates\data-primer-template.qmd" "$dst\templates\"
Copy-Item "$src\copilot\composing-orchestra-SKILL.md" "$dst\copilot\"
Copy-Item "$src\prompts\composing-new.prompt.md" "$dst\prompts\"
```

Or on Unix/macOS:

```bash
src="path/to/sda-fiesta-29/.github"
dst="path/to/target-repo/.github"
cp "$src/composing-orchestra-1.md" "$dst/"
cp "$src/agents/report-composer.agent.md" "$dst/agents/"
cp "$src/instructions/report-composition.instructions.md" "$dst/instructions/"
cp "$src/templates/composing-"* "$dst/templates/"
cp "$src/templates/data-primer-template.qmd" "$dst/templates/"
cp "$src/copilot/composing-orchestra-SKILL.md" "$dst/copilot/"
cp "$src/prompts/composing-new.prompt.md" "$dst/prompts/"
```

#### Step 2 — Verify VS Code picks up the agent

Open the target repo in VS Code. In the Copilot chat panel, type `@` and confirm that **Report Composer** appears in the agent list.

If it does not appear:

- Check that `.github/agents/report-composer.agent.md` exists
- Reload VS Code window (`Ctrl+Shift+P` → "Developer: Reload Window")

#### Step 3 — Update `copilot-instructions.md` (if target repo has one)

If the target repo has a `.github/copilot-instructions.md`, add a reference to the composing orchestra so the default agent knows it exists:

```markdown
## Composing Orchestra

This repo includes a single-agent system for bootstrapping and developing analytical reports (EDA or presentation Report) in `analysis/`.
- **Report Composer** (`@report-composer`): Scaffolds directories, conducts adaptive interviews, iteratively develops .R + .qmd reports with a per-report Data Context section.
- **Data Primer** (`analysis/data-primer-1/`): Centralized, human-verified data reference composed once via `@report-composer`. All EDAs and Reports link to it.
- Design doc: `.github/composing-orchestra-1.md`
- Bootstrap prompt: `.github/prompts/composing-new.prompt.md`
- Instructions: `.github/instructions/report-composition.instructions.md` (applies to `analysis/**`)
- Templates: `.github/templates/composing-*.{R,qmd,md}` + `data-primer-template.qmd`
```

#### Step 4 — Update data paths in the templates

The templates reference parquet files via `arrow::read_parquet()` paths that are specific to `sda-fiesta-29`. Open the three template files and update any hard-coded paths to match the target repo's pipeline outputs:

- `.github/templates/composing-template.R` — update the commented-out parquet paths under `# load-data`
- `.github/templates/data-primer-template.qmd` — update the Data Assets Inventory code chunks that scan parquet files

If the target repo uses a different data format (e.g., `.csv`, `.rds`), replace the `arrow::read_parquet()` calls with the appropriate reader.

#### Step 5 — Compose `data-primer-1` first

The data primer is the prerequisite for all new EDAs and Reports. Before composing any analysis, compose the centralized data reference:

```text
@report-composer let's compose data-primer-1
```

The agent will scaffold `analysis/data-primer-1/` using `data-primer-template.qmd`, interview you about which data tables to cover, and produce:

```text
analysis/data-primer-1/
    report-contract.prompt.md     ← structured brief
    data-primer-1.R               ← data profiling code
    data-primer-1.qmd             ← renders to data-primer-1.html
```

Render and **review the output** before proceeding. The data primer is human-verified and treated as ground truth by all downstream EDAs.

#### Step 6 — Start composing EDAs and Reports

Once the data primer exists, invoke the bootstrap prompt for any new analysis:

```text
@report-composer #file:.github/prompts/composing-new.prompt.md
```

Or directly:

```text
@report-composer let's start a new EDA on [topic]
```

The agent will determine the next available `N`, scaffold `analysis/eda-N/`, conduct an adaptive interview, populate the Data Context section, and register a commented-out entry in `flow.R`.

---

### What Stays in the Source Repo

- **`ai/` directory**: The persona system, dynamic context builder, and project-specific AI config are repo-specific. Do not copy unless the target repo has the same structure.
- **`analysis/` content**: Existing EDA and report files are repo-specific. The agent reads them from the target repo.
- **`flow.R`**: The pipeline registration script is repo-specific. The agent will add entries to whatever `flow.R` exists in the target repo.
- **`data-private/` and `data-public/`**: Data files are never migrated; only the templates that reference them.
- **`analysis/data-primer-1/`**: Must be freshly composed in the target repo — it is data-specific, not template-specific.

---

### Minimum Target Repo Setup

For the composing orchestra to function, the target repo needs:

```text
target-repo/
├── .github/
│   ├── composing-orchestra-1.md
│   ├── agents/
│   │   └── report-composer.agent.md
│   ├── instructions/
│   │   └── report-composition.instructions.md
│   ├── templates/
│   │   ├── composing-contract-template.md
│   │   ├── composing-template.R
│   │   ├── composing-template.qmd
│   │   └── data-primer-template.qmd
│   ├── copilot/
│   │   └── composing-orchestra-SKILL.md
│   └── prompts/
│       └── composing-new.prompt.md
├── analysis/
│   └── eda-1/          ← Style reference (mtcars scaffold); must exist but is never modified
├── flow.R              ← Pipeline registration script (agent adds commented-out entries)
└── README.md           ← Used by agent for project context
```

---

### Composing Orchestra Troubleshooting

| Issue | Fix |
| --- | --- |
| `@report-composer` not visible in VS Code | Reload window; verify `.github/agents/report-composer.agent.md` exists |
| `report-composition` instructions not applying | Check `applyTo: "analysis/**"` frontmatter in `report-composition.instructions.md` |
| Agent cannot find parquet files | Update data paths in `composing-template.R` and `data-primer-template.qmd` to match target repo |
| Agent warns "data primer not found" | Compose `analysis/data-primer-1/` first (Step 5 above) |
| Quarto render fails on `read_chunk()` | Ensure the `.R` file path in `knitr::read_chunk()` is relative to the `.qmd` file's location |
| Graphs appear but are unsized | Check `fig.width` / `fig.height` chunk options; default is 8.5 × 5.5 inches |
| `flow.R` entries not added | Agent adds entries as comments — search for `# eda-N` in `flow.R` after scaffolding |

---

### Composing Orchestra Version

This migration guide is written against **Composing Orchestra v1** (`composing-orchestra-1.md`, March 2026).
If you encounter a newer design doc in `sda-fiesta-29/.github/`, check whether a newer migration guide supersedes this one.
