# AI Context System

**📍 Location**: `ai/docs/` | **🏠 Home**: [`ai/README.md`](../README.md) | **📚 Main**: [`README.md`](../../README.md)

The AI context management system provides structured control over AI assistant context through three sections in the copilot instructions.

## 📋 System Architecture

Context management comes down to controlling the text in the .github/copilot-instructions.md file (system prompt), so that you chat input (user prompt) has sufficient context to generate high-quality responses. The copilot-instructions.md file is divided into three main sections:

- Section 1: Fundamentals of AI behavior (conductor)
- Section 2: Current active persona (soloist)
- Section 3: Custom context files (orchestra)

When switching personas or adding/removing context files, the copilot-instructions.md file is automatically regenerated to reflect the new configuration. We also create a context overview header to see current configuration at a glance when we open the file. 

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

## 🎭 AI Persona System


This project template includes several specialized AI personas, each optimized for different research tasks. Users are encouraged to edits the language of each persona to reflect personal preferences. 

### **Defined Personas**

- **⚡ Data Engineer** - Data pipelines and quality assurance
- **🔧 Developer** - Technical infrastructure and reproducible code
- **🚀 DevOps Engineer** - Deployment and operational excellence
- **🎨 Frontend Architect** - User interfaces and visualization
- **💡 Prompt Engineer** - AI optimization and prompt design
- **📈 Grapher** - Data visualization and display of informatioin
- **🎤 Presenter** - Produces slides and talk materials. 
- **📊 Project Manager** - Strategic oversight and coordination
- **📝 Reporter** - Analysis communication and storytelling
- **🔬 Research Scientist** - Statistical analysis and methodology

Every time you switch persona, the copilot-instructions.md file is regenerated to load the new persona file into Section 2, along with that persona's default context files in Section 3.

You can switch between personas in VSCode:

- `Ctrl+Shift+P` → "Tasks: Run Task" → "Activate [Persona Name] Persona"  
- Instruct the chat agent to switch to the specific persona you name  

You can define persona's default context in `get_persona_configs()` function of `ai/scripts/dynamic-context-builder.R`:

```r
"project-manager" = list(
  file = "./ai/personas/project-manager.md",
  default_context = c("project/mission", "project/method", "project/glossary")
)
```

You can define what context files get a shortcut alias, so they can be integrated into the chat calls easily. See `get_file_map()` function in `ai/scripts/dynamic-context-builder.R`.


### Built-In Context Overview

Every copilot-instructions.md file starts with a **Context Configuration Overview** that provides:

- **Real-time metrics**: Total size (KB), line counts, generation timestamp
- **Section breakdown**: Individual size and status for each section
- **File inventory**: Detailed listing of all loaded context files with individual sizes

This overview updates automatically every time you change persona or context, giving you immediate visibility into your current configuration without needing to run separate commands.

## 📚 Context File Categories

### Project Framework Files

- `project/mission` - Project objectives and strategic vision
- `project/method` - Research methodology and analytical approach  
- `project/glossary` - Domain terminology and definitions

You can name any specific file in the projec to the dynamic context (Section 3) by specifying its path (e.g., `add_context_file('project/mission')`) or by looking it by with `list_available_md_files()` request. 

### Research Design

- `philosophy/analysis-templatization.md` - Analysis framework and templates
- `philosophy/causal-inference.md` - Causal analysis principles
- `philosophy/semiology.md` - Methodological foundations
- `philosophy/threats-to-validity.md` - research design for quasi-experimental studies

### Memory

- `memory-human` - Human project memory
- `memory-ai` - AI learning and insights
