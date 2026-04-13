---
mode: 'agent'
description: 'Bootstrap a new talk folder with README, slides.qmd, and abstract.md'
---

# Bootstrap a New Talk

Scaffold a complete talk folder for this repository.

## Step 1 — Gather information

Ask the author for the following details (all required):

1. **Venue name** — full name of the conference, symposium, or institution
   (e.g., "OUHSC Research Seminar", "useR! 2026", "ASA Section on Statistics in Epidemiology")
2. **Venue abbreviation** — short lowercase token for the folder name
   (e.g., `ouhsc`, `useR`, `asa-epi`)
3. **Talk date** — ISO format YYYY-MM-DD (the day of delivery, not submission)
4. **Talk title** — working title (can be refined later)
5. **Format** — one of: conference talk / invited lecture / workshop / lightning talk /
   poster / webinar
6. **Duration** — in minutes (e.g., 20, 45, 90)
7. **Primary audience** — 1–2 sentences describing who will be in the room and what
   they already know
8. **Key claim or goal** — one sentence: what should the audience think, feel, or do
   differently after this talk?

## Step 2 — Determine folder name

Construct the folder name as:

```
YYYY-MM-DD-venue-abbreviation-N/
```

- Use the ISO date from Step 1
- Use the abbreviation from Step 1 (lowercase, hyphens only, no underscores)
- Append `-N` (integer) only if another talk already exists for the same date + venue;
  otherwise omit the suffix (the first talk has no suffix, the second gets `-2`)

Check `analysis/talks/` for existing folders matching the date + venue pattern before deciding.

Example: `2026-04-13-ouhsc-ai4rr-1/` (first OUHSC talk on that date with this abbreviation)

Put all talks in `./analysis/talks/` folder.

## Step 3 — Create folder and files

Create the following files inside the new folder:

### `README.md`

```markdown
# {Talk Title}

| Field    | Value                         |
|----------|-------------------------------|
| Venue    | {Full venue name}             |
| Date     | {YYYY-MM-DD}                  |
| Format   | {Format}                      |
| Duration | {N} minutes                   |
| Author   | Andriy Koval                  |

## Abstract

{One-paragraph summary — draft from the key claim; refine with abstract.md later}

## Links

- Slides (rendered): *(add after render)*
- Recording: *(add if available)*
- Abstract submission: *(add if submitted)*

## Status

- [ ] Outline approved
- [ ] Draft slides complete
- [ ] Speaker notes written
- [ ] Abstract finalized
- [ ] Rendered and reviewed
- [ ] Delivered
```

### `slides.qmd`

```yaml
---
title: "{Talk Title}"
subtitle: "{Full Venue Name} | {YYYY-MM-DD}"
author: "Andriy Koval"
date: "{YYYY-MM-DD}"
format:
  revealjs:
    theme: default
    slide-number: true
    footer: "Andriy Koval | {Venue Abbreviation} | {YYYY-MM-DD}"
    transition: slide
    incremental: false
    smaller: false
---
```

Then add the following stub slide sections based on format and duration:

- **≤ 10 min** (lightning): Title → 3–5 content slides → Takeaway + contact
- **15–25 min** (conference talk): Title → Motivation (1–2) → Approach (2–3) →
  Findings (3–5) → Implications (1–2) → Takeaway + contact
- **45–60 min** (lecture): Title → Context/background (3–4) → Problem (2) →
  Approach (3–4) → Results (4–6) → Discussion (3–4) → Takeaway + contact
- **Workshop**: Title → Goals + agenda → Content sections (variable) →
  Hands-on exercises → Wrap-up + resources

Each stub slide should have:

- A sentence-form, claim-bearing title (not just a topic label)
- A speaker notes block (`::: notes ... :::`) with a placeholder prompt

### `abstract.md`

```markdown
# Abstract: {Talk Title}

**Venue**: {Full venue name}
**Date**: {YYYY-MM-DD}
**Format**: {Format} | **Duration**: {N} min

---

## Motivation

*(Why does this question or problem matter? 2–3 sentences)*

## Approach

*(What did you do, or what will you cover? 2–3 sentences)*

## Key Findings / Contents

*(What will the audience learn? 2–3 sentences)*

## Significance

*(Why should the audience care? 1–2 sentences)*

---

*Word count target: {150 if lightning/poster | 250 if conference | 400 if workshop}*
```

## Step 4 — Confirm and summarize
