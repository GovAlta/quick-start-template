# Context Management Functions for AI Assistant System
# These functions manage the dynamic loading/unloading of context in copilot-instructions.md

# Helper: update the CONTEXT OVERVIEW header to reflect active persona
update_context_overview_persona <- function(instructions_lines, persona_label) {
  # Find the overview persona line (e.g., "- 2: Active Persona: Project Manager | ...")
  idx <- which(grepl("^- 2: Active Persona:", instructions_lines))
  if (length(idx) == 0) return(instructions_lines)
  # Preserve any size/token info after the first pipe if present
  line <- instructions_lines[idx[1]]
  suffix <- sub("^[^|]*\\|", "|", line)  # keeps leading pipe and the rest
  # Build the new line; fall back to no suffix if pipe wasn't present
  if (identical(suffix, line)) {
    new_line <- paste0("- 2: Active Persona: ", persona_label)
  } else {
    new_line <- paste0("- 2: Active Persona: ", persona_label, " ", suffix)
  }
  instructions_lines[idx[1]] <- new_line
  instructions_lines
}

# Function to activate project manager persona with full context
activate_project_manager <- function() {
  cat("🔄 Switching to Project Manager persona...\n")
  # Delegate to the dynamic context builder to ensure the Context Overview is accurate
  source("ai-support-system/scripts/dynamic-context-builder.R")
  set_persona_with_defaults("project-manager")
  cat("✅ Switched to Project Manager persona with full project context\n")
}

# Function to activate developer persona with minimal context
activate_developer <- function() {
  cat("🔄 Switching to Developer persona...\n")
  source("ai-support-system/scripts/dynamic-context-builder.R")
  set_persona_with_defaults("developer")
  cat("✅ Switched to Developer persona with minimal context\n")
}

# Function to activate case note analyst persona with specialized context
activate_casenote_analyst <- function() {
  cat("🔄 Switching to Case Note Analyst persona...\n")
  source("scripts/update-copilot-context.R")
  set_persona_with_defaults("casenote-analyst")
  cat("✅ Switched to Case Note Analyst persona with domain context\n")
}

# Function to activate data engineer persona with minimal context
activate_data_engineer <- function() {
  cat("🔄 Switching to Data Engineer persona...\n")
  source("scripts/update-copilot-context.R")
  set_persona_with_defaults("data-engineer")
  cat("✅ Switched to Data Engineer persona with data-focused context\n")
}

# Function to activate research scientist persona with minimal context
activate_research_scientist <- function() {
  cat("🔄 Switching to Research Scientist persona...\n")
  source("scripts/update-copilot-context.R")
  set_persona_with_defaults("research-scientist")
  cat("✅ Switched to Research Scientist persona with analytical focus\n")
}

# Function to activate devops engineer persona with minimal context
activate_devops_engineer <- function() {
  cat("🔄 Switching to DevOps Engineer persona...\n")
  source("scripts/update-copilot-context.R")
  set_persona_with_defaults("devops-engineer")
  cat("✅ Switched to DevOps Engineer persona with production focus\n")
}

# Function to activate frontend architect persona with visualization focus
activate_frontend_architect <- function() {
  cat("🔄 Switching to Frontend Architect persona...\n")
  source("scripts/update-copilot-context.R")
  set_persona_with_defaults("frontend-architect")
  cat("✅ Switched to Frontend Architect persona with visualization and UI focus\n")
}

# Function to activate prompt engineer persona with specialized context
activate_prompt_engineer <- function() {
  cat("🔄 Switching to Prompt Engineer persona...\n")
  source("scripts/update-copilot-context.R")
  set_persona_with_defaults("prompt-engineer")
  cat("✅ Switched to Prompt Engineer persona with RICECO framework context\n")
}

# Function to activate reporter persona with on-demand context
activate_reporter <- function() {
  cat("🔄 Switching to Reporter persona...\n")
  source("scripts/update-copilot-context.R")
  set_persona_with_defaults("reporter")
  cat("✅ Switched to Reporter persona with analytical storytelling focus\n")
}

# Function to activate default persona (minimal context)
activate_default <- function() {
  cat("🔄 Switching to Default persona...\n")
  source("scripts/update-copilot-context.R")
  # Use the unified 3-section builder with the 'default' persona we added
  set_persona_with_defaults("default")
  cat("✅ Switched to Default persona with minimal context\n")
}

# Function to show current context status
show_context_status <- function() {
  instructions_path <- ".github/copilot-instructions.md"
  
  if (!file.exists(instructions_path)) {
    cat("❌ Copilot instructions file not found\n")
    return(invisible())
  }
  
  instructions <- readLines(instructions_path, warn = FALSE)
  
  # Find current persona
  persona_line <- instructions[grepl("Currently active persona:", instructions, fixed = TRUE)]
  
  if (length(persona_line) > 0) {
    current_persona <- sub(".*Currently active persona:\\s*([^*]+).*", "\\1", persona_line[1])
    cat("🎭 Current Persona:", current_persona, "\n")
  } else {
    cat("❓ Could not determine current persona\n")
  }
  
  # Check for loaded context
  has_mission <- any(grepl("Project Mission", instructions, fixed = TRUE))
  has_method <- any(grepl("Project Method", instructions, fixed = TRUE))
  has_glossary <- any(grepl("Project Glossary", instructions, fixed = TRUE))
  
  cat("📄 Loaded Context:\n")
  cat("  Mission:", ifelse(has_mission, "✅", "❌"), "\n")
  cat("  Method:", ifelse(has_method, "✅", "❌"), "\n")
  cat("  Glossary:", ifelse(has_glossary, "✅", "❌"), "\n")
  
  # Calculate approximate size
  content_size <- sum(nchar(instructions)) / 1024
  cat("📊 Content Size:", round(content_size, 1), "KB\n")
  
  cat("🔧 Available Commands:\n")
  cat("  activate_default()         - General assistance (minimal context)\n")
  cat("  activate_developer()       - Technical focus (minimal context)\n")
  cat("  activate_data_engineer()   - Data pipeline & quality specialist (minimal context)\n")
  cat("  activate_research_scientist() - Statistical analysis & methodology specialist (minimal context)\n")
  cat("  activate_devops_engineer() - Production deployment & operations specialist (minimal context)\n")
  cat("  activate_project_manager() - Strategic oversight (full context)\n")
  cat("  activate_casenote_analyst() - Domain expertise (specialized context)\n")
  cat("  activate_prompt_engineer() - RICECO framework specialist (specialized context)\n")
  cat("  activate_reporter()        - Analytical storytelling (on-demand context)\n")
  cat("  show_context_status()      - Show this status\n")
}

# Initialize with default persona on script load
if (interactive()) {
  cat("🤖 AI Context Management System Loaded\n")
  cat("Type show_context_status() to see current configuration\n")
}