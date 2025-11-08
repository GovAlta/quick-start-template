# Portable AI Memory Management Functions
# Exportable logic for memory system functionality  
# Version: 1.0.0 - Designed for storage/logic separation
# Storage: project-specific memory files (memory-ai.md, memory-human.md, etc.)
# Logic: portable functions that work across projects

# === CONFIGURATION READING ===

read_ai_config <- function(project_root = ".") {
  config_file <- file.path(project_root, "config.yml")
  
  if (!file.exists(config_file)) {
    return(list(memory_dir = "./ai/memory/"))  # fallback default
  }
  
  tryCatch({
    if (requireNamespace("yaml", quietly = TRUE)) {
      config_content <- yaml::read_yaml(config_file)
      if (!is.null(config_content$default$ai_support$memory_dir)) {
        return(list(memory_dir = config_content$default$ai_support$memory_dir))
      }
    }
    # Fallback to default if yaml package not available or config not found
    return(list(memory_dir = "./ai/memory/"))
  }, error = function(e) {
    return(list(memory_dir = "./ai/memory/"))  # fallback on error
  })
}

# === MEMORY SYSTEM DETECTION ===

detect_memory_system <- function(project_root = ".") {
  # Read configuration for memory directory
  ai_config <- read_ai_config(project_root)
  memory_path <- ai_config$memory_dir
  
  # Remove leading "./" if present to normalize path
  memory_path <- gsub("^\\./", "", memory_path)
  
  # Build full path
  if (project_root == ".") {
    memory_dir <- memory_path
  } else {
    memory_dir <- file.path(project_root, memory_path)
  }
  
  # Also check for ai directory as fallback
  ai_dir <- file.path(project_root, "ai")
  
  if (dir.exists(memory_dir)) {
    return(list(type = "ai", path = memory_dir, root = project_root))
  } else if (dir.exists(ai_dir)) {
    return(list(type = "ai", path = ai_dir, root = project_root))
  } else {
    return(list(type = "none", path = NULL, root = project_root))
  }
}

# === MEMORY FILE MANAGEMENT (PORTABLE LOGIC) ===

get_memory_file_paths <- function(project_root = ".") {
  memory_config <- detect_memory_system(project_root)
  
  if (memory_config$type == "none") {
    return(list())
  }
  
  base_path <- memory_config$path
  
  return(list(
    ai = file.path(base_path, "memory-ai.md"),
    human = file.path(base_path, "memory-human.md"),
    hub = file.path(base_path, "memory-hub.md"),
    guide = file.path(base_path, "memory-guide.md"),
    log_dir = file.path(base_path, "log")
  ))
}

# === MEMORY STATUS FUNCTIONS (EXPORTABLE) ===

#' Quick Memory Status Check
#' 
#' Lightweight function to show current project memory state
memory_status <- function(project_root = ".") {
  memory_config <- detect_memory_system(project_root)
  memory_paths <- get_memory_file_paths(project_root)
  
  cat("📊 **Memory System Status** (", basename(project_root), ")\n")
  cat("🏗️  Memory System:", memory_config$type, "\n")
  
  # Show current persona if function exists and context management is available
  persona_file <- file.path(project_root, ".copilot-persona")
  if (file.exists(persona_file)) {
    current_persona <- trimws(readLines(persona_file, n = 1, warn = FALSE))
    cat("🎭 **Active Persona**: ", current_persona, "\n")
  }
  
  # Check memory files
  for (name in names(memory_paths)) {
    if (name != "log_dir") {
      file_path <- memory_paths[[name]]
      if (file.exists(file_path)) {
        mtime <- file.info(file_path)$mtime
        age_days <- as.numeric(Sys.time() - mtime) / 86400
        cat("[[memory-", name, "]]:", format(mtime, "%Y-%m-%d"), paste0("(", round(age_days, 1), " days ago)\n"))
      } else {
        cat("[[memory-", name, "]]: ❌ Not found\n")
      }
    }
  }
  
  # Check for detailed logs
  if (!is.null(memory_paths$log_dir) && dir.exists(memory_paths$log_dir)) {
    log_files <- list.files(memory_paths$log_dir, pattern = "\\.md$", full.names = FALSE)
    if (length(log_files) > 0) {
      latest_log <- tail(sort(log_files), 1)
      cat("Latest log:", latest_log, "\n")
    }
  }
  
  cat("\n💡 Use [[memory-hub]] for navigation\n")
  cat("🔍 Use Ctrl+Shift+F in VS Code for memory search\n")
  return(invisible(TRUE))
}

# === MEMORY UPDATE FUNCTIONS (EXPORTABLE) ===

