# Portable AI Migration Toolkit
# Exportable logic for persona switching and repository migration
# Version: 1.0.0 - Designed for portability and cross-repository deployment

# === CONFIGURATION DETECTION ===
# Detects the AI support system configuration in the current project

detect_ai_config <- function(project_root = ".") {
  # Look for main config.yml file
  config_path <- file.path(project_root, "config.yml")
  
  if (file.exists(config_path)) {
    # Try to read and check if it has AI support section
    tryCatch({
      if (requireNamespace("yaml", quietly = TRUE)) {
        config_content <- yaml::yaml.load_file(config_path)
        has_ai_support <- !is.null(config_content$default$ai_support)
        config_type <- ifelse(has_ai_support, "ai-support-enabled", "basic")
      } else {
        # Fallback if yaml package not available - check for ai_support text
        config_text <- readLines(config_path, warn = FALSE)
        has_ai_support <- any(grepl("ai_support:", config_text, fixed = TRUE))
        config_type <- ifelse(has_ai_support, "ai-support-enabled", "basic")
      }
      return(list(type = config_type, path = config_path, root = project_root))
    }, error = function(e) {
      return(list(type = "basic", path = config_path, root = project_root))
    })
  } else {
    return(list(type = "none", path = NULL, root = project_root))
  }
}

# === PERSONA MANAGEMENT (PORTABLE LOGIC) ===

# Get available personas from the project structure
get_available_personas <- function(project_root = ".") {
  config <- detect_ai_config(project_root)
  
  # For both ai-support-enabled and basic configs, personas are in ai/personas
  persona_dir <- file.path(project_root, "ai", "personas")
  
  if (!dir.exists(persona_dir)) {
    cat("⚠️  Personas directory not found:", persona_dir, "\n")
    cat("💡 To enable AI personas, create the directory and add persona definition files (.md)\n")
    cat("   Example: Create files like 'developer.md', 'analyst.md' with persona instructions\n")
    return(character(0))
  }
  
  personas <- list.files(persona_dir, pattern = "\\.md$", full.names = FALSE)
  
  if (length(personas) == 0) {
    cat("⚠️  No persona files found in:", persona_dir, "\n")
    cat("💡 Add persona definition files (.md) to enable AI role switching\n")
  }
  
  return(gsub("\\.md$", "", personas))
}

# Set persona with automatic path detection
set_persona_with_autodetect <- function(persona_name, project_root = ".") {
  # Update copilot instructions
  instructions_path <- file.path(project_root, ".github", "copilot-instructions.md")
  if (!file.exists(instructions_path)) {
    cat("❌ Copilot instructions file not found:", instructions_path, "\n")
    return(invisible(FALSE))
  }

  # Track active persona (simple marker file)
  persona_file <- file.path(project_root, ".copilot-persona")
  writeLines(persona_name, persona_file)

  # Try to use dynamic-context-builder if available; fall back to simple insert
  context_script <- file.path(project_root, "ai", "scripts", "dynamic-context-builder.R")
  if (file.exists(context_script)) {
    source(context_script, local = TRUE)
    # Some versions expose set_persona_with_defaults; if not present we proceed with lightweight update.
    if (exists("set_persona_with_defaults")) {
      fn <- get("set_persona_with_defaults")
      tryCatch({
        fn(persona_name)
        return(invisible(TRUE))
      }, error = function(e) {
        cat("⚠️  Failed enhanced persona load, using fallback minimal update.\n")
      })
    }
  }

  # Fallback: prepend simple persona header (non-destructive) if dynamic builder not used
  current <- readLines(instructions_path, warn = FALSE)
  header <- c(
    "<!-- ACTIVE PERSONA (fallback) START -->",
    paste0("Currently active persona: ", persona_name),
    "<!-- ACTIVE PERSONA (fallback) END -->"
  )
  # Remove previous fallback header if present
  start_idx <- grep("<!-- ACTIVE PERSONA (fallback) START -->", current, fixed = TRUE)
  end_idx <- grep("<!-- ACTIVE PERSONA (fallback) END -->", current, fixed = TRUE)
  if (length(start_idx) == 1 && length(end_idx) == 1 && end_idx >= start_idx) {
    current <- current[-c(start_idx:end_idx)]
  }
  writeLines(c(header, current), instructions_path)
  invisible(TRUE)
}

# === PERSONA ACTIVATION FUNCTIONS (EXPORTABLE) ===

