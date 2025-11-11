# AI Scripts Directory

Core R scripts that power the AI support system for reproducible research projects.

---

## Quick Reference

| Script | Purpose |
|--------|---------|
| **ai-config-utils.R** | Centralized configuration management for AI system paths and settings |
| **ai-memory-functions.R** | Portable memory system functions for tracking decisions and project state |
| **ai-migration-toolkit.R** | Portable persona switching and cross-repository migration utilities |
| **dynamic-context-builder.R** | Comprehensive context management engine for AI assistant customization |
| **migration-utilities.R** | Export/import tools for migrating AI support systems between repositories |

---

## Detailed Descriptions

### ai-config-utils.R
**Configuration Management Foundation**

Provides centralized configuration reading functions used by all other AI scripts. Reads from `config.yml` with intelligent fallbacks and sensible defaults for AI system paths (personas, memory, project directories). This eliminates hardcoded paths and ensures portability across different project structures. All other scripts depend on this utility for consistent path resolution.

**Key Functions:**
- `read_ai_config()` - Main configuration reader
- `get_ai_file_path()` - Resolve AI system file paths
- `get_persona_path()` - Locate persona definition files

**Version:** 1.1.0 - Simplified configuration management (config.yml only)

---

### ai-memory-functions.R
**Memory System Logic Layer**

Implements portable memory management functions following a storage/logic separation pattern. Provides tools for tracking project decisions, AI system status, and human reasoning across research workflows. Works with project-specific memory files (memory-ai.md, memory-human.md, memory-hub.md) while keeping logic portable for reuse across repositories.

**Key Functions:**
- `ai_memory_check()` - Comprehensive memory system status check
- `memory_status()` - Quick memory file status overview
- `detect_memory_system()` - Auto-detect memory configuration
- Memory file reading and validation utilities

**Version:** 1.0.0 - Designed for storage/logic separation

---

### ai-migration-toolkit.R
**Portable Persona Switching & Migration**

Lightweight, portable toolkit for activating AI personas and migrating AI support systems to other repositories. Designed for cross-repository deployment with automatic configuration detection and fallback mechanisms. Provides the core persona switching functions used by VS Code tasks and migration workflows.

**Key Functions:**
- `activate_developer()` - Technical focus, minimal context
- `activate_project_manager()` - Strategic oversight, full context
- `activate_data_engineer()` - Data pipeline specialist
- `activate_research_scientist()` - Statistical analysis specialist
- `activate_devops_engineer()` - Production deployment focus
- `activate_frontend_architect()` - Visualization and UI specialist
- `activate_prompt_engineer()` - RICECO framework specialist
- `activate_reporter()` - Analytical storytelling specialist
- `activate_default()` - General assistance
- `show_context_status()` - Display current AI configuration
- `detect_ai_config()` - Auto-detect project AI system type
- `check_migration_compatibility()` - Assess target repository readiness
- `generate_migration_assessment()` - Create detailed migration impact report

**Version:** 1.0.0 - Designed for portability and cross-repository deployment

---

### dynamic-context-builder.R
**Comprehensive Context Management Engine**

The full-featured AI context management system for the current repository. Provides rich functionality for loading project files into AI context, managing personas with a 3-section system (Core Instructions + Active Persona + Additional Context), validating context freshness, and analyzing project status. This is the daily workflow tool with extensive features for context optimization.

**Key Functions:**

*Context Loading:*
- `add_to_instructions()` - Load specific context files
- `add_core_context()` - Load mission + method
- `add_full_context()` - Load comprehensive context set
- `add_data_context()` - Load data pipeline context
- `add_memory_context()` - Load memory system context
- `remove_all_dynamic_instructions()` - Reset all dynamic content

*Context Management:*
- `context_refresh()` - Complete status scan with refresh options
- `validate_context()` - Check if loaded files are current
- `check_context_size()` - Monitor file size and performance impact
- `suggest_context()` - Smart suggestions by analysis phase