#' Simple Memory Update
#' 
#' Add entry to AI memory with minimal automation
simple_memory_update <- function(entry, project_root = ".") {
  memory_paths <- get_memory_file_paths(project_root)
  
  if (is.null(memory_paths$ai) || !file.exists(memory_paths$ai)) {
    cat("❌ [[memory-ai]] not found at:", memory_paths$ai, "\n")
    cat("💡 Initialize memory system first\n")
    return(invisible(FALSE))
  }
  
  timestamp <- format(Sys.time(), "%Y-%m-%d")
  new_entry <- paste("**", timestamp, "**:", entry)
  
  # Simple append to end of file
  cat(paste("\n---\n\n", new_entry, "\n"), file = memory_paths$ai, append = TRUE)
  
  cat("✅ Added to [[memory-ai]]\n")
  return(invisible(TRUE))
}

#' Human Memory Update
#' 
#' Add entry to human decision memory
human_memory_update <- function(entry, project_root = ".") {
  memory_paths <- get_memory_file_paths(project_root)
  
  if (is.null(memory_paths$human) || !file.exists(memory_paths$human)) {
    cat("❌ [[memory-human]] not found at:", memory_paths$human, "\n")
    cat("💡 Initialize memory system first\n")
    return(invisible(FALSE))
  }
  
  timestamp <- format(Sys.time(), "%Y-%m-%d")
  new_entry <- paste("**", timestamp, "**:", entry)
  
  # Simple append to end of file
  cat(paste("\n---\n\n", new_entry, "\n"), file = memory_paths$human, append = TRUE)
  
  cat("✅ Added to [[memory-human]]\n")
  return(invisible(TRUE))
}

# === MEMORY SCANNING FUNCTIONS (EXPORTABLE) ===

#' Quick Intent Check
#' 
#' Simple scan for TODO/FIXME patterns in current directory
quick_intent_scan <- function(pattern = "TODO|FIXME|XXX|NOTE:", project_root = ".") {
  # Change to project root for scanning
  old_wd <- getwd()
  on.exit(setwd(old_wd))
  setwd(project_root)
  
  r_files <- list.files(pattern = "\\.R$", recursive = TRUE)
  md_files <- list.files(pattern = "\\.md$", recursive = TRUE)
  
  all_files <- c(r_files, md_files)
  
  if (length(all_files) == 0) {
    cat("No R or Markdown files found\n")
    return(invisible(TRUE))
  }
  
  cat("🔍 **Quick Intent Scan** (", basename(project_root), ")\n")
  
  found_items <- 0
  for (file in all_files) {
    if (file.exists(file)) {
      content <- readLines(file, warn = FALSE)
      matches <- grep(pattern, content, ignore.case = TRUE, value = TRUE)
      
      if (length(matches) > 0) {
        cat(paste("📄", file, ":\n"))
        for (match in head(matches, 3)) { # Show max 3 per file
          cat(paste("  -", trimws(match), "\n"))
        }
        found_items <- found_items + length(matches)
      }
    }
  }
  
  if (found_items == 0) {
    cat("✅ No pending items found\n")
  } else {
    cat(paste("\n💡 Found", found_items, "items. Consider updating [[memory-human]] or [[memory-ai]]\n"))
  }
  
  return(invisible(TRUE))
}

# === MAIN MEMORY SYSTEM INTERFACE (EXPORTABLE) ===

#' Memory System Check
#' 
#' Main function - portable across projects with storage/logic separation
ai_memory_check <- function(project_root = ".") {
  memory_config <- detect_memory_system(project_root)
  
  cat("🧠 **AI Memory System** (", basename(project_root), " - Portable)\n")
  cat("🏗️  System Type:", memory_config$type, "\n\n")
  
  if (memory_config$type == "none") {
    cat("❌ No memory system detected\n")
    cat("💡 Initialize memory system with initialize_memory_system()\n")
    return(invisible(FALSE))
  }
  
  # Quick status
  memory_status(project_root)
  cat("\n")
  
  # Quick intent scan
  quick_intent_scan(project_root = project_root)
  cat("\n")
  
  cat("📝 **Quick Actions:**\n")
  cat("- simple_memory_update('your note') - Add to [[memory-ai]]\n")
  cat("- human_memory_update('decision') - Add to [[memory-human]]\n")
  cat("- Navigate to [[memory-hub]] for full system navigation\n")
  cat("- Use VS Code search (Ctrl+Shift+F) across memory directory\n")
  cat("- Use Foam wiki-links for navigation between memory components\n\n")
  
  cat("📚 **Memory Components:**\n")
  cat("- [[memory-hub]] - Central navigation and status\n")
  cat("- [[memory-human]] - Human decisions and reasoning\n")
  cat("- [[memory-ai]] - AI technical status and briefings\n")
  cat("- [[memory-guide]] - System documentation\n")
  cat("- log/ - Detailed implementation reports\n\n")
  
  return(invisible(TRUE))
}

# === MEMORY SYSTEM INITIALIZATION (MIGRATION HELPER) ===

