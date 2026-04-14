# Dendron Quick Reference

> VS Code extension for hierarchical, wiki-linked markdown notes.
> Install: `dendron.dendron` | Docs: https://wiki.dendron.so

---

## Core Concept: Dot-Notation Hierarchy

Notes are flat files named with dots that imply hierarchy:

```
project.era.methodology.md       →  project > era > methodology
project.era.glossary.md          →  project > era > glossary
journal.2026.03.11.md            →  journal > 2026 > 03 > 11
comms.stakeholder.kyler.md       →  comms > stakeholder > kyler
```

All notes live as flat `.md` files in the vault folder — the hierarchy is in the name.

---

## Essential Commands (Command Palette: `Ctrl+Shift+P`)

| Action | Command |
|--------|---------|
| Create / open a note | `Dendron: Go to Note` (or `Ctrl+L`) |
| Rename note + update all links | `Dendron: Rename Note` |
| Look up note by hierarchy | `Dendron: Lookup Note` |
| Insert link to another note | `[[` then type to fuzzy-search |
| Show backlinks | Backlinks panel in sidebar |
| Create daily journal note | `Dendron: Create Daily Journal Note` |
| Open graph view | `Dendron: Show Note Graph` |
| Apply a schema/template | Automatic on note creation if schema is defined |

---

## Linking

```markdown
[[project.era.glossary]]                   — link by note id
[[Glossary|project.era.glossary]]          — link with display text
![[project.era.methodology]]               — embed note content inline
```

Ctrl+Click any `[[link]]` to navigate. All links update automatically on rename.

---

## Typical Workflow

1. **Look up** — `Ctrl+L`, type hierarchy path (e.g. `comms.stakeholder.`) → press Enter to create if missing.
2. **Write** — standard markdown. Frontmatter is auto-managed; don't touch `id`.
3. **Link** — type `[[` to insert a link to any other note.
4. **Rename/move** — always use `Dendron: Rename Note`, never rename via file system.
5. **Find connections** — check the Backlinks panel or open the graph view.

---

## Frontmatter (auto-generated, do not manually edit `id`)

```yaml
---
id: abc123xyz          # unique ID — never change this
title: Methodology
desc: ''
updated: 1741723200000
created: 1741723200000
---
```

---

## Suggested Namespace Starters for This Project

| Prefix | Purpose |
|--------|---------|
| `project.*` | Mission, method, glossary, decisions |
| `analysis.*` | Per-analysis notes and findings |
| `comms.*` | Administrative/stakeholder communication records |
| `journal.*` | Daily logs, meeting notes |
| `ref.*` | Reference material, external docs |

---

## Key Rules

- **Rename with Dendron** — never via Explorer/OS
- **One vault** — keep all notes in the initialized vault folder
- **Frontmatter is sacred** — don't strip or manually alter `id` fields
- **Hierarchy first** — choose your namespace before creating a note; restructuring later requires a bulk refactor

---

## Watch-outs when adopting Dendron:

- **Naming convention is everything.** Dendron uses dot-notation hierarchies (`project.era.methodology`, `project.era.glossary`). Decide your top-level namespaces early — they are hard to restructure later without a refactor.
- **Vault placement.** Dendron uses a "vault" concept (a root folder for notes). If you initialize inside the repo, keep the vault folder consistent and add generated Dendron files (`dendron.yml`, `.dendron.port`) to `.gitignore` as appropriate. The vault `notes/` folder itself should be committed.
- **Frontmatter is required.** Every Dendron note gets YAML frontmatter (`id`, `title`, `created`, `updated`). This is injected automatically but modifying notes outside VS Code can corrupt them — avoid editing raw `.md` files in other tools without re-validating frontmatter.
- **Refactor early, not late.** Dendron's rename/refactor command (`Dendron: Rename Note`) is the correct way to move notes — it updates all backlinks. Never rename files via OS/Explorer.
- **Schema investment pays off later.** For administrative communication records, define schemas (`*.schema.yml`) once the note types stabilize. Don't over-engineer schemas upfront.
- **Daily notes pattern.** Dendron has a built-in daily journal pattern (`journal.2026.03.11`). Useful for meeting notes and communication logs.
- **Reference guide:** `guides/dendron-guide.md`

---
