# Dynamic Context Builder - System Overview

**Date:** 2025-11-11  
**Version:** 2.0.0 - Pure 3-Section Architecture  
**Purpose:** Complete documentation of the AI context management system

---

## What This System Does

The `dynamic-context-builder.R` script provides a clean, powerful AI context management system for GitHub Copilot. It implements a pure 3-section architecture that:

- **Manages AI Behavior**: Controls core instructions, persona expertise, and project-specific context
- **Enables Persona Switching**: Instantly switch between specialized AI roles (developer, analyst, manager, etc.)
- **Maintains Simplicity**: 18 focused functions organized by clear responsibilities
- **Supports Discovery**: Built-in tools to explore available personas and context documents

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  SECTION 1: Core AI Instructions                        │
│  ├─ Source: ai/core/base-instructions.md               │
│  └─ Editing: Manual (human edits copilot-*.md)        │
├─────────────────────────────────────────────────────────┤
│  SECTION 2: Active Persona                             │
│  ├─ Source: ai/personas/*.md                           │
│  └─ Loading: Verbatim on activation                   │
├─────────────────────────────────────────────────────────┤
│  SECTION 3: Additional Context                          │
│  ├─ Source: ai/project/*.md or custom .md files        │
│  └─ Loading: A) Persona defaults OR B) Manual         │
└─────────────────────────────────────────────────────────┘
```

### How It Works

1. **Section 1** provides foundational AI behavioral guidelines (evidence-based reasoning, collaborative excellence, quality focus)
2. **Section 2** loads specialized expertise based on the active persona (developer, analyst, etc.)
3. **Section 3** adds project-specific context (mission, methodology, glossary, etc.) either automatically via persona defaults or manually via user commands

---

## Function Inventory (18 Functions)

### Core Engine (5 functions - Internal Use)

These functions power the system internally. Users don't call them directly.

#### `get_file_map()`
- **Purpose:** Configuration-driven file path resolution
- **Used By:** Internal infrastructure for resolving friendly file names to actual paths
- **Importance:** Critical - enables all file operations

#### `resolve_file_path(file_key, file_map)`
- **Purpose:** Resolve friendly names (like 'mission') to actual file paths
- **Used By:** add_context_file() and other file operations
- **Importance:** High - enables clean user interface with aliases

#### `get_persona_configs()`
- **Purpose:** Registry of all personas with their default context settings
- **Used By:** Persona activation functions
- **Importance:** Critical - defines all available personas and their behavior

#### `get_general_instructions()`
- **Purpose:** Read Section 1 content from ai/core/base-instructions.md
- **Used By:** build_3_section_instructions()
- **Importance:** Critical - loads foundational AI behavioral guidelines
- **Note:** File-based approach allows easy editing without touching R code

#### `generate_context_overview()`
- **Purpose:** Create header with size metrics and context overview
- **Used By:** build_3_section_instructions()
- **Importance:** Medium - provides useful diagnostics in instruction file
- **Note:** Complex signature (10 parameters) but functional

---

### 3-Section System Core (3 functions - Primary Engines)

These are the main orchestration functions that make the system work.

#### `build_3_section_instructions(persona_name, additional_context)`
- **Purpose:** Main assembly engine - builds complete copilot-instructions.md
- **Called By:** set_persona_with_defaults(), add_context_file(), remove_context_file()
- **What It Does:** 
  1. Reads Section 1 from base-instructions.md
  2. Loads persona file for Section 2
  3. Assembles Section 3 from provided context list
  4. Writes complete file with proper markers
- **Importance:** Critical - the heart of the entire system

#### `set_persona_with_defaults(persona_name)`
- **Purpose:** Activate persona with its default context configuration
- **Called By:** All activation shortcuts (activate_developer, etc.)
- **What It Does:**
  1. Looks up persona configuration
  2. Loads default context files for that persona
  3. Calls build_3_section_instructions()
  4. Confirms activation to user
- **Importance:** High - primary interface for persona management

#### `show_context_status()`
- **Purpose:** Display current state of all 3 sections
- **Called By:** Users and AI for diagnostics
- **What It Does:**
  1. Parses current copilot-instructions.md
  2. Extracts active persona and context files
  3. Calculates sizes and displays organized summary
  4. Shows commands for managing context
- **Importance:** High - essential for understanding current state

---

### User Interface (3 functions - Direct Human/AI Use)

These functions provide direct control over Section 3 context.

#### `add_context_file(file_path)`
- **Purpose:** Add a document to Section 3 (additional context)
- **Usage:** `add_context_file('project/mission')` or `add_context_file('ai/project/glossary.md')`
- **What It Does:**
  1. Resolves friendly name to actual file path
  2. Reads current context from copilot-instructions.md
  3. Adds new file if not already present
  4. Rebuilds instruction file with updated context
- **Use Cases:** Adding project docs, methodology, glossary, etc.

#### `remove_context_file(file_path)`
- **Purpose:** Remove a document from Section 3
- **Usage:** `remove_context_file('project/glossary')`
- **What It Does:**
  1. Reads current context
  2. Removes specified file from list
  3. Rebuilds instruction file without that context
- **Use Cases:** Removing stale or unnecessary context

#### `list_available_md_files(pattern)`
- **Purpose:** Discover available markdown files in the repository
- **Usage:** `list_available_md_files()` or `list_available_md_files('personas')`
- **What It Does:**
  1. Scans repository for .md files
  2. Groups by directory for readability
  3. Displays organized list with file paths
- **Use Cases:** Exploring available personas, finding project documents

---

### Persona Activation Shortcuts (10 functions - High-Value Convenience)

These provide instant persona switching with intuitive names. All follow the same pattern: `activate_*() { set_persona_with_defaults("*") }`

| Function | Persona | Default Context | Use Case |
|----------|---------|-----------------|----------|
| `activate_default()` | Default | None | General assistance |
| `activate_developer()` | Developer | None | Technical implementation, minimal context |
| `activate_data_engineer()` | Data Engineer | None | Data pipeline specialist |
| `activate_research_scientist()` | Research Scientist | None | Statistical analysis |
| `activate_devops_engineer()` | DevOps Engineer | None | Production deployment |
| `activate_frontend_architect()` | Frontend Architect | None | Visualization specialist |
| `activate_project_manager()` | Project Manager | mission, method, glossary | Strategic oversight, full context |
| `activate_casenote_analyst()` | Casenote Analyst | None | Domain-specific analyst |
| `activate_prompt_engineer()` | Prompt Engineer | None | Prompt engineering specialist |
| `activate_reporter()` | Reporter | None | Analytical storytelling |

**Note:** These functions are integrated with VS Code tasks for one-click persona switching from the command palette.

---

## Typical Usage Patterns

### Switching Personas

**Basic Switch:**
```r
activate_developer()  # Loads developer persona, minimal context
```

**Switch with Full Context:**
```r
activate_project_manager()  # Loads PM persona + mission + method + glossary
```

### Managing Section 3 Context

**Add Project Context:**
```r
add_context_file('project/mission')     # Add mission statement
add_context_file('project/glossary')    # Add glossary
add_context_file('pipeline')            # Add data pipeline docs
```

**Remove Context:**
```r
remove_context_file('project/glossary')  # Remove when no longer needed
```

**Check Current State:**
```r
show_context_status()  # See what's currently loaded
```

### Discovery

**Find Available Files:**
```r
list_available_md_files()           # All .md files in project
list_available_md_files('personas') # Just personas
list_available_md_files('project')  # Just project docs
```

---

## Workflow Examples

### Starting a Development Session
```r
activate_developer()          # Load developer expertise
add_context_file('pipeline')  # Add data pipeline context if needed
show_context_status()         # Verify setup
```

### Strategic Planning Session
```r
activate_project_manager()  # Loads PM + mission + method + glossary automatically
show_context_status()       # Confirm all context loaded
```

### Focused Analysis Work
```r
activate_research_scientist()      # Load analyst expertise
add_context_file('project/method') # Add methodology
show_context_status()              # Verify configuration
```

### Context Cleanup
```r
show_context_status()                    # See what's loaded
remove_context_file('project/glossary')  # Remove unnecessary context
activate_default()                       # Or reset to minimal state
```

---

## Design Principles

### Single Responsibility
Each function has one clear purpose with well-defined inputs and outputs.

### Configuration-Driven
- **File Paths:** Resolved via ai-config-utils.R and get_file_map()
- **Persona Definitions:** Centralized in get_persona_configs()
- **Core Instructions:** Externalized to ai/core/base-instructions.md

### Clear User Flow
1. **Activate** a persona: `activate_developer()`
2. **Add** context if needed: `add_context_file('project/mission')`
3. **Check** status: `show_context_status()`
4. **Remove** context when done: `remove_context_file('project/mission')`

### Extensibility
- **New Personas:** Add to get_persona_configs() + create activation shortcut
- **New Context Files:** Add to get_file_map() alias registry
- **Core Instructions:** Edit ai/core/base-instructions.md (no code changes needed)

---

## System Integration

### VS Code Tasks
All persona activation functions are integrated with VS Code tasks for one-click switching:
- `Tasks: Run Task` → `Activate Developer Persona`
- `Tasks: Run Task` → `Activate Project Manager Persona`
- etc.

### Configuration System
Uses `ai-config-utils.R` for centralized configuration management:
- Reads from `config.yml` with intelligent fallbacks
- Resolves all file paths consistently
- Supports both friendly names and full paths

### Memory System
Integrates with project memory functions:
- Context changes can be logged to memory
- AI can reference memory files as additional context
- Memory files discoverable via `list_available_md_files('memory')`

---

## Technical Details

### File Structure
```
ai/
├── core/
│   └── base-instructions.md          # Section 1 source
├── personas/
│   ├── developer.md                  # Section 2 sources
│   ├── project-manager.md
│   └── ... (10 total personas)
├── project/
│   ├── mission.md                    # Section 3 sources
│   ├── method.md
│   └── glossary.md
└── scripts/
    └── dynamic-context-builder.R     # This system
```

### Generated Output
```
.github/
└── copilot-instructions.md          # Final assembled instructions
```

### Code Statistics
- **Total Lines:** ~670
- **Functions:** 18 (organized in 4 categories)
- **Dependencies:** ai-config-utils.R, config.yml
- **Output:** Single copilot-instructions.md file

---

## Known Limitations & Future Enhancements

### Current Limitations

1. **generate_context_overview() Complexity**
   - Has 10 parameters (high parameter count)
   - Works correctly but could be refactored to use config object
   - Priority: Low

2. **Section 3 Parsing**
   - Uses regex to extract current context from instruction file
   - Reliable but dependent on specific marker format
   - Could be improved with structured metadata

3. **Persona Config Hard-Coded**
   - Persona definitions in get_persona_configs() are hard-coded
   - Could be externalized to YAML for easier maintenance
   - Priority: Low - current approach simple and functional

### Future Enhancement Ideas

- **Externalize persona configs to YAML** for easier maintenance
- **Add context file validation** to verify files exist before loading
- **Enhanced discovery tools** with filtering, sorting, metadata
- **Context file preview** to see file contents before loading
- **Automatic context suggestions** based on recent file activity
- **Context size warnings** when approaching token limits

---

## Troubleshooting

### Common Issues

**Problem:** "File not found" when adding context  
**Solution:** Use `list_available_md_files()` to find correct path, or use friendly name from get_file_map()

**Problem:** Persona activation doesn't show changes  
**Solution:** Run `show_context_status()` to verify activation completed

**Problem:** Context file not loading  
**Solution:** Check file exists at specified path, verify file is valid markdown

**Problem:** VS Code task fails to activate persona  
**Solution:** Verify ai-migration-toolkit.R is sourcing dynamic-context-builder.R correctly

---

## Summary

**What:** Pure 3-section AI context management system  
**Purpose:** Control GitHub Copilot behavior via personas and project context  
**Scope:** 18 focused functions in 4 categories  
**Status:** Production-ready  
**Complexity:** Low - simple, maintainable architecture  

**Key Features:**
- ✅ 10 instant persona switches
- ✅ Surgical context loading (add/remove specific files)
- ✅ Built-in discovery tools
- ✅ VS Code task integration
- ✅ Configuration-driven design
- ✅ File-based Section 1 (easy to edit)

**For Users:** Simple, intuitive commands for powerful AI customization  
**For Maintainers:** Clean, well-organized code with clear responsibilities  
**For AI:** Comprehensive context management with self-awareness capabilities

---

**Version:** 2.0.0  
**Last Updated:** 2025-11-11  
**Maintained By:** GitHub Copilot (with human oversight)
