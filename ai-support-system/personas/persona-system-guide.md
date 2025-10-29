# Persona System Guide

A comprehensive guide to understanding, using, and managing the AI persona system in the case-note-simulator repository.

## 🎯 What is the Persona System?

The persona system provides **specialized AI assistants** tailored for different aspects of research and development work. Instead of a generic AI that tries to do everything, you get focused expertise that understands your specific context and needs.

### Core Concepts

- **Persona**: A specialized AI assistant with domain expertise, specific knowledge, and focused capabilities
- **Dynamic Content**: Context files that get loaded alongside a persona to provide relevant background
- **Activation**: The process of switching between different personas based on your current work
- **Default Behavior**: The Developer persona loads automatically, providing immediate backend expertise

## 🔧 For Humans: Using the Persona System

### Quick Reference Commands

```r
# Essential Commands
source('./scripts/update-copilot-context.R')   # Load the system
list_personas()                                # See all available personas  
activate_developer()                           # Backend/infrastructure focus
activate_casenote_analyst()                    # Domain analysis focus
get_current_persona()                          # Check active persona
deactivate_persona()                           # Return to basic context

# Context Management
context_refresh()                              # Quick status + options
add_core_context()                             # Load foundational context
remove_all_dynamic_instructions()              # Reset all context
```

### When to Use Each Persona

#### 🔧 Developer (Default)
**Activate**: Automatically loaded, or `activate_developer()`
**Best For**:
- Backend system design and troubleshooting
- Reproducible research infrastructure  
- Database design and optimization
- Performance tuning and debugging
- CI/CD and deployment issues
- Code architecture and refactoring
- Testing framework development

**Example Questions**:
- "Help me debug this flow.R pipeline failure"
- "Design a robust data validation system"
- "Review our repository structure for maintainability"
- "Optimize this R script for better performance"

#### 📊 Case Note Analyst  
**Activate**: `activate_casenote_analyst()`
**Best For**:
- Social services data analysis
- Risk stratification and assessment
- Case note interpretation and flagging
- Population demographic analysis
- Research methodology for social sciences
- Statistical analysis of case patterns

**Example Questions**:
- "Analyze these case notes for risk indicators"
- "Create a demographic profile of this client population" 
- "Design a risk assessment framework"
- "Interpret these case note patterns statistically"

### Workflow Examples

#### Typical Development Session
```r
# Start working (Developer auto-loads)
source('./scripts/update-copilot-context.R')
# ✅ Developer persona ready for backend work

# Work on infrastructure, debugging, system design...

# Switch to domain analysis when needed
activate_casenote_analyst()
# Analyze case data, create reports...

# Return to backend work
activate_developer()
# Continue with infrastructure tasks...
```

#### Project Phase Alignment
```r
# Data Engineering Phase
activate_developer()
# Focus: ETL pipelines, database design, system setup

# Analysis Phase  
activate_casenote_analyst()
# Focus: Case note analysis, risk assessment, reporting

# Infrastructure Maintenance
activate_developer()  
# Focus: Performance, monitoring, deployment
```

## 🤖 For AI Agents: Understanding the Persona System

### System Architecture

The persona system operates through several integrated components:

1. **Persona Files** (`./ai/personas/*.md`): Define specialized expertise and behavior
2. **Activation Functions** (`update-copilot-context.R`): Handle persona loading and switching
3. **Dynamic Content Loading**: Automatically loads relevant context based on persona
4. **State Management**: Maintains persona configuration across sessions

### Default Behavior

- **Startup**: Developer persona loads automatically if no persona is active
- **Context Loading**: Each persona specifies its dynamic content requirements
- **State Persistence**: Active persona saved in `.copilot-persona` configuration file
- **Graceful Fallback**: System handles missing files and provides clear error messages

### Dynamic Content Configuration

Each persona specifies what context to load:

```r
# Developer: Minimal, focused context
activate_developer()
# Loads: agent-persona only

# Case Note Analyst: Rich domain context  
activate_casenote_analyst()
# Loads: agent-persona + mission + method
```

### Integration Points

- **Memory System**: Persona-aware memory and intent detection
- **VS Code Tasks**: Automated workflows respect active persona
- **Configuration**: Personas utilize `config.yml` for environment settings
- **Testing**: Integration tests validate persona functionality

## 🛠️ Technical Implementation

