# PowerShell Scripts Directory

This directory contains PowerShell scripts used for **workflow automation** in the Books of Ukraine project.

## Organization Principle

- **Root-level `.ps1` files**: Bootstrapping/setup scripts (e.g., `setup-nodejs.ps1`, `project-status.ps1`)
- **`./scripts/ps1/`**: Workflow automation scripts that assume the project is already set up

## Current Scripts

### Workflow Automation
- `run-complete-ellis-pipeline.ps1` - Executes the complete 4-stage Ellis data pipeline

## Standards

⚠️ **IMPORTANT**: All `.ps1` files must follow ASCII-only standards (no emojis/Unicode). 
See `ai/onboarding-ai.md` → "PowerShell Scripting Standards" for complete guidelines.

## Usage

These scripts are typically executed via VS Code tasks or directly:
```powershell
# Via PowerShell
powershell -File "scripts/ps1/run-complete-ellis-pipeline.ps1"

# Via VS Code
Ctrl+Shift+P → Tasks: Run Task → "Ellis Pipeline - Complete (All Stages)"
```
