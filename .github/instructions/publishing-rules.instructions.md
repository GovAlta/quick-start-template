---
description: "Rules for assembling edited_content/ from repository source files. Organized by writing protocol: Direct Line, Technical Bridge, Narrative Bridge. Applied by the Publishing Writer."
applyTo: "_frontend-*/**"
---

# Publishing Rules

Exhaustive rules for how the Writer agent constructs pages in `edited_content/`. Each page in `edited_content/` follows exactly one protocol. The protocols classify edited pages, not raw files — raw files are source material that feeds into the construction of each edited page.

Organized by writing protocol. Consult `.github/publishing-orchestra-3.md` for the full system design.

---

## 1. General Principles

### Self-Containment Rule

At the conclusion of assembly, the `edited_content/` folder must be fully autonomous. All images, data artifacts, and includes must be co-located. No relative paths may point outside this folder.

### Source File Integrity

Never edit original source files in their repository locations. All transformations happen on copies placed inside `edited_content/`. The originals remain the source of truth.

### Explicit Render List

The `_quarto.yml` file must list every page individually in `project.render`. Never use wildcards or auto-discovery.

### Page Semantics

- Each page defined in the contract becomes one page in `edited_content/` and one page on the website.
- Protocols classify these edited pages, not the raw source files. A raw file may feed multiple edited pages under different protocols.
- Never expose raw file paths as visible page text, headings, or navigation labels.
- Derive display labels from: (1) YAML frontmatter `title`, (2) first markdown heading, (3) humanized filename stem — in that priority order.

---

## 2. Direct Line Protocol

For content that should reach the reader essentially as the analyst wrote it. Two modes: VERBATIM and REDIRECTED.

### 2a. VERBATIM Mode

**When**: The contract assigns Direct Line (VERBATIM) to a source file.

**QMD Morphing** (for all `.md` and `.qmd` source files):

1. **Derive the title** from the source file's first `#` heading. If no `#` heading exists, humanize the filename stem (e.g., `cache-manifest` → `Cache Manifest`).
2. **Prepend YAML frontmatter** — add a frontmatter block at the top of the file if one is missing, or augment an existing one with at minimum a `title:` field:

   ```yaml
   ---
   title: "<derived title>"
   ---
   ```

3. **Write as `.qmd`** — save the result to `content/<section>/` with a `.qmd` extension regardless of the source extension. Quarto renders `.qmd` to `.html` natively, producing clean URLs.
4. **Do not modify content** — preserve every line of the source body exactly. The only permitted change is the addition of the YAML frontmatter block. No editorial rewriting, no section trimming, no reformatting.
5. **Register in `_quarto.yml`** as a `.qmd` path. Quarto renders it to `_site/content/<section>/<filename>.html`.

**Asset resolution**: Apply the asset resolution algorithm (Section 6) to co-locate all referenced images and files.

### 2b. REDIRECTED Mode

**When**: The contract assigns Direct Line (REDIRECTED) to an HTML report.

**Stub creation**: Create a `.qmd` stub in `edited_content/<section>/`:

```qmd
---
title: "<Report Title>"
format:
  html:
    page-layout: full
    toc: false
---

<meta http-equiv="refresh" content="0; url=<relative-path-to-html>">
```

**Hook registration**: Register a post-render R script to copy the target `.html` into `_site/` at the correct path. The script goes in `_frontend-N/scripts/` and is registered in `_quarto.yml` under `project.post-render`.

**Never use iframes**. Never use `target="_blank"` links.

---

## 3. Technical Bridge Protocol

For content derived from a repo file with modifications applied. The source is recognizably the same document — adapted for the website context.

**When**: The contract assigns Technical Bridge to a source file and specifies which transforms to apply.

### 3a. Link Rewriting

Convert internal repository paths to relative website paths:

- `./guides/getting-started.md` → `../guides/getting-started.html` (if that page exists in the site)
- Links to files not included in the website → convert to plain text or remove
- Align links with the site's navigation structure

### 3b. Shortcode Injection (Mermaid Diagrams)

Replace markdown mermaid fences with Quarto include shortcodes:

1. Extract the mermaid fence content into a separate `_partial.qmd` file
2. Replace the fence with `{{< include _partial.qmd >}}`
3. This ensures Quarto's mermaid renderer processes the diagram correctly

### 3c. Developer Content Stripping

Remove content not relevant to the website audience:

- TODO lists and internal-only comments
- Local file-system paths and CLI commands
- Git clone instructions, `renv` setup, environment configuration
- CI/CD details and contributor guidelines
- Internal-only references (`data-private/`, credentials)

### 3d. Extension Promotion

When a `.md` file requires Quarto-specific features (e.g., `{{< include >}}` shortcodes), rename it to `.qmd` so Quarto processes it correctly.

### 3e. Frontmatter and Formatting

- Ensure proper YAML frontmatter exists
- Adapt section headings if needed for website context
- Apply the asset resolution algorithm (Section 6)