### File Structure
```
./ai/personas/
├── README.md                    # Directory overview
├── persona-system-guide.md      # This comprehensive guide
├── developer.md                 # Default backend specialist
├── casenote-analyst.md          # Domain analysis specialist
└── [future-persona.md]          # Additional specialized personas
```

### Activation Function Pattern
```r
activate_[persona_name] <- function() {
  set_persona("./ai/personas/[persona-name].md", 
              "[persona-name]", 
              character(0))  # or c("mission", "method") for rich context
}
```

### Persona File Template
```markdown
# [Persona Name] System Prompt

## Role
[Define the persona's identity and primary function]

## Objective/Task  
[Specify main goals and responsibilities]

## Tools/Capabilities
[List technical skills and methodological knowledge]

## Rules/Constraints
[Define operating principles and limitations]

## Input/Output Format
[Describe expected inputs and output formats]

## Style/Tone/Behavior
[Define communication style and approach]

## Response Process
[Outline systematic approach to problem-solving]

## Integration with Project Ecosystem
[Specify how this persona works with project systems]
```

## 📈 Creating New Personas

### 1. Identify the Need
- What specialized expertise is missing?
- What domain knowledge would be valuable?
- How would this complement existing personas?

### 2. Create the Persona File
```bash
# Create new persona file
touch ./ai/personas/new-persona.md
```

### 3. Define the Persona
- Follow the standard template structure
- Be specific about expertise areas
- Define clear boundaries and limitations
- Specify integration points with existing systems

### 4. Add Activation Function
```r
# In update-copilot-context.R
activate_new_persona <- function() {
  set_persona("./ai/personas/new-persona.md", "new-persona", 
              c("relevant", "context", "files"))
}
```

### 5. Update Documentation
- Add to `./ai/personas/README.md`
- Update this guide with usage examples
- Create user-facing documentation if needed

### 6. Create Integration Tests
```r
# Test persona loading and functionality
test_new_persona_integration <- function() {
  # Validate file exists
  # Test activation function
  # Verify content loading
  # Check persona detection
}
```

## 🔍 Troubleshooting

### Common Issues

#### Persona Not Loading
```r
# Check if file exists
file.exists("./ai/personas/persona-name.md")

# Verify activation function
exists("activate_persona_name")

# Check for syntax errors in persona file
# Look for proper markdown formatting
```

#### Wrong Content Loading
```r
# Force refresh
deactivate_persona()
remove_all_dynamic_instructions()
activate_desired_persona()

# Check persona configuration
readLines(".copilot-persona")
```

#### Performance Issues
```r
# Check copilot instructions file size
file.size(".github/copilot-instructions.md")

# Use streamlined personas (like Developer)
# Consider deactivating unused context
```

### Debug Commands
```r
# System status
context_refresh()
list_personas()
get_current_persona()

# File validation
file.exists("./ai/personas/developer.md")
file.exists(".copilot-persona")

# Reset everything
remove_all_dynamic_instructions()
if (file.exists(".copilot-persona")) file.remove(".copilot-persona")
```

## 🚀 Best Practices

### For Humans
1. **Start with Developer**: The default persona handles most backend needs
2. **Switch Contextually**: Activate domain personas only when doing specialized work
3. **Check Current State**: Use `get_current_persona()` to know what's active
4. **Reset When Confused**: Use `deactivate_persona()` to return to basics

### For AI Agents  
1. **Respect Persona Boundaries**: Stay within the activated persona's expertise
2. **Suggest Appropriate Switches**: Recommend persona changes when needed
3. **Leverage Dynamic Content**: Use loaded context files effectively
4. **Maintain System Health**: Monitor performance and suggest optimizations

### For System Maintainers
1. **Keep Personas Focused**: Each should have clear, non-overlapping expertise
2. **Test Regularly**: Run integration tests to catch issues early
3. **Document Changes**: Update guides when adding or modifying personas
4. **Monitor Performance**: Watch copilot instruction file size and complexity

## 📚 Related Documentation

- **User Guides**: `../../guides/developer-persona-guide.md`
- **AI System**: `../README.md` - Overall AI system architecture
- **Memory System**: `../memory-guide.md` - Project memory and intent tracking
- **Task System**: `../vscode-tasks-reference.md` - VS Code integration

---

*The persona system transforms your AI assistant from a generic helper into a specialized expert team, ensuring you always have the right expertise for your current work while maintaining the flexibility to switch contexts as your needs change.*