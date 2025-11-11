# Portable AI Memory Management Functions
# Exportable logic for memory system functionality  
# Version: 1.0.0 - Designed for storage/logic separation
# Storage: project-specific memory files (memory-ai.md, memory-human.md, etc.)
# Logic: portable functions that work across projects

# === CONFIGURATION READING ===

# Source shared configuration utilities
if (!file.exists("ai/scripts/ai-config-utils.R")) {
  stop("Required dependency 'ai/scripts/ai-config-utils.R' not found. Please ensure AI support system is properly installed.")
}
source("ai/scripts/ai-config-utils.R")

# === MEMORY SYSTEM DETECTION ===

detect_memory_system <- function(project_root = ".") {
  # Read configuration for memory directory
  ai_config <- read_ai_config(project_root)
  memory_path <- ai_config$memory_dir
  
  # Build full path
  if (project_root == ".") {
    memory_dir <- memory_path
  } else {
    memory_dir <- file.path(project_root, memory_path)
  }
  
  # Check if memory directory exists
  if (dir.exists(memory_dir)) {
    return(list(type = "ai", path = memory_dir))
  }
  
  # Fallback: check ai directory
  ai_dir <- file.path(project_root, ai_config$ai_dir)
  if (dir.exists(ai_dir)) {
    return(list(type = "ai", path = ai_dir))
  }
  
  return(list(type = "none", path = NULL))
}

# === MEMORY FILE MANAGEMENT (PORTABLE LOGIC) ===

get_memory_file_paths <- function(project_root = ".") {
  memory_config <- detect_memory_system(project_root)
  
  if (memory_config$type == "none") {
    return(list())
  }
  
  # Use ai-config-utils.R functions for proper configuration-driven paths
  return(list(
    ai = get_ai_file_path("memory-ai", project_root),
    human = get_ai_file_path("memory-human", project_root),
    hub = get_ai_file_path("memory-hub", project_root),
    guide = get_ai_file_path("memory-guide", project_root),
    log_dir = file.path(dirname(get_ai_file_path("memory-ai", project_root)), "log")
  ))
}

# === MEMORY STATUS FUNCTIONS (EXPORTABLE) ===

#' Quick Memory Status Check
#' 
#' Lightweight function to show current project memory state
memory_status <- function(project_root = ".") {
  memory_paths <- get_memory_file_paths(project_root)
  
  if (length(memory_paths) == 0) {
    cat("No memory system found\n")
    return(invisible(FALSE))
  }
  
  cat("Memory Files:\n")
  
  # Check memory files
  for (name in names(memory_paths)) {
    if (name != "log_dir") {
      file_path <- memory_paths[[name]]
      if (file.exists(file_path)) {
        mtime <- file.info(file_path)$mtime
        age_days <- as.numeric(Sys.time() - mtime) / 86400
        cat(sprintf("  [[memory-%s]]: %s (%.1f days ago)\n", 
                    name, format(mtime, "%Y-%m-%d"), age_days))
      } else {
        cat(sprintf("  [[memory-%s]]: Not found\n", name))
      }
    }
  }
  
  # Check for detailed logs
  if (!is.null(memory_paths$log_dir) && dir.exists(memory_paths$log_dir)) {
    log_files <- list.files(memory_paths$log_dir, pattern = "\\.md$", full.names = FALSE)
    if (length(log_files) > 0) {
      cat(sprintf("  Log files: %d (latest: %s)\n", length(log_files), tail(sort(log_files), 1)))
    }
  }
  
  return(invisible(TRUE))
}

# === MEMORY UPDATE FUNCTIONS (EXPORTABLE) ===

#' Simple Memory Update
#' 
#' Add entry to AI memory with minimal automation
simple_memory_update <- function(entry, project_root = ".") {
  memory_paths <- get_memory_file_paths(project_root)
  
  if (is.null(memory_paths$ai) || !file.exists(memory_paths$ai)) {
    cat("ERROR: [[memory-ai]] not found at:", memory_paths$ai, "\n")
    cat("Initialize memory system first\n")
    return(invisible(FALSE))
  }
  
  timestamp <- format(Sys.time(), "%Y-%m-%d")
  new_entry <- paste("**", timestamp, "**:", entry)
  
  # Simple append to end of file
  cat(paste("\n---\n\n", new_entry, "\n"), file = memory_paths$ai, append = TRUE)
  
  cat("Added to [[memory-ai]]\n")
  return(invisible(TRUE))
}

#' Human Memory Update
#' 
#' Add entry to human decision memory
human_memory_update <- function(entry, project_root = ".") {
  memory_paths <- get_memory_file_paths(project_root)
  
  if (is.null(memory_paths$human) || !file.exists(memory_paths$human)) {
    cat("ERROR: [[memory-human]] not found at:", memory_paths$human, "\n")
    cat("Initialize memory system first\n")
    return(invisible(FALSE))
  }
  
  timestamp <- format(Sys.time(), "%Y-%m-%d")
  new_entry <- paste("**", timestamp, "**:", entry)
  
  # Simple append to end of file
  cat(paste("\n---\n\n", new_entry, "\n"), file = memory_paths$human, append = TRUE)
  
  cat("Added to [[memory-human]]\n")
  return(invisible(TRUE))
}

# === MEMORY SCANNING FUNCTIONS (EXPORTABLE) ===

