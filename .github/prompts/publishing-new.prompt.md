---
description: "Bootstrap a new _frontend-N/ workspace for publishing. Scans the repo, creates the workspace directory, and initializes publishing-contract.prompt.md with sensible defaults."
---

# Initialize New Frontend Workspace

Use this prompt to create a new `_frontend-N/` workspace and start the publishing workflow.

## What This Does

1. **Finds the next available workspace number** by scanning for existing `_frontend-*/` directories.
2. **Creates the workspace directory** (`_frontend-N/`).
3. **Invokes the Publishing Interviewer** to scan the repository and produce a default `publishing-contract.prompt.md`.
4. The Interviewer interviews the human to refine the contract before the Writer begins.

## Instructions

When this prompt is invoked:

1. List all directories matching `_frontend-*/` in the repository root.
2. Determine the next available number N.
3. Create the `_frontend-N/` directory.
4. Read the template from `.github/templates/publishing-contract-template.md`.
5. Scan the repository for publishable content:
   - Root `README.md`
   - `analysis/*/` — look for `.qmd`, `.html`, and `prints/` directories
   - `manipulation/` — look for `pipeline.md`, `README.md`, and `images/`
   - `guides/` — all `.md` files
   - `ai/project/` — mission, methodology, glossary files
   - `data-public/metadata/` — data manifests
6. Generate a default `publishing-contract.prompt.md` using the template schema, with each page assigned an appropriate protocol (Direct Line, Technical Bridge, or Narrative Bridge).
7. Write `publishing-contract.prompt.md` to `_frontend-N/`.
8. Present the result and begin the Interviewer workflow to refine with the human.

## Default Section Mapping

| Navbar Section | Default Sources | Typical Protocol |
|---|---|---|
| Project | `ai/project/*.md` (mission, methodology, glossary) | Direct Line (VERBATIM) |
| Pipeline | `manipulation/pipeline.md`, `data-public/metadata/*.md` | Technical Bridge or Direct Line |
| Analysis | `analysis/*/` (each subfolder = one page) | Direct Line (REDIRECTED for HTML) |
| Docs | Root `README.md` | Technical Bridge |
| Index | Synthesized from README + key visuals | Narrative Bridge |

Adjust sections based on what actually exists in the repository. Omit sections if no matching content is found.
