# Command Usage Guide

A human-friendly guide to the main commands in this project, organized by how often you'll use them.

## 📊 Main Commands (Daily Use)

### `context_refresh()`

**What it does**: Instantly shows project status and refresh options
**When to use**: Start of work session, when you need quick overview

**Example**:
```r
context_refresh()
```
**Output**:
```
🧠 Project Memory Status: Last updated 2025-08-02
📁 Currently loaded: mission, method
🔄 Quick actions available: add_core_context(), memory_status()
```

### `log_change("file.R", "Added new visualization function")`

**What it does**: Tracks file changes in project logbook
**When to use**: After modifying any important file

**Example**:
```r
log_change("analysis/eda-1/eda-1.R", "Added regional comparison plots")
```
**Output**:
```
✅ Change logged for analysis/eda-1/eda-1.R
📝 Entry added to ai/logbook.md
```

### `ai_memory_check()`

**What it does**: Reviews and updates project memory
**When to use**: When making important decisions or planning

**Example**:
```r
ai_memory_check()
```
**Output**:
```
🔍 Scanning project for key decisions and intent...
💭 Found 3 new items to potentially capture
📋 Memory file ready for review
```

### `analyze_project_status()`

**What it does**: Complete project health check and navigation command
**When to use**: New team member onboarding, regular health checks, when unsure what to do next

**Example**:
```r
analyze_project_status()
```
**Output**:
```
✅ Setup Status: Environment validated
📚 AI Context Status: 3 components loaded
🧠 Project Memory Status: Up to date (2025-08-02)
💾 Data Status: 6 datasets available
📈 Analysis Readiness: Ready for work
🎯 Recommendations: Ready for EDA-3 development
```

### `project_setup_check()`

**What it does**: Comprehensive environment validation with detailed diagnostics
**When to use**: After fresh installation, when experiencing errors, troubleshooting

**Example**:
```r
project_setup_check()
```
**Output**:
```
✅ R packages: All required packages installed
✅ Project structure: All directories present
✅ Database access: Local databases available
⚠️ Data directories: Missing some derived data
💡 Check scripts/verify-data-access.R for database status
```

## 🔧 Regular Commands (Weekly Use)

### `memory_status()`

**What it does**: Shows what's currently loaded in AI context
**When to use**: Before starting complex analysis work

**Example**:
```r
memory_status()
```
**Output**:
```
Currently loaded components:
✅ mission (updated 2025-08-01)
✅ mission (updated 2025-07-30)
✅ method (updated 2025-08-02)
❌ Not loaded: dialects, semiology
```

### `add_core_context("filename")`

**What it does**: Loads specific AI context files
**When to use**: When switching to different project aspects

**Example**:
```r
add_core_context("semiology")
```
**Output**:
```
📂 Loading semiology.md into AI context...
✅ Added semiology component
🧠 Context refreshed with semiology content
```

### `add_data_context("dataset_name")`

**What it does**: Loads specific dataset information
**When to use**: Before analyzing particular datasets

**Example**:
```r
add_data_context("ds_language_long")
```
**Output**:
```
📊 Loading ds_language_long context...
✅ Dataset metadata added to context
📋 Structure: 145,234 rows, 4 columns
```

## 📋 Occasional Commands (Monthly Use)

### `add_to_instructions("new instruction")`

**What it does**: Updates AI instructions with new guidance
**When to use**: When establishing new project patterns

**Example**:
```r
add_to_instructions("Always include data source citations in visualizations")
```
**Output**:
```
📝 Instruction added to copilot-instructions.md
🔄 Dynamic content section updated
✅ AI context refreshed
```

### `log_file_change("path/to/file.R", "Description")`

**What it does**: Full file change logging with metadata
**When to use**: For detailed documentation of major changes

**Example**:
```r
log_file_change("manipulation/0-ellis.R", "Refactored data loading pipeline")
```
**Output**:
```
📁 File: manipulation/0-ellis.R
👤 Changed by: muaro
⏰ Modified: 2025-08-02 14:30:00
📝 Changes: Refactored data loading pipeline
✅ Logged: 2025-08-02 14:35:00
```

## 🎯 Pro Tips

- **Start each session** with `context_refresh()` to see current state
- **Log changes frequently** with `log_change()` for better collaboration
- **Use short commands** like `log_change()` instead of full `log_file_change()` for quick updates
- **Check memory status** before complex work to ensure right context is loaded
- **Type "context refresh"** in chat for instant automated scanning

## 📖 Quick Reference

| Command | Frequency | Purpose |
|---------|-----------|---------|
| `context_refresh()` | Daily | Project status overview |
| `log_change()` | Daily | Track file modifications |
| `ai_memory_check()` | Daily | Review project memory |
| `analyze_project_status()` | Daily | Complete project health check |
| `project_setup_check()` | Daily | Environment validation |
| `memory_status()` | Weekly | Check loaded context |
| `add_core_context()` | Weekly | Load specific context |
| `add_data_context()` | Occasional | Load dataset info |
| `add_to_instructions()` | Rare | Update AI guidance |

Remember: All commands are designed to enhance human-AI collaboration and project transparency. Use them to keep track of your analytical journey and help your AI assistant provide better support.
