# AI Intent Detection & Memory Management

# This file contains R functions for automated project memory management
# It scans code, comments, and conversations for signs of creative intent
# and prompts for clarification to maintain project continuity

#' Detect Creative Intent Markers in Code
#' 
#' Scans R files for comments and code patterns that suggest unfinished 
#' work, design decisions, or future intentions
#' 
#' @param file_path Path to R file to analyze
#' @return List of detected intent markers with context
detect_code_intent <- function(file_path) {
  
  # Read file content
  if (!file.exists(file_path)) {
    return(list(error = paste("File not found:", file_path)))
  }
  
  content <- readLines(file_path, warn = FALSE)
  
  # Define intent markers
  intent_patterns <- list(
    todo = c("TODO", "FIXME", "HACK", "XXX"),
    future_work = c("next step", "next:", "later:", "future:", "plan to", "want to", "should", "need to"),
    decisions = c("decision:", "choice:", "note:", "rationale:", "because", "strategy:"),
    questions = c("\\?", "consider", "think about", "maybe", "perhaps", "might", "could"),
    unfinished = c("incomplete", "partial", "draft", "temp", "temporary", "placeholder"),
    research_intent = c("hypothesis", "expect", "predict", "compare", "analyze", "investigate")
  )
  
  detected_intents <- list()
  
  for (category in names(intent_patterns)) {
    patterns <- intent_patterns[[category]]
    matches <- list()
    
    for (i in seq_along(content)) {
      line <- content[i]
      for (pattern in patterns) {
        if (grepl(pattern, line, ignore.case = TRUE)) {
          matches <- append(matches, list(list(
            line_number = i,
            line_content = line,
            pattern = pattern,
            context = if(i > 1) content[max(1, i-1)] else ""
          )))
        }
      }
    }
    
    if (length(matches) > 0) {
      detected_intents[[category]] <- matches
    }
  }
  
  return(detected_intents)
}

#' Generate Project Memory Briefing
#' 
#' Creates a contextual briefing based on current project state,
#' recent changes, and detected intentions
#' 
#' @param project_root Path to project root directory
#' @return Character vector with briefing content
generate_project_briefing <- function(project_root = ".") {
  
  briefing <- c()
  timestamp <- Sys.time()
  
  # Header
  briefing <- c(briefing, paste("# Project Memory Briefing"))
  briefing <- c(briefing, paste("Generated:", format(timestamp, "%Y-%m-%d %H:%M")))
  briefing <- c(briefing, "")
  
  # Current working context
  current_files <- list.files(file.path(project_root, "manipulation"), 
                             pattern = "\\.R$", full.names = TRUE)
  recent_files <- current_files[file.info(current_files)$mtime > (Sys.time() - 86400*7)] # Last week
  
  if (length(recent_files) > 0) {
    briefing <- c(briefing, "## 🔄 Recent Activity")
    briefing <- c(briefing, paste("Recently modified files:"))
    for (file in recent_files) {
      mtime <- file.info(file)$mtime
      briefing <- c(briefing, paste("-", basename(file), "| Modified:", format(mtime, "%Y-%m-%d")))
    }
    briefing <- c(briefing, "")
  }
  
  # Detect intentions in key files
  key_files <- c(
    file.path(project_root, "manipulation", "0-ellis.R"),
    file.path(project_root, "manipulation", "1-scribe.R"), 
    file.path(project_root, "flow.R")
  )
  
  briefing <- c(briefing, "## 🎯 Detected Intentions")
  
  for (file in key_files) {
    if (file.exists(file)) {
      intents <- detect_code_intent(file)
      if (length(intents) > 0) {
        briefing <- c(briefing, paste("### ", basename(file)))
        for (category in names(intents)) {
          if (length(intents[[category]]) > 0) {
            briefing <- c(briefing, paste("**", toupper(category), ":**"))
            for (item in head(intents[[category]], 3)) { # Top 3 per category
              briefing <- c(briefing, paste("- Line", item$line_number, ":", trimws(item$line_content)))
            }
          }
        }
        briefing <- c(briefing, "")
      }
    }
  }
  
  # Recent git activity (if available)
  if (dir.exists(file.path(project_root, ".git"))) {
    briefing <- c(briefing, "## 📝 Recent Commits")
    tryCatch({
      recent_commits <- system2("git", 
                               args = c("log", "--oneline", "-5"), 
                               stdout = TRUE, 
                               stderr = FALSE)
      for (commit in recent_commits) {
        briefing <- c(briefing, paste("-", commit))
      }
    }, error = function(e) {
      briefing <- c(briefing, "Git log not available")
    })
    briefing <- c(briefing, "")
  }
  
  return(briefing)
}