### Priority

Formatting over content. The Writer preserves the source's meaning while adapting its technical format. Do not editorially revise the content.

---

## 4. Narrative Bridge Protocol

For content that doesn't exist in the repo — or that synthesizes multiple sources into something new.

**When**: The contract assigns Narrative Bridge and provides a brief with intent, goal, spirit, and inputs.

### 4a. General Rules

- Read the brief from the contract to identify intent, goal, and spirit
- Read the specified input sources from the repo
- Author the page content following the brief
- **Epistemological grounding**: Every factual claim must trace to a specific Raw source. When making claims about data or results, reference which file supports it. Do not hallucinate data results not found in the source files.

### 4b. Index / Landing Page

The index page has **three mandatory components**, assembled in this order:

#### Component 1 — Key Image (Hero)

The single most important visual in the project — typically the primary forecast or results chart. Place it first, above all prose.

- The contract brief or the human's intent statement identifies which image to use. If not specified, use the primary forecast chart from `analysis/report-1/prints/` (or the highest-numbered report available).
- Co-locate the image in `edited_content/images/` and reference it with a relative path.
- Include a concise caption (one sentence) that explains what the reader is looking at.
- Render at `width=90%` or similar to fill the page column without overflow.

#### Component 2 — Welcome

A brief, plain-language orientation — no more than 3–4 short paragraphs or equivalent bullet prose.

- State what this project is and who it is for.
- Mention the mandatory website sections by name (Project, Pipeline, Analysis, Docs), and any optional sections present (Story, etc.) — one sentence each.
- No developer jargon, CLI commands, or build instructions.
- No link to external repositories or file paths.
- Every internal link must point to a page that exists in the site's navbar.
- Draw from `ai/project/mission.md` and the root `README.md` for factual grounding.

#### Component 3 — Pipeline Architecture Diagram

Render the pipeline diagram immediately after the Welcome section.

- Extract the mermaid diagram from `manipulation/pipeline.md` (or `README.md` if not available there) into a `_mermaid-index.qmd` partial file co-located in `edited_content/`.
- Include it via `{{< include _mermaid-index.qmd >}}`.
- Precede the diagram with a short label (e.g., `## How It Works` or `## Pipeline`) — one heading level below the page title.
- Do not duplicate this partial if one already exists for another page; reuse the same file.

#### General rules

- Link alignment: every link must point to a page that exists in the site's navbar.
- No developer jargon, CLI commands, or build instructions.
- If the contract specifies additional images beyond the hero, place them after Component 3.

### 4c. Site Map

Rules for auto-generating a site map. The site map page must contain two mandatory sections in this order:

**1. Content Types table**

Define the four content types used in this site. Use this exact table structure:

```markdown
## Content Types

| Type | Meaning |
|------|----------|
| **VERBATIM** | Source `.md` morphed to `.qmd` with YAML frontmatter added; content preserved exactly |
| **COMPOSED** | Authored by the Publishing Writer; synthesized from one or more raw sources per the contract brief |
| **GENERATED** | Produced by a pre-render script from a verbatim source, with transforms applied (e.g., mermaid diagram injection) |
| **REDIRECT** | Transit `.qmd` stub that forwards the browser to a standalone rendered HTML file |
```

**2. Navigation Structure tree**

An ASCII tree showing every page in the site with its content type annotation and source provenance arrow. Use this format:

```markdown
## Navigation Structure

```
[Site Title]
│
├── 🏠  Index                      COMPOSED  ← [brief source description]
│
├── [Section]
│   ├── [Page]                     VERBATIM  ← [source file path]
│   └── [Page]                     GENERATED ← [source file] (pre-render: [transform])
│
└── [Section]
    ├── [Page]                     REDIRECT  → [target html path]
    └── [Page]                     COMPOSED  ← [brief source description]
` `` 
```

Annotation rules:
- Use `←` for pages where content flows in from a raw source
- Use `→` for REDIRECT pages where the browser is forwarded out to an HTML file
- Every navbar page must appear in the tree
- The index page appears first, marked with `🏠`, and is noted as absent from the navbar

After the two mandatory sections, the site map may also include a **Source File Provenance** table and a **Build System** description (pre/post-render hooks), as appropriate.

### 4d. Project Summary

Rules for synthesizing a project overview:

- Draw from `ai/project/mission.md`, `ai/project/method.md`, and the root `README.md`
- 300-500 words unless the contract specifies differently
- Professional tone appropriate for the stated audience
- Reference source files for every factual claim

### 4e. Audience Adaptation

If the contract specifies a different audience than the repo's natural one:

- Paraphrase technical evidence into the appropriate register
- Executive audience: focus on outcomes, impact, timeline
- Technical peer audience: preserve methodological detail
- Mixed audience: layer information (summary first, detail available via linked pages)

---

## 5. Source-Specific Rules

