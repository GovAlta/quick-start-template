# ==============================================================================
# Update Copilot Instructions Context
# ==============================================================================
# 
# This script automates the process of updating .github/copilot-instructions.md
# with the contents of foundational project files. It allows analysts to quickly
# refresh the AI context by typing: add_to_instructions("glossary", "mission", ...)
#
# Author: GitHub Copilot (with human analyst)
# Created: 2025-07-16
# Updated: 2025-07-25 - Added KOG functionality and improvements

update_copilot_instructions <- function(file_list) {
  # Map friendly names to actual file paths (SDA-specific)
  file_map <- list(
    "onboarding-ai" = "./ai/onboarding-ai.md",
    "mission" = "./ai/mission.md", 
    "method" = "./ai/method.md",
    "glossary" = "./ai/glossary.md",
    "semiology" = "./ai/semiology.md",
    "pipeline" = "./pipeline.md",
    "research-request" = "./data-private/raw/research_request.md",
    "rdb-manifest" = "./ai/RDB-manifest.md",
    "cache-manifest" = "./ai/CACHE-manifest.md",
    "fides" = "./ai/FIDES.md",
    "logbook" = "./ai/logbook.md"
  )
  
  instructions_path <- ".github/copilot-instructions.md"
  
  # Check if instructions file exists
  if (!file.exists(instructions_path)) {
    stop("Copilot instructions file not found at: ", instructions_path)
  }
  
  # Read the current copilot instructions
  current_content <- readLines(instructions_path, warn = FALSE)
  
  # Find the dynamic content section markers
  start_marker <- which(grepl("<!-- DYNAMIC CONTENT START -->", current_content))
  end_marker <- which(grepl("<!-- DYNAMIC CONTENT END -->", current_content))
  
  if (length(start_marker) == 0 || length(end_marker) == 0) {
    stop("Dynamic content markers not found in copilot instructions. Please add:\n<!-- DYNAMIC CONTENT START -->\n<!-- DYNAMIC CONTENT END -->")
  }
  
  
  # Build new content section with summary
  component_list <- paste(file_list, collapse=", ")
  new_content <- c(
    "<!-- DYNAMIC CONTENT START -->",
    "",
    paste("**Currently loaded components:**", component_list),
    ""
  )
  
  for (file_name in file_list) {
    if (file_name %in% names(file_map)) {
      file_path <- file_map[[file_name]]
      if (file.exists(file_path)) {
        file_content <- readLines(file_path, warn = FALSE)
        new_content <- c(
          new_content,
          paste0("### ", tools::toTitleCase(gsub("-", " ", file_name)), " (from `", file_path, "`)"),
          "",
          file_content,
          ""
        )
        message("✓ Added: ", file_path)
      } else {
        warning("✗ File not found: ", file_path)
      }
    } else {
      warning("✗ Unknown file alias: ", file_name, ". Available: ", paste(names(file_map), collapse=", "))
    }
  }
  
  # Don't add the closing marker here - we'll use the existing one
  
  # Replace the section (including both markers)
  updated_content <- c(
    current_content[1:(start_marker-1)],
    new_content,
    current_content[end_marker:length(current_content)]
  )
  
  # Write back
  writeLines(updated_content, instructions_path)
  
  # Ensure file ends with newline to prevent warnings
  if (length(updated_content) > 0 && !endsWith(updated_content[length(updated_content)], "\n")) {
    cat("\n", file = instructions_path, append = TRUE)
  }
  
  message("🔄 Updated .github/copilot-instructions.md with: ", paste(file_list, collapse=", "))
  message("📄 Total lines in updated file: ", length(updated_content))
}

