# AI Memory Functions (Streamlined) - Books of Ukraine Project
# Simplified, essential functions for human-friendly memory management
# Optimized for VS Code workflow and reduced cognitive load
# Adapted from mature sda-ceis-impact implementation

#' Quick Memory Status Check
#' 
#' Lightweight function to show current project memory state
memory_status <- function(project_root = ".") {
  
  memory_ai_file <- file.path(project_root, "ai", "memory-ai.md")
  memory_human_file <- file.path(project_root, "ai", "memory-human.md")
  memory_hub_file <- file.path(project_root, "ai", "memory-hub.md")
  
  cat("📊 **Memory System Status** (Books of Ukraine)\n")
  
  if (file.exists(memory_ai_file)) {
    mtime <- file.info(memory_ai_file)$mtime
    age_days <- as.numeric(Sys.time() - mtime) / 86400
    cat("[[memory-ai]]:", format(mtime, "%Y-%m-%d"), paste0("(", round(age_days, 1), " days ago)\n"))
  }
  
  if (file.exists(memory_human_file)) {
    mtime <- file.info(memory_human_file)$mtime  
    age_days <- as.numeric(Sys.time() - mtime) / 86400
    cat("[[memory-human]]:", format(mtime, "%Y-%m-%d"), paste0("(", round(age_days, 1), " days ago)\n"))
  }
  
  if (file.exists(memory_hub_file)) {
    mtime <- file.info(memory_hub_file)$mtime  
    age_days <- as.numeric(Sys.time() - mtime) / 86400
    cat("[[memory-hub]]:", format(mtime, "%Y-%m-%d"), paste0("(", round(age_days, 1), " days ago)\n"))
  }
  
  # Check for detailed logs
  log_dir <- file.path(project_root, "ai", "log")
  if (dir.exists(log_dir)) {
    log_files <- list.files(log_dir, pattern = "\\.md$", full.names = FALSE)
    if (length(log_files) > 0) {
      latest_log <- tail(sort(log_files), 1)
      cat("Latest log:", latest_log, "\n")
    }
  }
  
  cat("\n💡 Use [[memory-hub]] for navigation\n")
  cat("🔍 Use Ctrl+Shift+F in VS Code for memory search\n")
  return(invisible(TRUE))
}

#' Simple Memory Update
#' 
#' Add entry to AI memory with minimal automation
simple_memory_update <- function(entry, project_root = ".") {
  
  memory_file <- file.path(project_root, "ai", "memory-ai.md")
  
  if (!file.exists(memory_file)) {
    cat("❌ [[memory-ai]] not found\n")
    return(invisible(FALSE))
  }
  
  timestamp <- format(Sys.time(), "%Y-%m-%d")
  new_entry <- paste("**", timestamp, "**:", entry)
  
  # Simple append to end of file
  cat(paste("\n---\n\n", new_entry, "\n"), file = memory_file, append = TRUE)
  
  cat("✅ Added to [[memory-ai]]\n")
  return(invisible(TRUE))
}

#' Human Memory Update
#' 
#' Add entry to human decision memory
human_memory_update <- function(entry, project_root = ".") {
  
  memory_file <- file.path(project_root, "ai", "memory-human.md")
  
  if (!file.exists(memory_file)) {
    cat("❌ [[memory-human]] not found\n")
    return(invisible(FALSE))
  }
  
  timestamp <- format(Sys.time(), "%Y-%m-%d")
  new_entry <- paste("**", timestamp, "**:", entry)
  
  # Simple append to end of file
  cat(paste("\n---\n\n", new_entry, "\n"), file = memory_file, append = TRUE)
  
  cat("✅ Added to [[memory-human]]\n")
  return(invisible(TRUE))
}

#' Quick Intent Check
#' 
#' Simple scan for TODO/FIXME patterns in current directory
quick_intent_scan <- function(pattern = "TODO|FIXME|XXX|NOTE:") {
  
  r_files <- list.files(pattern = "\\.R$", recursive = TRUE)
  md_files <- list.files(pattern = "\\.md$", recursive = TRUE)
  
  all_files <- c(r_files, md_files)
  
  if (length(all_files) == 0) {
    cat("No R or Markdown files found\n")
    return(invisible(TRUE))
  }
  
  cat("🔍 **Quick Intent Scan** (Books of Ukraine)\n")
  
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

#' Memory System Check
#' 
#' Main function - simplified and focused for Books of Ukraine project
ai_memory_check <- function() {
  
  cat("🧠 **AI Memory System** (Books of Ukraine - Streamlined)\n\n")
  
  # Quick status
  memory_status()
  cat("\n")
  
  # Quick intent scan
  quick_intent_scan()
  cat("\n")
  
  cat("📝 **Quick Actions:**\n")
  cat("- simple_memory_update('your note') - Add to [[memory-ai]]\n")
  cat("- human_memory_update('decision') - Add to [[memory-human]]\n")
  cat("- Navigate to [[memory-hub]] for full system navigation\n")
  cat("- Use VS Code search (Ctrl+Shift+F) across ./ai/ folder\n")
  cat("- Use Foam wiki-links for navigation between memory components\n\n")
  
  cat("📚 **Memory Components:**\n")
  cat("- [[memory-hub]] - Central navigation and status\n")
  cat("- [[memory-human]] - Human decisions and reasoning\n")
  cat("- [[memory-ai]] - AI technical status and briefings\n")
  cat("- [[memory-guide]] - System documentation\n")
  cat("- ai/log/ - Detailed implementation reports\n\n")
  
  return(invisible(TRUE))
}

#' Context Refresh Helper
#' 
#' Simple reminder for context management
context_refresh <- function() {
  cat("🔄 **Context Refresh**\n")
  cat("For dynamic context management, use:\n")
  cat("- source('./scripts/update-copilot-context.R')\n")
  cat("- add_core_context() # Load essential project context\n")
  cat("- suggest_context() # Get smart suggestions\n")
  cat("- validate_context() # Check current context\n\n")
  cat("For memory navigation:\n")
  cat("- [[memory-hub]] # Central navigation\n")
  cat("- ai_memory_check() # This function\n")
  return(invisible(TRUE))
}

# Simple initialization
cat("🧠 AI Memory Functions Loaded (Books of Ukraine - Streamlined)\n")
cat("📚 Main Functions: ai_memory_check(), memory_status()\n")
cat("📝 Update Functions: simple_memory_update(), human_memory_update()\n")
cat("🔄 Utility Functions: quick_intent_scan(), context_refresh()\n")
cat("💡 Focus: Human-friendly, VS Code integrated, 5-component architecture\n")
