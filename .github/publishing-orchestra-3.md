# Publishing Orchestra — Design v3

**Status**: Current design reference (March 2026). Supersedes `publishing-orchestra-2.md`.

A two-agent system that transforms a reproducible analytics repository into a static Quarto website — with human editorial control at every state of rest.

> **Every frontend is a static Quarto website.** Even when the primary deliverable is a single presentation or slideshow, it must be published within the standard site architecture (Project, Pipeline, Analysis, Docs), with the presentation appearing in the Story section. A presentation without a home is not a frontend — it is a file.

---

## Three States of Analytic Content

The central model: a three-state content lifecycle with a **probabilistic** first transition and a **deterministic** second.

```
RAW  ───prob───►  EDITED  ───det───►  PRINTED
(repo)            (content/)           (_site/)
```

### Raw

The repository at a point in time. Contains everything: working drafts, analyses, pipelines, AI config, developer tooling. Honest but noisy. Not shaped for any audience — shaped to the convenience of the analyst who composed it.

### Edited

Content curated by a human (via `publishing-contract.prompt.md`) and assembled by the Writer agent into `_frontend-N/content/`. Self-contained, normalized, ready for Quarto rendering. Every page in `content/` follows exactly one of three protocols (see Writing Protocols below). The protocols classify pages in the Edited state — not files in Raw. Raw files are source material; the protocol defines how each edited page gets constructed.

### Printed

The rendered static website in `_frontend-N/_site/`. Output of `quarto render` applied to the Edited state. Browseable, portable, self-contained. Can be opened via `file://` without a local server.

### The Two Transitions

| Transition | Nature | Agents | Explanation |
|---|---|---|---|
| RAW → EDITED | **Probabilistic** | Interviewer + Writer (iterative, human-guided) | Requires judgment: what to include, how to frame it, who reads it |
| EDITED → PRINTED | **Deterministic** | `quarto render` | Mechanical: same `content/` + `_quarto.yml` → same `_site/` |

---

## Two Agents

| Agent | Role | Human-facing? | Analogy |
|---|---|---|---|
| **Interviewer** | Planning + human conversation. Reads human intent, scans repo, designs the edited site structure with protocol assignments, produces `publishing-contract.prompt.md`. | Yes | "What do you want to say?" |
| **Writer** | Execution. Populates `edited_content/`, generates `_quarto.yml`, renders `_site/`. Guided by instruction rules. Non-conversational — reports results. | No | "Here's what you are saying, right?" |

### Why this split

- The **Interviewer** requires judgment: interpreting vague human intent, designing the edited site, deciding which protocol each page follows, writing Narrative Bridge briefs. It's conversational.
- The **Writer** requires precision: copying files, authoring Narrative Bridge pages per instruction rules, resolving assets. It's procedural.
- `publishing-contract.prompt.md` is the clean handoff: human-readable intent on one side, mechanical execution on the other.
- If the Writer gets something wrong in `edited_content/`, you re-run *just the Writer* without redoing editorial planning.

### What happened to v2's agents

| v2 Agent | v3 Fate | Rationale |
|---|---|---|
| Publishing Orchestrator | Absorbed into **Interviewer** | The Interviewer is the human-facing agent; state detection is a decision tree, not a separate entity |
| Publishing PE | Absorbed into **Interviewer** Phase 1 | Repo scanning and intent elicitation are the Interviewer's first act |
| Publishing Editor | Split: planning → **Interviewer**, assembly → **Writer** | Planning and assembly are conceptually distinct |
| Publishing Printer | Absorbed into **Writer** | Assembly and rendering are sequential steps of the same procedural agent |

### Interviewer: Objective Statement

> Your task is to transform raw human intent and repository evidence into a singular, high-fidelity contract: `publishing-contract.prompt.md`. You must approach this task with the "spiritual goal" of an analyst: seeking the most parsimonious path from available evidence to desired knowledge.

---

## Phases as States of Rest

Phases denote movement between **states of rest** at which humans can inspect the language of the artifacts. Each checkpoint is a mandatory pause — no agent auto-proceeds.

### Phase 0 — Human Intent

**Gate**: Before the Interviewer can engage, the human must author:

