# ==============================================================================
# Dynamic Context Builder for AI Support System (3-Section Architecture)
# ==============================================================================
# 
# This script implements the 3-section context management system for building
# .github/copilot-instructions.md with a clear architecture:
#
# SECTION 1: Core AI Instructions (from ai/core/base-instructions.md)
#            Manually edited in copilot-instructions.md by humans
#
# SECTION 2: Active Persona (from ai/personas/*.md)
#            Loaded verbatim when persona is activated
#
# SECTION 3: Additional Context (project docs from ai/project/ or other .md files)
#            A) Auto-loaded as default for specific personas
#            B) Manually added via add_context_file() / remove_context_file()
#
# Author: GitHub Copilot (with human analyst)
# Created: 2025-07-16
# Updated: 2025-11-11 - Simplified to pure 3-section architecture
# Location: ai/scripts/dynamic-context-builder.R

# Load configuration utilities
if (file.exists("ai/scripts/ai-config-utils.R")) {
  source("ai/scripts/ai-config-utils.R")
} else if (file.exists("./ai/scripts/ai-config-utils.R")) {
  source("./ai/scripts/ai-config-utils.R")
}

# ==============================================================================
# CORE 3-SECTION SYSTEM FUNCTIONS
# ==============================================================================

# Get file mapping for context resolution (configuration-driven)
get_file_map <- function() {
  config <- read_ai_config()
  
  list(
    # Project context files (ai/project/)
    "project/mission" = file.path(config$project_dir, "mission.md"), 
    "project/method" = file.path(config$project_dir, "method.md"),
    "project/glossary" = file.path(config$project_dir, "glossary.md"),
      
    # Memory system files (ai/memory/)
    "memory-human" = file.path(config$memory_dir, "memory-human.md"),
    "memory-ai" = file.path(config$memory_dir, "memory-ai.md"),
    
    # Other project files (examples)
    "semiology" = "./philosophy/semiology.md",
    "input-manifest" = "./data-public/metadata/INPUT-manifest.md",
    "rdb-manifest" = "./data-public/metadata/RDB-manifest.md",
    "cache-manifest" = "./data-public/metadata/CACHE-manifest.md"  )
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

# Available personas with their default context configurations
get_persona_configs <- function() {
  config <- read_ai_config()
  
  list(
    "default" = list(
      file = get_persona_path("default.md"),
      default_context = c()
    ),
    "developer" = list(
      file = get_persona_path("developer.md"),
      default_context = c()
    ),
    "data-engineer" = list(
      file = get_persona_path("data-engineer.md"),
      default_context = c("cache-manifest","project/glossary")
    ),
    "research-scientist" = list(
      file = get_persona_path("research-scientist.md"),
      default_context = c()
    ),
    "devops-engineer" = list(
      file = get_persona_path("devops-engineer.md"),
      default_context = c()
    ),
    "frontend-architect" = list(
      file = get_persona_path("frontend-architect.md"),
      default_context = c()
    ),
    "project-manager" = list(
      file = get_persona_path("project-manager.md"), 
      default_context = c("project/mission", "project/method", "project/glossary")
    ),
    "prompt-engineer" = list(
      file = get_persona_path("prompt-engineer.md"),
      default_context = c()
    ),
    "reporter" = list(
      file = get_persona_path("reporter.md"),
      default_context = c()
    ),
    "grapher" = list(
      file = get_persona_path("grapher.md"),
      default_context = c("project/glossary", "project/mission", "project/method")
    )
  )
}

# Read Section 1 content from ai/core/base-instructions.md
get_general_instructions <- function() {
  config <- read_ai_config()
  base_instructions_path <- file.path(config$core_dir, "base-instructions.md")
  
  if (file.exists(base_instructions_path)) {
    content <- readLines(base_instructions_path, warn = FALSE)
    return(c("<!-- SECTION 1: CORE AI INSTRUCTIONS -->", "", content, ""))
  } else {
    warning("Base instructions file not found at: ", base_instructions_path)
    return(c(
      "<!-- SECTION 1: CORE AI INSTRUCTIONS -->",
      "",
      "# AI Assistant Core Instructions",
      "",
      "ERROR: Base instructions file not found at ", base_instructions_path,
      "Please create this file to define core AI behavioral guidelines.",
      ""
    ))
  }
}

# Generate context overview header with metrics
generate_context_overview <- function(persona_name, additional_context, 
                                     section1_kb, section1_tokens,
                                     section2_kb, section2_tokens,
                                     section3_kb, section3_tokens,
                                     total_kb, total_tokens) {
  
  overview <- c(
    "<!-- CONTEXT OVERVIEW -->",
    paste0("Total size: ", sprintf("%4.1f", total_kb), " KB (~", format(total_tokens, big.mark = ","), " tokens)"),
    paste0("- 1: Core AI Instructions  | ", sprintf("%3.1f", section1_kb), " KB (~", format(section1_tokens, big.mark = ","), " tokens)"),
    paste0("- 2: Active Persona: ", if (!is.null(persona_name) && persona_name != "") tools::toTitleCase(gsub("-", " ", persona_name)) else "None", " | ", sprintf("%3.1f", section2_kb), " KB (~", format(section2_tokens, big.mark = ","), " tokens)"),
    paste0("- 3: Additional Context     | ", sprintf("%3s", if (section3_kb == 0) "0" else sprintf("%.1f", section3_kb)), " KB (~", format(section3_tokens, big.mark = ","), " tokens)")
  )
  
  # Add component breakdown if Section 3 has content
  if (!is.null(additional_context) && length(additional_context) > 0) {
    persona_configs <- get_persona_configs()
    default_for_persona <- if (!is.null(persona_name)) persona_configs[[persona_name]]$default_context else c()
    
    for (i in seq_along(additional_context)) {
      file_map <- get_file_map()
      resolved_path <- resolve_file_path(additional_context[i], file_map)
      
      if (file.exists(resolved_path)) {
        file_lines <- readLines(resolved_path, warn = FALSE)
        file_text <- paste(file_lines, collapse = "\n")
        file_chars <- nchar(file_text, type = "chars")
        file_tokens <- round(file_chars / 4)  # ~4 chars per token
        file_kb <- round(file_chars / 1024, 1)
        
        is_default <- additional_context[i] %in% default_for_persona
        default_marker <- if (is_default) " (default)" else ""
        
        overview <- c(overview, 
                     paste0("  -- ", additional_context[i], default_marker, "  | ", 
                           sprintf("%3.1f", file_kb), " KB (~", 
                           format(file_tokens, big.mark = ","), " tokens)"))
      }
    }
  }
  
 
  return(overview)
}

# Build complete 3-section copilot instructions
build_3_section_instructions <- function(persona_name = NULL, additional_context = NULL) {
  instructions_path <- ".github/copilot-instructions.md"
  
  # Build all sections
  section1_content <- get_general_instructions()
  section2_content <- c()
  section3_content <- c()
  
  # Section 2: Active Persona
  if (!is.null(persona_name) && persona_name != "") {
    persona_configs <- get_persona_configs()
    
    if (persona_name %in% names(persona_configs)) {
      persona_file <- persona_configs[[persona_name]]$file
    } else {
      persona_file <- persona_name  # Assume it's a file path
    }
    
    if (file.exists(persona_file)) {
      section2_content <- c(
        "<!-- SECTION 2: ACTIVE PERSONA -->",
        "",
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
  
  # Section 3: Additional Context
  if (!is.null(additional_context) && length(additional_context) > 0) {
    section3_content <- c(
      "<!-- SECTION 3: ADDITIONAL CONTEXT -->",
      "",
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
  
  # Calculate metrics
  section1_chars <- sum(nchar(section1_content, type = "chars"))
  section1_kb <- round(section1_chars / 1024, 1)
  section1_tokens <- round(section1_chars / 4)
  
  section2_chars <- sum(nchar(section2_content, type = "chars"))
  section2_kb <- round(section2_chars / 1024, 1)
  section2_tokens <- round(section2_chars / 4)
  
  section3_chars <- sum(nchar(section3_content, type = "chars"))
  section3_kb <- round(section3_chars / 1024, 1)  
  section3_tokens <- round(section3_chars / 4)
  
  total_chars <- section1_chars + section2_chars + section3_chars
  total_kb <- round(total_chars / 1024, 1)
  total_tokens <- section1_tokens + section2_tokens + section3_tokens
  
  # Generate overview
  context_overview <- generate_context_overview(
    persona_name, additional_context,
    section1_kb, section1_tokens,
    section2_kb, section2_tokens, 
    section3_kb, section3_tokens,
    total_kb, total_tokens
  )
  
  # Combine all sections
  content <- c(context_overview, section1_content)
  
  if (length(section2_content) > 0) {
    content <- c(content, section2_content)
  }
  
  if (length(section3_content) > 0) {
    content <- c(content, section3_content)
  }
  
  content <- c(content, "<!-- END DYNAMIC CONTENT -->")
  
  return(content)
}

# ==============================================================================
# PRIMARY USER INTERFACE FUNCTIONS
# ==============================================================================

# Activate persona with default context (primary interface)
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
  
  # Build and write 3-section instructions
  content <- build_3_section_instructions(persona_name, additional_context)
  instructions_path <- ".github/copilot-instructions.md"
  
  writeLines(content, instructions_path)
  
  if (length(content) > 0 && !endsWith(content[length(content)], "\n")) {
    cat("\n", file = instructions_path, append = TRUE)
  }
  
  # Update .copilot-persona file to track active persona
  persona_file <- ".copilot-persona"
  writeLines(persona_name, persona_file)
  
  message("✅ Persona activated: ", persona_name)
  message("📄 Total lines: ", length(content), " | Size: ", round(sum(nchar(content))/1024, 1), " KB")
  
  return(invisible(TRUE))
}

# Add context file to Section 3
add_context_file <- function(file_path) {
  instructions_path <- ".github/copilot-instructions.md"
  
  if (!file.exists(instructions_path)) {
    stop("Instructions file not found. Please activate a persona first.")
  }
  
  current_content <- readLines(instructions_path, warn = FALSE)
  
  # Find current persona
  persona_line <- current_content[grepl("\\*\\*Currently active persona:\\*\\*", current_content)]
  if (length(persona_line) == 0) {
    stop("No active persona found. Please activate a persona first.")
  }
  
  current_persona <- gsub(".*Currently active persona:\\*\\* ", "", persona_line)
  
  # Get current additional context from Section 3
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
  
  # Resolve and validate new file
  file_map <- get_file_map()
  resolved_path <- resolve_file_path(file_path, file_map)
  
  if (!file.exists(resolved_path)) {
    stop("File not found: ", file_path, " (resolved to: ", resolved_path, ")")
  }
  
  # Add to context and rebuild
  new_additional_context <- unique(c(current_additional_context, file_path))
  
  content <- build_3_section_instructions(current_persona, new_additional_context)
  writeLines(content, instructions_path)
  
  if (length(content) > 0 && !endsWith(content[length(content)], "\n")) {
    cat("\n", file = instructions_path, append = TRUE)
  }
  
  message("✅ Added context file: ", file_path)
  message("📄 Total lines: ", length(content), " | Size: ", round(sum(nchar(content))/1024, 1), " KB")
  
  return(invisible(TRUE))
}

# Remove context file from Section 3
remove_context_file <- function(file_path) {
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
  
  # Get current additional context and remove specified file
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
  
  # Remove file and rebuild
  new_additional_context <- current_additional_context[current_additional_context != file_path]
  
  content <- build_3_section_instructions(current_persona, new_additional_context)
  writeLines(content, instructions_path)
  
  if (length(content) > 0 && !endsWith(content[length(content)], "\n")) {
    cat("\n", file = instructions_path, append = TRUE)
  }
  
  message("✅ Removed context file: ", file_path)
  message("📄 Total lines: ", length(content), " | Size: ", round(sum(nchar(content))/1024, 1), " KB")
  
  return(invisible(TRUE))
}

# Show current context status
show_context_status <- function() {
  instructions_path <- ".github/copilot-instructions.md"
  
  if (!file.exists(instructions_path)) {
    message("❌ No context file found")
    return(invisible(NULL))
  }
  
  content <- readLines(instructions_path, warn = FALSE)
  
  message("📋 3-SECTION CONTEXT STATUS")
  message(paste(rep("=", 60), collapse = ""))
  
  # Section 1 - always present
  message("📄 Section 1: Core AI Instructions")
  config <- read_ai_config()
  base_path <- file.path(config$core_dir, "base-instructions.md")
  if (file.exists(base_path)) {
    message("   Source: ", base_path)
    message("   Status: ✅ Loaded")
  } else {
    message("   Status: ⚠️  Base instructions file not found")
  }
  
  # Section 2 - active persona
  persona_line <- content[grepl("\\*\\*Currently active persona:\\*\\*", content)]
  if (length(persona_line) > 0) {
    current_persona <- gsub(".*Currently active persona:\\*\\* ", "", persona_line)
    message("🎭 Section 2: Active Persona - ", current_persona)
    persona_configs <- get_persona_configs()
    if (current_persona %in% names(persona_configs)) {
      message("   Source: ", persona_configs[[current_persona]]$file)
    }
  } else {
    message("🎭 Section 2: No active persona")
  }
  
  # Section 3 - additional context
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
          message("   • ", file_path)
        }
      }
    } else {
      message("📚 Section 3: No additional context")
    }
  } else {
    message("📚 Section 3: No additional context")
  }
  
  # File metrics
  file_size <- round(file.size(instructions_path)/1024, 1)
  message("")
  message("📊 File Metrics:")
  message("   Size: ", file_size, " KB | Lines: ", length(content))
  
  if (file_size > 50) {
    message("   ⚠️  Large context - may impact AI performance")
  } else {
    message("   ✅ Optimal size for AI processing")
  }
  
  return(invisible(TRUE))
}

# List available markdown files for discovery
list_available_md_files <- function(pattern = NULL) {
  all_md_files <- list.files(".", pattern = "\\.md$", recursive = TRUE, full.names = FALSE)
  
  # Filter out system files
  filtered_files <- all_md_files[!grepl("node_modules|.git", all_md_files)]
  
  if (!is.null(pattern)) {
    filtered_files <- filtered_files[grepl(pattern, filtered_files, ignore.case = TRUE)]
  }
  
  message("📁 Available .md files in repository:")
  message(paste(rep("-", 60), collapse = ""))
  
  # Group by directory for better readability
  dirs <- unique(dirname(filtered_files))
  for (dir in sort(dirs)) {
    dir_files <- filtered_files[dirname(filtered_files) == dir]
    if (dir == ".") {
      message("\n📂 Root directory:")
    } else {
      message("\n📂 ", dir, "/")
    }
    for (file in sort(dir_files)) {
      message("   • ", basename(file))
    }
  }
  
  message("\n💡 Usage: add_context_file('path/to/file.md')")
  
  return(invisible(filtered_files))
}

# ==============================================================================
# PERSONA ACTIVATION SHORTCUTS
# ==============================================================================

activate_default <- function() {
  set_persona_with_defaults("default")
}

activate_developer <- function() {
  set_persona_with_defaults("developer")
}

activate_data_engineer <- function() {
  set_persona_with_defaults("data-engineer")
}

activate_research_scientist <- function() {
  set_persona_with_defaults("research-scientist")
}

activate_devops_engineer <- function() {
  set_persona_with_defaults("devops-engineer")
}

activate_frontend_architect <- function() {
  set_persona_with_defaults("frontend-architect")
}

activate_project_manager <- function() {
  set_persona_with_defaults("project-manager")
}

activate_casenote_analyst <- function() {
  set_persona_with_defaults("casenote-analyst")
}

activate_prompt_engineer <- function() {
  set_persona_with_defaults("prompt-engineer")
}

activate_reporter <- function() {
  set_persona_with_defaults("reporter")
}

activate_grapher <- function() {
  set_persona_with_defaults("grapher")
}

# ==============================================================================
# AI MEMORY SYSTEM INTEGRATION
# ==============================================================================

# Load AI Memory System if available
if (file.exists("./scripts/ai-memory-functions-core.R")) {
  source("./scripts/ai-memory-functions-core.R")
} else if (file.exists("./scripts/ai-memory-functions.R")) {
  source("./scripts/ai-memory-functions.R")
}

# ==============================================================================
# AUTO-INITIALIZATION
# ==============================================================================

if (!exists("copilot_context_initialized")) {
  cat("🤖 3-Section Context Management System Loaded\n")
  cat(paste(rep("=", 60), collapse = ""), "\n\n")
  
  cat("📋 ARCHITECTURE:\n")
  cat("   Section 1: Core AI Instructions (from ai/core/base-instructions.md)\n")
  cat("   Section 2: Active Persona (from ai/personas/*.md)\n")
  cat("   Section 3: Additional Context (project docs)\n\n")
  
  cat("🎭 PERSONA MANAGEMENT:\n")
  cat("   activate_developer()         # Minimal context\n")
  cat("   activate_project_manager()   # Full project context\n")
  cat("   activate_data_engineer()     # Data pipeline focus\n")
  cat("   activate_research_scientist() # Statistical analysis\n")
  cat("   (+ 6 more personas available)\n\n")
  
  cat("📚 CONTEXT MANAGEMENT:\n")
  cat("   show_context_status()          # View current 3-section state\n")
  cat("   add_context_file('file.md')    # Add to Section 3\n")
  cat("   remove_context_file('file.md') # Remove from Section 3\n")
  cat("   list_available_md_files()      # Discover available files\n\n")
  
  cat("💡 Quick Start: run show_context_status() to see current configuration\n")
  cat(paste(rep("=", 60), collapse = ""), "\n")
  
  copilot_context_initialized <- TRUE
}
