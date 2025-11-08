# 🛠️ Complete Command Reference

## 🆕 NEW: Comprehensive Project Analysis

### `analyze_project_status()`
**The ultimate project health check and navigation command**

This new command provides:
- ✅ **Setup Status**: Environment validation with detailed diagnostics
- 📚 **AI Context Status**: Dynamic context loading status and freshness check
- 🧠 **Project Memory Status**: Memory system status and intent tracking
- 💾 **Data Status**: Processing pipeline status and data availability
- 📈 **Analysis Readiness**: Complete workflow readiness assessment
- 🎯 **Intelligent Recommendations**: Smart next steps based on current state
- 📖 **Complete Command Reference**: All available functions with descriptions

**When to use**: 
- New team member onboarding
- Regular project health checks
- When unsure what to do next
- Troubleshooting project issues

**Example output**: Complete 7-section analysis with actionable recommendations

---

## 🔧 Setup & Diagnostics Commands

### `project_setup_check()`
**Comprehensive environment validation with detailed diagnostics**
- Validates R packages, project structure, database access, data directories
- Provides detailed error messages and resolution suggestions
- Returns setup status object when `return_status = TRUE`

### `quick_setup_check()`
**Fast setup status check (returns TRUE/FALSE)**
- Lightweight validation for script automation
- Silent execution, returns boolean result only

### `safe_run_script('file.R')`
**Execute scripts with automatic setup validation**
- Automatically runs setup validation before script execution
- Prevents failures due to environment issues
- Perfect for new team members running scripts

---

## 📚 Context Management Commands

### `context_refresh()`
**Complete status scan with setup validation and context options**
- One-stop command for project overview
- Shows current context, setup status, and available actions
- Enhanced with setup validation warnings

### `add_core_context()`
**Load essential context (onboarding, mission, method)**
- Provides AI with fundamental project understanding
- Best starting point for new analysis work

### `add_data_context()`
**Load data-focused context (manifests, pipeline)**
- Optimized for data processing and manipulation tasks
- Includes data structure and pipeline documentation

### `add_compass_context()`
**Load compass-specific context (logbook)**
- Project-specific analytical context
- Includes decision history and analytical approaches

### `add_full_context()`
**Load comprehensive context set**
- Complete project context for complex tasks
- May impact performance due to size

### `suggest_context('phase')`
**Smart context suggestions by analysis phase**
- Available phases: 'exploration', 'modeling', 'reporting'
- Provides optimized context recommendations

### `add_to_instructions()`
**Manual context loading with custom file selection**
- Interactive file selection for custom contexts
- Advanced users can specify exact context needs

### `remove_all_dynamic_instructions()`
**Reset/clear all dynamic context**
- Clean slate for context management
- Removes all dynamic content from copilot instructions

### `validate_context()`
**Check if loaded context files are current**
- Identifies stale context that needs refreshing
- Helps maintain context accuracy

### `check_context_size()`
**Monitor context file size and performance impact**
- Prevents context bloat that could impact AI performance
- Provides optimization recommendations

### `check_cache_manifest()`
**Check presence of the manual CACHE manifest (automation deprecated)**
- Verifies that `data-public/metadata/CACHE-MANIFEST.md` exists
- Reports last modified timestamp
- Does NOT auto-generate or modify any files
- Returns simple status list (present/missing)

### `update_cache_manifest()` (deprecated)
**Deprecated: no longer writes or generates manifest**
- Retained only for backward compatibility
- Emits informative message and exits
- Use manual edit of `data-public/metadata/CACHE-MANIFEST.md`

---

## 🔄 Flow.R Management Commands

### `check_flow_currency(update_if_needed = TRUE)`
**🆕 Check if flow.R is current vs project scripts**
- Analyzes all R, .qmd, and .sql files in the project
- Compares script timestamps with flow.R timestamp
- Identifies scripts not referenced in flow.R
- Shows detailed status of newer/missing scripts
- Returns comprehensive analysis object

### `analyze_and_update_flow(backup = TRUE)`
**🆕 Intelligently analyze and update flow.R structure**
- Creates backup of current flow.R before changes
- Generates new ds_rail structure based on current project scripts
- Organizes scripts by phase (data preparation, analysis, reports)
- Automatically generates descriptions from script comments
- Validates syntax of updated flow.R

### `check_flow_status()`
**🆕 Quick flow.R status check**
- Lightweight version of check_flow_currency()
- Returns boolean status for script automation
- Perfect for automated workflow validation

