# AI Support System Migration Utilities
# Export/Import tools for AI-augmented research infrastructure
# Version: 1.0.0 - Manual and AI-assisted migration support

# Load required libraries
if (!require("yaml", quietly = TRUE)) {
  stop("Required package 'yaml' not found. Install with: install.packages('yaml')")
}

if (!require("jsonlite", quietly = TRUE)) {
  stop("Required package 'jsonlite' not found. Install with: install.packages('jsonlite')")
}

# === EXPORT UTILITIES ===

#' Export AI Support Components
#' 
#' Package selected AI support components for migration to another repository
export_ai_components <- function(
  components = c("personas", "context", "memory", "vscode"),
  export_path = "ai-support-export",
  source_path = ".",
  include_templates = TRUE,
  create_assessment = TRUE
) {
  
  cat("📦 **Exporting AI Support Components**\n")
  cat("=====================================\n\n")
  
  # Validate source
  if (!validate_source_structure(source_path)) {
    cat("❌ Source repository does not have valid AI support system\n")
    return(invisible(FALSE))
  }
  
  # Create export directory
  if (!dir.exists(export_path)) {
    dir.create(export_path, recursive = TRUE)
    cat("📁 Created export directory:", export_path, "\n")
  }
  
  export_manifest <- list(
    export_date = Sys.time(),
    source_path = source_path,
    components = components,
    version = "1.0.0"
  )
  
  # Export each component
  for (component in components) {
    result <- export_component(component, source_path, export_path)
    export_manifest[[paste0(component, "_export")]] <- result
    
    if (result$success) {
      cat("✅ Exported:", component, "\n")
    } else {
      cat("❌ Failed to export:", component, "-", result$error, "\n")
    }
  }
  
  # Include migration templates
  if (include_templates) {
    export_migration_templates(source_path, export_path)
    cat("✅ Exported migration templates\n")
  }
  
  # Create migration assessment template
  if (create_assessment) {
    create_assessment_template(export_path, components)
    cat("✅ Created assessment template\n")
  }
  
  # Write export manifest
  yaml::write_yaml(export_manifest, file.path(export_path, "export-manifest.yml"))
  
  cat("\n📋 **Export Summary**\n")
  cat("Export path:", export_path, "\n")
  cat("Components:", paste(components, collapse = ", "), "\n")
  cat("Use import_ai_components() to install in target repository\n")
  
  return(export_manifest)
}

#' Export Individual Component
export_component <- function(component, source_path, export_path) {
  
  result <- list(success = FALSE, files = character(0), error = NULL)
  
  tryCatch({
    if (component == "personas") {
      result <- export_personas(source_path, export_path)
    } else if (component == "context") {
      result <- export_context_management(source_path, export_path) 
    } else if (component == "memory") {
      result <- export_memory_system(source_path, export_path)
    } else if (component == "vscode") {
      result <- export_vscode_integration(source_path, export_path)
    } else {
      result$error <- paste("Unknown component:", component)
    }
  }, error = function(e) {
    result$error <- as.character(e)
  })
  
  return(result)
}

#' Export Personas
export_personas <- function(source_path, export_path) {
  personas_source <- file.path(source_path, "./ai", "personas")
  personas_export <- file.path(export_path, "personas")
  
  if (!dir.exists(personas_source)) {
    personas_source <- file.path(source_path, "ai", "personas")
  }
  
  if (!dir.exists(personas_source)) {
    return(list(success = FALSE, error = "Personas directory not found"))
  }
  
  dir.create(personas_export, recursive = TRUE, showWarnings = FALSE)
  
  persona_files <- list.files(personas_source, pattern = "\\.md$", full.names = TRUE)
  exported_files <- character(0)
  
  for (file in persona_files) {
    target_file <- file.path(personas_export, basename(file))
    if (file.copy(file, target_file, overwrite = TRUE)) {
      exported_files <- c(exported_files, basename(file))
    }
  }
  
  return(list(success = TRUE, files = exported_files))
}

