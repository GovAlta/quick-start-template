# Commands Reference

**📍 Location**: `ai/docs/` | **🏠 Home**: [`ai/README.md`](../README.md) | **📚 Main**: [`README.md`](../../README.md)

Essential commands for working with the AI support system.

## 🎭 Persona Management

Switch between AI assistant personas with different expertise areas:

```r
# Load the system
source('ai/scripts/ai-migration-toolkit.R')

# Switch personas
activate_project_manager()   # Strategic oversight + full project context
activate_developer()         # Technical focus, minimal context  
activate_data_engineer()     # Data pipeline specialist, minimal context
activate_research_scientist() # Statistical analysis specialist, minimal context
activate_prompt_engineer()   # RICECO framework specialist + specialized context
activate_reporter()          # Analytical storytelling, on-demand context
activate_default()           # General assistance, minimal context

# Check current status
show_context_status()
```

## 📄 Context Management

Manage additional context files for the AI assistant:

```r
# Add specific files to context
add_context_file('./ai/project/mission.md')
add_context_file('./analysis/eda-1/README.md')

# Remove files from context  
remove_context_file('./ai/project/mission.md')

# List available .md files
list_available_md_files()
list_available_md_files('pattern')  # Filter by pattern
```

## 🧠 Memory & Status

Track project memory and status:

```r
# Memory functions
memory_status()          # Quick memory system status
ai_memory_check()        # Comprehensive memory analysis with intent detection
context_refresh()        # Complete status scan with options

# Project status
show_context_status()    # Current persona and context status
```

## 📝 Change Logging

Track file modifications in the project:

```r
# Log file changes
log_change('analysis/eda-1/eda-1.qmd', 'Added new visualizations')
log_file_change('scripts/common-functions.R', 'Updated data loading functions')
```

## 🚀 Quick Start

**New to the project?**
1. `source('ai/scripts/ai-migration-toolkit.R')`
2. `show_context_status()` - See current configuration
3. `activate_project_manager()` - Load full project context
4. Start working with complete project understanding

**Daily workflow:**
1. `show_context_status()` - Check current setup
2. Switch persona if needed with `activate_*()`
3. Add relevant context with `add_context_file()`
4. Log changes with `log_change()`

## 💡 Tips

- **Project Manager persona** includes full project context (mission, method, glossary)
- **Developer persona** is minimal context for focused technical work
- Use `show_context_status()` to see what's currently loaded
- Context files are automatically managed - no manual cleanup needed
- All personas have access to the same core commands

---
*Updated: October 2025 | Current system functions only*