# Convenience function for easy calling
add_to_instructions <- function(...) {
  file_list <- c(...)
  if (length(file_list) == 0) {
    message("Available file aliases:")
    file_map <- list(
      "onboarding-ai" = "./ai/onboarding-ai.md",
      "mission" = "./ai/mission.md", 
      "method" = "./ai/method.md",
      "glossary" = "./ai/glossary.md",
      "semiology" = "./ai/semiology.md",
      "pipeline" = "./pipeline.md",
      "research-request" = "./data-private/raw/research_request.md",
      "rdb-manifest" = "./ai/RDB-manifest.md",
      "cache-manifest" = "./ai/CACHE-manifest.md",
      "fides" = "./ai/FIDES.md",
      "logbook" = "./ai/logbook.md"
    )
    for (alias in names(file_map)) {
      exists_marker <- if (file.exists(file_map[[alias]])) "✓" else "✗"
      message("  ", exists_marker, " ", alias, " -> ", file_map[[alias]])
    }
    message("\nUsage: add_to_instructions('onboarding-ai','mission', 'glossary')")
  } else {
    update_copilot_instructions(file_list)
  }
}

# Quick alias for common combinations
add_core_context <- function() {
  add_to_instructions("onboarding-ai", "mission", "method")
}

add_full_context <- function() {
  add_to_instructions("onboarding-ai", "mission", "method", "glossary", "pipeline")
}

# SDA-specific context combinations
add_data_context <- function() {
  add_to_instructions("rdb-manifest", "cache-manifest", "pipeline")
}

add_compass_context <- function() {
  add_to_instructions("logbook")
}

remove_all_dynamic_instructions <- function() {
  instructions_path <- ".github/copilot-instructions.md"
  
  # Check if instructions file exists
  if (!file.exists(instructions_path)) {
    stop("Copilot instructions file not found at: ", instructions_path)
  }
  
  # Read the current copilot instructions
  current_content <- readLines(instructions_path, warn = FALSE)
  
  # Find the dynamic content section markers
  start_marker <- which(grepl("<!-- DYNAMIC CONTENT START -->", current_content))
  end_marker <- which(grepl("<!-- DYNAMIC CONTENT END -->", current_content))
  
  if (length(start_marker) == 0 || length(end_marker) == 0) {
    stop("Dynamic content markers not found in copilot instructions. Please add:\n<!-- DYNAMIC CONTENT START -->\n<!-- DYNAMIC CONTENT END -->")
  }
  
  # Create new content with just the markers and empty space between
  new_content <- c(
    "<!-- DYNAMIC CONTENT START -->",
    "",
    "<!-- DYNAMIC CONTENT END -->"
  )
  
  # Replace the section (including both markers)
  updated_content <- c(
    current_content[1:(start_marker-1)],
    new_content,
    current_content[(end_marker+1):length(current_content)]
  )
  
  # Write back
  writeLines(updated_content, instructions_path)
  
  # Ensure file ends with newline to prevent warnings
  if (length(updated_content) > 0 && !endsWith(updated_content[length(updated_content)], "\n")) {
    cat("\n", file = instructions_path, append = TRUE)
  }
  
  message("🗑️ Removed all dynamic content from .github/copilot-instructions.md")
  message("📄 Total lines in updated file: ", length(updated_content))
}

# ==============================================================================
# CONTEXT MANAGEMENT COMMANDS
# ==============================================================================

# ==============================================================================
# CONTEXT MANAGEMENT COMMANDS
# ==============================================================================

# Helper operator for string repetition
`%r%` <- function(str, times) paste(rep(str, times), collapse = "")

# Quick context scan and refresh - triggered by keyphrase
context_refresh <- function() {
  message("🔍 DYNAMIC CONTEXT SCAN")
  message(paste(rep("=", 50), collapse = ""))
  
  # Check current context
  instructions_path <- ".github/copilot-instructions.md"
  
  if (!file.exists(instructions_path)) {
    message("❌ Copilot instructions file not found")
    return()
  }
  
  content <- readLines(instructions_path, warn = FALSE)
  component_line <- content[grepl("\\*\\*Currently loaded components:\\*\\*", content)]
  
  if (length(component_line) == 0) {
    message("📋 Current status: NO dynamic content loaded")
  } else {
    components <- gsub(".*Currently loaded components:\\*\\* ", "", component_line)
    message("📋 Currently loaded: ", components)
  }
  
  # Check file freshness
  validate_context()
  check_context_size()
  
  # Quick project structure check
  required_dirs <- c("data-private", "data-public", "manipulation", "analysis", "scripts", "ai")
  missing_dirs <- required_dirs[!sapply(required_dirs, dir.exists)]
  
  if (length(missing_dirs) == 0) {
    message("✅ Project structure validated")
  } else {
    message("⚠️  Project structure issues detected:")
    message("    Missing directories: ", paste(missing_dirs, collapse = ", "))
  }

  message("\n🚀 QUICK REFRESH OPTIONS:")
  message("1️⃣  Core context: add_core_context()")
  message("2️⃣  Data context: add_data_context()")  
  message("3️⃣  Compass context: add_compass_context()")
  message("4️⃣  Full context: add_full_context()")
  message("5️⃣  Custom phase: suggest_context('phase')")
  message("🗑️  Reset: remove_all_dynamic_instructions()")
  message("\n🔧 TROUBLESHOOTING & ANALYSIS:")
  message("�  Check CACHE status: check_cache_manifest()")
  message("�  Full project analysis: analyze_project_status()")
  message("�  Get command help: get_command_help()")
  message("\n💡 Or specify custom files: add_to_instructions('file1', 'file2')")
}

