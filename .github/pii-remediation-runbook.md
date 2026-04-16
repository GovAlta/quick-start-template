# PII Remediation Runbook

**Purpose:** Step-by-step guide for investigating and responding to a T&I security report that a repository may contain Personally Identifiable Information (PII) — specifically Social Insurance Numbers (SINs) or other sensitive identifiers.

**Audience:** Repository owner/maintainer receiving a security flag email from T&I.

---

## 1. Trigger — What the email will say

T&I will send an email along these lines:

> *"Repository X has been identified as a potential security risk. SQL queries pull from a SIN table / R scripts process social_insurance_number fields. Please verify no .rds, .csv, or output data files containing actual SIN values have been committed. Ensure .gitignore properly excludes all data outputs."*

The email will name specific files. **Treat these as leads, not conclusions** — the flagged files are often the SQL/R source code that *processes* SINs, not the files that actually *expose* them. The real exposure is usually in rendered outputs.

---

## 2. Investigation — What to look for

Work through these layers in order:

### 2.1 Source code (`.R`, `.Rmd` files)

Search for hardcoded 9-digit values in SIN contexts:

```bash
# In PowerShell
Select-String -Path "manipulation\*.R","manipulation\*.Rmd" -Pattern "\d{9}"

# In bash
grep -rn --include="*.R" --include="*.Rmd" "[0-9]\{9\}" manipulation/
```

A file that *queries* a SIN column or *references* `social_insurance_number` as a column name is **not an exposure** — that is normal data processing code. A real exposure is a hardcoded 9-digit number assigned to a variable, e.g., `sin == 999000001` or `case1 <- 999000001` linked to a SIN field.

### 2.2 Rendered outputs (`.md`, `.html` files)

This is the most common actual exposure vector. R's `glimpse()`, `print()`, and `filter()` calls render real data into markdown/HTML output files. Check:

```bash
# Check tracked .md files for SIN-column glimpse output with real values
git ls-files "*.md" | ForEach-Object { Select-String -Path $_ -Pattern "\d{9}" }

# Or with grep
git ls-files "*.md" | xargs grep -l "[0-9]\{9\}"
```

**What to look for:** Lines like:
```
## $ social_insurance_number  <chr> "999000001", "999000002", ...
## 1     492544 ea     999000003 2018-09-25
```

These confirm real SIN values are present in the rendered file.

### 2.3 Data files (`.rds`, `.csv`, `.parquet`, `.xlsx`)

```bash
git ls-files | grep -iE "\.(rds|csv|parquet|xlsx)$"
```

In a well-configured repo these should return nothing — all data files should be in `data-private/` which is gitignored. If any appear, they must be removed immediately.

### 2.4 Git history

Even if a file has been deleted from the working tree, SIN values may persist in prior commits:

```bash
git log --all -S "<SIN_VALUE>" --name-only --format=""
```

Run this for every SIN value you've identified. If it returns file names, those commits contain the SIN in their diff and must be scrubbed.

### 2.5 What is NOT an exposure

- A file that references `social_insurance_number` as a **column name string** — this is schema documentation
- A file that contains `person_oid` integer values used for spot-checking — `person_oid` is not classified as sensitive (per SDA project owner convention)
- A file that says SIN is "masked for privacy" — informational documentation
- Files in `data-private/` — gitignored by convention, never reach the remote

---

## 3. Scope Assessment

After investigation, classify each flagged item:

| Category | Example | Action needed |
|----------|---------|---------------|
| Hardcoded SIN in source `.R` | `sin == 999000001` | Replace with synthetic `999`-prefix value |
| Real SIN in rendered `.md`/`.html` | `glimpse()` output | Untrack + delete + scrub history |
| Real SIN in data file (`.rds`, `.csv`) | `ds_sin.csv` | Remove from tracking + scrub history |
| Column name reference only | `"social_insurance_number"` in string | No action |
| `person_oid` in source code | `case1 <- 492544` | No action |
| Documentation mention | "SIN is masked" | No action |

---

## 4. Remediation

### 4.1 Fix source code (if hardcoded SINs found)

Replace each real SIN with a synthetic `999`-prefix value (not a valid Canadian SIN series — unambiguously fake). Use a consistent mapping, e.g.:

| Real SIN | Synthetic replacement |
|----------|-----------------------|
| [REDACTED] | 999000001 |
| [REDACTED] | 999000002 |

Mark each replacement with a comment: `# synthetic id (original removed for security)`

### 4.2 Untrack rendered outputs

Remove all rendered output files from git tracking (keep them on disk):

```bash
git rm --cached manipulation/ellis-ea-core.md   # repeat per file
# or for all at once:
git ls-files "manipulation/*.md" | grep -v "README\|RDB-manifest" | xargs git rm --cached
```

### 4.3 Update `.gitignore`

Ensure the output directory's `.gitignore` excludes rendered outputs:

```
# manipulation/.gitignore
*.html
*.md
*.png
*.jpg

# Keep documentation
!README.md
!RDB-manifest.md
```

### 4.4 Commit the working-tree cleanup

```bash
git add manipulation/.gitignore
git commit -m "security: remove rendered outputs containing PII, update .gitignore"
```

### 4.5 Scrub git history