---

## 🧠 Memory & Intelligence Commands

### `ai_memory_check()`
**Main AI memory function with intent detection**
- Comprehensive project memory analysis
- Detects creative intent and planning language
- Offers to capture important decisions and intentions

### `memory_status()`
**Quick project memory status overview**
- Shows memory age, size, and content overview
- Lightweight memory system check

### `generate_project_briefing()`
**Comprehensive project briefing generation**
- Complete project status and context summary
- Useful for handoffs and status reports

### `update_project_memory()`
**Manual project memory updates**
- Direct memory system updates
- For capturing specific decisions or changes

---

## 📝 File Change Tracking Commands

### `log_file_change('path/to/file.ext', 'description')`
**Log file modifications to project logbook**
- Records when file was modified and by whom
- Automatically captures user information from system environment
- Appends structured entries to `./ai/logbook.md`
- Creates logbook if it doesn't exist
- Handles both absolute and relative file paths
- Perfect for team collaboration and audit trails

**Example**: 
```r
log_file_change("analysis/eda-1/eda-1.qmd", "Added regional analysis visualizations")
```

**Output in logbook**:
```markdown
## File Change Log - 2025-08-02
**File**: `analysis/eda-1/eda-1.qmd`  
**Modified**: 2025-08-02 14:30:25  
**Changed by**: muaro  
**Changes**: Added regional analysis visualizations  
**Logged**: 2025-08-02 14:35:12
```

### `log_change('file.ext', 'description')`
**Short alias for log_file_change()**
- Convenient shorter command for frequent use
- Identical functionality to `log_file_change()`
- Saves typing for active development sessions

**When to use**:
- After making significant changes to any project file
- When modifying analysis scripts or reports
- For documenting configuration changes
- Before committing changes to version control
- When collaborating on team projects

---

## 📊 Analysis & Help Commands

### `analyze_project_status()`
**Complete project analysis with intelligent recommendations**
- **THIS IS THE FLAGSHIP COMMAND** - use when unsure what to do
- 7-section comprehensive analysis
- Intelligent next-step recommendations
- Perfect for onboarding and regular health checks

### `get_command_help('command_name')`
**Detailed help for specific commands**
- Available for all major commands
- Shows usage, purpose, and when to use
- Run without arguments to see all available help topics

---

## 🎯 Quick Reference by Use Case

### 👥 **New Team Member Onboarding**
1. `analyze_project_status()` - Get complete project overview
2. Fix any setup issues identified
3. `add_core_context()` - Load essential AI context
4. `safe_run_script('flow.R')` - Test complete workflow

### 📊 **Data Processing Work**
1. `quick_setup_check()` - Verify environment
2. `add_data_context()` - Load data-focused context
3. `safe_run_script('manipulation/0-ellis.R')` - Process data
4. `check_cache_manifest()` - Verify manual data manifest presence
5. `check_flow_currency()` - 🆕 Ensure workflow structure is current

### 🔄 **Workflow Management**
1. `check_flow_status()` - 🆕 Quick flow.R currency check
2. `analyze_and_update_flow()` - 🆕 Update flow.R with current scripts
3. `safe_run_script('flow.R')` - Execute complete workflow

### 📈 **Analysis Work**
1. `context_refresh()` - Check current status
2. `suggest_context('exploration')` or `suggest_context('modeling')`
3. Run analysis scripts with `safe_run_script()`

### 🔧 **Troubleshooting**
1. `analyze_project_status()` - Comprehensive diagnostics
2. `project_setup_check()` - Detailed setup validation
3. Follow specific recommendations provided

### 🧠 **Project Planning**
1. `ai_memory_check()` - Review project intentions
2. `analyze_project_status()` - Current state assessment
3. Update memory with `update_project_memory()` as needed

### 📝 **File Change Tracking**
1. `log_file_change('path/to/file.ext', 'description')` - Log file modifications to logbook
2. `log_change('file.ext', 'description')` - Short alias for file change logging

---

## 💡 Pro Tips

- **Start with `analyze_project_status()`** when in doubt - it provides comprehensive guidance
- Use `get_command_help('command_name')` for detailed information on any command
- The system detects setup issues automatically and provides specific solutions
- Context management is optimized for performance - stale contexts are automatically detected
- All commands are designed to be safe for new team members to use

---

**Last Updated**: August 1, 2025  
**System Version**: Enhanced with comprehensive analysis, intelligent recommendations, CACHE manifest management, and Flow.R workflow automation