# ==============================================================================
# PROPOSED IMPROVEMENTS
# ==============================================================================

# 1. Context Validation - Check if loaded content is still current
validate_context <- function() {
  instructions_path <- ".github/copilot-instructions.md"
  
  if (!file.exists(instructions_path)) {
    message("❌ Copilot instructions file not found")
    return(FALSE)
  }
  
  content <- readLines(instructions_path, warn = FALSE)
  
  # Find loaded components
  component_line <- content[grepl("\\*\\*Currently loaded components:\\*\\*", content)]
  
  if (length(component_line) == 0) {
    message("ℹ️ No dynamic content currently loaded")
    return(TRUE)
  }
  
  # Extract component list
  components <- gsub(".*Currently loaded components:\\*\\* ", "", component_line)
  component_list <- trimws(strsplit(components, ",")[[1]])
  
  # Map to file paths and check if files have been modified recently
  file_map <- list(
    "onboarding-ai" = "./ai/onboarding-ai.md",
    "mission" = "./ai/mission.md", 
    "method" = "./ai/method.md",
    "glossary" = "./ai/glossary.md",
    "semiology" = "./ai/semiology.md",
    "pipeline" = "./pipeline.md",
    "research-request" = "./data-private/raw/research_request.md",
    "rdb-manifest" = "./ai/RDB-manifest.md",
    "cache-manifest" = "./ai/CACHE-manifest.md",
    "fides" = "./ai/FIDES.md",
    "logbook" = "./ai/logbook.md"
  )
  
  message("🔍 Checking context freshness...")
  stale_files <- c()
  
  for (component in component_list) {
    if (component %in% names(file_map)) {
      file_path <- file_map[[component]]
      if (file.exists(file_path)) {
        file_time <- file.mtime(file_path)
        instructions_time <- file.mtime(instructions_path)
        if (file_time > instructions_time) {
          stale_files <- c(stale_files, component)
        }
      }
    }
  }
  
  if (length(stale_files) > 0) {
    message("⚠️ These components have been updated since last context load:")
    for (file in stale_files) {
      message("  📝 ", file)
    }
    message("💡 Consider running: add_to_instructions(", paste0('"', paste(component_list, collapse='", "'), '"'), ")")
    return(FALSE)
  } else {
    message("✅ All loaded components are current")
    return(TRUE)
  }
}

# 2. Smart Context Management - Auto-suggest relevant context based on analysis phase
suggest_context <- function(analysis_phase = NULL) {
  if (is.null(analysis_phase)) {
    message("🎯 Available analysis phases:")
    message("  📊 'data-setup' - Focus on data assembly and pipeline")
    message("  🔍 'exploration' - Focus on EDA and initial findings") 
    message("  📈 'modeling' - Focus on analysis and reporting")
    message("  🚀 'compass' - Focus on compass_Assessment_ID updates")
    message("\nUsage: suggest_context('data-setup')")
    return()
  }
  
  suggestions <- switch(analysis_phase,
    "data-setup" = c("onboarding-ai", "pipeline", "rdb-manifest", "cache-manifest"),
    "exploration" = c("onboarding-ai", "mission", "method", "glossary"),
    "modeling" = c("mission", "method", "semiology", "fides"),
    "compass" = c("logbook", "rdb-manifest"),
    c("onboarding-ai", "mission", "method")
  )
  
  message("💡 Suggested context for '", analysis_phase, "' phase:")
  message("   add_to_instructions(", paste0('"', paste(suggestions, collapse='", "'), '"'), ")")
  
  # Auto-load option
  response <- readline("🤖 Load this context automatically? (y/n): ")
  if (tolower(trimws(response)) %in% c("y", "yes")) {
    do.call(add_to_instructions, as.list(suggestions))
  }
}

