# ==============================================================================
# Dynamic Context Builder for AI Support System
# ==============================================================================
# 
# This script automates the process of dynamically building AI context in 
# .github/copilot-instructions.md with the contents of foundational project files. 
# It allows users to quickly refresh the AI context by typing: add_to_instructions("glossary", "mission", ...)
#
# Author: GitHub Copilot (with human analyst)
# Created: 2025-07-16
# Updated: 2025-11-08 - Configuration-driven paths for portability
# Location: ai/scripts/dynamic-context-builder.R

# Load configuration utilities
if (file.exists("ai/scripts/ai-config-utils.R")) {
  source("ai/scripts/ai-config-utils.R")
} else if (file.exists("./ai/scripts/ai-config-utils.R")) {
  source("./ai/scripts/ai-config-utils.R")
}

# ==============================================================================
# 3-SECTION CONTEXT MANAGEMENT SYSTEM
# ==============================================================================
# Section 1: Core AI Instructions (from ai/core/base-instructions.md - manually edited in copilot-instructions.md)
# Section 2: Active Persona (from ai/personas/*.md - loaded verbatim on activation)
# Section 3: Additional Context (A) default per persona OR B) manually added via add_context_file())

# DEPRECATED OLD SYSTEM - DO NOT USE
# The following function is retained temporarily for backwards compatibility
# Use the new 3-section system instead (see below)
update_copilot_instructions_DEPRECATED <- function(file_list) {
  # Map friendly names to actual file paths (configuration-driven)
  file_map <- get_file_map()
  
  # Add agent persona if one is active
  active_persona_file <- get_active_persona_file()
  if (!is.null(active_persona_file)) {
    file_map[["agent-persona"]] <- active_persona_file
  }
  
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
    file_map <- get_file_map()
    
    # Add agent persona if one is active
    active_persona_file <- get_active_persona_file()
    if (!is.null(active_persona_file)) {
      file_map[["agent-persona"]] <- active_persona_file
    }
    for (alias in names(file_map)) {
      exists_marker <- if (file.exists(file_map[[alias]])) "✓" else "✗"
      message("  ", exists_marker, " ", alias, " -> ", file_map[[alias]])
    }
    message("\nUsage: add_to_instructions('mission', 'method', 'glossary')")
  } else {
    update_copilot_instructions(file_list)
  }
}

# Quick alias for common combinations
add_core_context <- function() {
  add_to_instructions("mission")
}

add_full_context <- function() {
  add_to_instructions("mission", "method", "glossary")
}

# Books of Ukraine specific context combinations
add_data_context <- function() {
  add_to_instructions("cache-manifest", "pipeline")
}