#' Prompt for Intent Clarification
#' 
#' When AI detects ambiguous or incomplete intentions,
#' generate clarifying questions for the human
#' 
#' @param detected_intents Output from detect_code_intent()
#' @return Character vector with clarifying questions
generate_clarification_prompts <- function(detected_intents) {
  
  prompts <- c()
  
  if ("questions" %in% names(detected_intents)) {
    prompts <- c(prompts, "🤔 **I noticed some uncertainties in your code:**")
    for (item in head(detected_intents$questions, 3)) {
      question <- gsub("^\\s*#\\s*", "", item$line_content)
      prompts <- c(prompts, paste("- Line", item$line_number, ":", question))
    }
    prompts <- c(prompts, "*Would you like to clarify these decisions?*")
    prompts <- c(prompts, "")
  }
  
  if ("future_work" %in% names(detected_intents)) {
    prompts <- c(prompts, "🚀 **I see planned next steps:**")
    for (item in head(detected_intents$future_work, 3)) {
      plan <- gsub("^\\s*#\\s*", "", item$line_content)
      prompts <- c(prompts, paste("- Line", item$line_number, ":", plan))
    }
    prompts <- c(prompts, "*Should I add these to the project memory with priority levels?*")
    prompts <- c(prompts, "")
  }
  
  if ("unfinished" %in% names(detected_intents)) {
    prompts <- c(prompts, "⚠️ **Detected incomplete work:**")
    for (item in head(detected_intents$unfinished, 3)) {
      incomplete <- gsub("^\\s*#\\s*", "", item$line_content)
      prompts <- c(prompts, paste("- Line", item$line_number, ":", incomplete))
    }
    prompts <- c(prompts, "*What's the plan for completing these items?*")
    prompts <- c(prompts, "")
  }
  
  return(prompts)
}

#' Update Project Memory File
#' 
#' Adds new intentions, decisions, or insights to project-memory.md
#' 
#' @param memory_entry New content to add
#' @param category Category for the entry (decisions, intentions, insights, etc.)
#' @param project_root Path to project root
update_project_memory <- function(memory_entry, category = "intentions", project_root = ".") {
  
  memory_file <- file.path(project_root, "ai", "project-memory.md")
  
  if (!file.exists(memory_file)) {
    stop("Project memory file not found. Run create_project_memory() first.")
  }
  
  # Read current content
  content <- readLines(memory_file, warn = FALSE)
  
  # Find insertion point based on category
  insertion_points <- list(
    decisions = "### **Design Decisions Made**",
    intentions = "## 🔄 Next Steps & Unfinished Business",
    insights = "## 💡 Insights & Discoveries",
    risks = "## 🚨 Risk Factors & Monitoring"
  )
  
  target_header <- insertion_points[[category]]
  if (is.null(target_header)) {
    target_header <- "## 🔄 Next Steps & Unfinished Business" # Default
  }
  
  # Find line to insert after
  insert_line <- which(grepl(target_header, content, fixed = TRUE))
  
  if (length(insert_line) == 0) {
    # Add at end if section not found
    insert_line <- length(content)
  } else {
    # Insert after the header and any existing content
    insert_line <- insert_line[1] + 1
    while (insert_line <= length(content) && 
           (content[insert_line] == "" || !grepl("^##", content[insert_line]))) {
      insert_line <- insert_line + 1
    }
    insert_line <- insert_line - 1
  }
  
  # Prepare new entry
  timestamp <- format(Sys.time(), "%Y-%m-%d")
  new_entry <- c(
    "",
    paste("**", timestamp, "**:", memory_entry),
    ""
  )
  
  # Insert the new content
  updated_content <- c(
    content[1:insert_line],
    new_entry,
    content[(insert_line + 1):length(content)]
  )
  
  # Write back to file
  writeLines(updated_content, memory_file)
  
  message("Updated project memory with new ", category, " entry")
}