# 3. Context Size Management - Warn about large contexts
check_context_size <- function() {
  instructions_path <- ".github/copilot-instructions.md"
  
  if (!file.exists(instructions_path)) {
    return()
  }
  
  file_size <- file.size(instructions_path)
  line_count <- length(readLines(instructions_path, warn = FALSE))
  
  message("📊 Context file stats:")
  message("  📄 Size: ", round(file_size / 1024, 1), " KB")
  message("  📝 Lines: ", line_count)
  
  # Multi-tier warnings for better guidance
  if (file_size > 100000) { # ~100KB - Critical
    message("🚨 CRITICAL: Context file is very large (>100KB) - high risk of truncation")
    message("    Recommend: remove_all_dynamic_instructions() and use focused contexts")
  } else if (file_size > 50000) { # ~50KB - Warning
    message("⚠️ WARNING: Context file is getting large (>50KB) - may impact performance")
    message("    Recommend: consider using focused contexts for better efficiency")
  } else if (file_size > 25000) { # ~25KB - Caution
    message("💡 NOTICE: Context file approaching optimal size (>25KB)")
    message("    Consider: focused contexts for complex analysis tasks")
  } else {
    message("✅ Context file size is optimal for AI focus")
  }
}

# ==============================================================================
# CACHE MANIFEST MANAGEMENT
# ==============================================================================

# Function to check and update CACHE-manifest.md based on actual data outputs
check_cache_manifest <- function(update_if_needed = TRUE) {
  cache_manifest_path <- "./ai/CACHE-manifest.md"
  
  message("🔍 Analyzing data outputs for CACHE manifest...")
  
  # Check if CACHE manifest exists and get its timestamp
  manifest_exists <- file.exists(cache_manifest_path)
  manifest_timestamp <- if (manifest_exists) file.mtime(cache_manifest_path) else NULL
  
  message("📋 CACHE Manifest Status:")
  if (manifest_exists) {
    message("   ✅ File exists: ", cache_manifest_path)
    message("   📅 Last updated: ", format(manifest_timestamp, "%Y-%m-%d %H:%M:%S"))
  } else {
    message("   ❌ File missing: ", cache_manifest_path)
  }
  
  # Check for common data directories
  data_paths <- c(
    "data-private/derived",
    "data-private/derived/manipulation", 
    "data-public/derived"
  )
  
  existing_data <- c()
  for (path in data_paths) {
    if (dir.exists(path)) {
      files <- list.files(path, pattern = "\\.(rds|csv|xlsx)$", recursive = TRUE, full.names = TRUE)
      existing_data <- c(existing_data, files)
    }
  }
  
  message("\n📊 Data File Analysis:")
  message("   📁 Total data files found: ", length(existing_data))
  
  if (length(existing_data) == 0) {
    message("   ❌ No data files found. Run data processing scripts first.")
    return(list(status = "no_data", datasets = 0, manifest_current = FALSE))
  }
  
  # Check which files are newer than manifest
  new_files <- c()
  if (manifest_exists) {
    for (file in existing_data) {
      if (file.mtime(file) > manifest_timestamp) {
        new_files <- c(new_files, file)
      }
    }
  }
  
  # Determine if update is needed
  needs_update <- !manifest_exists || length(new_files) > 0
  
  if (!needs_update) {
    message("\n🎉 CACHE manifest is up-to-date! No action needed.")
    return(list(status = "current", datasets = length(existing_data), manifest_current = TRUE))
  }
  
  if (!update_if_needed) {
    message("\n💡 CACHE manifest needs updating but update_if_needed = FALSE")
    message("    Run check_cache_manifest(update_if_needed = TRUE) to update")
    return(list(status = "needs_update", datasets = length(existing_data), manifest_current = FALSE))
  }
  
  message("\n🔄 Updating CACHE manifest...")
  
  # Create manifest content
  manifest_content <- c(
    "# CACHE Manifest",
    "",
    "This document serves as a comprehensive guide to the data structure and organization of the CACHE for this project.",
    "",
    "---",
    "",
    "## CACHE Overview",
    "",
    paste("**Last Updated**: ", Sys.Date(), " (", length(existing_data), " files)"),
    "",
    "## Data Files",
    ""
  )
  
  # Group files by directory
  for (path in data_paths) {
    if (dir.exists(path)) {
      files <- list.files(path, pattern = "\\.(rds|csv|xlsx)$", recursive = TRUE, full.names = TRUE)
      if (length(files) > 0) {
        manifest_content <- c(manifest_content,
          paste("### Files in", path),
          ""
        )
        
        for (file in files) {
          file_size <- round(file.size(file) / 1024, 1)
          file_date <- format(file.mtime(file), "%Y-%m-%d")
          rel_path <- gsub(paste0("^", path, "/"), "", file)
          
          manifest_content <- c(manifest_content,
            paste("- **", basename(file), "** (", file_size, " KB, ", file_date, ")")
          )
        }
        manifest_content <- c(manifest_content, "")
      }
    }
  }
  
  # Write the manifest
  writeLines(manifest_content, cache_manifest_path)
  
  message("✅ Updated CACHE-manifest.md")
  message("📊 Total files documented: ", length(existing_data))
  
  return(list(status = "updated", datasets = length(existing_data), manifest_current = TRUE))
}

