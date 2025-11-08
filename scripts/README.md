`./scripts/` Directory
=========

Contains collections of scripts aimed at anticipating standard needs during analytic and publishing work flow.

## Directory Structure

### `./ps1/` - PowerShell Workflow Scripts
PowerShell scripts for workflow automation that assume the project is already set up.
- **Organization Principle**: Workflow `.ps1` files go here; bootstrapping scripts stay in project root
- **Standards**: ASCII-only (no emojis/Unicode) - see `ai/onboarding-ai.md`
- **Current Scripts**: `run-complete-ellis-pipeline.ps1`

### `./wrappers/` - Script Wrappers
Small wrapper scripts that bridge VS Code tasks with main project scripts.
- **Purpose**: Avoid PowerShell quoting issues and provide clean task entry points
- **Contents**: Minimal R/Python wrappers for automation
- **Documentation**: See `./wrappers/README.md` for details

## Key Scripts

### `update-copilot-context.R`
**🆕 Enhanced with CACHE Manifest Management**

This script now includes comprehensive project management functions:

#### Context Management Functions:
- `add_to_instructions()` - Load dynamic context into Copilot
- `context_refresh()` - Complete project status scan
- `analyze_project_status()` - Comprehensive project analysis

#### 🆕 New CACHE Manifest Functions:
- `check_cache_manifest()` - Check and update data manifest as needed
- `update_cache_manifest()` - Force update manifest with current datasets

#### Project Setup Functions:
- `project_setup_check()` - Full environment validation
- `safe_run_script()` - Execute scripts with setup validation

#### AI Memory Functions:
- `ai_memory_check()` - Project memory and intent detection
- `memory_status()` - Quick memory overview

#### 📝 File Change Tracking Functions:
- `log_file_change()` - Log file modifications to project logbook
- `log_change()` - Short alias for file change logging

**Usage**: Source this script to access all project management functions.

### Other Important Scripts
- `google-auth-helper.R` - Google Sheets authentication
- `setup-google-auth.R` - Initial authentication setup
- `common-functions.R` - Shared utility functions 