# Function to activate project manager persona with full context
activate_project_manager <- function(project_root = ".") {
  cat("🔄 Switching to Project Manager persona...\n")
  set_persona_with_autodetect("project-manager", project_root)
  cat("✅ Switched to Project Manager persona with full project context\n")
}

# Function to activate developer persona with minimal context
activate_developer <- function(project_root = ".") {
  cat("🔄 Switching to Developer persona...\n")
  set_persona_with_autodetect("developer", project_root)
  cat("✅ Switched to Developer persona with minimal context\n")
}

# Function to activate data engineer persona with minimal context
activate_data_engineer <- function(project_root = ".") {
  cat("🔄 Switching to Data Engineer persona...\n")
  set_persona_with_autodetect("data-engineer", project_root)
  cat("✅ Switched to Data Engineer persona with data-focused context\n")
}

# Function to activate research scientist persona with minimal context
activate_research_scientist <- function(project_root = ".") {
  cat("🔄 Switching to Research Scientist persona...\n")
  set_persona_with_autodetect("research-scientist", project_root)
  cat("✅ Switched to Research Scientist persona with analytical focus\n")
}

# Function to activate devops engineer persona with minimal context
activate_devops_engineer <- function(project_root = ".") {
  cat("🔄 Switching to DevOps Engineer persona...\n")
  set_persona_with_autodetect("devops-engineer", project_root)
  cat("✅ Switched to DevOps Engineer persona with production focus\n")
}

# Function to activate frontend architect persona with visualization focus
activate_frontend_architect <- function(project_root = ".") {
  cat("🔄 Switching to Frontend Architect persona...\n")
  set_persona_with_autodetect("frontend-architect", project_root)
  cat("✅ Switched to Frontend Architect persona with visualization and UI focus\n")
}

# Function to activate prompt engineer persona with specialized context
activate_prompt_engineer <- function(project_root = ".") {
  cat("🔄 Switching to Prompt Engineer persona...\n")
  set_persona_with_autodetect("prompt-engineer", project_root)
  cat("✅ Switched to Prompt Engineer persona with RICECO framework context\n")
}

# Function to activate reporter persona with on-demand context
activate_reporter <- function(project_root = ".") {
  cat("🔄 Switching to Reporter persona...\n")
  set_persona_with_autodetect("reporter", project_root)
  cat("✅ Switched to Reporter persona with analytical storytelling focus\n")
}

activate_grapher <- function(project_root = ".") {
  cat("🔄 Switching to Grapher persona...\n")
  set_persona_with_autodetect("grapher", project_root)
  cat("✅ Switched to Grapher persona with data visualization focus\n")
}

# Function to activate default persona (minimal context)
activate_default <- function(project_root = ".") {
  cat("🔄 Switching to Default persona...\n")
  set_persona_with_autodetect("default", project_root)
  cat("✅ Switched to Default persona with minimal context\n")
}

# === STATUS AND DIAGNOSTICS (PORTABLE) ===

# Function to show current context status
show_context_status <- function(project_root = ".") {
  config <- detect_ai_config(project_root)
  instructions_path <- file.path(project_root, ".github", "copilot-instructions.md")
  
  cat("🏗️  Configuration Type:", config$type, "\n")
  
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
  
  # Show available personas
  available_personas <- get_available_personas(project_root)
  if (length(available_personas) > 0) {
    cat("🎭 Available Personas:", paste(available_personas, collapse = ", "), "\n")
  }
  
  cat("🔧 Available Commands:\n")
  cat("  activate_default()         - General assistance (minimal context)\n")
  cat("  activate_developer()       - Technical focus (minimal context)\n")
  cat("  activate_data_engineer()   - Data pipeline & quality specialist (minimal context)\n")
  cat("  activate_research_scientist() - Statistical analysis & methodology specialist (minimal context)\n")
  cat("  activate_devops_engineer() - Production deployment & operations specialist (minimal context)\n")
  cat("  activate_project_manager() - Strategic oversight (full context)\n")
  cat("  activate_prompt_engineer() - RICECO framework specialist (specialized context)\n")
  cat("  activate_reporter()        - Analytical storytelling (on-demand context)\n")
  cat("  activate_grapher()         - Data visualization focus\n")
  cat("  show_context_status()      - Show this status\n")
}

# === MIGRATION UTILITIES ===