```
./analysis/frontend-N/initial.prompt.md
```

This file ships as a lightweight getting-started template. The Interviewer's first act is to verify it has been filled in — not just the default placeholder. If the file still contains only the template stub, the Interviewer stops and asks the human to complete it before proceeding.

`initial.prompt.md` captures the human's vision for this specific frontend: who the audience is, what the site should communicate, what content from the repository should appear, and what feeling a visitor should walk away with. It is the permanent starting record for this frontend's editorial intent.

**Iteration rounds** produce delta files:

- `frontend-N-1.prompt.md` — first refinements after seeing the initial contract
- `frontend-N-2.prompt.md` — further adjustments
- Each delta assumes prior prompts have been implemented. Deltas are additive, not replacements.
- Kept as separate files to preserve the trajectory of evolving human thinking.

### Phase 1 — Interview

**Agent**: Interviewer (human-facing, conversational)

**Inputs**:

- `analysis/frontend-N/initial.prompt.md` — primary human intent (must be authored before Phase 1 begins)
- `analysis/frontend-N/frontend-N-*.prompt.md` — delta rounds, read in order
- `.github/templates/publishing-contract-template.md` — default architecture scaffold
- Repo contents — scanned for publishable material

**Process**:

1. Verify `initial.prompt.md` is authored (not the template stub). Stop and prompt the human if not.
2. Read `initial.prompt.md` and any delta files in order.
3. Scan the repo for publishable content. Assess **maturity**: does the repo have at least one EDA script beyond EDA-1 and at least one non-exploratory report? If not, warn the human before proceeding.
4. Design the `content/` structure using the **Default Site Architecture** (see below) as the scaffold. Add optional sections (Story, Materials, Philosophy) based on human intent. When the human describes a talk, slideshow, or presentation, route it to the Story section.
5. For each planned page, assign a protocol: Direct Line, Technical Bridge, or Narrative Bridge.
6. For Narrative Bridge pages, write a brief: intent, goal, spirit, desired effect.
7. Produce `_frontend-N/publishing-contract.prompt.md`.

**Output**: `_frontend-N/publishing-contract.prompt.md`

**Checkpoint**: Human reviews and confirms the contract. May edit it directly before proceeding.

### Phase 2 — Writing

**Agent**: Writer (non-conversational, instruction-guided)

**Inputs**:

- `_frontend-N/publishing-contract.prompt.md` (confirmed by human)
- `.github/instructions/publishing-rules.instructions.md`
- Repo source files (read-only)

**Process**: Populate `_frontend-N/content/`:

- **Direct Line** pages → copy from repo, add frontmatter if missing; create redirect stubs for HTML targets
- **Technical Bridge** pages → copy source, apply modifications per rules
- **Narrative Bridge** pages → author new content per brief + instruction rules

**Self-containment rule**: At the end of Phase 2, `content/` is fully self-contained. All images, figures, and assets are co-located. No relative paths may point outside this folder.

**Output**: `_frontend-N/content/` — all pages and assets, organized by section.

**Checkpoint**: Human can browse `edited_content/` to verify content before rendering.

### Phase 3 — Printing

**Agent**: Writer (continued)

**Process**:

1. Generate `_frontend-N/_quarto.yml` from `publishing-contract.prompt.md`
   - Explicit render list (no wildcards)
   - Navbar structure matching contract sections
   - Pre/post-render hooks if needed (documented, first-class)
2. Run `quarto render` from `_frontend-N/`
3. Reconcile: verify every page in the contract has a corresponding `.html` in `_site/`

**Output**:

- `_frontend-N/_quarto.yml` — Quarto config (the real and only build spec)
- `_frontend-N/_site/` — rendered static website

**Checkpoint**: Human reviews `_site/`.

---

## Writing Protocols

Protocols classify **pages in `edited_content/`**, not files in Raw. Each page in the edited site follows exactly one protocol. Raw files are source material — they may feed into one or more edited pages, each under a different protocol.

The Interviewer's job in Phase 1 is to **design the edited site**: decide what pages will exist in `edited_content/`, assign each page a protocol, and identify which raw files serve as source material. For example, `README.md` might produce a Direct Line page in the Docs section and also serve as an input source for a Narrative Bridge landing page — two different edited pages, two different protocols, one raw file.

