

# VS Code Tasks Reference

> **Purpose**: Track all VS Code tasks, their triggers, and functionality for team reference and maintenance.

## 🚨 Maintenance Needed

**Action Items** (added 2025-10-01):
- [ ] Update "Last Updated" date from August 8 → October 1, 2025
- [ ] Verify all 26 task statuses are current  
- [ ] Add version info and related files section
- [ ] Establish routine maintenance schedule
- [ ] Consider integration with project memory system

---

## Overview

This document maintains a comprehensive list of all custom VS Code tasks created for the Books of Ukraine project. Each task is designed to automate common workflows and reduce friction in the development process.

### ⚠️ **PowerShell Script Standards**

**IMPORTANT**: All `.ps1` files must use ASCII-only characters (no emojis/Unicode). See `ai/onboarding-ai.md` → "PowerShell Scripting Standards" for complete guidelines. Unicode characters cause parsing errors and task failures.


## Available Tasks

### 1. Render EDA-1 Report (Quarto)
- **Task ID**: `Render EDA-1 Report (Quarto)`
- **Command**: `quarto render analysis/eda-1/eda-1.qmd --to html`
- **Description**: Renders the EDA-1 analysis report to HTML using Quarto
- **When to Use**: Generate final report from EDA-1 analysis
- **Access Method**: Tasks: Run Task → "Render EDA-1 Report (Quarto)"
- **Expected Output**: HTML report in analysis/eda-1/ directory
- **Status**: ✅ Active

### 2. Check Quarto Availability
- **Task ID**: `Check Quarto Availability`
- **Command**: `quarto --version`
- **Description**: Checks if Quarto CLI is installed and available
- **When to Use**: Environment setup verification, troubleshooting Quarto issues
- **Access Method**: Tasks: Run Task → "Check Quarto Availability"
- **Expected Output**: Quarto version number
- **Status**: ✅ Active