# Check compatibility with target repository
check_migration_compatibility <- function(target_path) {
  required_files <- c("config.yml", "flow.R", "README.md")
  
  cat("🔍 Checking migration compatibility for:", target_path, "\n")
  
  compatibility <- list(
    target_exists = dir.exists(target_path),
    required_files = character(0),
    missing_files = character(0),
    existing_ai_support = FALSE,
    vscode_tasks = file.exists(file.path(target_path, ".vscode", "tasks.json")),
    github_dir = dir.exists(file.path(target_path, ".github"))
  )
  
  for (file in required_files) {
    file_path <- file.path(target_path, file)
    if (file.exists(file_path)) {
      compatibility$required_files <- c(compatibility$required_files, file)
    } else {
      compatibility$missing_files <- c(compatibility$missing_files, file)
    }
  }
  
  # Check for existing AI support
  ai_indicators <- c(
    ".copilot-persona",
    "ai/personas",
    ".github/copilot-instructions.md"
  )
  
  for (indicator in ai_indicators) {
    if (file.exists(file.path(target_path, indicator)) || dir.exists(file.path(target_path, indicator))) {
      compatibility$existing_ai_support <- TRUE
      break
    }
  }
  
  return(compatibility)
}

# Generate migration impact assessment
generate_migration_assessment <- function(source_path = ".", target_path, components = c("personas", "context", "memory", "vscode")) {
  cat("📋 MIGRATION IMPACT ASSESSMENT\n")
  cat("=====================================\n\n")
  
  cat("🎯 **Migration Details**\n")
  cat("Source:", source_path, "\n")
  cat("Target:", target_path, "\n")
  cat("Components:", paste(components, collapse = ", "), "\n\n")
  
  compatibility <- check_migration_compatibility(target_path)
  
  cat("🔍 **Compatibility Check**\n")
  cat("Target exists:", ifelse(compatibility$target_exists, "✅", "❌"), "\n")
  cat("Required files present:", length(compatibility$required_files), "/", length(compatibility$required_files) + length(compatibility$missing_files), "\n")
  
  if (length(compatibility$missing_files) > 0) {
    cat("Missing files:", paste(compatibility$missing_files, collapse = ", "), "\n")
  }
  
  cat("Existing AI support:", ifelse(compatibility$existing_ai_support, "⚠️  YES", "✅ None"), "\n")
  cat("VSCode tasks:", ifelse(compatibility$vscode_tasks, "✅", "❌"), "\n")
  cat("GitHub directory:", ifelse(compatibility$github_dir, "✅", "❌"), "\n\n")
  
  cat("📝 **Planned Changes**\n")
  
  # Files to be created
  new_files <- c()
  if ("personas" %in% components) new_files <- c(new_files, "ai/personas/")
  if ("context" %in% components) new_files <- c(new_files, ".github/copilot-instructions.md", ".copilot-persona")
  if ("memory" %in% components) new_files <- c(new_files, "ai/scripts/ai-memory-functions.R")
  if ("vscode" %in% components) new_files <- c(new_files, ".vscode/tasks.json (additions)")
  
  cat("New files/directories:\n")
  for (file in new_files) {
    cat("  +", file, "\n")
  }
  
  # Files to be modified
  modified_files <- c()
  if (file.exists(file.path(target_path, "config.yml"))) modified_files <- c(modified_files, "config.yml (ai_support section)")
  if (compatibility$vscode_tasks && "vscode" %in% components) modified_files <- c(modified_files, ".vscode/tasks.json (task additions)")
  
  if (length(modified_files) > 0) {
    cat("\nModified files:\n")
    for (file in modified_files) {
      cat("  ~", file, "\n")
    }
  }
  
  cat("\n⚠️  **Potential Conflicts**\n")
  if (compatibility$existing_ai_support) {
    cat("- Existing AI support system detected - manual review required\n")
  }
  if (!compatibility$github_dir && "context" %in% components) {
    cat("- .github directory will be created for Copilot integration\n")
  }
  if (length(compatibility$missing_files) > 0) {
    cat("- Missing required files may indicate incompatible repository structure\n")
  }
  
  cat("\n✅ **Recommended Actions**\n")
  cat("1. Review and approve this assessment\n")
  cat("2. Backup target repository\n")
  if (compatibility$existing_ai_support) {
    cat("3. Manually resolve AI support conflicts\n")
  }
  cat("3. Proceed with migration\n")
  cat("4. Test all components after migration\n")
  
  return(compatibility)
}

# Initialize with current project detection
if (interactive()) {
  config <- detect_ai_config()
  cat("🤖 Portable AI Context Management System Loaded\n")
  cat("🏗️  Detected configuration:", config$type, "\n")
  cat("Type show_context_status() to see current configuration\n")
}
