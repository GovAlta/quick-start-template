# Project Manager Integration Test
# Tests the Project Manager persona system and project context loading

# ---- load-system ----
# Auto-detect AI support system location
if (file.exists('././ai/scripts/ai-migration-toolkit.R')) {
  source('././ai/scripts/ai-migration-toolkit.R')
} else if (file.exists('./scripts/ai-migration-toolkit.R')) {
  source('./scripts/ai-migration-toolkit.R')
} else {
  stop("Cannot locate AI context management system")
}

# ---- test-functions ----
test_project_manager_integration <- function() {
  cat("TESTING PROJECT MANAGER INTEGRATION\n")
  cat(paste(rep("=", 50), collapse = ""), "\n")
  
  # Test 1: Check persona file exists
  cat("Test 1: Persona file existence...\n")
  persona_file <- "./ai/personas/project-manager.md"
  if (file.exists(persona_file)) {
    cat("Project Manager persona file found\n")
  } else {
    stop("Project Manager persona file missing")
  }
  
  # Test 2: Check project context files exist
  cat("Test 2: Project context files existence...\n")
  project_files <- c(
    "./ai/project/mission.md",
    "./ai/project/method.md", 
    "./ai/project/glossary.md"
  )
  
  for (file in project_files) {
    if (file.exists(file)) {
      cat(basename(file), "found\n")
    } else {
      stop("Project file missing: ", file)
    }
  }
  
  # Test 3: Check activation function exists
  cat("Test 3: Activation function availability...\n")
  if (exists("activate_project_manager")) {
    cat("activate_project_manager() function available\n")
  } else {
    stop("activate_project_manager() function missing")
  }
  
  # Test 4: Test persona activation
  cat("Test 4: Persona activation test...\n")
  tryCatch({
    activate_project_manager()
    cat("Project Manager activated successfully\n")
  }, error = function(e) {
    stop("Failed to activate Project Manager: ", e$message)
  })
  
  # Test 5: Check persona detection
  cat("Test 5: Persona detection in list...\n")
  persona_list <- capture.output(list_personas(), type = "message")
  if (any(grepl("project-manager", persona_list))) {
    cat("Project Manager detected in persona list\n")
  } else {
    stop("Project Manager not found in persona list")
  }
  
  # Test 6: Check persona content
  cat("Test 6: Persona content validation...\n")
  persona_content <- readLines(persona_file)
  required_sections <- c("Role", "Objective/Task", "Tools/Capabilities", "Rules/Constraints")
  
  all_sections_found <- TRUE
  for (section in required_sections) {
    if (!any(grepl(paste0("## ", section), persona_content))) {
      cat("Missing section:", section, "\n")
      all_sections_found <- FALSE
    }
  }
  
  if (all_sections_found) {
    cat("All required persona sections present\n")
  } else {
    stop("Persona content validation failed")
  }
  
  # Test 7: Test architectural separation
  cat("Test 7: Architectural separation test...\n")
  
  # Test Project Manager loads full context
  file_size_before <- file.size(".github/copilot-instructions.md")
  activate_project_manager()
  file_size_pm <- file.size(".github/copilot-instructions.md")
  
  # Test Developer loads minimal context  
  activate_developer()
  file_size_dev <- file.size(".github/copilot-instructions.md")
  
  if (file_size_pm > file_size_dev) {
    cat("Project Manager loads more context than Developer\n")
    cat("   PM Context:", round(file_size_pm/1024, 1), "KB, Dev Context:", round(file_size_dev/1024, 1), "KB\n")
  } else {
    stop("Architectural separation test failed - context sizes don't match expected pattern")
  }
  
  cat("\nALL TESTS PASSED - Project Manager integration successful!\n")
  cat(paste(rep("=", 50), collapse = ""), "\n")
  
  # Provide usage summary
  cat("\nUSAGE SUMMARY:\n")
  cat("   activate_project_manager()   # Strategic oversight & full project context\n")
  cat("   activate_developer()         # Technical focus & minimal context\n") 
  cat("   activate_casenote_analyst()  # Domain analysis & specialized context\n")
  cat("   list_personas()              # See all personas\n")
  cat("   deactivate_persona()         # Return to basic context\n")
  cat("   See: ./ai/personas/persona-system-guide.md\n")
  cat("   Project Context: ./ai/project/README.md\n")
  
  return(TRUE)
}

# ---- run-test ----
if (interactive() || !exists(".test_mode")) {
  # Only run test if called interactively or not in test mode
  test_project_manager_integration()
}