### Protocol 1: Direct Line

For content that should reach the reader essentially as the analyst wrote it. Two modes:

**VERBATIM mode**: Morph the source `.md` or `.qmd` to a `.qmd` file in the appropriate subfolder in `content/`. Derive the page title from the source file's first `#` heading (or humanize the filename if none exists). Prepend a YAML frontmatter block with at minimum a `title:` field. Do not modify any body content — preserve every line exactly.

**REDIRECTED mode**: For self-contained HTML reports that should be displayed in full. Create a stub `.qmd` file with `<meta http-equiv="refresh">` pointing to the target `.html`. Register a post-render hook to copy the target `.html` into `_site/`. Use `page-layout: full`, `toc: false`.

**Priority**: Formatting over content. The Writer's job is technical legibility, not editorial revision.

### Protocol 2: Technical Bridge

For content derived from a repo file with modifications applied. The source is recognizably the same document — but adapted for the website context.

**Operations**:

- **Link rewriting**: Convert internal repository paths to relative website paths
- **Shortcode injection**: Replace complex code blocks (like Mermaid diagrams) with `{{< include >}}` shortcodes for Quarto compatibility
- **Sanitization**: Strip developer-centric noise: TODO lists, local file-system paths, internal-only comments, build instructions
- **Extension promotion**: `.md` → `.qmd` when the file requires executable content like `{{< include >}}`
- **Frontmatter addition**: Ensure proper YAML frontmatter exists

**Priority**: Formatting over content. The Writer preserves the source's meaning while adapting its technical format.

### Protocol 3: Narrative Bridge

For content that doesn't exist in the repo — or that synthesizes multiple sources into something new.

**Process**:

- **Contextual synthesis**: Read the brief in `publishing-contract.prompt.md` to identify the intent, goal, and spirit
- **Narrative construction**: Assemble a coherent story (e.g., a landing page, project summary) by weaving together findings from multiple sources
- **Audience adaptation**: If the contract specifies a different audience, paraphrase existing technical evidence into the appropriate register (e.g., executive vs. technical peer)

**Epistemological grounding**: For Narrative Bridge content, every factual claim must be traceably derived from the Raw repository state. The Writer must not hallucinate data results not found in the source files. When making claims about what the data says, reference which Raw file supports it.

### Protocol Examples

| Page | Protocol | Source → Action |
|---|---|---|
| `project/mission.qmd` | Direct Line (VERBATIM) | `ai/project/mission.md` → morph to .qmd, add frontmatter |
| `project/method.qmd` | Direct Line (VERBATIM) | `ai/project/method.md` → morph to .qmd, add frontmatter |
| `project/glossary.qmd` | Direct Line (VERBATIM) | `ai/project/glossary.md` → morph to .qmd, add frontmatter |
| `pipeline/cache-manifest.qmd` | Direct Line (VERBATIM) | `data-public/metadata/CACHE-manifest.md` → morph to .qmd, add frontmatter |
| `docs/publisher-notes.qmd` | Direct Line (VERBATIM) | `.github/publishing-orchestra-3.md` → morph to .qmd, add frontmatter |
| `analysis/eda-2.qmd` | Direct Line (REDIRECTED) | Stub → redirects to `eda-2.html` |
| `analysis/report-1.qmd` | Direct Line (REDIRECTED) | Stub → redirects to `report-1.html` |
| `pipeline/pipeline.qmd` | Technical Bridge | `manipulation/pipeline.md` → mermaid shortcode, extension promoted, sanitized |
| `docs/readme.qmd` | Technical Bridge | `README.md` → links rewritten, mermaid injected, images co-located |
| `index.qmd` | Narrative Bridge | Agent-authored landing page from brief |
| `project/summary.md` | Narrative Bridge | Agent-authored project summary |
| `docs/site-map.md` | Narrative Bridge | Agent-authored site map |

> **Note on EDA-1**: `analysis/eda-1/` is a working example using the mtcars dataset — a scaffold for analysts learning to write EDA, not an analytical product. EDA-1 must never appear in a published frontend.

### How Raw Files Can Feed Multiple Edited Pages