#' Export Context Management
export_context_management <- function(source_path, export_path) {
  context_export <- file.path(export_path, "context")
  dir.create(context_export, recursive = TRUE, showWarnings = FALSE)
  
  # Core instructions
  core_source <- file.path(source_path, "./ai", "core")
  if (dir.exists(core_source)) {
    file.copy(core_source, context_export, recursive = TRUE, overwrite = TRUE)
  }
  
  # Context management script
  script_files <- c(
    "./ai/scripts/ai-migration-toolkit.R",
    "./ai/scripts/update-copilot-context.R",
    "scripts/ai-migration-toolkit.R",
    "scripts/update-copilot-context.R"
  )
  
  exported_files <- character(0)
  for (script in script_files) {
    source_file <- file.path(source_path, script)
    if (file.exists(source_file)) {
      target_file <- file.path(context_export, basename(script))
      if (file.copy(source_file, target_file, overwrite = TRUE)) {
        exported_files <- c(exported_files, basename(script))
      }
    }
  }
  
  return(list(success = length(exported_files) > 0, files = exported_files))
}

#' Export Memory System  
export_memory_system <- function(source_path, export_path) {
  memory_export <- file.path(export_path, "memory")
  dir.create(memory_export, recursive = TRUE, showWarnings = FALSE)
  
  # Memory functions script
  script_files <- c(
    "./ai/scripts/ai-memory-functions.R",
    "scripts/ai-memory-functions.R"
  )
  
  exported_files <- character(0)
  for (script in script_files) {
    source_file <- file.path(source_path, script)
    if (file.exists(source_file)) {
      target_file <- file.path(memory_export, basename(script))
      if (file.copy(source_file, target_file, overwrite = TRUE)) {
        exported_files <- c(exported_files, basename(script))
      }
    }
  }
  
  # Memory templates (not actual memory files - storage/logic separation)
  template_content <- list(
    "memory-hub-template.md" = "# Memory Hub\n\nCentral navigation for project memory system.\n",
    "memory-ai-template.md" = "# AI Memory\n\nAI system status and technical briefings.\n",
    "memory-human-template.md" = "# Human Memory\n\nHuman decisions and reasoning.\n",
    "memory-guide-template.md" = "# Memory Guide\n\nDocumentation for the memory system.\n"
  )
  
  for (filename in names(template_content)) {
    target_file <- file.path(memory_export, filename)
    writeLines(template_content[[filename]], target_file)
    exported_files <- c(exported_files, filename)
  }
  
  return(list(success = TRUE, files = exported_files))
}

#' Export VSCode Integration
export_vscode_integration <- function(source_path, export_path) {
  vscode_export <- file.path(export_path, "vscode")
  dir.create(vscode_export, recursive = TRUE, showWarnings = FALSE)
  
  # Task template
  task_template <- file.path(source_path, "./ai", "vscode", "tasks-template.json")
  if (file.exists(task_template)) {
    file.copy(task_template, file.path(vscode_export, "tasks-template.json"), overwrite = TRUE)
    return(list(success = TRUE, files = c("tasks-template.json")))
  }
  
  return(list(success = FALSE, error = "VSCode task template not found"))
}

# === IMPORT UTILITIES ===