# ==============================================================================
# PROJECT ANALYSIS & COMMAND OVERVIEW SYSTEM  
# ==============================================================================

# Helper operator for string repetition
`%r%` <- function(str, times) paste(rep(str, times), collapse = "")

# Comprehensive project analysis and command recommendations
analyze_project_status <- function() {
  cat("🔍 COMPREHENSIVE PROJECT ANALYSIS\n")
  cat("=" %r% 80, "\n")
  cat("Analyzing project memory, context, setup, and providing recommendations...\n\n")
  
  # === 1. PROJECT SETUP STATUS ===
  cat("📋 1. PROJECT SETUP STATUS\n")
  cat("-" %r% 40, "\n")
  
  # Basic project structure check
  required_dirs <- c("data-private", "data-public", "manipulation", "analysis", "scripts", "ai")
  required_files <- c("flow.R", "README.md")
  
  setup_ready <- TRUE
  missing_items <- c()
  
  for (dir in required_dirs) {
    if (!dir.exists(dir)) {
      setup_ready <- FALSE
      missing_items <- c(missing_items, paste("Directory:", dir))
    }
  }
  
  for (file in required_files) {
    if (!file.exists(file)) {
      setup_ready <- FALSE  
      missing_items <- c(missing_items, paste("File:", file))
    }
  }
  
  if (setup_ready) {
    cat("✅ Setup Status: READY\n")
  } else {
    cat("❌ Setup Status: ISSUES DETECTED\n")
    cat("   Missing items: ", length(missing_items), "\n")
    for (item in head(missing_items, 3)) {
      cat("   - ", item, "\n")
    }
    if (length(missing_items) > 3) {
      cat("   ... and ", length(missing_items) - 3, " more\n")
    }
  }
  
  # === 2. AI CONTEXT STATUS ===
  cat("\n📚 2. AI CONTEXT STATUS\n")
  cat("-" %r% 40, "\n")
  
  instructions_path <- ".github/copilot-instructions.md"
  component_line <- c()  # Initialize for later use
  
  if (file.exists(instructions_path)) {
    content <- readLines(instructions_path, warn = FALSE)
    component_line <- content[grepl("\\*\\*Currently loaded components:\\*\\*", content)]
    
    if (length(component_line) == 0) {
      cat("📄 Dynamic Context: NONE LOADED\n")
      cat("   🤖 Recommendation: Run add_core_context() to start\n")
    } else {
      components <- gsub(".*Currently loaded components:\\*\\* ", "", component_line)
      cat("📄 Dynamic Context: LOADED\n")
      cat("   Components: ", components, "\n")
      cat("   ✅ Status: CURRENT\n")
    }
    
    # Check file size
    file_size <- file.size(instructions_path)
    cat("   📊 Size: ", round(file_size / 1024, 1), " KB")
    if (file_size > 50000) {
      cat(" (⚠️  Large - may impact performance)")
    } else if (file_size > 25000) {
      cat(" (💡 Getting large - consider focused contexts)")
    } else {
      cat(" (✅ Optimal)")
    }
    cat("\n")
  } else {
    cat("❌ Copilot Instructions: NOT FOUND\n")
    cat("   🔧 Recommendation: Check repository structure\n")
  }
  
  # === 3. DATA STATUS ===
  cat("\n💾 3. DATA STATUS\n")
  cat("-" %r% 40, "\n")
  
  # Check for data files
  data_files <- c()
  data_dirs <- c("data-private/derived", "data-public/derived", "data-private/raw", "data-public/raw")
  
  for (dir in data_dirs) {
    if (dir.exists(dir)) {
      files <- list.files(dir, pattern = "\\.(rds|csv|xlsx)$", recursive = TRUE, full.names = TRUE)
      data_files <- c(data_files, files)
    }
  }
  
  cat("📊 Data Files: ", length(data_files), " found\n")
  
  if (length(data_files) == 0) {
    cat("   Status: NO DATA FILES\n")
    cat("   🚀 Recommendation: Run data processing scripts\n")
  } else {
    cat("   Status: DATA AVAILABLE\n")
    
    # Check data freshness
    if (length(data_files) > 0) {
      newest_data <- max(sapply(data_files, file.mtime))
      hours_old <- as.numeric(difftime(Sys.time(), newest_data, units = "hours"))
      
      if (hours_old > 24) {
        cat("   ⏰ Age: ", round(hours_old, 1), " hours old\n")
        cat("   💡 Consider refreshing if source data has changed\n")
      } else {
        cat("   ✅ Age: Recent (", round(hours_old, 1), " hours old)\n")
      }
    }
  }
  
  # === 4. ANALYSIS READINESS ===
  cat("\n📈 4. ANALYSIS READINESS\n")
  cat("-" %r% 40, "\n")
  
  analysis_ready <- setup_ready && length(data_files) > 0
  
  if (analysis_ready) {
    cat("🎯 Status: READY FOR ANALYSIS\n")
    cat("   Available data files: ", length(data_files), "\n")
    cat("   🚀 Next: Run analysis scripts or create new ones\n")
  } else {
    cat("⏳ Status: NOT READY\n")
    if (!setup_ready) {
      cat("   Blocker: Setup issues need resolution\n")
    }
    if (length(data_files) == 0) {
      cat("   Blocker: No data files available\n")
    }
  }
  
  # === 5. COMMAND REFERENCE ===
  cat("\n🛠️  5. AVAILABLE COMMANDS\n")
  cat("=" %r% 80, "\n")
  
  cat("\n📚 CONTEXT MANAGEMENT:\n")
  cat("├─ context_refresh()         │ Complete status scan + context options\n")
  cat("├─ add_core_context()        │ Load essential context (onboarding, mission, method)\n")
  cat("├─ add_data_context()        │ Load data-focused context (cache-manifest, pipeline)\n")
  cat("├─ add_compass_context()     │ Load compass-specific context (logbook)\n")
  cat("├─ add_full_context()        │ Load comprehensive context set\n")
  cat("├─ suggest_context('phase')  │ Smart context suggestions by analysis phase\n")
  cat("├─ add_to_instructions()     │ Manual context loading with custom file selection\n")
  cat("├─ remove_all_dynamic_instructions() │ Reset/clear all dynamic context\n")
  cat("├─ validate_context()        │ Check if loaded context files are current\n")
  cat("├─ check_context_size()      │ Monitor context file size and performance impact\n")
  cat("└─ check_cache_manifest()    │ Check CACHE manifest status and update if needed\n")
  
  cat("\n📊 PROJECT ANALYSIS:\n")
  cat("├─ analyze_project_status()  │ THIS COMMAND - Complete project analysis\n")
  cat("└─ get_command_help('cmd')   │ Detailed help for specific commands\n")
  
  # === 6. RECOMMENDATIONS ===
  cat("\n🎯 6. INTELLIGENT RECOMMENDATIONS\n")
  cat("=" %r% 80, "\n")
  
  recommendations <- c()
  
  # Setup recommendations
  if (!setup_ready) {
    recommendations <- c(recommendations, 
      "🔧 CRITICAL: Fix missing project structure items")
  }
  
  # Context recommendations
  if (length(component_line) == 0) {
    recommendations <- c(recommendations,
      "🤖 Start with core AI context → add_core_context()")
  }
  
  # Data recommendations
  if (length(data_files) == 0) {
    recommendations <- c(recommendations,
      "💾 Generate initial data → run data processing scripts")
  }
  
  # Analysis phase recommendations
  if (analysis_ready) {
    recommendations <- c(recommendations,
      "📈 Ready for analysis → suggest_context('exploration') or suggest_context('modeling')",
      "🎯 Run analysis workflows → source('flow.R')")
  }
  
  if (length(recommendations) > 0) {
    cat("Based on current status, recommended next steps:\n\n")
    for (i in seq_along(recommendations)) {
      cat(sprintf("%d. %s\n", i, recommendations[i]))
    }
  } else {
    cat("🎉 Excellent! Your project is in great shape.\n")
    cat("💡 Consider running suggest_context() for phase-specific optimizations.\n")
  }
  
  cat("\n" %r% 80, "\n")
  cat("💡 Pro tip: Save this analysis → capture.output(analyze_project_status())\n")
  cat("🔄 Re-run anytime to get updated status and recommendations\n")
  cat("=" %r% 80, "\n")
}

