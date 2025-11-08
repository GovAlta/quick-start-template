# AI Personas Directory

This directory contains the complete AI persona system for the case-note-simulator repository. Each persona is a specialized AI assistant designed for specific aspects of research and development work.

## 📁 Directory Structure

```
./ai/personas/
├── README.md                    # This file - persona system overview
├── persona-system-guide.md      # Complete guide for humans and AI
├── developer.md                 # [DEFAULT] Backend & reproducible research
├── casenote-analyst.md          # Domain-specific case note analysis
└── [future personas...]         # Additional personas as needed
```

## 🎭 Available Personas

### 🔧 Developer (Default)
**File**: `developer.md`  
**Activation**: `activate_developer()` (auto-loads on startup)  
**Specialization**: Backend systems, reproducible research infrastructure, DevOps  
**Dynamic Content**: `agent-persona` only (streamlined)  
**When to Use**: Default for all backend development, system architecture, infrastructure work

### � Project Manager
**File**: `project-manager.md`  
**Activation**: `activate_project_manager()`  
**Specialization**: Strategic oversight, project alignment, requirements analysis, stakeholder coordination  
**Dynamic Content**: `agent-persona`, `project/mission`, `project/method`, `project/glossary`  
**When to Use**: Strategic planning, project oversight, ensuring alignment with research objectives

### 📊 Case Note Analyst  
**File**: `casenote-analyst.md`  
**Activation**: `activate_casenote_analyst()`  
**Specialization**: Social services data analysis, risk stratification, case note interpretation  
**Dynamic Content**: `agent-persona` only (focused domain expertise)  
**When to Use**: Domain-specific analysis of case notes, social services research

### 🎯 Prompt Engineer
**File**: `prompt-engineer.md`  
**Activation**: `activate_prompt_engineer()`  
**Specialization**: RICECO framework implementation, prompt optimization, AI interaction design  
**Dynamic Content**: `agent-persona` only (focused prompt optimization)  
**When to Use**: Transforming prompts into RICECO-compliant versions, prompt template creation, AI response optimization

## 🚀 Quick Start

### For Humans
```r
# Load the persona system
source('./scripts/update-copilot-context.R')

# See all available personas
list_personas()

# Switch between personas
activate_developer()          # Default backend/infrastructure (minimal context)
activate_project_manager()    # Strategic oversight (full project context)
activate_casenote_analyst()   # Domain expertise (focused context)
activate_prompt_engineer()    # RICECO prompt optimization (minimal context)
activate_casenote_analyst()   # Domain analysis (focused expertise)
deactivate_persona()          # Basic context only
```

### For AI Agents
The persona system automatically:
- Loads the Developer persona by default on initialization
- Provides context-specific expertise based on active persona
- Maintains persona state across work sessions
- Enables smooth switching between specialized roles

## 📋 Persona Configuration

Each persona defines:
- **Role & Responsibilities**: Clear scope and expertise areas
- **Tools & Capabilities**: Technical skills and methodological knowledge  
- **Rules & Constraints**: Operating principles and limitations
- **Dynamic Content**: What additional context components to load
- **Integration Points**: How to work with other personas and systems

## 🔄 Adding New Personas

1. Create new `.md` file in `./ai/personas/`
2. Follow the standard persona template structure
3. Add activation function to `update-copilot-context.R`
4. Update documentation and tests
5. Configure dynamic content loading preferences

See `persona-system-guide.md` for detailed instructions.

## 🛠️ Technical Integration

The persona system integrates with:
- **VS Code Tasks**: Automated persona loading and management
- **Memory System**: Context-aware memory and intent detection  
- **Configuration**: `config.yml` and environment management
- **Documentation**: Living documentation that updates with persona changes
- **Testing**: Automated integration tests for persona functionality

## 📖 Documentation

- **Complete Guide**: `persona-system-guide.md` - Comprehensive instructions for humans and AI
- **User Guide**: `../../guides/developer-persona-guide.md` - User-focused persona usage
- **Technical Docs**: `../README.md` - AI system architecture overview

---
*The persona system enables specialized AI assistance tailored to different aspects of research and development work, ensuring you always have the right expertise available for your current task.*