add_memory_context <- function() {
  add_to_instructions("memory-hub", "memory-human", "memory-ai")
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

# Helper operator for string repetition
`%r%` <- function(str, times) paste(rep(str, times), collapse = "")

# Quick context scan and refresh - triggered by keyphrase
context_refresh <- function() {
  message("🔍 DYNAMIC CONTEXT SCAN")
  message(paste(rep("=", 50), collapse = ""))
  
  # Check current persona
  current_persona <- get_current_persona()
  message("🎭 Active persona: ", current_persona)
  
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

  message("\n🎭 PERSONA MANAGEMENT (Dynamic):")
  message("👤  Load persona: set_persona('path/to/persona.md', 'name')")
  message("📋  List personas: list_personas()")
  message("🔧  Quick switches: activate_developer() [DEFAULT], activate_project_manager(), activate_casenote_analyst()")
  message("🔄  Deactivate: deactivate_persona()")
  
  message("\n🚀 QUICK REFRESH OPTIONS:")
  message("1️⃣  Core context: add_core_context()")
  message("2️⃣  Data context: add_data_context()")  
  message("3️⃣  Memory context: add_memory_context()")
  message("4️⃣  Full context: add_full_context()")
  message("5️⃣  Custom phase: suggest_context('phase')")
  message("🗑️  Reset: remove_all_dynamic_instructions()")
  message("\n🔧 TROUBLESHOOTING & ANALYSIS:")
  message("📊  Check CACHE status: check_cache_manifest()")
  message("🔍  Full project analysis: analyze_project_status()")
  message("💡  Get command help: get_command_help()")
  message("\n💡 Or specify custom files: add_to_instructions('file1', 'file2')")
}

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
  file_map <- get_file_map()
  
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
    message("  🧠 'memory' - Focus on project memory and documentation")
    message("\nUsage: suggest_context('data-setup')")
    return()
  }
  
  suggestions <- switch(analysis_phase,
    "data-setup" = c("pipeline", "cache-manifest", "input-manifest"),
    "exploration" = c("mission", "method", "glossary"),
    "modeling" = c("mission", "method", "semiology", "fides"),
    "memory" = c("memory-hub", "memory-human", "memory-ai"),
    c("mission", "method")
  )
  
  message("💡 Suggested context for '", analysis_phase, "' phase:")
  message("   add_to_instructions(", paste0('"', paste(suggestions, collapse='", "'), '"'), ")")
  
  # Auto-load option
  if (interactive()) {
    response <- readline("🤖 Load this context automatically? (y/n): ")
    if (tolower(trimws(response)) %in% c("y", "yes")) {
      do.call(add_to_instructions, as.list(suggestions))
    }
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
# 3-SECTION CONTEXT MANAGEMENT SYSTEM
# ==============================================================================

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
  cat("├─ add_memory_context()      │ Load memory-focused context (memory-hub, memory-human, memory-ai)\n")
  cat("├─ add_full_context()        │ Load comprehensive context set\n")
  cat("├─ suggest_context('phase')  │ Smart context suggestions by analysis phase\n")
  cat("├─ add_to_instructions()     │ Manual context loading with custom file selection\n")
  cat("├─ remove_all_dynamic_instructions() │ Reset/clear all dynamic context\n")
  cat("├─ validate_context()        │ Check if loaded context files are current\n")
  cat("├─ check_context_size()      │ Monitor context file size and performance impact\n")
  cat("└─ check_cache_manifest()    │ Verify manual CACHE manifest presence (no auto-update)\n")
  
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
# PERSONA MANAGEMENT SYSTEM
# ==============================================================================

# Get the currently active persona file path (configuration-driven)
get_active_persona_file <- function() {
  persona_config <- "./.copilot-persona"
  
  if (file.exists(persona_config)) {
    config_lines <- readLines(persona_config, warn = FALSE)
    # Look for a line starting with "file:"
    file_line <- config_lines[grepl("^file:", config_lines)]
    if (length(file_line) > 0) {
      persona_file <- trimws(gsub("^file:", "", file_line[1]))
      if (file.exists(persona_file)) {
        return(persona_file)
      }
    }
  }
  
  # Default: no agent persona active
  return(NULL)
}

# Get current persona info
get_current_persona <- function() {
  persona_config <- "./.copilot-persona"
  
  if (file.exists(persona_config)) {
    config_lines <- readLines(persona_config, warn = FALSE)
    
    # Extract persona name
    name_line <- config_lines[grepl("^name:", config_lines)]
    persona_name <- if (length(name_line) > 0) {
      trimws(gsub("^name:", "", name_line[1]))
    } else {
      "unnamed-persona"
    }
    
    return(persona_name)
  }
  
  return("default")
}

# Set current persona with flexible file path
set_persona <- function(persona_file_path, persona_name = NULL, additional_context = c("mission", "method")) {
  persona_config <- "./.copilot-persona"
  
  # Validate persona file exists
  if (!file.exists(persona_file_path)) {
    message("❌ Persona file not found: ", persona_file_path)
    return(invisible(FALSE))
  }
  
  # Auto-generate persona name if not provided
  if (is.null(persona_name)) {
    persona_name <- tools::file_path_sans_ext(basename(persona_file_path))
    persona_name <- gsub("system-prompt-|prompt-", "", persona_name)
  }
  
  # Create persona configuration
  config_content <- c(
    paste("name:", persona_name),
    paste("file:", persona_file_path),
    paste("created:", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
    paste("additional_context:", paste(additional_context, collapse = ", "))
  )
  
  writeLines(config_content, persona_config)
  
  # Load the persona context
  context_components <- c("agent-persona", additional_context)
  
  message("🎭 Activating persona: ", persona_name)
  message("📁 Persona file: ", persona_file_path)
  message("📚 Loading context: ", paste(context_components, collapse = ", "))
  
  # Load the context
  do.call(add_to_instructions, as.list(context_components))
  
  message("✅ Persona activated: ", persona_name)
  return(invisible(TRUE))
}

# Show available personas and current status
list_personas <- function(scan_directory = NULL) {
  current <- get_current_persona()
  current_file <- get_active_persona_file()
  
  message("🎭 PERSONA SYSTEM STATUS")
  message("=" %r% 50)
  
  if (!is.null(current_file)) {
    message("🎯 ACTIVE PERSONA: ", current)
    message("   File: ", current_file)
    message("   Status: ✅ Loaded")
  } else {
    message("🎯 ACTIVE PERSONA: default (no agent persona loaded)")
    message("   Status: 🔄 Using general context only")
  }
  
  message("")
  message("📁 DISCOVERED PERSONA FILES:")
  
  # Scan for personas in the dedicated personas directory (configuration-driven)
  config <- read_ai_config()
  personas_dir <- config$personas_dir
  legacy_dirs <- c(
    "./analysis/eda-2-casenote/",
    config$ai_dir,
    "./guides/",
    if (!is.null(scan_directory)) scan_directory
  )
  
  found_personas <- c()
  
  # First, scan the main personas directory
  if (dir.exists(personas_dir)) {
    # Look for .md files (excluding README and guide files)
    all_files <- list.files(personas_dir, 
      pattern = "\\.md$", 
      full.names = TRUE, recursive = FALSE
    )
    
    # Filter out README and guide files
    persona_files <- all_files[!grepl("README|guide", basename(all_files), ignore.case = TRUE)]
    
    for (file in persona_files) {
      persona_name <- tools::file_path_sans_ext(basename(file))
      
      active_marker <- if (identical(file, current_file)) " (ACTIVE)" else ""
      message("   🤖 ", persona_name, active_marker)
      message("      📁 ", file)
      
      found_personas <- c(found_personas, file)
    }
  }
  
  # Then scan legacy directories for any remaining personas
  for (dir in legacy_dirs) {
    if (dir.exists(dir)) {
      # Look for system-prompt-*.md, prompt-*.md, or *-persona.md files
      persona_files <- list.files(dir, 
        pattern = "(system-prompt-.*\\.md|prompt-.*\\.md|.*-persona\\.md)", 
        full.names = TRUE, recursive = FALSE
      )
      
      for (file in persona_files) {
        persona_name <- tools::file_path_sans_ext(basename(file))
        persona_name <- gsub("system-prompt-|prompt-|-persona", "", persona_name)
        
        active_marker <- if (identical(file, current_file)) " (ACTIVE)" else ""
        message("   🤖 ", persona_name, " [LEGACY]", active_marker)
        message("      📁 ", file)
        
        found_personas <- c(found_personas, file)
      }
    }
  }
  
  if (length(found_personas) == 0) {
    message("   📭 No persona files found in standard locations")
  }
  
  message("")
  message("💡 USAGE:")
  message("   set_persona('path/to/persona-file.md', 'optional-name')")
  message("   activate_casenote_analyst()  # Quick shortcut")
  message("   deactivate_persona()         # Switch back to default")
  message("   list_personas('custom/dir')  # Scan specific directory")
}

# Deactivate current persona (return to default)
deactivate_persona <- function() {
  persona_config <- "./.copilot-persona"
  
  if (file.exists(persona_config)) {
    file.remove(persona_config)
    message("🎭 Persona deactivated - returning to default context")
    
    # Load default context
    add_to_instructions("mission", "method")
    return(invisible(TRUE))
  } else {
    message("ℹ️ No active persona to deactivate")
    return(invisible(FALSE))
  }
}

# ==============================================================================
# ENHANCED 3-SECTION CONTEXT MANAGEMENT SYSTEM
# ==============================================================================

# Section structure for copilot-instructions.md:
# Section 1: General Instructions (static)
# Section 2: Active Persona (dynamic)  
# Section 3: Additional Context (dynamic)

# Get file mapping for context resolution (configuration-driven)
get_file_map <- function() {
  config <- read_ai_config()
  
  list(
    "project/mission" = file.path(config$project_dir, "mission.md"), 
    "project/method" = file.path(config$project_dir, "method.md"),
    "project/glossary" = file.path(config$project_dir, "glossary.md"),
    "mission" = file.path(config$project_dir, "mission.md"),  # Legacy alias
    "method" = file.path(config$project_dir, "method.md"),    # Legacy alias  
    "glossary" = file.path(config$project_dir, "glossary.md"), # Legacy alias
    "semiology" = "./philosophy/semiology.md",
    "pipeline" = "./pipeline.md",
    "handoff" = "./analysis/handoff.md",
    "memory-hub" = file.path(config$memory_dir, "memory-hub.md"),
    "memory-human" = file.path(config$memory_dir, "memory-human.md"),
    "memory-ai" = file.path(config$memory_dir, "memory-ai.md"),
    "input-manifest" = "./data-public/metadata/INPUT-manifest.md",
    "ua-admin-manifest" = "./data-public/metadata/ua-admin-manifest.md"
  )
}

# Resolve file path using file map or direct path
resolve_file_path <- function(file_key, file_map) {
  if (file_key %in% names(file_map)) {
    return(file_map[[file_key]])
  } else {
    # If not in map, assume it's a direct file path
    return(file_key)
  }
}

# Generate context overview header
generate_context_overview <- function(persona_name, additional_context, 
                                     section1_kb, section1_tokens,
                                     section2_kb, section2_tokens,
                                     section3_kb, section3_tokens,
                                     total_kb, total_tokens) {
  
  # Generate compact overview with token estimates (more relevant for prompt limits)
  overview <- c(
    "<!-- CONTEXT OVERVIEW -->",
    paste0("Total size: ", sprintf("%4.1f", total_kb), " KB (~", format(total_tokens, big.mark = ","), " tokens)"),
    paste0("- 1: Core AI Onboarding  | ", sprintf("%3.1f", section1_kb), " KB (~", format(section1_tokens, big.mark = ","), " tokens)"),
    paste0("- 2: Active Persona: ", if (!is.null(persona_name) && persona_name != "") tools::toTitleCase(gsub("-", " ", persona_name)) else "None", " | ", sprintf("%3.1f", section2_kb), " KB (~", format(section2_tokens, big.mark = ","), " tokens)"),
    paste0("- 3: Additional Context     | ", sprintf("%3s", if (section3_kb == 0) "0" else sprintf("%.1f", section3_kb)), " KB (~", format(section3_tokens, big.mark = ","), " tokens)")
  )
  
  # Add detailed component breakdown if Section 3 has content
  if (!is.null(additional_context) && length(additional_context) > 0) {
    # Get persona default context for comparison
    persona_configs <- list(
      "developer" = c(),
      "project-manager" = c("project/mission", "project/method", "project/glossary"), 
      "casenote-analyst" = c()
    )
    
    default_for_persona <- if (!is.null(persona_name)) persona_configs[[persona_name]] else c()
    
    # Add component details
    for (i in seq_along(additional_context)) {
      file_map <- get_file_map()
      resolved_path <- resolve_file_path(additional_context[i], file_map)
      
      if (file.exists(resolved_path)) {
        # Calculate individual file metrics
        file_lines <- readLines(resolved_path, warn = FALSE)
        file_text <- paste(file_lines, collapse = "\n")
        file_chars <- nchar(file_text, type = "chars")
        # Rough token estimate: ~4 chars per token for English text
        file_tokens <- round(file_chars / 4)
        file_kb <- round(file_chars / 1024, 1)
        
        # Check if this component is default for current persona
        is_default <- additional_context[i] %in% default_for_persona
        default_marker <- if (is_default) " (default)" else ""
        
        # Add component line with token estimate
        overview <- c(overview, 
                     paste0("  -- ", additional_context[i], default_marker, "  | ", 
                           sprintf("%3.1f", file_kb), " KB (~", 
                           format(file_tokens, big.mark = ","), " tokens)"))
      }
    }
  }
  
  overview <- c(overview, "")
  
  # Add management commands
  overview <- c(overview,
                "## 🔧 Management Commands",
                "",
                "```r",
                "# View current status",
                "show_context_status()",
                "",
                "# Switch personas", 
                "activate_developer()         # Technical focus (minimal context)",
                "activate_project_manager()   # Strategic oversight (full project context)",
                "activate_casenote_analyst()  # Domain expertise (specialized context)",
                "",
                "# Manage additional context",
                "add_context_file('path/to/file.md')     # Add context file",
                "remove_context_file('path/to/file.md')  # Remove context file", 
                "list_available_md_files('pattern')     # Discover available files",
                "```",
                "",
                "---",
                ""
  )
  
  return(overview)
}

# Available personas with their context loading configurations (configuration-driven)
get_persona_configs <- function() {
  config <- read_ai_config()
  
  list(
    "default" = list(
      file = get_persona_path("default.md"),
      default_context = c()  # No default additional context
    ),
    "developer" = list(
      file = get_persona_path("developer.md"),
      default_context = c()  # No default additional context
    ),
    "data-engineer" = list(
      file = get_persona_path("data-engineer.md"),
      default_context = c()  # No default additional context for focused data work
    ),
    "research-scientist" = list(
      file = get_persona_path("research-scientist.md"),
      default_context = c()  # No default additional context for focused analytical work
    ),
    "devops-engineer" = list(
      file = get_persona_path("devops-engineer.md"),
      default_context = c()  # No default additional context for focused operational work
    ),
    "frontend-architect" = list(
      file = get_persona_path("frontend-architect.md"),
      default_context = c()  # No default additional context for focused visualization work
    ),
    "project-manager" = list(
      file = get_persona_path("project-manager.md"), 
      default_context = c("project/mission", "project/method", "project/glossary")
    ),
    "casenote-analyst" = list(
      file = get_persona_path("casenote-analyst.md"),
      default_context = c()  # No default additional context
    ),
    "prompt-engineer" = list(
      file = get_persona_path("prompt-engineer.md"),
      default_context = c()  # Minimal context for focused prompt work
    ),
    "reporter" = list(
      file = get_persona_path("reporter.md"),
      default_context = c()  # On-demand context loading as needed
    )
  )
}

# Get general instructions (Section 1) - static content
get_general_instructions <- function() {
  c(
    "<!-- SECTION 1: CORE AI INSTRUCTIONS -->",
    "",
    "# AI Assistant Core Instructions",
    "",
    "You are an expert AI programming assistant working with a user in a research and development environment. Your role is to provide sophisticated assistance while maintaining the highest standards of academic rigor and technical excellence.",
    "",
    "## 🎯 Core Principles",
    "",
    "- **Evidence-Based Reasoning**: Anchor all recommendations in established methodologies and best practices",
    "- **Contextual Awareness**: Adapt your approach based on the current project context and user needs",
    "- **Collaborative Excellence**: Work as a strategic partner, not just a code generator",
    "- **Quality Focus**: Prioritize correctness, maintainability, and reproducibility in all outputs",
    "",
    "## 🧠 Project Memory & Intent Detection",
    "",
    "**ALWAYS MONITOR** conversations for signs of creative intent, design decisions, or planning language. When detected, **proactively offer** to capture in project memory:",
    "",
    "- **Intent Markers**: \"TODO\", \"next step\", \"plan to\", \"should\", \"need to\", \"want to\", \"thinking about\"",
    "- **Decision Language**: \"decided\", \"chose\", \"because\", \"rationale\", \"strategy\", \"approach\"",
    "- **Uncertainty**: \"consider\", \"maybe\", \"perhaps\", \"not sure\", \"thinking\", \"wondering\"",
    "- **Future Work**: \"later\", \"eventually\", \"after this\", \"once we\", \"then we'll\"",
    "",
    "**When You Detect These**: Ask \"Should I capture this intention/decision in the project memory?\" and offer to use available memory management functions.",
    "",
    "## 🤖 Context & Automation Management",
    "",
    "**KEYPHRASE TRIGGERS**:",
    "- \"**context refresh**\" → Provide status and context refresh options",
    "- \"**scan context**\" → Same as above",
    "- \"**switch persona**\" → Show persona switching options",
    "- When discussing new project areas → Suggest relevant context loading",
    "",
    "## 🎭 Dynamic AI System",
    "",
    "This project uses a dynamic AI assistant system with three key components:",
    "",
    "1. **Core Instructions** (this section): Universal behavioral guidelines",
    "2. **Active Persona** (Section 2): Specialized expertise and focus area",
    "3. **Additional Context** (Section 3): Project-specific knowledge and resources",
    "",
    "The active persona in Section 2 defines your specialized expertise and approach. Additional context in Section 3 provides relevant background knowledge. Work within these parameters while maintaining the core principles above.",
    "",
    "## 📋 Response Guidelines",
    "",
    "- **Clarity**: Provide clear, actionable guidance appropriate to the user's expertise level",
    "- **Completeness**: Address the full scope of requests while staying focused",
    "- **Options**: Offer multiple approaches when appropriate (\"Would you like a diagram?\", \"Should I show the code?\")",
    "- **Traceability**: Surface uncertainties with evidence and suggest verification approaches",
    "- **Tool Usage**: Leverage available tools effectively rather than providing manual instructions",
    "- **Context Awareness**: Reference project-specific configurations and standards when relevant",
    "",
    "## 🚫 Boundaries & Constraints",
    "",
    "- Avoid speculation beyond defined project scope or available evidence",
    "- If conflicts arise between different information sources, pause and seek clarification",
    "- Maintain consistency with the active persona defined in Section 2",
    "- Respect the project's established methodologies and frameworks",
    ""
  )
}

# Build 3-section copilot instructions with context overview
build_3_section_instructions <- function(persona_name = NULL, additional_context = NULL) {
  instructions_path <- ".github/copilot-instructions.md"
  
  # Build all sections first to calculate sizes
  section1_content <- get_general_instructions()
  section2_content <- c()
  section3_content <- c()
  
  # Section 2: Active Persona (if specified)
  if (!is.null(persona_name) && persona_name != "") {
    persona_configs <- get_persona_configs()
    
    if (persona_name %in% names(persona_configs)) {
      persona_file <- persona_configs[[persona_name]]$file
    } else {
      # Handle custom persona files
      persona_file <- persona_name
    }
    
    if (file.exists(persona_file)) {
      section2_content <- c(
        "<!-- SECTION 2: ACTIVE PERSONA -->\n",
        paste0("# Section 2: Active Persona - ", tools::toTitleCase(gsub("-", " ", persona_name))),
        "",
        paste0("**Currently active persona:** ", persona_name),
        "",
        paste0("### ", tools::toTitleCase(gsub("-", " ", persona_name)), " (from `", persona_file, "`)"),
        "",
        readLines(persona_file, warn = FALSE),
        ""
      )
    }
  }
  
  # Section 3: Additional Context (if specified)
  if (!is.null(additional_context) && length(additional_context) > 0) {
    section3_content <- c(
      "<!-- SECTION 3: ADDITIONAL CONTEXT -->\n",
      "# Section 3: Additional Context",
      ""
    )
    
    file_map <- get_file_map()
    
    for (context_item in additional_context) {
      resolved_path <- resolve_file_path(context_item, file_map)
      
      if (file.exists(resolved_path)) {
        context_file_content <- readLines(resolved_path, warn = FALSE)
        section3_content <- c(section3_content,
                             paste0("### ", tools::toTitleCase(gsub("[/-]", " ", context_item)), " (from `", resolved_path, "`)"),
                             "",
                             context_file_content,
                             "")
      } else {
        message("⚠️  Context file not found: ", context_item, " (resolved to: ", resolved_path, ")")
      }
    }
  }
  
  # Calculate section sizes with token estimates
  section1_chars <- sum(nchar(section1_content, type = "chars"))
  section1_kb <- round(section1_chars / 1024, 1)
  section1_tokens <- round(section1_chars / 4)  # ~4 chars per token
  
  section2_chars <- sum(nchar(section2_content, type = "chars"))
  section2_kb <- round(section2_chars / 1024, 1)
  section2_tokens <- round(section2_chars / 4)
  
  section3_chars <- sum(nchar(section3_content, type = "chars"))
  section3_kb <- round(section3_chars / 1024, 1)  
  section3_tokens <- round(section3_chars / 4)
  
  total_chars <- section1_chars + section2_chars + section3_chars
  total_kb <- round(total_chars / 1024, 1)
  total_tokens <- section1_tokens + section2_tokens + section3_tokens
  
  # Generate context overview header
  context_overview <- generate_context_overview(
    persona_name, additional_context,
    section1_kb, section1_tokens,
    section2_kb, section2_tokens, 
    section3_kb, section3_tokens,
    total_kb, total_tokens
  )
  
  # Combine all content with overview header
  content <- c(context_overview, section1_content)
  
  # Add Section 2 content if present
  if (length(section2_content) > 0) {
    content <- c(content, section2_content)
  }
  
  # Add Section 3 content if present  
  if (length(section3_content) > 0) {
    content <- c(content, section3_content)
  }
  
  # Add footer marker
  content <- c(content, "<!-- END DYNAMIC CONTENT -->")
  
  return(content)
}

# Set persona with defaults - new primary function
set_persona_with_defaults <- function(persona_name) {
  persona_configs <- get_persona_configs()
  
  if (!persona_name %in% names(persona_configs)) {
    stop("Unknown persona: ", persona_name, ". Available personas: ", paste(names(persona_configs), collapse = ", "))
  }
  
  config <- persona_configs[[persona_name]]
  
  message("🎭 Setting persona: ", persona_name)
  message("📁 Persona file: ", config$file)
  
  if (length(config$default_context) > 0) {
    message("📚 Loading default context: ", paste(config$default_context, collapse = ", "))
    additional_context <- config$default_context
  } else {
    message("📚 No default context for this persona")
    additional_context <- NULL
  }
  
  # Build and write the 3-section instructions
  content <- build_3_section_instructions(persona_name, additional_context)
  instructions_path <- ".github/copilot-instructions.md"
  
  writeLines(content, instructions_path)
  
  if (length(content) > 0 && !endsWith(content[length(content)], "\n")) {
    cat("\n", file = instructions_path, append = TRUE)
  }
  
  message("✅ Persona activated: ", persona_name)
  message("📄 Total lines in updated file: ", length(content))
  
  return(invisible(TRUE))
}

# Add context file to Section 3
add_context_file <- function(file_path, section_name = NULL) {
  # Read current instructions
  instructions_path <- ".github/copilot-instructions.md"
  
  if (!file.exists(instructions_path)) {
    stop("Instructions file not found. Please set a persona first.")
  }
  
  current_content <- readLines(instructions_path, warn = FALSE)
  
  # Find current persona
  persona_line <- current_content[grepl("\\*\\*Currently active persona:\\*\\*", current_content)]
  if (length(persona_line) == 0) {
    stop("No active persona found. Please set a persona first.")
  }
  
  current_persona <- gsub(".*Currently active persona:\\*\\* ", "", persona_line)
  
  # Get current additional context
  section3_start <- which(grepl("<!-- SECTION 3: ADDITIONAL CONTEXT -->", current_content))
  end_marker <- which(grepl("<!-- END DYNAMIC CONTENT -->", current_content))
  
  current_additional_context <- c()
  if (length(section3_start) > 0 && length(end_marker) > 0) {
    # Extract existing context files from Section 3
    section3_content <- current_content[(section3_start[1]+1):(end_marker[1]-1)]
    context_headers <- section3_content[grepl("^### .* \\(from `.*`\\)$", section3_content)]
    
    for (header in context_headers) {
      # Extract file path from header
      file_match <- regmatches(header, regexpr("\\(from `.*`\\)", header))
      if (length(file_match) > 0) {
        current_file <- gsub("\\(from `|`\\)", "", file_match)
        # Convert back to context key if possible
        file_map <- get_file_map()
        context_key <- names(file_map)[file_map == current_file]
        if (length(context_key) > 0) {
          current_additional_context <- c(current_additional_context, context_key[1])
        } else {
          current_additional_context <- c(current_additional_context, current_file)
        }
      }
    }
  }
  
  # Resolve the new file path
  file_map <- get_file_map()
  resolved_path <- resolve_file_path(file_path, file_map)
  
  if (!file.exists(resolved_path)) {
    stop("File not found: ", file_path, " (resolved to: ", resolved_path, ")")
  }
  
  # Add the new context file
  new_additional_context <- unique(c(current_additional_context, file_path))
  
  # Rebuild instructions with new context
  content <- build_3_section_instructions(current_persona, new_additional_context)
  writeLines(content, instructions_path)
  
  if (length(content) > 0 && !endsWith(content[length(content)], "\n")) {
    cat("\n", file = instructions_path, append = TRUE)
  }
  
  message("✅ Added context file: ", file_path)
  message("📄 Total lines in updated file: ", length(content))
  
  return(invisible(TRUE))
}

# Remove context file from Section 3
remove_context_file <- function(file_path) {
  # Similar implementation to add_context_file but removes instead
  instructions_path <- ".github/copilot-instructions.md"
  
  if (!file.exists(instructions_path)) {
    stop("Instructions file not found.")
  }
  
  current_content <- readLines(instructions_path, warn = FALSE)
  
  # Find current persona
  persona_line <- current_content[grepl("\\*\\*Currently active persona:\\*\\*", current_content)]
  if (length(persona_line) == 0) {
    stop("No active persona found.")
  }
  
  current_persona <- gsub(".*Currently active persona:\\*\\* ", "", persona_line)
  
  # Get current additional context and remove the specified file
  section3_start <- which(grepl("<!-- SECTION 3: ADDITIONAL CONTEXT -->", current_content))
  end_marker <- which(grepl("<!-- END DYNAMIC CONTENT -->", current_content))
  
  current_additional_context <- c()
  if (length(section3_start) > 0 && length(end_marker) > 0) {
    section3_content <- current_content[(section3_start[1]+1):(end_marker[1]-1)]
    context_headers <- section3_content[grepl("^### .* \\(from `.*`\\)$", section3_content)]
    
    for (header in context_headers) {
      file_match <- regmatches(header, regexpr("\\(from `.*`\\)", header))
      if (length(file_match) > 0) {
        current_file <- gsub("\\(from `|`\\)", "", file_match)
        file_map <- get_file_map()
        context_key <- names(file_map)[file_map == current_file]
        if (length(context_key) > 0) {
          current_additional_context <- c(current_additional_context, context_key[1])
        } else {
          current_additional_context <- c(current_additional_context, current_file)
        }
      }
    }
  }
  
  # Remove the specified file
  new_additional_context <- current_additional_context[current_additional_context != file_path]
  
  # Rebuild instructions
  content <- build_3_section_instructions(current_persona, new_additional_context)
  writeLines(content, instructions_path)
  
  if (length(content) > 0 && !endsWith(content[length(content)], "\n")) {
    cat("\n", file = instructions_path, append = TRUE)
  }
  
  message("✅ Removed context file: ", file_path)
  message("📄 Total lines in updated file: ", length(content))
  
  return(invisible(TRUE))
}

# List all available .md files in repository
list_available_md_files <- function(pattern = NULL) {
  all_md_files <- list.files(".", pattern = "\\.md$", recursive = TRUE, full.names = FALSE)
  
  # Filter out some system files
  filtered_files <- all_md_files[!grepl("node_modules|.git", all_md_files)]
  
  if (!is.null(pattern)) {
    filtered_files <- filtered_files[grepl(pattern, filtered_files, ignore.case = TRUE)]
  }
  
  message("📁 Available .md files in repository:")
  for (i in seq_along(filtered_files)) {
    message(sprintf("  %2d. %s", i, filtered_files[i]))
  }
  
  return(invisible(filtered_files))
}

# Show current context status
show_context_status <- function() {
  instructions_path <- ".github/copilot-instructions.md"
  
  if (!file.exists(instructions_path)) {
    message("❌ No context file found")
    return(invisible(NULL))
  }
  
  content <- readLines(instructions_path, warn = FALSE)
  
  message("📋 CURRENT CONTEXT STATUS")
  message(paste(rep("=", 50), collapse = ""))
  
  # Section 1 is always present
  message("📄 Section 1: General Instructions (static)")
  
  # Check for active persona
  persona_line <- content[grepl("\\*\\*Currently active persona:\\*\\*", content)]
  if (length(persona_line) > 0) {
    current_persona <- gsub(".*Currently active persona:\\*\\* ", "", persona_line)
    message("🎭 Section 2: Active Persona - ", current_persona)
  } else {
    message("🎭 Section 2: No active persona")
  }
  
  # Check for additional context
  section3_start <- which(grepl("<!-- SECTION 3: ADDITIONAL CONTEXT -->", content))
  if (length(section3_start) > 0) {
    end_marker <- which(grepl("<!-- END DYNAMIC CONTENT -->", content))
    section3_content <- content[(section3_start[1]+1):(end_marker[1]-1)]
    context_headers <- section3_content[grepl("^### .* \\(from `.*`\\)$", section3_content)]
    
    if (length(context_headers) > 0) {
      message("📚 Section 3: Additional Context (", length(context_headers), " files)")
      for (header in context_headers) {
        file_match <- regmatches(header, regexpr("\\(from `.*`\\)", header))
        if (length(file_match) > 0) {
          file_path <- gsub("\\(from `|`\\)", "", file_match)
          message("  - ", file_path)
        }
      }
    } else {
      message("📚 Section 3: No additional context")
    }
  } else {
    message("📚 Section 3: No additional context")
  }
  
  message("📊 Total file size: ", round(file.size(instructions_path)/1024, 1), " KB")
  message("📊 Total lines: ", length(content))
  
  return(invisible(TRUE))
}

# Quick persona switching shortcuts (updated to use new system)
activate_casenote_analyst <- function() {
  set_persona_with_defaults("casenote-analyst")
}

activate_developer <- function() {
  set_persona_with_defaults("developer")
}

activate_project_manager <- function() {
  set_persona_with_defaults("project-manager")
}

activate_prompt_engineer <- function() {
  set_persona_with_defaults("prompt-engineer")
}

# Generic persona loader for any file
load_persona_from_file <- function(file_path, persona_name = NULL) {
  set_persona(file_path, persona_name)
}

# ==============================================================================
# FILE CHANGE LOGGING FUNCTION
# ==============================================================================

# Log file changes to logbook with timestamp, user, and change description
log_file_change <- function(file_path, change_description = NULL) {
  config <- read_ai_config()
  logbook_path <- file.path(config$memory_dir, "memory-human.md")
  
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
      "# memory-human.md\n\n",
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
if (file.exists("./scripts/ai-memory-functions-core.R")) {
  source("./scripts/ai-memory-functions-core.R")
} else if (file.exists("./scripts/ai-memory-functions.R")) {
  source("./scripts/ai-memory-functions.R")
}

# Auto-export functions for easy access
if (!exists("copilot_context_initialized")) {
  cat("🤖 Copilot Context Management System Loaded\n")
  
  # Auto-load Developer persona as default
  if (!file.exists("./.copilot-persona")) {
    cat("🔧 Auto-loading default Developer persona...\n")
    activate_developer()
  }
  
  cat("📚 Available functions:\n")
  cat("  - analyze_project_status() # 🆕 COMPREHENSIVE project analysis + recommendations\n")
  cat("  - context_refresh()     # Quick status + refresh options\n")
  cat("  - add_core_context()    # mission, method\n")
  cat("  - add_data_context()    # cache-manifest, pipeline\n")
  cat("  - add_memory_context()  # memory-hub, memory-human, memory-ai\n")
  cat("  - add_full_context()    # comprehensive set\n")
  cat("  - suggest_context()     # smart suggestions by phase\n")
  cat("  - add_to_instructions() # manual component selection\n")
  cat("  - remove_all_dynamic_instructions() # reset dynamic content\n")
  cat("  - check_cache_manifest()   # 🆕 Check CACHE manifest status & update if needed\n")
  cat("🎭 PERSONA SYSTEM (Dynamic):\n")
  cat("  - list_personas()       # 🆕 Show available persona files & status\n")
  cat("  - set_persona('file.md', 'name') # 🆕 Load any persona file\n")
  cat("  - get_current_persona() # 🆕 Check active persona\n")
  cat("  - deactivate_persona()  # 🆕 Return to default context\n")
  cat("  - activate_casenote_analyst() # 🆕 Quick shortcut\n")
  cat("  - activate_developer()        # 🆕 Default developer persona\n")
  cat("  - activate_project_manager()  # 🆕 Strategic project oversight\n")
  cat("  - load_persona_from_file()    # 🆕 Generic persona loader\n")
  cat("🧠 MEMORY SYSTEM:\n")
  cat("  - ai_memory_check()     # 🧠 Project memory & intent detection\n")
  cat("  - memory_status()       # Quick memory status\n")
  cat("  - log_file_change()     # 📝 Log file modifications to logbook\n")
  cat("  - log_change()          # 📝 Short alias for log_file_change()\n")
  cat("  - get_command_help('cmd') # 🆕 Detailed help for any command\n")
  
  copilot_context_initialized <- TRUE
}
