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
**3-Section Context Management System**

Clean, simplified AI context management system implementing a pure 3-section architecture:

**Section 1:** Core AI Instructions (from `ai/core/base-instructions.md`) - manually edited in copilot-instructions.md  
**Section 2:** Active Persona (from `ai/personas/*.md`) - loaded verbatim on activation  
**Section 3:** Additional Context (project docs) - A) default per persona OR B) manually added

**Key Functions:**

*Persona Management (Primary Interface):*
- `activate_developer()` - Minimal context
- `activate_project_manager()` - Full project context (mission, method, glossary)
- `activate_data_engineer()` - Data pipeline specialist
- `activate_research_scientist()` - Statistical analysis specialist
- `activate_devops_engineer()` - Production deployment focus
- `activate_frontend_architect()` - Visualization specialist
- `activate_prompt_engineer()` - Prompt engineering specialist
- `activate_reporter()` - Analytical storytelling
- `activate_casenote_analyst()` - Domain-specific analyst
- `activate_default()` - General assistance

*Context Management:*
- `show_context_status()` - View current 3-section state
- `add_context_file('path/file.md')` - Add document to Section 3
- `remove_context_file('path/file.md')` - Remove document from Section 3
- `list_available_md_files('pattern')` - Discover available markdown files

*Core Engine (Internal):*
- `build_3_section_instructions()` - Assemble complete instruction file
- `set_persona_with_defaults()` - Activate persona with default context
- `get_file_map()` - File path resolution mapping
- `get_persona_configs()` - Persona registry with defaults
- `get_general_instructions()` - Read Section 1 from base-instructions.md

**Version:** 2.0.0 - Simplified pure 3-section architecture (2025-11-11)

**Author:** GitHub Copilot (with human analyst)

**Function Count:** 18 functions (down from 38 in v1.x = 53% reduction)

**Key Improvements:**
- Pure 3-section architecture (eliminated dual-system confusion)
- Section 1 now file-based (reads from ai/core/base-instructions.md)
- Simplified user interface (clear command patterns)
- Consolidated status display (show_context_status is primary function)
- Removed 20 deprecated/redundant functions

**Documentation:** See `dynamic-context-builder-overview.md` for complete system documentation

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
