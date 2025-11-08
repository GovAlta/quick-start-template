# Flow System Usage Guide

## Overview

The `flow.R` script orchestrates the execution of all data processing, analysis, and reporting tasks in the Books of Ukraine project. It has been updated to run all relevant scripts in the correct order.

## Pipeline Structure

The pipeline is organized into 4 phases:

### Phase 1: Ellis Data Pipeline (Multi-Stage Processing)
- **Stage 0**: `manipulation/0-ellis.R` - Core book data processing from local sources
- **Stage 1**: `manipulation/1-ellis-ua-admin.R` - Ukrainian administrative data integration
- **Stage 2**: `manipulation/2-ellis-extra.R` - **NEW** Modular custom data with bilingual support
- **Final Stage**: `manipulation/last-ellis.R` - Analysis-ready tables + CSV exports
- **🆕 Automatic CACHE manifest updates** - The system automatically updates data documentation

### Phase 2: Analysis Scripts  
- `analysis/eda-1/eda-1.R` - Exploratory data analysis script
- `analysis/Data-visualization/Data-visual.R` - Data visualization script
- `analysis/report-example-2/1-scribe.R` - Scribe script for analysis-ready data

### Phase 3: Reports & Documentation
- `analysis/eda-1/eda-1.qmd` - Main EDA report (Quarto)
- `analysis/Data-visualization/Data-visual.qmd` - Data visualization report (Quarto)
- `analysis/report-example-2/eda-1.qmd` - Analysis report example (Quarto)
- `analysis/analysis-templatization/README.qmd` - Documentation template

### Phase 4: Advanced Reports (Optional - Commented Out)
- Additional Quarto reports are available but commented out by default
- Uncomment lines in `ds_rail` to include them

## How to Run

### Option 1: Run the complete pipeline
```r
# From R console
source("flow.R")

# From command line  
Rscript flow.R
```

### Option 2: Check pipeline status first
```r
# Load the flow configuration
source("flow.R")

# 🆕 Check flow.R currency (NEW!)
check_flow_status()     # Quick check if flow.R is current
check_flow_currency()   # Detailed analysis of flow vs project scripts

# 🆕 Check CACHE manifest status (NEW!)
check_cache_manifest()  # Checks if data documentation is current

# Check which files exist
file_found <- sapply(ds_rail$path, file.exists)
missing_files <- ds_rail$path[!file_found]
if(length(missing_files) > 0) {
  cat("Missing files:\n")
  cat(paste(missing_files, collapse = "\n"))
}
```

## Requirements

### Essential packages (automatically loaded):
- `magrittr` - For pipe operations
- `dplyr`, `tidyr` - For data manipulation
- `DBI`, `RSQLite` - For database connectivity
- Standard R packages for analysis

### Optional packages (gracefully handled if missing):
- `purrr`, `rlang` - For advanced functional programming (falls back to base R)
- `config` - For configuration management (uses defaults if missing)
- `OuhscMunge` - For SQL operations (skips SQL steps if missing)
- `quarto` - For rendering .qmd files

## Data Access

The repository includes pre-processed SQLite databases in `data-private/derived/manipulation/SQLite/`. No external authentication is required.

To verify data access:

```r
# Test database connection
source("scripts/test-database-connection.R")
```

## Customizing the Pipeline

To modify which scripts run:

1. Open `flow.R`
2. Find the `ds_rail` tibble (around line 95)
3. Comment out unwanted steps with `#`
4. Add new steps following the pattern:
   ```r
   "run_r"   , "path/to/script.R",     # R scripts
   "run_qmd" , "path/to/report.qmd",   # Quarto reports
   "run_rmd" , "path/to/report.Rmd",   # R Markdown reports
   "run_sql" , "path/to/queries.sql"   # SQL files (if OuhscMunge available)
   ```

## Troubleshooting

### Common Issues:
1. **Database connection**: Run `scripts/test-database-connection.R` to verify
2. **Missing packages**: Install required packages or they'll be skipped gracefully
3. **File not found**: Check file paths in `ds_rail` are correct
4. **Data access**: Ensure the SQLite databases exist in `data-private/derived/`

### Logs:
- Interactive sessions: Output shown in console
- Non-interactive: Logs saved to `logs/` directory (if config available)

## File Structure Created

The pipeline creates the following data outputs:
- `data-private/derived/manipulation/` - Processed datasets

## 🆕 Flow.R Workflow Management