# Detailed command help system
get_command_help <- function(command_name = NULL) {
  help_info <- list(
    "analyze_project_status" = list(
      description = "Comprehensive analysis of project status with intelligent recommendations",
      usage = "analyze_project_status()",
      purpose = "Complete project health check with actionable next steps",
      when_to_use = "Project onboarding, regular health checks, when unsure what to do next"
    ),
    
    "context_refresh" = list(
      description = "Complete project status scan with context management options",
      usage = "context_refresh()",
      purpose = "One-stop command for project overview + context management options",
      when_to_use = "Regular project status checks, when starting work sessions"
    ),
    
    "add_core_context" = list(
      description = "Load essential AI context (onboarding, mission, method)",
      usage = "add_core_context()",
      purpose = "Provides AI with fundamental project understanding",
      when_to_use = "Starting analysis work, when AI needs project background"
    ),
    
    "check_cache_manifest" = list(
      description = "Check CACHE manifest status and update if needed",
      usage = "check_cache_manifest(update_if_needed = TRUE)",
      purpose = "Analyzes data files and maintains up-to-date CACHE documentation",
      when_to_use = "After data processing, when data files change, during project setup"
    )
  )
  
  if (is.null(command_name)) {
    cat("📖 AVAILABLE COMMANDS FOR DETAILED HELP:\n")
    cat("=" %r% 50, "\n")
    for (cmd in names(help_info)) {
      cat("• get_command_help('", cmd, "')\n", sep = "")
    }
    cat("\nUsage: get_command_help('command_name')\n")
    return()
  }
  
  if (!command_name %in% names(help_info)) {
    cat("❌ Command not found: ", command_name, "\n")
    cat("Available commands: ", paste(names(help_info), collapse = ", "), "\n")
    return()
  }
  
  info <- help_info[[command_name]]
  cat("📖 COMMAND HELP: ", toupper(command_name), "\n")
  cat("=" %r% 60, "\n")
  cat("Description: ", info$description, "\n")
  cat("Usage:       ", info$usage, "\n")
  cat("Purpose:     ", info$purpose, "\n")
  cat("When to use: ", info$when_to_use, "\n")
  cat("=" %r% 60, "\n")
}