#' Import AI Support Components
#' 
#' Import and install AI support components from export package
import_ai_components <- function(
  export_path,
  target_path = ".",
  components = NULL,
  mode = "manual",  # "manual" or "ai_assisted"
  dry_run = TRUE,
  backup = TRUE
) {
  
  cat("📥 **Importing AI Support Components**\n")
  cat("=====================================\n\n")
  
  # Load export manifest
  manifest_file <- file.path(export_path, "export-manifest.yml")
  if (!file.exists(manifest_file)) {
    cat("❌ Export manifest not found:", manifest_file, "\n")
    return(invisible(FALSE))
  }
  
  manifest <- yaml::read_yaml(manifest_file)
  
  # Use all components from manifest if not specified
  if (is.null(components)) {
    components <- manifest$components
  }
  
  cat("📋 Import Details:\n")
  cat("  Export date:", as.character(manifest$export_date), "\n")
  cat("  Components:", paste(components, collapse = ", "), "\n")
  cat("  Mode:", mode, "\n")
  cat("  Target:", target_path, "\n\n")
  
  # Pre-import assessment
  if (mode == "manual") {
    assessment <- generate_import_assessment(export_path, target_path, components)
    
    cat("📊 **MANDATORY ASSESSMENT REQUIRED**\n")
    print_import_assessment(assessment)
    
    if (!assessment$compatible) {
      cat("❌ Import cannot proceed due to compatibility issues\n")
      return(invisible(FALSE))
    }
    
    if (!dry_run && !confirm_import_after_assessment()) {
      cat("❌ Import cancelled by user\n")
      return(invisible(FALSE))
    }
  }
  
  # Create backup if requested
  backup_path <- NULL
  if (backup && !dry_run) {
    backup_path <- create_import_backup(target_path)
    cat("💾 Backup created:", backup_path, "\n")
  }
  
  # Execute import
  if (!dry_run) {
    if (mode == "ai_assisted") {
      result <- execute_ai_assisted_import(export_path, target_path, components)
    } else {
      result <- execute_manual_import(export_path, target_path, components)
    }
    
    # Validate import
    validation <- validate_import(target_path, components)
    
    if (validation$success) {
      cat("✅ **Import Successful**\n")
      print_import_summary(result, validation)
    } else {
      cat("❌ **Import Failed**\n")
      if (!is.null(backup_path)) {
        cat("🔄 Restoring from backup...\n")
        restore_from_backup(backup_path, target_path)
      }
    }
    
    return(result)
  } else {
    cat("🧪 **Dry Run Complete - No Changes Made**\n")
    return(list(dry_run = TRUE, assessment = assessment))
  }
}

# === ASSESSMENT UTILITIES ===

#' Generate Import Assessment
#' 
#' Mandatory assessment for manual imports
generate_import_assessment <- function(export_path, target_path, components) {
  
  assessment <- list(
    compatible = TRUE,
    warnings = character(0),
    conflicts = character(0),
    requirements_met = TRUE,
    estimated_changes = list()
  )
  
  # Check target repository structure
  target_analysis <- analyze_target_structure(target_path)
  assessment$target_analysis <- target_analysis
  
  if (!target_analysis$valid) {
    assessment$compatible <- FALSE
    assessment$warnings <- c(assessment$warnings, "Target repository structure invalid")
  }
  
  # Check for conflicts
  conflicts <- detect_import_conflicts(export_path, target_path, components)
  if (length(conflicts) > 0) {
    assessment$conflicts <- conflicts
    if (any(conflicts$severity == "critical")) {
      assessment$compatible <- FALSE
    }
  }
  
  # Estimate changes for each component
  for (component in components) {
    changes <- estimate_component_changes(component, export_path, target_path)
    assessment$estimated_changes[[component]] <- changes
  }
  
  return(assessment)
}

#' Print Import Assessment
print_import_assessment <- function(assessment) {
  
  cat("🎯 **TARGET REPOSITORY ANALYSIS**\n")
  cat("Repository type:", assessment$target_analysis$type, "\n")
  cat("Structure valid:", ifelse(assessment$target_analysis$valid, "✅", "❌"), "\n")
  cat("Existing AI support:", ifelse(assessment$target_analysis$has_ai_support, "⚠️  YES", "✅ None"), "\n\n")
  
  cat("⚠️  **POTENTIAL CONFLICTS** (", length(assessment$conflicts), ")\n")
  if (length(assessment$conflicts) == 0) {
    cat("✅ No conflicts detected\n")
  } else {
    for (conflict in assessment$conflicts) {
      cat("  -", conflict$type, ":", conflict$description, "\n")
    }
  }
  cat("\n")
  
  cat("📝 **ESTIMATED CHANGES**\n")
  for (component in names(assessment$estimated_changes)) {
    changes <- assessment$estimated_changes[[component]]
    cat("  ", component, ":\n")
    cat("    New files:", length(changes$new_files), "\n")
    cat("    Modified files:", length(changes$modified_files), "\n")
    if (length(changes$modified_files) > 0) {
      for (file in changes$modified_files) {
        cat("      ~", file, "\n")
      }
    }
  }
  cat("\n")
  
  cat("🔍 **COMPATIBILITY SUMMARY**\n")
  cat("Overall compatibility:", ifelse(assessment$compatible, "✅ COMPATIBLE", "❌ INCOMPATIBLE"), "\n")
  cat("Requirements met:", ifelse(assessment$requirements_met, "✅", "❌"), "\n")
  cat("Warnings:", length(assessment$warnings), "\n")
  
  if (length(assessment$warnings) > 0) {
    for (warning in assessment$warnings) {
      cat("  ⚠️ ", warning, "\n")
    }
  }
}

