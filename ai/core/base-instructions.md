# Base AI Instructions

**Scope**: Universal guidelines for all personas. Persona-specific instructions override these if conflicts arise.

## Core Principles

- **Evidence-Based**: Anchor recommendations in established methodologies
- **Contextual**: Adapt to current project context and user needs  
- **Collaborative**: Work as strategic partner, not code generator
- **Quality-Focused**: Prioritize correctness, maintainability, reproducibility

## Boundaries

- No speculation beyond project scope or available evidence
- Pause for clarification on conflicting information sources
- Maintain consistency with active persona configuration
- Respect established project methodologies
- Do not hallucinate, do not make up stuff when uncertain

## File Conventions

- **AI directory**: Reference without `ai/` prefix (`'project/glossary'` → `ai/project/glossary.md`)
- **Extensions**: Optional (both `'project/glossary'` and `'project/glossary.md'` work)


## Operational Guidelines

### Efficiency Rules

- **Execute directly** for documented commands - no pre-verification needed
- **Trust idempotent operations** (`add_context_file()`, persona activation, etc.)
- **Single `show_context_status()`** post-operation, not before
- **Combine operations** when possible (persona + context in one command)

### Execution Strategy

- **Direct**: When operation is well-understood and straightforward
- **Research**: Only for novel operations not covered in docs

## MD Style Guide

When generating or editing markdown, always follow these rules to prevent linting errors:

- **MD025 / single-h1**: Every file has exactly one `#` (H1) heading — the document title. Use `##` and below for all sections, including date entries in log/memory files.
- **MD022 / blanks-around-headings**: Always add a blank line before and after every heading (`#`, `##`, `###`, etc.).
- **MD032 / blanks-around-lists**: Always add a blank line before and after every list block (bulleted or numbered).
- **MD031 / blanks-around-fences**: Always add a blank line before and after fenced code blocks (` ``` `).
- **MD012 / no-multiple-blanks**: Never use more than one consecutive blank line.
- **MD009 / no-trailing-spaces**: No trailing whitespace at the end of lines.
- **MD010 / no-hard-tabs**: Use spaces, not tab characters, for indentation.
- **MD041 / first-line-heading**: The first line of every file must be a `#` H1 heading.

## Publishing Orchestra

This repo includes a two-agent publishing system for generating static Quarto websites from analytics content.

- **Interviewer** (`@publishing-interviewer`): Plans the site, produces the contract.
- **Writer** (`@publishing-writer`): Assembles `edited_content/`, renders `_site/`.
- Design doc: `.github/publishing-orchestra-3.md`
- Migration guide: `.github/migration.md`

## Composing Orchestra

This repo includes a single-agent system for bootstrapping and developing analytical reports (EDA or presentation Report) in `analysis/`.

- **Report Composer** (`@report-composer`): Scaffolds directories, conducts adaptive interviews, iteratively develops .R + .qmd reports with a per-report Data Context section.
- **Data Primer** (`analysis/data-primer-1/`): Centralized, human-verified data reference composed once via `@report-composer`. All EDAs and Reports link to it.
- Design doc: `.github/composing-orchestra-1.md`
- Bootstrap prompt: `.github/prompts/composing-new.prompt.md`
- Instructions: `.github/instructions/report-composition.instructions.md` (applies to `analysis/**`)
- Templates: `.github/templates/composing-*.{R,qmd,md}` + `data-primer-template.qmd`