### 5a. Analysis Content (`analysis/`)

When sources come from `analysis/` subfolders:

| Source | Priority | Use for |
|---|---|---|
| `prints/` | **Preferred** | Publication-ready PNGs for website visuals |
| `figure-png-iso/` | Avoid | Intermediate Quarto render artifacts |
| `*_cache/` | Exclude | Internal knitr/Quarto caches |

Always exclude from content:

- `*.R` script files
- `README.md` inside analysis subfolders
- `prompt-start.md` authoring briefs
- `*_cache/` directories
- `data-local/` directories

### 5b. Manipulation Content (`manipulation/`)

When sources come from `manipulation/`:

- `pipeline.md` is the primary page content
- Use images from `manipulation/images/` (prefer `flow-skeleton.png`)
- Copy images to `content/<section>/images/`

Always exclude:

- All `*.R` script files
- `nonflow/` directory
- `example/` directory (unless explicitly requested)
- `data-private/` references

When describing pipeline outputs, refer to output types generically ("Parquet files", "SQLite database") without exposing file system paths.

### 5c. Index Page Source (`README.md`)

When the root `README.md` is used as a Technical Bridge source for the index:

- Adapt for website audience (retain purpose/overview; remove setup/CI details)
- Rewrite internal links to match site structure
- Align with site map from the contract
- Apply user notes if specified

When `README.md` is used as a Direct Line source in a Docs section:

- Copy as-is via the VERBATIM protocol
- Co-locate all referenced images

The same `README.md` can serve both roles in the same site.

---

## 6. Asset Resolution Algorithm

Apply to every file copied into `edited_content/`:

1. **Scan** the source file for all local asset references:
   - Markdown images: `![...](path)`
   - HTML images: `<img src="path">`
   - HTML/CSS resources: `<link href="path">`, `<script src="path">`
   - Quarto includes: `{{< include path >}}`
   - Exclude absolute URLs (`http://`, `https://`, `data:`)

2. **Resolve** each relative path against the source file's original directory in the repo.

3. **Copy** the resolved file to a mirrored path under `content/<section>/`:
   - Preserve the relative path structure so references resolve automatically
   - Example: `README.md` references `libs/images/foo.png` → copy to `content/docs/libs/images/foo.png`

4. **Do not rewrite** internal references. Preserving relative paths means copies resolve from their new location.

5. **Recurse**: if a copied asset references further assets, apply the same algorithm.

### Broken Link Prevention

Verify every internal cross-reference in `content/` resolves. If a link points to a file excluded by the contract:

- Convert to plain text, or
- Flag in `BUILD_REPORT.md`

---

## 7. Pre/Post-Render Hooks

Hooks are a **first-class pattern**, not workarounds.

### When to Use

- REDIRECTED pages whose HTML targets live outside `edited_content/`
- Images or assets that cannot be pre-resolved at assembly time
- Dynamic content generation (e.g., mermaid diagram injection from source files)

### Implementation

1. Create R scripts in `_frontend-N/scripts/`
2. Register in `_quarto.yml` under `project.pre-render` or `project.post-render`
3. Each script must include a header comment:

   ```r
   # Purpose: [what this hook does]
   # Registered as: [pre-render | post-render]
   # Why needed: [why the self-containment rule doesn't cover this case]
   ```

### Established Patterns

| Script | Hook | Purpose |
|---|---|---|
| `prep-pipeline-qmd.R` | pre-render | Generate `pipeline.qmd` from `manipulation/pipeline.md`, inject mermaid include |
| `copy-analysis-html.R` | post-render | Copy redirect target HTMLs into `_site/`, mirror README images |

---

## 8. `_quarto.yml` Rules

### Explicit Render List

Every page in the contract must appear individually in `project.render`. No wildcards.

### Navigation Mirroring

The navbar structure must exactly match the contract's navigation hierarchy. Single-page sections use direct links; multi-page sections use dropdown menus.

### Hook Registration

All pre/post-render scripts registered under `project.pre-render` / `project.post-render` with their full relative path.

### Theme and Format

```yaml
format:
  html:
    theme: <theme from contract>
    toc: true
    mermaid:
      theme: neutral
```

---

## 9. Error Handling

### BUILD_REPORT.md

If the Writer encounters issues that don't block assembly:

1. Complete the rest of the assembly
2. Create `edited_content/BUILD_REPORT.md` with:
   - Issue description
   - Affected page(s)
   - Suggested resolution
   - Severity (warning vs. error)

### Post-Render Reconciliation

After rendering:

1. Count `.html` files in `_site/`
2. Compare against intended pages in the contract
3. Report discrepancies in the assembly report

---

## 10. Sync Behavior

- Re-resolve all file references on every Writer run
- If source files changed since the last run, update corresponding files in `edited_content/`
- If new matching files appear, add them during the same run
- Always overwrite `_quarto.yml` from the contract (the contract is the source of truth)