### What is Flow.R Currency Checking?
The flow currency system ensures that your `flow.R` workflow file stays synchronized with your actual project scripts. As you add, modify, or reorganize scripts, the flow management system can detect these changes and help update the workflow accordingly.

### Flow Management Commands

#### Check if flow.R is current:
```r
check_flow_status()      # Quick boolean check
check_flow_currency()    # Detailed analysis with recommendations
```

#### Update flow.R automatically:
```r
analyze_and_update_flow()  # Intelligent flow.R reconstruction
```

### What the system analyzes:
- **Script timestamps**: Identifies scripts newer than flow.R
- **Missing scripts**: Finds scripts not referenced in current flow.R
- **Project structure**: Scans manipulation/, analysis/, and scripts/ directories
- **File types**: Handles .R, .qmd, and .sql files appropriately

### Intelligent flow generation:
- **Automatic phasing**: Organizes scripts into logical phases (data prep, analysis, reports)
- **Description extraction**: Reads script comments to generate meaningful descriptions
- **Backup creation**: Always creates timestamped backups before changes
- **Syntax validation**: Ensures updated flow.R is syntactically correct

### When to use:
- After adding new analysis scripts
- When reorganizing project structure
- During team onboarding
- If flow.R execution fails due to missing scripts

### Example workflow:
```r
# Check current status
check_flow_currency()

# If updates needed:
analyze_and_update_flow()

# Verify the updated flow works:
safe_run_script("flow.R")
```

## 🆕 CACHE Manifest Management

### What is the CACHE Manifest?
The CACHE manifest (`data-public/metadata/CACHE-manifest-0.md`) is an automatically generated documentation file that describes all datasets created by the 0-ellis data processing script. It provides:
- Complete dataset inventory with descriptions
- File sizes and modification dates  
- Primary key structures and data sources
- SQLite database information

### Managing the CACHE Manifest

#### Check manifest status:
```r
check_cache_manifest()  # Shows status and updates if needed
```

#### Force update manifest:
```r
update_cache_manifest()  # Always updates regardless of status
```

#### What happens during updates:
- Scans all `ds_*.rds` files in manipulation folder
- Compares file timestamps with manifest timestamp
- Documents new datasets with 🆕 markers
- Updates logbook with change summary
- Creates comprehensive data documentation

#### When to run:
- After running `manipulation/0-ellis.R`
- When onboarding new team members
- Before major analysis work
- If datasets have been modified

The manifest is automatically integrated with the AI context system, so updated documentation immediately improves AI assistance quality.

## 📝 File Change Tracking

### What is File Change Tracking?
The project includes a file change logging system that helps teams track modifications across all project files. This creates an audit trail for collaboration and helps team members understand what changes were made and when.

### File Change Tracking Commands

#### Log changes to any file:
```r
log_file_change("path/to/file.ext", "description of changes")
log_change("file.ext", "description")  # Short alias
```

#### Examples:
```r
# After modifying an analysis script
log_change("analysis/eda-1/eda-1.R", "Added regional comparison visualizations")

# After updating a report
log_change("analysis/Data-visualization/Data-visual.qmd", "Fixed axis labels and added legends")

# After configuration changes
log_change("config.yml", "Updated database connection settings")
```

#### What gets logged:
- **File path and name**
- **Modification timestamp** (when file was actually changed)
- **User information** (who made the change)
- **Change description** (what was changed)
- **Log timestamp** (when the change was logged)

#### Output format in logbook:
```markdown
## File Change Log - 2025-08-02
**File**: `analysis/eda-1/eda-1.qmd`  
**Modified**: 2025-08-02 14:30:25  
**Changed by**: muaro  
**Changes**: Added regional analysis visualizations  
**Logged**: 2025-08-02 14:35:12
```

#### When to use:
- After making significant changes to any project file
- Before committing changes to version control
- When collaborating on team projects
- For important configuration or methodology changes
- To document decision-making process

#### Integration with workflow:
The file change tracking integrates with the entire project ecosystem:
- Changes are logged to `./ai/logbook.md` 
- Logbook is part of the AI context system
- Team members can quickly see recent changes
- Provides audit trail for quality assurance

#### Best practices:
- Log changes immediately after making them
- Use descriptive change descriptions
- Include the reasoning behind changes when significant
- Log both code and documentation changes
- `data-private/derived/manipulation/SQLite/` - SQLite database
- `data-private/derived/manipulation/CSV/` - CSV exports
- Various HTML reports in `analysis/` subdirectories
