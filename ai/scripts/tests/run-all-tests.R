# AI Support System Test Runner
# Comprehensive testing suite for the AI Support System components

# ---- configuration ----
.test_mode <- TRUE  # Prevent individual tests from auto-running

# ---- test-utilities ----
run_test_safely <- function(test_name, test_function) {
  cat("\n", paste(rep("=", 60), collapse = ""), "\n")
  cat("RUNNING:", test_name, "\n")
  cat(paste(rep("=", 60), collapse = ""), "\n")
  
  result <- tryCatch({
    test_function()
    list(status = "PASSED", error = NULL)
  }, error = function(e) {
    list(status = "FAILED", error = e$message)
  })
  
  cat("\nRESULT:", result$status, "\n")
  if (!is.null(result$error)) {
    cat("ERROR:", result$error, "\n")
  }
  cat(paste(rep("=", 60), collapse = ""), "\n")
  
  return(result)
}

# ---- main-test-runner ----
run_ai_support_tests <- function(individual_tests = TRUE, integration_tests = TRUE) {
  cat("AI SUPPORT SYSTEM TEST SUITE\n")
  cat("Starting comprehensive testing...\n")
  
  test_results <- list()
  
  # Individual component tests
  if (individual_tests) {
    cat("\n>>> INDIVIDUAL COMPONENT TESTS <<<\n")
    
    # Test 1: Developer Integration
    if (file.exists("./ai-support-system/scripts/tests/test-developer-integration.R")) {
      source("./ai-support-system/scripts/tests/test-developer-integration.R")
      test_results[["developer"]] <- run_test_safely(
        "Developer Integration Test", 
        test_developer_integration
      )
    }
    
    # Test 2: Project Manager Integration  
    if (file.exists("./ai-support-system/scripts/tests/test-project-manager-integration.R")) {
      source("./ai-support-system/scripts/tests/test-project-manager-integration.R")
      test_results[["project_manager"]] <- run_test_safely(
        "Project Manager Integration Test",
        test_project_manager_integration
      )
    }
    
    # Test 3: Mini-EDA System
    if (file.exists("./ai-support-system/scripts/tests/test-mini-eda-system.R")) {
      source("./ai-support-system/scripts/tests/test-mini-eda-system.R")
      test_results[["mini_eda"]] <- run_test_safely(
        "Mini-EDA System Test",
        function() {
          source("./ai-support-system/scripts/tests/test-mini-eda-system.R")
          return(TRUE)
        }
      )
    }
  }
  
  # Integration tests
  if (integration_tests) {
    cat("\n>>> INTEGRATION TESTS <<<\n")
    
    # Test: Context Management System
    test_results[["context_management"]] <- run_test_safely(
      "Context Management Integration",
      function() {
        # Test AI context management loading
        if (file.exists('./ai-support-system/scripts/ai-context-management.R')) {
          source('./ai-support-system/scripts/ai-context-management.R')
        } else {
          stop("AI context management script not found")
        }
        
        # Test basic persona switching
        original_persona <- readLines(".github/copilot-instructions.md")
        activate_developer()
        dev_persona <- readLines(".github/copilot-instructions.md")
        
        if (identical(original_persona, dev_persona)) {
          stop("Persona switching did not change context")
        }
        
        cat("Context management integration successful\n")
        return(TRUE)
      }
    )
    
    # Test: Memory System
    test_results[["memory_system"]] <- run_test_safely(
      "Memory System Integration",
      function() {
        # Test memory functions loading
        if (file.exists('./ai-support-system/scripts/ai-memory-functions.R')) {
          source('./ai-support-system/scripts/ai-memory-functions.R')
        } else {
          stop("AI memory functions script not found")
        }
        
        # Test basic memory operations
        status <- memory_status()
        if (is.null(status)) {
          stop("Memory status function failed")
        }
        
        cat("Memory system integration successful\n")
        return(TRUE)
      }
    )
  }
  
  # Generate test summary
  cat("\n", paste(rep("=", 80), collapse = ""), "\n")
  cat("TEST SUMMARY\n")
  cat(paste(rep("=", 80), collapse = ""), "\n")
  
  passed <- 0
  failed <- 0
  
  for (test_name in names(test_results)) {
    result <- test_results[[test_name]]
    status_symbol <- if (result$status == "PASSED") "PASS" else "FAIL"
    cat(sprintf("%-30s %s\n", test_name, status_symbol))
    
    if (result$status == "PASSED") {
      passed <- passed + 1
    } else {
      failed <- failed + 1
    }
  }
  
  cat(paste(rep("-", 80), collapse = ""), "\n")
  cat(sprintf("Total Tests: %d | Passed: %d | Failed: %d\n", 
              passed + failed, passed, failed))
  
  if (failed == 0) {
    cat("ALL TESTS PASSED - AI Support System is fully operational!\n")
  } else {
    cat("SOME TESTS FAILED - Review errors above\n")
  }
  
  cat(paste(rep("=", 80), collapse = ""), "\n")
  
  return(test_results)
}

# ---- run-tests ----
if (interactive() || !exists(".test_mode")) {
  # Run all tests by default
  run_ai_support_tests()
}