---
name: publishing-orchestra
description: "**WORKFLOW SKILL** — Publish a reproducible analytics repository as a static Quarto website using a two-agent pipeline (Interviewer → Writer). USE FOR: building project websites from repo content; creating new frontend workspaces; understanding the publishing workflow; resolving build issues. DO NOT USE FOR: modifying analysis code; running data pipelines; general R/Python coding. INVOKES: Publishing Interviewer agent as entry point, which produces the contract; Publishing Writer agent executes assembly and rendering."
---

# Publishing Orchestra

A two-agent system for publishing reproducible analytics repositories as static Quarto websites with human editorial control at every state of rest.

---

## Architecture

```
Human ↔ Publishing Interviewer
              │
              └──► Publishing Writer  →  edited_content/ + _quarto.yml + _site/
```

### Agents

| Agent | Role | Human-facing? | Invocation |
|-------|------|---------------|------------|
| **Publishing Interviewer** | Planning, conversation, contract production | Yes | `@publishing-interviewer` |
| **Publishing Writer** | Assembly, rendering, reconciliation | No | `@publishing-writer` |

### Writing Protocols

| Protocol | When to use | Action |
|---|---|---|
| **Direct Line** | Content should appear as the analyst wrote it | Copy as-is (VERBATIM) or redirect to HTML (REDIRECTED) |
| **Technical Bridge** | Content needs format adaptation for the web | Copy + transform (links, shortcodes, sanitize) |
| **Narrative Bridge** | Content doesn't exist yet or needs synthesis | Author new content from brief + sources |

### Contract File

All handoffs use a single contract in `_frontend-N/`:

| File | Producer | Consumer | Purpose |
|------|----------|----------|---------|
| `publishing-contract.prompt.md` | Interviewer | Writer | What to publish, how to process each page |

---

## Workflow

1. **Human writes intent** in `analysis/frontend-N/frontend-N-*.prompt.md`
2. **Interviewer** scans repo, interviews human, produces `publishing-contract.prompt.md` → **human checkpoint**
3. **Writer** assembles `edited_content/`, generates `_quarto.yml`, renders `_site/` → **human checkpoint**
4. If issues arise, Writer flags them in `BUILD_REPORT.md` for human review

---

## File Locations

### Design Reference
- `.github/publishing-orchestra-3.md` — Single source of truth for system design

### Agent Definitions
- `.github/agents/publishing-interviewer.agent.md`
- `.github/agents/publishing-writer.agent.md`

### Rules and Templates
- `.github/instructions/publishing-rules.instructions.md` — Protocol rules for the Writer
- `.github/templates/publishing-contract-template.md` — Schema for the contract file

### Entry Points
- `.github/prompts/publishing-new.prompt.md` — Bootstrap a new frontend workspace

### Frontend Workspaces
- `_frontend-N/` — Independent website workspaces (created at runtime)

---

## Quick Reference

| Task | What to do |
|------|------------|
| Start the publishing pipeline | `@publishing-interviewer` |
| Bootstrap a new frontend workspace | `/publishing-new` |
| Re-run only the Write + Render step | `@publishing-writer` |
| Change what pages appear | Edit `publishing-contract.prompt.md`, re-run Writer |
| Change how content is processed | Edit `publishing-rules.instructions.md` |
