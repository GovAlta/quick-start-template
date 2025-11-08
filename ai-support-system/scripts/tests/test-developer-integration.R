# Developer Persona Integration Test
# Tests the basic functionality of the Developer persona system

# ---- load-system ----
# Auto-detect AI support system location
if (file.exists('./ai-support-system/scripts/ai-context-management.R')) {
  source('./ai-support-system/scripts/ai-context-management.R')
} else if (file.exists('./scripts/ai-context-management.R')) {
  source('./scripts/ai-context-management.R')
} else {
  stop("Cannot locate AI context management system")
}

# ---- test-functions ----
test_developer_integration <- function() {
  cat("TESTING DEVELOPER PERSONA INTEGRATION\n")
  cat(paste(rep("=", 50), collapse = ""), "\n")
  
  # Test 1: Check persona file exists
  cat("Test 1: Persona file existence...\n")
  persona_file <- "./ai/personas/developer.md"
  if (file.exists(persona_file)) {
    cat("Developer persona file found\n")
  } else {
    stop("Developer persona file missing")
  }
  
  # Test 2: Check activation function exists
  cat("Test 2: Activation function availability...\n")
  if (exists("activate_developer")) {
    cat("activate_developer() function available\n")
  } else {
    stop("activate_developer() function missing")
  }
  
  # Test 3: Test persona activation
  cat("Test 3: Persona activation test...\n")
  tryCatch({
    activate_developer()
    cat("Developer activated successfully\n")
  }, error = function(e) {
    stop("Failed to activate Developer: ", e$message)
  })
  
  # Test 4: Check persona detection
  cat("Test 4: Persona detection in list...\n")
  persona_list <- capture.output(list_personas(), type = "message")
  if (any(grepl("developer", persona_list))) {
    cat("Developer detected in persona list\n")
  } else {
    stop("Developer not found in persona list")
  }
  
  # Test 5: Check persona content
  cat("Test 5: Persona content validation...\n")
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
  
  cat("\nALL TESTS PASSED - Developer integration successful!\n")
  cat(paste(rep("=", 50), collapse = ""), "\n")
  
  # Provide usage summary
  cat("\nUSAGE SUMMARY:\n")
  cat("   activate_developer()         # Quick activation (default)\n")
  cat("   list_personas()              # See all personas\n") 
  cat("   deactivate_persona()         # Return to basic context\n")
  cat("   See: ./guides/developer-persona-guide.md\n")
  cat("   Advanced: ./ai/personas/persona-system-guide.md\n")
  
  return(TRUE)
}

# ---- run-test ----
if (interactive() || !exists(".test_mode")) {
  # Only run test if called interactively or not in test mode
  test_developer_integration()
}