### 3. Memory System Status Check
- **Task ID**: `Memory System Status Check`
- **Command**: PowerShell script to check ai/*.md file timestamps
- **Description**: Shows status and last modification times of memory system files in ai/ directory
- **When to Use**: Memory system maintenance, checking for recent updates
- **Access Method**: Tasks: Run Task → "Memory System Status Check"
- **Expected Output**: List of ai/*.md files with modification timestamps
- **Status**: ✅ Active

### 4. Load Memory Functions (R)
- **Task ID**: `Load Memory Functions (R)`
- **Command**: `Rscript scripts/wrappers/run-ai-memory-check.R`
- **Description**: Loads AI memory functions from R wrapper script
- **When to Use**: Initialize memory system, AI context management
- **Access Method**: Tasks: Run Task → "Load Memory Functions (R)"
- **Expected Output**: Memory functions loaded confirmation
- **Status**: ✅ Active

### 5. Project Files Overview
- **Task ID**: `Project Files Overview`
- **Command**: PowerShell tree command with full file listing
- **Description**: Complete project structure including all files
- **When to Use**: Project overview, file location, comprehensive structure review
- **Access Method**: Tasks: Run Task → "Project Files Overview"
- **Expected Output**: Complete tree structure with files
- **Status**: ✅ Active

### 6. Project Files Overview (Directories Only)
- **Task ID**: `Project Files Overview (Directories Only)`
- **Command**: PowerShell tree command for directories only
- **Description**: Project directory structure without individual files
- **When to Use**: Quick project layout overview, directory structure review
- **Access Method**: Tasks: Run Task → "Project Files Overview (Directories Only)"
- **Expected Output**: Directory-only tree structure
- **Status**: ✅ Active

### 7. Project Status Check
- **Task ID**: `Project Status Check`
- **Command**: `powershell -File project-status.ps1 -Detailed`
- **Description**: Runs detailed project status check using PowerShell script
- **When to Use**: Comprehensive project health check, environment validation
- **Access Method**: Tasks: Run Task → "Project Status Check"
- **Expected Output**: Detailed project status report
- **Status**: ✅ Active

### 8. Setup Node.js Environment
- **Task ID**: `Setup Node.js Environment`
- **Command**: `powershell -File setup-nodejs.ps1`
- **Description**: Initializes Node.js environment setup
- **When to Use**: First-time setup, Node.js environment configuration
- **Access Method**: Tasks: Run Task → "Setup Node.js Environment"
- **Expected Output**: Node.js setup completion status
- **Status**: ✅ Active

### 9. Add Core Context (R)
- **Task ID**: `Add Core Context (R)`
- **Command**: `Rscript scripts/wrappers/run-add-core-context.R`
- **Description**: Loads core AI context using R wrapper script
- **When to Use**: AI context initialization, core context refresh
- **Access Method**: Tasks: Run Task → "Add Core Context (R)"
- **Expected Output**: Core context loaded confirmation
- **Status**: ✅ Active

### 10. Run flow.R
- **Task ID**: `Run flow.R`
- **Command**: `Rscript flow.R`
- **Description**: Executes the main project flow script
- **When to Use**: Run main project workflow, execute analysis pipeline
- **Access Method**: Tasks: Run Task → "Run flow.R"
- **Expected Output**: Flow execution results and status
- **Status**: ✅ Active

### 11. Test Silent Mini-EDA System
- **Task ID**: `Test Silent Mini-EDA System`
- **Command**: R script to test mini-EDA functionality
- **Description**: Tests the silent mini-EDA system with mtcars dataset
- **When to Use**: Verify EDA system functionality, system testing
- **Access Method**: Tasks: Run Task → "Test Silent Mini-EDA System"
- **Expected Output**: System operational confirmation
- **Status**: ✅ Active

## Task Categories

### Report Generation Tasks
- **Render EDA-3 Report (Quarto)**: HTML report generation from Quarto documents

### Environment & Setup Tasks
- **Check Quarto Availability**: Quarto CLI validation
- **Setup Node.js Environment**: Node.js environment initialization  
- **Project Status Check**: Comprehensive project health check

### Memory & Context Management Tasks
- **Memory System Status Check**: AI memory system file monitoring
- **Load Memory Functions (R)**: AI memory system initialization
- **Add Core Context (R)**: Core AI context loading

### Project Overview Tasks
- **Project Files Overview**: Complete project structure display
- **Project Files Overview (Directories Only)**: Directory-only structure display

### Analysis & Workflow Tasks
- **Run flow.R**: Main project workflow execution
- **Test Silent Mini-EDA System**: EDA system functionality testing

## Usage Patterns

### Common Workflow Triggers
- **"render eda report"** → Execute Render EDA-3 Report (Quarto) task
- **"check quarto"** → Execute Check Quarto Availability task
- **"memory status"** → Execute Memory System Status Check task
- **"load memory"** → Execute Load Memory Functions (R) task
- **"project overview"** → Execute Project Files Overview task
- **"check setup"** → Execute Project Status Check task
- **"setup node"** → Execute Setup Node.js Environment task
- **"add context"** → Execute Add Core Context (R) task
- **"run flow"** → Execute Run flow.R task
- **"test eda"** → Execute Test Silent Mini-EDA System task

### Task Naming Convention
- Tasks use kebab-case naming: `task-name-description`
- Task labels use Title Case: "Task Name Description"
- Group related tasks by category prefix when applicable

## Technical Implementation Notes

### PowerShell Command Structure
```powershell
Rscript -e "source('scripts/update-copilot-context.R'); function_name()"
```

### Task Configuration Location
- **File**: `.vscode/tasks.json`
- **Schema**: VS Code Task 2.0.0
- **Shell**: PowerShell (Windows default)

### Error Handling
- Tasks should include appropriate error handling in the R functions
- Exit codes are captured and displayed in VS Code terminal
- Failed tasks show in the terminal with diagnostic information

## Maintenance

### Adding New Tasks
1. Define the task in `.vscode/tasks.json`
2. Test the task execution
3. Document the task in this reference file
4. Update project memory if significant workflow change

### Task Documentation Template
```markdown
### Task Name
- **Task ID**: `task-id`
- **Trigger Prompt**: "natural language trigger"
- **Command**: `command to execute`
- **Description**: What this task does and why
- **When to Use**: Specific use cases
- **Access Method**: How to run the task
- **Expected Output**: What should happen
- **Created**: Date
- **Status**: ✅ Active | ⚠️ Deprecated | ❌ Broken
```

## Integration with AI Workflow

### Context Refresh Automation
The Load Core Context task specifically supports the AI collaboration workflow by:
- Ensuring consistent AI context across team members
- Reducing manual context management overhead
- Providing reliable starting point for AI interactions
- Supporting the project's context management system defined in `scripts/update-copilot-context.R`

### Natural Language Triggers
Tasks are designed to respond to natural language prompts that team members might naturally use:
- "load core context" → Context management
- "refresh setup" → (future) Setup validation
- "run analysis" → (future) Analysis execution

## Version History

### v1.0 (August 8, 2025)
- Initial creation with Load Core Context task
- Established documentation pattern
- Created task reference system

---

**Last Updated**: October 1, 2025  
**Maintained By**: Project Team  
**Related Files**: 
- `.vscode/tasks.json` - Task definitions (11 active tasks)
- `scripts/wrappers/` - R wrapper scripts for task execution
- `project-status.ps1` - Project health check script
- `setup-nodejs.ps1` - Node.js environment setup script