A single raw file can appear as source material for multiple pages in `edited_content/`, each following a different protocol:

- `README.md` → feeds a **Direct Line** page in Docs section (displayed as-is for reference)
- `README.md` → feeds a **Narrative Bridge** page `index.qmd` (used as source material for a composed landing page)
- `manipulation/pipeline.md` → feeds a **Technical Bridge** page `pipeline/pipeline.qmd` (displayed with shortcode injection)
- `manipulation/pipeline.md` → feeds a **Narrative Bridge** page `index.qmd` (pipeline diagram extracted for landing page)

The protocol belongs to the **edited page**, not to the raw file. A raw file has no inherent protocol — it acquires one only when it becomes the source for a specific page in `edited_content/`.

---

## Default Site Architecture

Every frontend follows this standard architecture. The Interviewer uses it as a scaffold when producing the contract. Sections marked **mandatory** must be populated before publication — a frontend missing any of them is unlikely to be ready for an audience.

The **index page** is the home page. It is present in `edited_content/` but absent from the navbar — it is the destination for the root URL.

### Mandatory Sections

#### Project

Establishes the project's identity, purpose, and vocabulary. Populated from the `ai/project/` directory.

| Page | Protocol | Default Source |
|---|---|---|
| Mission | Direct Line (VERBATIM) | `./ai/project/mission.md` |
| Method | Direct Line (VERBATIM) | `./ai/project/method.md` |
| Glossary | Direct Line (VERBATIM) | `./ai/project/glossary.md` |
| Summary | Narrative Bridge | Synthesized from mission, method, README, and EDA findings |

#### Pipeline

Explains the data pipeline to someone who did not build it. Calibrated to be accessible to casual analysts — technically honest, approachable enough to be useful.

| Page | Protocol | Default Source |
|---|---|---|
| Pipeline Guide | Technical Bridge | `./manipulation/pipeline.md` — mermaid shortcode injection, sanitize developer noise; draws on `./README.md` for context |
| Cache Manifest | Direct Line (VERBATIM) | `./data-public/metadata/CACHE-manifest.md` |

#### Analysis

The analytical products of the project. Minimum: one exploratory and one non-exploratory report with conclusions.

| Page | Protocol | Default Source |
|---|---|---|
| EDA | Direct Line (REDIRECTED) | `./analysis/eda-2/eda-2.html` (or highest-numbered real EDA) |
| Report | Direct Line (REDIRECTED) | `./analysis/report-1/report-1.html` |

> **EDA-1 is excluded from all frontends.** `analysis/eda-1/` is a working example using the mtcars dataset — a scaffold for analysts learning to write EDA, not an analytical product. The Interviewer must never include EDA-1 in any contract.

#### Docs

Meta-documentation: what the site is, how it was built, how to navigate it.

| Page | Protocol | Default Source |
|---|---|---|
| README | Technical Bridge | `./README.md` — links rewritten, mermaid injected, images co-located |
| Site Map | Narrative Bridge | Agent-authored from contract navigation structure |
| Publisher Notes | Direct Line (VERBATIM) | `./.github/publishing-orchestra-3.md` |

### Optional Sections

Add these based on human intent. The Interviewer proposes them when matching content exists in the repo.

| Section | Use when | Typical content |
|---|---|---|
| **Story** | Human describes a talk, slideshow, or presentation | RevealJS slides, annotated narratives, workshop materials |
| **Materials** | Supplementary resources not fitting Analysis | Guides, datasets, templates, reference docs |
| **Philosophy** | Project has explicit philosophy documentation | Methodology essays, design rationale, epistemic notes |

> When the human describes a talk, deck, slides, or presentation, the Interviewer routes it to the **Story** section — not as a standalone deliverable. Even a single presentation belongs inside the standard website architecture.

### Maturity Gate

Before producing a contract, the Interviewer assesses whether the repo has enough analytical substance to justify publication. Minimum requirements:

- At least one EDA report **beyond EDA-1** (EDA-2 or higher)
- At least one non-exploratory report communicating conclusions with evidence (Report-1 or equivalent)

If either is missing, the Interviewer warns the human: *"The repository may not be mature enough to publish. A frontend without real analysis risks presenting infrastructure without insight."* The human may proceed anyway, but the warning is mandatory.