# ==============================================================================
# FILE CHANGE LOGGING FUNCTION
# ==============================================================================

# Log file changes to logbook with timestamp, user, and change description
log_file_change <- function(file_path, change_description = NULL) {
  logbook_path <- "./ai/logbook.md"
  
  # Validate inputs
  if (missing(file_path)) {
    stop("❌ file_path is required. Usage: log_file_change('path/to/file.ext', 'description of changes')")
  }
  
  # Normalize file path (handle relative paths)
  if (!file.exists(file_path)) {
    # Try relative to project root
    alt_path <- file.path(".", file_path)
    if (file.exists(alt_path)) {
      file_path <- alt_path
    } else {
      stop("❌ File not found: ", file_path)
    }
  }
  
  # Get file information
  file_info <- file.info(file_path)
  file_name <- basename(file_path)
  file_ext <- tools::file_ext(file_path)
  mod_time <- format(file_info$mtime, "%Y-%m-%d %H:%M:%S")
  
  # Get user information (try multiple methods)
  user_name <- Sys.getenv("USERNAME", unset = Sys.getenv("USER", unset = "Unknown User"))
  
  # Create change description if not provided
  if (is.null(change_description)) {
    change_description <- paste("Modified", file_name)
  }
  
  # Create logbook entry
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  entry <- paste0(
    "\n## File Change Log - ", format(Sys.time(), "%Y-%m-%d"),
    "\n**File**: `", file_path, "`  ",
    "\n**Modified**: ", mod_time, "  ",
    "\n**Changed by**: ", user_name, "  ",
    "\n**Changes**: ", change_description, "  ",
    "\n**Logged**: ", timestamp, "\n"
  )
  
  # Check if logbook exists
  if (!file.exists(logbook_path)) {
    # Create basic logbook structure
    initial_content <- paste0(
      "# logbook.md\n\n",
      "## Project Logbook\n",
      "Use this to document key decisions, model revisions, and reasoning transitions across modalities.\n"
    )
    writeLines(initial_content, logbook_path)
    message("📝 Created new logbook at: ", logbook_path)
  }
  
  # Append the entry to logbook
  cat(entry, file = logbook_path, append = TRUE)
  
  # Provide user feedback
  message("📝 Logged change to logbook:")
  message("   File: ", file_name, " (", file_ext, ")")
  message("   User: ", user_name)
  message("   Time: ", mod_time)
  message("   Description: ", change_description)
  
  # Return the entry for potential further use
  invisible(entry)
}