*Persona System:*
- `set_persona_with_defaults()` - Activate persona with default context
- `set_persona()` - Custom persona activation
- `list_personas()` - Show available personas and status
- `get_current_persona()` - Check active persona
- `deactivate_persona()` - Return to default
- `build_3_section_instructions()` - Build complete instruction file

*Project Analysis:*
- `analyze_project_status()` - Comprehensive project health check
- `get_command_help()` - Detailed command documentation

*File Management:*
- `log_file_change()` - Track file modifications in logbook
- `add_context_file()` - Add file to Section 3 context
- `remove_context_file()` - Remove file from Section 3
- `list_available_md_files()` - Discover available context files

**Version:** Configuration-driven paths for portability (Updated 2025-11-08)

**Author:** GitHub Copilot (with human analyst)

---

### migration-utilities.R
**Export/Import Infrastructure**

High-level export and import tools for packaging and deploying AI support systems across repositories. Provides assessment-based migration with dry-run capabilities, automatic conflict detection, and backup/restore functionality. Designed for both manual and AI-assisted migration workflows.

**Key Functions:**

*Export:*
- `export_ai_components()` - Package AI components for migration
- `export_component()` - Export individual component (personas, context, memory, vscode)
- `export_personas()` - Export persona definition files
- `export_context_management()` - Export context scripts
- `export_memory_system()` - Export memory functions and templates
- `export_vscode_integration()` - Export VS Code task templates

*Import:*
- `import_ai_components()` - Import and install AI components
- `execute_manual_import()` - Manual import workflow
- `execute_ai_assisted_import()` - AI-assisted import workflow

*Assessment:*
- `generate_import_assessment()` - Mandatory pre-import assessment
- `print_import_assessment()` - Display assessment results
- `confirm_import_after_assessment()` - User confirmation prompt
- `detect_import_conflicts()` - Identify potential conflicts
- `estimate_component_changes()` - Estimate file changes per component

*Validation:*
- `validate_source_structure()` - Verify source has valid AI system
- `analyze_target_structure()` - Analyze target repository structure
- `validate_import()` - Post-import validation

*Backup:*
- `create_import_backup()` - Create timestamped backup
- `restore_from_backup()` - Rollback failed import

**Version:** 1.0.0 - Manual and AI-assisted migration support

**Dependencies:** Requires `yaml` and `jsonlite` packages

---

## Script Dependencies

```
ai-config-utils.R (foundation)
    ├── ai-memory-functions.R (uses config utils)
    ├── ai-migration-toolkit.R (uses config utils in dynamic-context-builder)
    ├── dynamic-context-builder.R (uses config utils)
    └── migration-utilities.R (independent, uses yaml/jsonlite)
```

## Usage Patterns

### Daily Workflow
Use **dynamic-context-builder.R** for:
- Loading and managing AI context
- Switching personas with rich features
- Analyzing project status
- Validating context freshness

### Cross-Repository Migration
Use **ai-migration-toolkit.R** + **migration-utilities.R** for:
- Portable persona switching
- Exporting AI components
- Assessing target repositories
- Importing AI support to new projects

### Memory Tracking
Use **ai-memory-functions.R** for:
- Checking memory system status
- Validating memory file structure
- Tracking decisions and reasoning

### Configuration
All scripts use **ai-config-utils.R** for:
- Consistent path resolution
- Configuration reading
- Portable directory detection

---

## Related Resources

- **Subdirectories:**
  - `tests/` - Test suites for AI system validation
  - `wrappers/` - VS Code task wrapper scripts

- **Documentation:**
  - `../docs/commands.md` - Command reference
  - `../docs/context-system.md` - Context system guide
  - `../docs/testing-guide.md` - Testing documentation

- **Configuration:**
  - `../ai-support-config.yml` - AI system configuration
  - `../../config.yml` - Main project configuration

---

**Note:** This README covers only the root-level scripts in `./ai/scripts/`. For information about test files and wrapper scripts, see the respective subdirectory documentation.