#' Confirm Import After Assessment
confirm_import_after_assessment <- function() {
  cat("\n❓ **MANDATORY REVIEW REQUIRED**\n")
  cat("Have you carefully reviewed the assessment above?\n")
  cat("Do you understand the changes that will be made?\n")
  cat("Do you have a backup of your target repository?\n\n")
  
  response <- readline("Type 'YES I UNDERSTAND' to proceed: ")
  return(response == "YES I UNDERSTAND")
}

# === VALIDATION UTILITIES ===

#' Validate Source Structure
validate_source_structure <- function(source_path) {
  required_indicators <- c(
    "./ai",
    "./ai/ai-support-config.yml",
    "./ai/personas"
  )
  
  for (indicator in required_indicators) {
    path <- file.path(source_path, indicator)
    if (!file.exists(path) && !dir.exists(path)) {
      return(FALSE)
    }
  }
  
  return(TRUE)
}

#' Analyze Target Structure
analyze_target_structure <- function(target_path) {
  analysis <- list(
    valid = FALSE,
    type = "unknown",
    has_ai_support = FALSE,
    has_vscode = FALSE,
    has_github = FALSE
  )
  
  if (!dir.exists(target_path)) {
    return(analysis)
  }
  
  analysis$valid <- TRUE
  
  # Detect type
  if (file.exists(file.path(target_path, "config.yml")) && 
      file.exists(file.path(target_path, "flow.R"))) {
    analysis$type <- "r_analysis_skeleton"
  } else if (file.exists(file.path(target_path, "DESCRIPTION"))) {
    analysis$type <- "r_package"
  } else {
    analysis$type <- "mixed_language"
  }
  
  # Check for existing AI support
  ai_indicators <- c(".copilot-persona", "./ai", "ai/personas")
  for (indicator in ai_indicators) {
    if (file.exists(file.path(target_path, indicator)) || 
        dir.exists(file.path(target_path, indicator))) {
      analysis$has_ai_support <- TRUE
      break
    }
  }
  
  analysis$has_vscode <- dir.exists(file.path(target_path, ".vscode"))
  analysis$has_github <- dir.exists(file.path(target_path, ".github"))
  
  return(analysis)
}

# === BACKUP UTILITIES ===

#' Create Import Backup
create_import_backup <- function(target_path) {
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  backup_path <- paste0(target_path, "_backup_", timestamp)
  
  file.copy(target_path, backup_path, recursive = TRUE)
  
  return(backup_path)
}

#' Restore from Backup
restore_from_backup <- function(backup_path, target_path) {
  if (!dir.exists(backup_path)) {
    cat("❌ Backup not found:", backup_path, "\n")
    return(invisible(FALSE))
  }
  
  # Remove current target
  unlink(target_path, recursive = TRUE)
  
  # Restore from backup
  file.copy(backup_path, target_path, recursive = TRUE)
  
  cat("✅ Restored from backup\n")
  return(invisible(TRUE))
}

# === INITIALIZATION ===

cat("🔧 AI Support System Migration Utilities Loaded\n")
cat("📦 Export Functions: export_ai_components()\n")
cat("📥 Import Functions: import_ai_components()\n")
cat("🔍 Assessment Functions: generate_import_assessment()\n")
cat("💡 Use dry_run=TRUE to test migrations safely\n")

