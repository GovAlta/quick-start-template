# publishing-contract.prompt.md Template

This template defines the schema for `publishing-contract.prompt.md` — the single contract file that captures **what pages will exist in `edited_content/` and which protocol governs each**. The Interviewer agent uses this as the scaffold when producing a contract from human intent.

Key principle: protocols classify pages in the edited site, not files in the repo. Each page listed below follows exactly one protocol. Raw files are source material — the same raw file can feed multiple edited pages under different protocols.

---

## Maturity Requirements

Before producing a contract, the Interviewer must verify:

- At least one EDA report **beyond EDA-1** exists (`analysis/eda-2/` or higher)
- At least one non-exploratory report exists (`analysis/report-1/` or equivalent)

> **EDA-1 is excluded from all frontends.** `analysis/eda-1/` uses the mtcars dataset as a learning scaffold. It is not an analytical product and must never appear in a contract.

If either maturity requirement is unmet, warn the human before proceeding: *"The repository may not be mature enough to publish. A frontend without real analysis risks presenting infrastructure without insight."*

---

## Default Architecture

Every frontend is a static Quarto website. The Interviewer scaffolds the contract from this standard architecture, adding optional sections based on human intent.

```
Navbar
├── (index)        ← Home page. Present in edited_content/ but absent from navbar.
├── Project        ← MANDATORY
├── Pipeline       ← MANDATORY
├── Analysis       ← MANDATORY
├── Docs           ← MANDATORY
├── Story          ← Optional: talks, slides, presentations
├── Materials      ← Optional: supplementary resources
└── Philosophy     ← Optional: methodology essays, epistemic notes
```

### Mandatory Section Defaults

#### index (Home Page — not in navbar)

| Page | Protocol | Default Source |
|---|---|---|
| Home | Narrative Bridge | Synthesized from mission, method, README, forecast image |

#### Project

| Page | Protocol | Default Source |
|---|---|---|
| Mission | Direct Line (VERBATIM) | `./ai/project/mission.md` |
| Method | Direct Line (VERBATIM) | `./ai/project/method.md` |
| Glossary | Direct Line (VERBATIM) | `./ai/project/glossary.md` |
| Summary | Narrative Bridge | Synthesized from mission, method, README, EDA findings |

#### Pipeline

| Page | Protocol | Default Source |
|---|---|---|
| Pipeline Guide | Technical Bridge | `./manipulation/pipeline.md` — mermaid shortcode, sanitize developer noise; draw on `./README.md` for context |
| Cache Manifest | Direct Line (VERBATIM) | `./data-public/metadata/CACHE-manifest.md` |

#### Analysis

| Page | Protocol | Default Source |
|---|---|---|
| EDA | Direct Line (REDIRECTED) | `./analysis/eda-2/eda-2.html` (or highest-numbered real EDA; never EDA-1) |
| Report | Direct Line (REDIRECTED) | `./analysis/report-1/report-1.html` |

#### Docs

| Page | Protocol | Default Source |
|---|---|---|
| README | Technical Bridge | `./README.md` — links rewritten, mermaid injected, images co-located |
| Site Map | Narrative Bridge | Agent-authored from contract navigation structure |
| Publisher Notes | Direct Line (VERBATIM) | `./.github/publishing-orchestra-3.md` |

### Optional Section Defaults

#### Story (when human describes a talk, slides, or presentation)

| Page | Protocol | Default Source |
|---|---|---|
| [Talk title] | Narrative Bridge or Technical Bridge | Per human intent |

> When the human mentions a talk, deck, slides, or presentation, route it to **Story** — not as a standalone deliverable.

---

## Schema