Per T&I guidance, use `git filter-repo --invert-paths` to completely erase a file from the git timeline.

**Prerequisites:** `git filter-repo` must be installed (`pip install git-filter-repo` or via package manager).

**Step 1 — Back up the file** (precaution, since we are deleting):
```bash
cp manipulation/ellis-ea-core.md ../ellis-ea-core.md.bak
```

**Step 2 — Purge from history** (one command per file, use `--force` if not a fresh clone):
```bash
git filter-repo --path manipulation/ellis-ea-core.md --invert-paths --force
```

Repeat for every file identified in step 2.4. Note: `git filter-repo` **removes the `origin` remote automatically** — this is expected, not an error.

**Step 3 — Verify after each pass** (or after all passes):
```bash
git log --all -S "<SIN_VALUE>" --name-only --format=""
```

Every known SIN value should return empty output. If any file still appears, run another `--invert-paths` pass on it.

**Step 4 — Re-add remote and force push:**
```bash
git remote add origin https://github.com/GovAlta-EMU/REPO-NAME.git
git push origin --force --all
```

**Step 5 — Notify collaborators.** Anyone with a local clone must delete it and re-clone — their history is now diverged.

### 4.6 Add pre-commit hook (prevention)

Create `.githooks/pre-commit`:

```sh
#!/bin/sh
# Pre-commit hook: reject staged files containing patterns that look like
# real Social Insurance Numbers (SINs).
#
# - Scans .R, .Rmd, .md, .csv files for 9-digit numbers in SIN contexts
# - Allows synthetic 999-prefix values (not a valid Canadian SIN series)
# - Install: git config core.hooksPath .githooks

FOUND=0

FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -iE '\.(R|Rmd|md|csv)$')

if [ -z "$FILES" ]; then
    exit 0
fi

for FILE in $FILES; do
    HITS=$(git show ":$FILE" 2>/dev/null | grep -inE '(social_insurance_number|_sin|sin\s*==|sin\s*%in%)' \
          | grep -oE '\b[0-9]{9}\b' | grep -v '^999' || true)
    if [ -n "$HITS" ]; then
        echo "BLOCKED: $FILE contains what appears to be real SIN value(s):"
        echo "$HITS" | head -5
        FOUND=1
    fi
done

if [ "$FOUND" -eq 1 ]; then
    echo ""
    echo "Commit rejected. Real SIN values must not be committed."
    echo "Use synthetic 999-prefix identifiers for debugging."
    exit 1
fi

exit 0
```

Activate it:
```bash
git config core.hooksPath .githooks
```

---

## 5. Communication

Three documents should be created in `security/YYYY-MM-DD/` (excluded from git by `security/.gitignore`):

### `response.md` — send to T&I (brief)

- Confirm whether the report is a true positive or false positive
- Specify where the actual exposure was (if different from what was flagged)
- List the 3–5 concrete actions completed
- Note any items that required collaborator coordination (force-push)
- Keep it under one page

### `report.md` — detailed internal record

- Original report vs. actual scope (comparison table)
- Clarification on each flagged file and whether it was actually exposed
- Full list of files modified/deleted/untracked
- Verification results (before and after)
- Git commands run

### `plan.md` — remediation plan (write before acting, update after)

- Phases: Investigation → Working tree cleanup → History scrub → Prevention
- Note decisions made (e.g., "permanently delete — do not regenerate")
- Reference any T&I guidance received on preferred scrubbing method

---

## 6. Common Pitfalls

| Pitfall | What happens | Fix |
|---------|-------------|-----|
| Deleting a file from working tree isn't enough | SINs persist in all prior commits | Run `git filter-repo --invert-paths` |
| `git filter-repo` removes `origin` | VS Code shows "Publish Branch"; can't push | `git remote add origin <url>` then `git push --force --all` |
| Security docs accidentally committed | Security folder's `*.gitignore` may be empty or you force-added | `git rm --cached` + amend commit |
| Rendered docs reference real SINs | You create a report that itself contains PII | Use [REDACTED] for SIN values in any committed document |
| Missing files in history | A file not in the initial list surfaces during verification | Run verification after every `--invert-paths` pass, not just at the end |
| `--invert-paths` needs `--force` | Repo is not a fresh clone | Always use `--force` flag on existing working repos |

---

## 7. Transferring This Runbook to Another Repo

Copy the file directly into the target repo's `.github/` folder:

```bash
cp path/to/sda-research-db/.github/pii-remediation-runbook.md path/to/other-repo/.github/
```

Then commit it:

```bash
cd path/to/other-repo
git add .github/pii-remediation-runbook.md
git commit -m "docs: add PII remediation runbook"
git push
```

Two supporting pieces should also be in place for the runbook to be fully operational:

1. **Pre-commit hook** — copy `.githooks/pre-commit` and activate it:
   ```bash
   cp path/to/sda-research-db/.githooks/pre-commit path/to/other-repo/.githooks/pre-commit
   cd path/to/other-repo
   git config core.hooksPath .githooks
   ```

2. **`security/.gitignore`** — ensure the `security/` folder has a `.gitignore` that excludes its contents from tracking (incident documents should stay local):
   ```
   *
   *.*
   ```