---

## The Contract: `publishing-contract.prompt.md`

The single contract file between human editorial intent and mechanical execution.

### Schema

```markdown
# [Website Name]

## Purpose
[1-2 paragraphs: goal, audience, context]

## Navigation

### [Section Name]

#### [Page Title]
- **Protocol**: Direct Line (VERBATIM)
- **Source**: ./ai/project/mission.md

#### [Page Title]
- **Protocol**: Narrative Bridge
- **Intent**: Orient the visitor. Establish credibility. Invite exploration.
- **Goal**: Landing page — first thing a visitor sees.
- **Spirit**: Professional but approachable. Visuals lead, prose follows.
- **Inputs**: Mermaid diagram from manipulation/pipeline.md,
  forecast image from analysis/report-1/prints/g1_forecast_report.png

#### [Page Title]
- **Protocol**: Direct Line (REDIRECTED)
- **Source**: ./analysis/eda-2/eda-2.html

#### [Page Title]
- **Protocol**: Technical Bridge
- **Source**: ./README.md
- **Transforms**: Inject mermaid diagram via include, rewrite links for site context,
  strip developer build instructions, co-locate images

## Exclusions
[Patterns to skip]

## Theme
[Bootswatch theme name]

## Footer
[Footer text]

## Repo URL
[GitHub repository URL]
```

### What changed from v2's `editor.prompt.md`

- **Explicit protocols**: Every page is tagged with its protocol and mode
- **Narrative Bridge briefs**: Structured fields (intent, goal, spirit, inputs) replace `<!-- TBD -->` comments
- **Multiple roles acknowledged**: A source file can appear under multiple pages with different protocols
- **Self-contained**: No separate `printer.prompt.md` — the Writer generates `_quarto.yml` directly from the contract

---

## Pre/Post-Render Hooks

V2 discovered hooks organically and treated them as workarounds. V3 gives them first-class status.

**When hooks are needed**: When the self-containment rule has a legitimate exception — typically REDIRECTED pages whose HTML targets live outside `edited_content/`.

**How they work**:

- Writer creates R scripts in `_frontend-N/scripts/`
- Writer registers them in `_quarto.yml` under `project.pre-render` / `project.post-render`
- Each script includes a header comment explaining what it does and why

**Established hook patterns** (from `_frontend-1`):

| Script | Hook | Purpose |
|---|---|---|
| `prep-pipeline-qmd.R` | pre-render | Generates `pipeline.qmd` from `manipulation/pipeline.md`, injecting mermaid include |
| `copy-analysis-html.R` | post-render | Copies redirect target HTMLs into `_site/`, mirrors README images |

---

## Asset & Link Management

### Image Co-location

Any image referenced in a page must be copied to a local `images/` or `assets/` directory within `edited_content/`. The Writer resolves all relative paths at assembly time so they work from their new location.

### Broken Link Prevention

The Writer must verify that every internal cross-reference in `edited_content/` resolves. If a link points to a file excluded by the contract, it must be converted to plain text or flagged in `BUILD_REPORT.md`.

### Asset Resolution Algorithm

For every file copied into `edited_content/`:

1. **Scan** for all local asset references (markdown images, HTML images, Quarto includes)
2. **Resolve** each relative path against the source file's original directory
3. **Copy** the resolved file to a mirrored path under `edited_content/`
4. **Do not rewrite** internal references — preserving relative path structure means copies resolve automatically
5. **Recurse** if a copied asset itself references further assets

---

## `_quarto.yml` Generation Rules

The Writer generates the project configuration from the contract using these rules:

- **Explicit render list**: Do not use wildcards. Every page in the contract must be explicitly named in `render:`
- **Navigation mirroring**: The navbar structure must exactly match the hierarchical sections in the contract
- **Hook documentation**: Any pre-render or post-render scripts must include a header comment explaining their purpose
- **Theme from contract**: Apply the Bootswatch theme specified in the contract
- **Footer and repo URL**: Include if specified in the contract

---

## Error Handling

### The BUILD_REPORT Protocol

If the Writer encounters:

- An ambiguous Narrative Bridge brief
- A missing source file
- An unresolvable asset reference
- Any issue that doesn't block the rest of assembly