```markdown
# [Website Name]

## Purpose

[1-2 paragraphs describing the website's goal, intended audience, and context.
Example: "A project documentation site for the caseload forecasting pipeline,
aimed at team members and stakeholders who need to understand the data,
methodology, and results."]

## Navigation

[Each ### section defines one navbar entry. Pages listed under each section
become dropdown items. Single-page sections become direct navbar links.
The index page is listed first but is NOT added to the navbar — it is the home page.]

### index (Home Page)
- **Protocol**: Narrative Bridge
- **Intent**: [Orient the visitor; establish credibility; invite exploration]
- **Goal**: Home page — the first thing a visitor sees
- **Spirit**: [Professional but approachable; visuals lead]
- **Inputs**: [mission, README pipeline diagram, hero forecast image, etc.]

### Project

#### Mission
- **Protocol**: Direct Line (VERBATIM)
- **Source**: ./ai/project/mission.md

#### Method
- **Protocol**: Direct Line (VERBATIM)
- **Source**: ./ai/project/method.md

#### Glossary
- **Protocol**: Direct Line (VERBATIM)
- **Source**: ./ai/project/glossary.md

#### Summary
- **Protocol**: Narrative Bridge
- **Intent**: [What this page should accomplish for the reader]
- **Goal**: Project summary — a synthesized overview for first-time visitors
- **Spirit**: [Tone and feel]
- **Inputs**: [ai/project/mission.md, ai/project/method.md, README.md]

### Pipeline

#### Pipeline Guide
- **Protocol**: Technical Bridge
- **Source**: ./manipulation/pipeline.md
- **Transforms**: Mermaid shortcode injection, sanitize developer noise; draw on README.md for framing context

#### Cache Manifest
- **Protocol**: Direct Line (VERBATIM)
- **Source**: ./data-public/metadata/CACHE-manifest.md

### Analysis

#### EDA
- **Protocol**: Direct Line (REDIRECTED)
- **Source**: ./analysis/eda-2/eda-2.html

#### Report
- **Protocol**: Direct Line (REDIRECTED)
- **Source**: ./analysis/report-1/report-1.html

### Docs

#### README
- **Protocol**: Technical Bridge
- **Source**: ./README.md
- **Transforms**: Rewrite internal links for site context, inject mermaid shortcode, co-locate images

#### Site Map
- **Protocol**: Narrative Bridge
- **Intent**: Help visitors navigate the site and understand what each section contains. Must include a **Content Types** table (defining VERBATIM, COMPOSED, GENERATED, REDIRECT) and a **Navigation Structure** ASCII tree annotating every page with its content type and source provenance.
- **Goal**: Site map — an oriented index of all pages
- **Spirit**: Concise, functional
- **Inputs**: Contract navigation structure (this file)

#### Publisher Notes
- **Protocol**: Direct Line (VERBATIM)
- **Source**: ./.github/publishing-orchestra-3.md

### Story  <!-- optional: include if human describes a presentation or talk -->

#### [Talk Title]
- **Protocol**: [Narrative Bridge or Technical Bridge, per intent]
- ...

## Exclusions

[Patterns and paths to exclude from content discovery]
- *.R
- *_cache/
- data-private/
- nonflow/
- README.md (inside subfolders)
- prompt-start.md
- analysis/eda-1/  ← always excluded

## Theme

[Quarto Bootswatch theme name]
journal

## Footer

[Footer text, or "none"]

## Repo URL

[GitHub repository URL, or "none"]
```

---

## Field Reference

| Field | Required | Producer | Description |
|-------|----------|----------|-------------|
| Website Name | Yes | Interviewer | Display title for the site |
| Purpose | Yes | Interviewer + Human | Goal and audience |
| Navigation | Yes | Interviewer + Human | Sections with pages, each assigned a protocol |
| Exclusions | Yes | Interviewer | Patterns to skip during content discovery |
| Theme | No | Interviewer + Human | Bootswatch theme (default: cosmo) |
| Footer | No | Interviewer + Human | Footer text |
| Repo URL | No | Interviewer | GitHub URL for site links |

---

## Protocol Reference

Each page must be assigned exactly one protocol. However, the same **raw file** can serve as source material for multiple edited pages, each under a different protocol.

### Direct Line (VERBATIM)

- **Source**: Required. Path to the repo `.md` or `.qmd` file.
- The Writer morphs the source to `.qmd`: prepends YAML frontmatter (`title:` derived from first `#` heading), preserves all body content exactly. No editorial changes.
- Renders to `.html` via standard Quarto processing.

### Direct Line (REDIRECTED)

- **Source**: Required. Path to the `.html` file.
- Displayed via redirect stub. Post-render hook copies HTML to `_site/`.

### Technical Bridge

- **Source**: Required. Path to the repo file.
- **Transforms**: Required. List of modifications to apply (link rewriting, shortcode injection, sanitization, etc.).

### Narrative Bridge

- **Intent**: Required. What this page accomplishes for the reader.
- **Goal**: Required. Functional role of the page.
- **Spirit**: Required. Tone and feel.
- **Inputs**: Required. Which repo files to consult and what to extract from each.

---

## Conventions

- **File paths**: Use relative paths from the repo root (e.g., `./guides/getting-started.md`).
- **Section ordering**: Sections appear in the navbar in the order listed.
- **Multiple roles**: Note when a raw file feeds both a Direct Line page and a Narrative Bridge page as input.
- **Human comments**: HTML comments (`<!-- ... -->`) are preserved as human reasoning.
- **Missing files**: The Interviewer validates all paths before finalizing. Missing files flagged as warnings.
- **analysis/eda-1/**: Always excluded. Never appears in any contract.
