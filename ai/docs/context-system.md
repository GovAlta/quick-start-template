# AI Context System

**📍 Location**: `ai/docs/` | **🏠 Home**: [`ai/README.md`](../README.md) | **📚 Main**: [`README.md`](../../README.md)

The AI context management system provides structured control over AI assistant context through three sections in the copilot instructions.

## 📋 System Architecture

### Context Overview Header
- **Purpose**: Real-time visibility into loaded context and file sizes
- **Content**: Section breakdown with KB/token counts, active files, management commands
- **Updates**: Automatically regenerated when context changes
- **Benefits**: Immediate understanding of current configuration and resource usage

### Section 1: Core AI Instructions (Static)
- **Purpose**: Core AI behavior, response guidelines, and system-wide instructions
- **Content**: Consistent baseline behavior that never changes
- **Includes**: Universal principles, memory detection, automation triggers, response guidelines

### Section 2: Active Persona (Dynamic)
- **Purpose**: Single active persona defining specialized role and expertise
- **Content**: One persona file loaded at a time
- **Examples**: Developer (technical), Project Manager (strategic)

### Section 3: Additional Context (Dynamic) 
- **Purpose**: Flexible context files relevant to current work
- **Content**: Persona default files + manually added files
- **Examples**: Project documentation, analysis workflows, methodology files

## 🚀 Quick Start

### Basic Persona Switching
```r
# Load system
source('ai/scripts/ai-migration-toolkit.R')

# Activate personas with their defaults
activate_developer()         # Technical focus, minimal context
activate_project_manager()   # Strategic oversight + mission/method/glossary  

# Check current status
show_context_status()
```

### Context File Management
```r
# Add specific context files
add_context_file('./ai/project/mission.md')
add_context_file('./analysis/eda-1/README.md')

# Remove context files
remove_context_file('./ai/project/mission.md')

# Discover available files
list_available_md_files()           # All .md files
list_available_md_files('guide')    # Files matching pattern

# Remove context files
remove_context_file('philosophy/analysis-templatization.md')

# Check what's loaded
show_context_status()
```

## 🎭 Available Personas

### Developer (Default)
- **Focus**: Technical implementation, system architecture, reproducible research
- **Default Context**: None (minimal context for focused technical work)
- **Use For**: Backend development, R programming, system maintenance
- **Activation**: `activate_developer()`

### Project Manager
- **Focus**: Strategic oversight, project alignment, stakeholder coordination
- **Default Context**: Project mission, methodology, glossary
- **Use For**: Planning, requirements analysis, project coordination
- **Activation**: `activate_project_manager()`

## 📚 Context File Categories

### Project Framework Files
- `project/mission` - Project objectives and strategic vision
- `project/method` - Research methodology and analytical approach  
- `project/glossary` - Domain terminology and definitions

### Analysis & Methodology
- `philosophy/analysis-templatization.md` - Analysis framework and templates
- `philosophy/semiology.md` - Methodological foundations
- `philosophy/causal-inference.md` - Causal analysis principles

### Implementation Documentation
- `simulation/implementation.md` - System implementation and architecture
- `simulation/README.md` - Synthetic data generation overview
- `analysis/*/README.md` - Analysis-specific documentation

### Memory & Documentation
- `memory-hub` - Central memory coordination
- `memory-human` - Human project memory
- `memory-ai` - AI learning and insights

## 🔧 Advanced Features

### File Discovery and Search
```r
# Find all guides
list_available_md_files('guide')

# Find philosophy files  
list_available_md_files('philosophy')

# Find analysis documentation
list_available_md_files('analysis')
```

### Context Status Monitoring
```r
show_context_status()
# Shows:
# - Section 1: Always present (general instructions) 
# - Section 2: Current active persona
# - Section 3: All additional context files with paths
# - Total file size and line count
```

### Built-In Context Overview
Every copilot-instructions.md file starts with a **Context Configuration Overview** that provides:

- **Real-time metrics**: Total size (KB), line counts, generation timestamp
- **Section breakdown**: Individual size and status for each section
- **File inventory**: Detailed listing of all loaded context files with individual sizes
- **Quick commands**: Ready-to-use R commands for context management

This overview updates automatically every time you change persona or context, giving you immediate visibility into your current configuration without needing to run separate commands.

### Persona Defaults Configuration
Each persona defines its default context in `get_persona_configs()`:
```r
"project-manager" = list(
  file = "./ai/personas/project-manager.md",
  default_context = c("project/mission", "project/method", "project/glossary")
)
```

## 🎯 Usage Patterns

### Planning Session
```r
activate_project_manager()  # Strategic oversight
add_context_file('philosophy/analysis-templatization.md')  # Analysis framework
add_context_file('analysis/README.md')  # Implementation guidance
```

### System Development Session  
```r
activate_developer()  # Technical focus
add_context_file('simulation/README.md')  # System overview
# Keep context minimal for focused technical work
```

### Cross-Functional Coordination
```r
activate_project_manager()  # Strategic oversight (loads mission/method/glossary automatically)
add_context_file('memory-human')  # Project history
add_context_file('philosophy/semiology.md')  # Methodological foundation
```

### Right-sizing Context

Use `show_context_status()` to monitor size vs. relevance. Generally:
- Smaller context → faster, more focused technical work
- Larger context → broader understanding for planning and coordination

## 🛠️ System Integration

### VS Code Integration
- Context changes update `.github/copilot-instructions.md` automatically
- GitHub Copilot reads updated instructions immediately
- No restart required; changes take effect instantly

### Backward Compatibility
- All existing `activate_*()` functions continue to work
- Legacy file aliases maintained (e.g., `mission` → `project/mission`)
- Gradual migration supported without breaking workflows

### File Organization
The system respects the project's organized structure:
```
ai/
├── personas/     # Section 2 content
├── project/      # Strategic context for Section 3
└── [memory & other files]  # Available for Section 3

philosophy/       # Methodological context for Section 3
simulation/       # Implementation context for Section 3  
analysis/         # Analysis workflow context for Section 3
```

## 📖 Next Steps

1. **Experiment with combinations**: Try different persona + context combinations for your tasks
2. **Create presets**: Save frequently used context combinations
3. **Monitor performance**: Use `show_context_status()` to optimize context size
4. **Extend personas**: Create custom personas for specialized workflows