...it completes the rest of the assembly and appends a `BUILD_REPORT.md` to `edited_content/` highlighting the issues with suggested resolutions.

### Post-Render Reconciliation

After rendering, verify that the number of `.html` files in `_site/` matches the number of intended pages in the contract. Report discrepancies.

---

## Iteration Loops

After reviewing `_site/`, the human can re-enter at multiple points:

| Loop | Entry point | Re-runs from | When to use |
|---|---|---|---|
| **A — Re-plan** | Write `frontend-N-K.prompt.md` (delta) | Phase 1 | Structural changes: add sections, change audience, rethink navigation |
| **B — Re-assemble** | Edit `publishing-contract.prompt.md` | Phase 2 | Content changes: swap a protocol, adjust a brief, add/remove pages |
| **C — Micro-edit** | Edit files in `edited_content/` directly | Phase 3 (render only) | Fine-tuning: fix a typo, adjust wording, tweak CSS |
| **D — Conversational** | Talk to Interviewer agent in chat | Agent determines appropriate loop | Most common in practice |

---

## File Inventory

### Framework Files (7)

```
.github/
├── publishing-orchestra-3.md                    ← Design doc (you are here)
├── agents/
│   ├── publishing-interviewer.agent.md          ← Interviewer (planning + conversation)
│   └── publishing-writer.agent.md               ← Writer (assembly + rendering)
├── instructions/
│   └── publishing-rules.instructions.md         ← Merged rules for all 3 protocols
├── templates/
│   └── publishing-contract-template.md          ← Schema for publishing-contract.prompt.md
├── copilot/
│   └── publishing-orchestra-SKILL.md            ← VS Code skill for discoverability
└── prompts/
    └── publishing-new.prompt.md                 ← Bootstrap new frontend workspace
```

### Historical Files (preserved, not active)

```
.github/
├── publishing-orchestra-1.md                    ← v1 design doc (archived)
└── publishing-orchestra-2.md                    ← v2 design doc (archived)
```

### Per-Frontend Workspace

```
analysis/frontend-N/                   DESIGN WORKSPACE (thinking space)
├── initial.prompt.md                 ← Human-authored vision (mandatory gate)
├── frontend-N-1.prompt.md            ← Round 1 delta (preserved)
├── frontend-N-2.prompt.md            ← Round 2 delta (preserved)
└── ...

_frontend-N/                           EXECUTION WORKSPACE (agent workspace)
├── publishing-contract.prompt.md     ← Confirmed contract (the one contract file)
├── edited_content/                   ← All pages + assets (self-contained)
│   ├── index.qmd                    ← Narrative Bridge (home page; not in navbar)
│   ├── _pipeline-diagram.qmd        ← Shared partial (mermaid include)
│   ├── project/
│   │   ├── summary.md               ← Narrative Bridge
│   │   ├── mission.md               ← Direct Line (VERBATIM)
│   │   ├── method.md                ← Direct Line (VERBATIM)
│   │   └── glossary.md              ← Direct Line (VERBATIM)
│   ├── pipeline/
│   │   ├── pipeline.qmd             ← Technical Bridge
│   │   └── cache-manifest.md        ← Direct Line (VERBATIM)
│   ├── analysis/
│   │   ├── eda-2.qmd                ← Direct Line (REDIRECTED)
│   │   └── report-1.qmd             ← Direct Line (REDIRECTED)
│   ├── docs/
│   │   ├── readme.qmd               ← Technical Bridge
│   │   ├── publishing-orchestra.md  ← Direct Line (VERBATIM)
│   │   └── site-map.md              ← Narrative Bridge
│   └── story/                       ← Optional: talks, slides, presentations
│       └── [slides].qmd
├── scripts/                          ← Pre/post-render hooks
│   ├── prep-pipeline-qmd.R
│   └── copy-analysis-html.R
├── _quarto.yml                       ← Generated by Writer
└── _site/                            ← Rendered website
```

### System Overview (ASCII)