# Convenience function with shorter name
log_change <- function(file_path, description = NULL) {
  log_file_change(file_path, description)
}

# ==============================================================================
# AI MEMORY SYSTEM INTEGRATION
# ==============================================================================

# Load AI Memory System
if (file.exists("./scripts/ai-memory-functions.R")) {
  source("./scripts/ai-memory-functions.R")
}

# Auto-export functions for easy access
if (!exists("copilot_context_initialized")) {
  cat("🤖 Copilot Context Management System Loaded\n")
  cat("📚 Available functions:\n")
  cat("  - analyze_project_status() # 🆕 COMPREHENSIVE project analysis + recommendations\n")
  cat("  - context_refresh()     # Quick status + refresh options\n")
  cat("  - add_core_context()    # onboarding-ai, mission, method\n")
  cat("  - add_data_context()    # rdb-manifest, cache-manifest, pipeline\n")
  cat("  - add_compass_context() # logbook\n")
  cat("  - add_full_context()    # comprehensive set\n")
  cat("  - suggest_context()     # smart suggestions by phase\n")
  cat("  - add_to_instructions() # manual component selection\n")
  cat("  - remove_all_dynamic_instructions() # reset dynamic content\n")
  cat("  - check_cache_manifest()   # 🆕 Check CACHE manifest status & update if needed\n")
  cat("  - ai_memory_check()     # 🧠 Project memory & intent detection\n")
  cat("  - memory_status()       # Quick memory status\n")
  cat("  - log_file_change()     # 📝 Log file modifications to logbook\n")
  cat("  - log_change()          # 📝 Short alias for log_file_change()\n")
  cat("  - get_command_help('cmd') # 🆕 Detailed help for any command\n")
  
  copilot_context_initialized <- TRUE
}
