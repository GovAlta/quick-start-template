---
name: composing-orchestra
description: "**WORKFLOW SKILL** — Compose new EDA (exploratory data analysis) or presentation Report in analysis/ using a single-agent pipeline (Report Composer). USE FOR: starting a new EDA or report after Ellis lane; scaffolding analysis directories with data primer, contract, and R+Quarto templates; iterative analytical report development; understanding the composing workflow. DO NOT USE FOR: publishing websites (use publishing-orchestra); modifying Ellis lane or data pipelines; running existing reports. INVOKES: Report Composer agent, which scaffolds, interviews, and iteratively develops analytical content."
---

# Composing Orchestra

A single-agent system for bootstrapping and iteratively developing analytical reports (EDA or presentation Report) in `analysis/`. The Report Composer agent synthesizes Tukey's exploratory philosophy, Tufte's visual clarity, and Wickham's tidy toolchain.

---

## Architecture

```
Human ↔ Report Composer
              │
              ├──► analysis/eda-N/     (EDA: explore with open mind)
              └──► analysis/report-N/  (Report: synthesize findings)
```

### Agent

| Agent | Role | Invocation |
|-------|------|------------|
| **Report Composer** | Scaffold, interview, develop, iterate | `@report-composer` |

### Two Modes

| Mode | Purpose | Output | Directory |
|------|---------|--------|-----------|
| **EDA** | Discover patterns with open mind | HTML (interactive) | `analysis/eda-N/` |
| **Report** | Synthesize EDAs into narrative | PDF or HTML | `analysis/report-N/` |

### Per-Report Artifacts

| File | Purpose |
|------|---------|
| `report-contract.prompt.md` | Structured brief: mission, data sources, research questions, graph families |
| `{name}-data-primer.qmd` | Standalone rendered knowledge base: pipeline, schema, single-person view |
| `{name}.R` + `{name}.qmd` | Dual-file analytical content (lab + publication layer) |

---

## Workflow

1. **Human invokes** `@report-composer` or runs `composing-new` prompt
2. **Composer scaffolds** directory with all template files + data primer
3. **Composer asks** 3–5 adaptive questions → refines contract
4. **Composer develops** graph families and narrative iteratively with human
5. **Human activates** in `flow.R` when ready (uncomments `ds_rail` entry)

## Relationship to Publishing Orchestra

Composing creates raw analytical content; Publishing curates it for a website. The two systems are complementary — Composing outputs appear as publishable content that Publishing can later discover and include.

## Key References

- Design document: `.github/composing-orchestra-1.md`
- Agent definition: `.github/agents/report-composer.agent.md`
- Instructions: `.github/instructions/report-composition.instructions.md`
- Bootstrap prompt: `.github/prompts/composing-new.prompt.md`
- Templates: `.github/templates/composing-*.{R,qmd,md}` + `data-primer-template.qmd`
- Style guide: `analysis/eda-1/eda-style-guide.md`