```
┌─────────────────────────────────────────────────────────────────────┐
│                      PUBLISHING ORCHESTRA v3                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Phase 0          Phase 1              Phase 2 + 3                  │
│  ────────         ────────             ──────────                   │
│                                                                     │
│  Human        ┌─► Interviewer ──┐   ┌─► Writer ──────────────┐     │
│  writes       │   reads intent  │   │   assembles             │     │
│  intent  ─────┘   scans repo    │   │   edited_content/       │     │
│  prompts      │   interviews    │   │   generates _quarto.yml │     │
│               │   human         │   │   runs quarto render    │     │
│               │                 │   │                         │     │
│               │   OUTPUT:       │   │   OUTPUT:               │     │
│               │   publishing-   │   │   edited_content/       │     │
│               │   contract.     │   │   _quarto.yml           │     │
│               │   prompt.md     │   │   _site/                │     │
│               └────────┬────────┘   └────────────┬────────────┘     │
│                        │                         │                  │
│                   [checkpoint]              [checkpoint]             │
│                   human reviews             human reviews            │
│                   contract                  site                     │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│  PROTOCOLS                                                          │
│                                                                     │
│  Direct Line ─────── copy as-is or redirect to HTML                 │
│  Technical Bridge ── copy + transform (links, shortcodes, sanitize) │
│  Narrative Bridge ── author new content from brief + sources        │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│  FILES                                                              │
│                                                                     │
│  .github/agents/publishing-interviewer.agent.md                     │
│  .github/agents/publishing-writer.agent.md                          │
│  .github/instructions/publishing-rules.instructions.md              │
│  .github/templates/publishing-contract-template.md                  │
│  .github/copilot/publishing-orchestra-SKILL.md                      │
│  .github/prompts/publishing-new.prompt.md                           │
│  .github/publishing-orchestra-3.md  (this file)                     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## V2 → V3 Comparison

| Aspect | V2 | V3 |
|---|---|---|
| Agents | 4 (Orchestrator, PE, Editor, Printer) | 2 (Interviewer, Writer) |
| Framework files | 14 | 7 |
| Contract files per frontend | 3 (`editor.prompt.md`, `printer.prompt.md`, `questions.prompt.md`) | 1 (`publishing-contract.prompt.md`) |
| Intermediate build spec | `printer.prompt.md` (leaked, diverged) | None — `_quarto.yml` is the spec |
| Content folder name | `content/` | `edited_content/` |
| Content organization | Implicit types on raw files (emerged organically) | 3 explicit protocols on edited pages: Direct Line, Technical Bridge, Narrative Bridge |
| Composed page guidance | `<!-- TBD -->` comments | Structured briefs: intent, goal, spirit, inputs |
| Classification target | Raw files labeled with types | Edited pages assigned protocols; raw files are just source material |
| Human intent preservation | Single `initial.prompt.md` | `initial.prompt.md` (mandatory gate) + versioned deltas: `frontend-N-1.prompt.md`, `-2`... |
| Instruction files | 4 separate (`publishing-content`, `publishing-analysis`, `publishing-manipulation`, `publishing-index`) | 1 merged (`publishing-rules.instructions.md`) |
| Pre/post-render hooks | Workarounds | First-class documented pattern |
| Self-containment | Not enforced (needed post-render fixups) | Mandatory rule for `edited_content/` |
| Workflow descriptions | Duplicated 5+ times across files | Single source of truth (this design doc) |
| Error handling | `questions.prompt.md` (blocker → stop → route to human) | `BUILD_REPORT.md` (best attempt, flag issues) |

---

## Quick Reference

| Task | What to do |
|------|------------|
| Start the publishing pipeline | `@publishing-interviewer` |
| Bootstrap a new frontend workspace | `/publishing-new` |
| Change what pages appear on the website | Edit `publishing-contract.prompt.md`, re-run Writer |
| Re-run only the Write + Render step | `@publishing-writer` (assumes contract is current) |
| Add a second website for a different audience | `/publishing-new` — creates `_frontend-N/` with its own workspace |
| Change how content is normalized | Edit `publishing-rules.instructions.md` |
| Change the contract schema | Edit `publishing-contract-template.md` |
| Fine-tune rendered pages | Edit files in `edited_content/` directly, re-run `quarto render` |

---

*This document is the single source of truth for Publishing Orchestra v3. All agents, instructions, and templates derive from and defer to it.*
