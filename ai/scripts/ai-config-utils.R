# AI Configuration Utilities
# Shared configuration reading functions for the AI support system
# Version: 1.1.0 - Simplified configuration management (config.yml only)

#' Read AI Support System Configuration
#' 
#' Reads configuration from config.yml with intelligent fallbacks:
#' 1. config.yml (main project configuration)
#' 2. Intelligent directory detection
#' 3. Sensible defaults
#' 
#' @param project_root Character. Root directory of the project. Default: "."
#' @return List containing all AI system paths and configuration
#' 
#' @examples
#' config <- read_ai_config()
#' memory_path <- config$memory_dir
#' personas_path <- config$personas_dir
read_ai_config <- function(project_root = ".") {
  config_file <- file.path(project_root, "config.yml")
  
  # Default configuration
  defaults <- list(
    ai_dir = "ai",
    personas_dir = "ai/personas",
    memory_dir = "ai/memory",
    project_dir = "ai/project",
    core_dir = "ai/core",
    copilot_instructions = ".github/copilot-instructions.md",
    copilot_persona = ".copilot-persona"
  )
  
  tryCatch({
    if (requireNamespace("yaml", quietly = TRUE) && file.exists(config_file)) {
      config_content <- yaml::read_yaml(config_file)
      if (!is.null(config_content$default)) {
        config_ai <- config_content$default
        
        # Extract configured paths from ai_support section
        if (!is.null(config_ai$ai_support)) {
          ai_support <- config_ai$ai_support
          
          if (!is.null(ai_support$memory_dir)) {
            defaults$memory_dir <- gsub("^\\./", "", ai_support$memory_dir)
          }
          if (!is.null(ai_support$personas_dir)) {
            defaults$personas_dir <- gsub("^\\./", "", ai_support$personas_dir)
          }
        }
        
        # Extract AI directory from directories section
        if (!is.null(config_ai$directories$ai)) {
          ai_base <- gsub("^\\./", "", config_ai$directories$ai)
          ai_base <- gsub("/$", "", ai_base)  # Remove trailing slash
          defaults$ai_dir <- ai_base
          
          # Update dependent paths based on ai_dir if they weren't explicitly set
          if (is.null(config_ai$ai_support$memory_dir)) {
            defaults$memory_dir <- file.path(ai_base, "memory")
          }
          if (is.null(config_ai$ai_support$personas_dir)) {
            defaults$personas_dir <- file.path(ai_base, "personas")
          }
          defaults$project_dir <- file.path(ai_base, "project")
          defaults$core_dir <- file.path(ai_base, "core")
        }
      }
    }
    
    # Normalize all paths - remove trailing slashes for consistency
    for (dir_key in c("ai_dir", "memory_dir", "personas_dir", "project_dir", "core_dir")) {
      if (!is.null(defaults[[dir_key]])) {
        defaults[[dir_key]] <- gsub("/$", "", defaults[[dir_key]])
      }
    }
    
    # Intelligent fallback - check if directories exist and adjust
    for (dir_key in c("memory_dir", "personas_dir", "project_dir", "core_dir")) {
      full_path <- file.path(project_root, defaults[[dir_key]])
      if (!dir.exists(full_path) && dir_key == "memory_dir") {
        # Special handling for memory - fall back to ai/ if ai/memory doesn't exist
        ai_path <- file.path(project_root, defaults$ai_dir)
        if (dir.exists(ai_path)) {
          defaults$memory_dir <- defaults$ai_dir
        }
      }
    }
    
    return(defaults)
    
  }, error = function(e) {
    # Error fallback - use intelligent defaults with directory detection
    ai_memory_path <- file.path(project_root, "ai", "memory")
    if (dir.exists(ai_memory_path)) {
      defaults$memory_dir <- "ai/memory"
    } else if (dir.exists(file.path(project_root, "ai"))) {
      defaults$memory_dir <- "ai"
    }
    
    return(defaults)
  })
}

#' Get Configured File Path
#' 
#' Helper function to get a configured file path with proper path joining
#' 
#' @param file_type Character. Type of file ("memory-ai", "memory-human", etc.)
#' @param project_root Character. Root directory of the project. Default: "."
#' @return Character. Full path to the requested file
get_ai_file_path <- function(file_type, project_root = ".") {
  config <- read_ai_config(project_root)
  
  switch(file_type,
    "memory-ai" = file.path(project_root, config$memory_dir, "memory-ai.md"),
    "memory-human" = file.path(project_root, config$memory_dir, "memory-human.md"),
    "memory-hub" = file.path(project_root, config$memory_dir, "memory-hub.md"),
    "memory-guide" = file.path(project_root, config$memory_dir, "memory-guide.md"),
    "mission" = file.path(project_root, config$project_dir, "mission.md"),
    "method" = file.path(project_root, config$project_dir, "method.md"),
    "glossary" = file.path(project_root, config$project_dir, "glossary.md"),
    "copilot-instructions" = file.path(project_root, config$copilot_instructions),
    "copilot-persona" = file.path(project_root, config$copilot_persona),
    # Handle direct filename requests (for backward compatibility)
    {
      if (grepl("\\.md$", file_type)) {
        # If it's a .md file, assume it's in the ai directory
        file.path(project_root, config$ai_dir, file_type)
      } else {
        stop("Unknown file type: ", file_type)
      }
    }
  )
}

#' Get Persona File Path
#' 
#' Helper function to get the path to a specific persona file
#' 
#' @param persona_name Character. Name of the persona (e.g., "developer", "project-manager")
#' @param project_root Character. Root directory of the project. Default: "."
#' @return Character. Full path to the persona file
get_persona_path <- function(persona_name, project_root = ".") {
  config <- read_ai_config(project_root)
  
  # Clean the persona name (remove .md extension if present)
  clean_name <- gsub("\\.md$", "", persona_name)
  
  # Normalize the personas_dir path (remove trailing slashes)
  personas_dir <- gsub("/$", "", config$personas_dir)
  
  file.path(project_root, personas_dir, paste0(clean_name, ".md"))
}

# Simple initialization message
cat("🔧 AI Configuration Utilities Loaded\n")
cat("📚 Functions: read_ai_config(), get_ai_file_path(), get_persona_path()\n")
cat("💡 Provides unified configuration reading across all AI scripts\n")