#' Quick Intent Check
#' 
#' Simple scan for TODO/FIXME patterns in current directory
#' Excludes common directories and large files
quick_intent_scan <- function(pattern = "TODO|FIXME|XXX|NOTE:", project_root = ".", max_file_size_mb = 1) {
  # Change to project root for scanning
  old_wd <- getwd()
  on.exit(setwd(old_wd))
  setwd(project_root)
  
  # Directories to exclude from scanning
  exclude_dirs <- c(
    ".git", "node_modules", "renv", "packrat", ".Rproj.user",
    "data-private", "tmp-local-ai-context-test", ".vscode"
  )
  
  # Get all R and Markdown files
  r_files <- list.files(pattern = "\\.R$", recursive = TRUE, full.names = FALSE)
  md_files <- list.files(pattern = "\\.md$", recursive = TRUE, full.names = FALSE)
  
  all_files <- c(r_files, md_files)
  
  # Filter out excluded directories
  for (exclude_dir in exclude_dirs) {
    all_files <- all_files[!grepl(paste0("^", exclude_dir, "/|/", exclude_dir, "/"), all_files)]
  }
  
  if (length(all_files) == 0) {
    cat("No R or Markdown files found\n")
    return(invisible(TRUE))
  }
  
  cat("Quick Intent Scan (", basename(project_root), ")\n")
  
  max_file_size_bytes <- max_file_size_mb * 1024 * 1024
  found_items <- 0
  skipped_files <- 0
  
  for (file in all_files) {
    if (file.exists(file)) {
      # Skip files larger than max size
      file_size <- file.info(file)$size
      if (!is.na(file_size) && file_size > max_file_size_bytes) {
        skipped_files <- skipped_files + 1
        next
      }
      
      content <- readLines(file, warn = FALSE)
      matches <- grep(pattern, content, ignore.case = TRUE, value = TRUE)
      
      if (length(matches) > 0) {
        cat(paste("File:", file, "\n"))
        for (match in head(matches, 3)) { # Show max 3 per file
          cat(paste("  -", trimws(match), "\n"))
        }
        found_items <- found_items + length(matches)
      }
    }
  }
  
  if (found_items == 0) {
    cat("No pending items found\n")
  } else {
    cat(paste("\nFound", found_items, "items. Consider updating [[memory-human]] or [[memory-ai]]\n"))
  }
  
  if (skipped_files > 0) {
    cat(paste("Skipped", skipped_files, "files larger than", max_file_size_mb, "MB\n"))
  }
  
  return(invisible(TRUE))
}

# === MAIN MEMORY SYSTEM INTERFACE (FOCUSED) ===

#' Check if Memory System Exists
#' 
#' Simple check for memory system availability
check_memory_system <- function(project_root = ".") {
  memory_config <- detect_memory_system(project_root)
  return(memory_config$type != "none")
}

#' Show Memory System Help
#' 
#' Display available memory functions and components
show_memory_help <- function() {
  cat("Memory System Functions:\n")
  cat("- memory_status() - Show memory file status\n")
  cat("- simple_memory_update('note') - Add to [[memory-ai]]\n")
  cat("- human_memory_update('decision') - Add to [[memory-human]]\n")
  cat("- quick_intent_scan() - Scan for TODO/FIXME/NOTE\n")
  cat("- initialize_memory_system() - Create memory structure\n\n")
  
  cat("Memory Files:\n")
  cat("- [[memory-hub]] - Navigation hub\n")
  cat("- [[memory-ai]] - AI technical notes\n")
  cat("- [[memory-human]] - Human decisions\n")
  cat("- [[memory-guide]] - System documentation\n")
  return(invisible(TRUE))
}

# === MEMORY SYSTEM INITIALIZATION ===

#' Initialize Memory System
#' 
#' Creates basic memory system structure for new projects
initialize_memory_system <- function(project_root = ".") {
  ai_config <- read_ai_config(project_root)
  
  # Determine memory directory
  if (project_root == ".") {
    memory_dir <- ai_config$memory_dir
  } else {
    memory_dir <- file.path(project_root, ai_config$memory_dir)
  }
  
  # Create directory if needed
  if (!dir.exists(memory_dir)) {
    dir.create(memory_dir, recursive = TRUE)
    cat("Created memory directory:", memory_dir, "\n")
  }
  
  # Memory file templates
  memory_files <- list(
    "memory-hub.md" = "# Memory Hub\n\nCentral navigation for project memory system.\n\n## Navigation\n- [[memory-ai]] - AI system status\n- [[memory-human]] - Human decisions  \n- [[memory-guide]] - Documentation\n",
    "memory-ai.md" = "# AI Memory\n\nAI system status and technical briefings.\n\n---\n",
    "memory-human.md" = "# Human Memory\n\nHuman decisions and reasoning.\n\n---\n",
    "memory-guide.md" = "# Memory Guide\n\nDocumentation for the memory system.\n\n## Usage\n- Use simple_memory_update() for AI notes\n- Use human_memory_update() for decisions\n- Navigate via [[memory-hub]]\n"
  )
  
  # Create memory files
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
    cat("Initialized:", paste(created_files, collapse = ", "), "\n")
  } else {
    cat("Memory system already exists\n")
  }
  
  return(invisible(TRUE))
}

# Initialization message
cat("Portable AI Memory Functions Loaded\n")
cat("Core: check_memory_system(), memory_status(), show_memory_help()\n")
cat("Update: simple_memory_update(), human_memory_update()\n")
cat("Utility: quick_intent_scan(), initialize_memory_system()\n")