#' AI Memory Prompt Function
#' 
#' Main function for AI to call when detecting need for memory capture
#' 
#' @param context Current conversation context
#' @param project_root Path to project root
ai_memory_check <- function(context = "", project_root = ".") {
  
  cat("🧠 **AI Memory System Activated**\n\n")
  
  # Generate current briefing
  briefing <- generate_project_briefing(project_root)
  cat(paste(briefing, collapse = "\n"))
  cat("\n\n")
  
  # Scan for intentions in current work
  current_file <- file.path(project_root, "manipulation", "0-ellis.R")
  if (file.exists(current_file)) {
    intents <- detect_code_intent(current_file)
    if (length(intents) > 0) {
      prompts <- generate_clarification_prompts(intents)
      if (length(prompts) > 0) {
        cat("🤖 **AI Detected Unclear Intentions:**\n")
        cat(paste(prompts, collapse = "\n"))
        cat("\n\n")
      }
    }
  }
  
  # Context-based suggestions
  if (grepl("TODO|next|plan|should|need to", context, ignore.case = TRUE)) {
    cat("💭 **I noticed planning language in our conversation.**\n")
    cat("Should I capture these intentions in the project memory?\n\n")
  }
  
  if (grepl("decision|choice|because|rationale", context, ignore.case = TRUE)) {
    cat("🎯 **I detected decision-making language.**\n")
    cat("Would you like me to document the rationale for future reference?\n\n")
  }
  
  cat("📝 **Memory Management Options:**\n")
  cat("1. Update project memory with current insights\n")
  cat("2. Add clarification to specific intention\n")
  cat("3. Generate full project status report\n")
  cat("4. Scan all files for undocumented intentions\n\n")
  
  return(invisible(TRUE))
}

#' Quick Memory Status Check
#' 
#' Lightweight function to show current project state
memory_status <- function(project_root = ".") {
  
  memory_file <- file.path(project_root, "ai", "project-memory.md")
  
  if (!file.exists(memory_file)) {
    cat("❌ No project memory file found\n")
    cat("💡 Run: ai_memory_check() to initialize\n")
    return(invisible(FALSE))
  }
  
  # Get last modification
  mtime <- file.info(memory_file)$mtime
  age_days <- as.numeric(Sys.time() - mtime) / 86400
  
  cat("📊 **Project Memory Status**\n")
  cat("Last updated:", format(mtime, "%Y-%m-%d %H:%M"), "\n")
  cat("Age:", round(age_days, 1), "days\n")
  
  if (age_days > 7) {
    cat("⚠️ Memory file is over a week old - consider refreshing\n")
  }
  
  # Count detected intentions in current work
  current_files <- list.files(file.path(project_root, "manipulation"), 
                             pattern = "\\.R$", full.names = TRUE)
  intent_count <- 0
  
  for (file in current_files) {
    intents <- detect_code_intent(file)
    intent_count <- intent_count + length(unlist(intents))
  }
  
  cat("Current detected intentions:", intent_count, "\n")
  
  if (intent_count > 10) {
    cat("💡 High intent count - consider memory update\n")
  }
  
  return(invisible(TRUE))
}

# Auto-export functions for easy access
if (!exists("project_memory_initialized")) {
  cat("🧠 Project Memory System Loaded\n")
  cat("📚 Available functions:\n")
  cat("  - ai_memory_check()     # Main AI function\n")
  cat("  - memory_status()       # Quick status check\n")
  cat("  - generate_project_briefing() # Full briefing\n")
  cat("  - update_project_memory()     # Manual memory update\n")
  
  project_memory_initialized <- TRUE
}