#' Initialize Memory System
#' 
#' Creates basic memory system structure for new projects
initialize_memory_system <- function(project_root = ".", system_type = "ai") {
  # Read configuration for memory directory
  ai_config <- read_ai_config(project_root)
  
  if (system_type == "ai") {
    memory_path <- ai_config$memory_dir
    # Remove leading "./" if present and normalize path
    memory_path <- gsub("^\\./", "", memory_path)
    
    # Build full path
    if (project_root == ".") {
      memory_dir <- memory_path
    } else {
      memory_dir <- file.path(project_root, memory_path)
    }
  } else {
    memory_dir <- file.path(project_root, "ai")
  }
  
  if (!dir.exists(memory_dir)) {
    dir.create(memory_dir, recursive = TRUE)
    cat("📁 Created memory directory:", memory_dir, "\n")
  }
  
  # Create basic memory files if they don't exist
  memory_files <- list(
    "memory-hub.md" = "# Memory Hub\n\nCentral navigation for project memory system.\n\n## Navigation\n- [[memory-ai]] - AI system status\n- [[memory-human]] - Human decisions  \n- [[memory-guide]] - Documentation\n",
    "memory-ai.md" = "# AI Memory\n\nAI system status and technical briefings.\n\n---\n",
    "memory-human.md" = "# Human Memory\n\nHuman decisions and reasoning.\n\n---\n",
    "memory-guide.md" = "# Memory Guide\n\nDocumentation for the memory system.\n\n## Usage\n- Use simple_memory_update() for AI notes\n- Use human_memory_update() for decisions\n- Navigate via [[memory-hub]]\n"
  )
  
  created_files <- character(0)
  for (filename in names(memory_files)) {
    filepath <- file.path(memory_dir, filename)
    if (!file.exists(filepath)) {
      writeLines(memory_files[[filename]], filepath)
      created_files <- c(created_files, filename)
    }
  }
  
  # Create log directory
  log_dir <- file.path(memory_dir, "log")
  if (!dir.exists(log_dir)) {
    dir.create(log_dir)
    created_files <- c(created_files, "log/")
  }
  
  if (length(created_files) > 0) {
    cat("✅ Initialized memory files:", paste(created_files, collapse = ", "), "\n")
  } else {
    cat("ℹ️  Memory system already exists\n")
  }
  
  return(invisible(TRUE))
}

# === CONTEXT REFRESH HELPER (PORTABLE) ===

#' Context Refresh Helper
#' 
#' Simple reminder for context management - works with any project structure
context_refresh <- function(project_root = ".") {
  cat("🔄 **Context Refresh**\n")
  
  # Look for context management scripts
  context_scripts <- c(
    file.path(project_root, "ai", "scripts", "ai-context-management.R"),
    file.path(project_root, "scripts", "ai-context-management.R")
  )
  
  available_script <- NULL
  for (script in context_scripts) {
    if (file.exists(script)) {
      available_script <- script
      break
    }
  }
  
  if (!is.null(available_script)) {
    cat("For dynamic context management, use:\n")
    cat("- source('", available_script, "')\n", sep = "")
    cat("- add_core_context() # Load essential project context\n")
    cat("- suggest_context() # Get smart suggestions\n")
    cat("- validate_context() # Check current context\n\n")
  } else {
    cat("⚠️  Context management script not found\n")
  }
  
  cat("For memory navigation:\n")
  cat("- [[memory-hub]] # Central navigation\n")
  cat("- ai_memory_check() # This function\n")
  return(invisible(TRUE))
}

# === MIGRATION UTILITIES FOR MEMORY ===

#' Export Memory Logic
#' 
#' Package memory management functions for export (without storage)
export_memory_logic <- function(target_path) {
  source_script <- file.path(getwd(), "ai", "scripts", "ai-memory-functions.R")
  target_script <- file.path(target_path, "ai", "scripts", "ai-memory-functions.R")
  
  # Create target directory
  dir.create(dirname(target_script), recursive = TRUE, showWarnings = FALSE)
  
  # Copy this script
  if (file.exists(source_script)) {
    file.copy(source_script, target_script, overwrite = TRUE)
    cat("✅ Exported memory logic to:", target_script, "\n")
  } else {
    cat("❌ Source script not found at:", source_script, "\n")
  }
  cat("💡 Initialize memory storage with initialize_memory_system() in target project\n")
}

# Simple initialization message
cat("🧠 Portable AI Memory Functions Loaded (Storage/Logic Separated)\n")
cat("📚 Main Functions: ai_memory_check(), memory_status()\n")
cat("📝 Update Functions: simple_memory_update(), human_memory_update()\n")
cat("🔄 Utility Functions: quick_intent_scan(), context_refresh()\n")
cat("🚀 Migration Functions: initialize_memory_system(), export_memory_logic()\n")
cat("💡 Focus: Portable logic with project-specific storage\n")