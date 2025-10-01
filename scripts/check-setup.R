# Project Setup Validation Script
# Run this script to check if your environment is ready for the AIM 2025 Sandbox project
# Usage: Rscript scripts/check-setup.R

cat("=========================================================\n")
cat("🧠 AIM 2025 SANDBOX - SETUP VALIDATION\n")
cat("=========================================================\n")
cat("Checking your development environment...\n\n")

# Function to check file/directory existence
check_file <- function(path, description, required = TRUE) {
  exists <- file.exists(path) || dir.exists(path)
  status <- if(exists) "✅" else if(required) "❌" else "⚠️"
  cat(sprintf("%-50s %s\n", description, status))
  return(exists)
}

# Function to check package installation
check_package <- function(pkg, description = NULL) {
  if(is.null(description)) description <- paste("Package:", pkg)
  installed <- requireNamespace(pkg, quietly = TRUE)
  status <- if(installed) "✅" else "❌"
  cat(sprintf("%-50s %s\n", description, status))
  return(installed)
}

# Initialize error tracking
setup_errors <- c()
setup_warnings <- c()

cat("1. PROJECT STRUCTURE\n")
cat("-------------------\n")
required_dirs <- c(
  "data-private",
  "data-public", 
  "manipulation",
  "analysis",
  "scripts",
  "ai"
)

for(dir in required_dirs) {
  if(!check_file(dir, paste("Directory:", dir))) {
    setup_errors <- c(setup_errors, paste("Missing directory:", dir))
  }
}

required_files <- c(
  "flow.R",
  "config.yml"
)

for(file in required_files) {
  if(!check_file(file, paste("File:", file))) {
    setup_errors <- c(setup_errors, paste("Missing file:", file))
  }
}

cat("\n2. R PACKAGES\n")
cat("-------------\n")
required_packages <- c(
  "dplyr", 
  "tidyr",
  "magrittr",
  "stringr",
  "janitor",
  "ggplot2",
  "tibble",
  "DBI",
  "RSQLite",
  "config"
)

for(pkg in required_packages) {
  if(!check_package(pkg)) {
    setup_errors <- c(setup_errors, paste("Missing package:", pkg))
  }
}

optional_packages <- c(
  "ggplot2",
  "lubridate", 
  "forcats",
  "scales",
  "broom",
  "emmeans"
)

cat("\nOptional packages (recommended):\n")
for(pkg in optional_packages) {
  if(!check_package(pkg)) {
    setup_warnings <- c(setup_warnings, paste("Missing optional package:", pkg))
  }
}

cat("\n3. AUTHENTICATION\n")
cat("-----------------\n")

gitignore_exists <- check_file(".gitignore", ".gitignore file", required = FALSE)

# Check if .secrets is in .gitignore
if(gitignore_exists) {
  gitignore_content <- readLines(".gitignore", warn = FALSE)
  secrets_in_gitignore <- any(grepl("\\.secrets", gitignore_content, fixed = TRUE))
  check_file(".secrets (in .gitignore)", "Auth cache properly ignored", required = FALSE)
  if(!secrets_in_gitignore) {
    setup_warnings <- c(setup_warnings, ".secrets should be added to .gitignore for security")
  }
}

cat("\n4. DATA DIRECTORIES\n")
cat("-------------------\n")
data_dirs <- c(
  "data-private/derived",
  "data-private/derived/manipulation",
  "data-private/derived/manipulation/SQLite",
  "data-private/derived/manipulation/CSV"
)

for(dir in data_dirs) {
  check_file(dir, paste("Data directory:", dir), required = FALSE)
}

cat("\n5. DATABASE AVAILABILITY\n")
cat("------------------------\n")
databases <- c(
  "data-private/derived/manipulation/SQLite/books-of-ukraine.sqlite",
  "data-private/derived/manipulation/SQLite/books-of-ukraine-0.sqlite",
  "data-private/derived/manipulation/SQLite/books-of-ukraine-1.sqlite",
  "data-private/derived/manipulation/SQLite/books-of-ukraine-2.sqlite"
)

db_names <- c(
  "Main database (analysis-ready)",
  "Stage 0 database (core books)",
  "Stage 1 database (+ admin data)",  
  "Stage 2 database (+ custom data)"
)

for(i in seq_along(databases)) {
  if(file.exists(databases[i])) {
    size_mb <- round(file.size(databases[i]) / 1024^2, 2)
    cat(sprintf("%-40s ✅ (%s MB)\n", db_names[i], size_mb))
  } else {
    cat(sprintf("%-40s ❌\n", db_names[i]))
    setup_warnings <- c(setup_warnings, paste("Database not found:", basename(databases[i])))
  }
}

cat("\n=========================================================\n")
cat("📋 SETUP SUMMARY\n")
cat("=========================================================\n")

if(length(setup_errors) == 0 && length(setup_warnings) == 0) {
  cat("🎉 PERFECT! Your environment is fully configured!\n")
  cat("\n✅ You can now run:\n")
  cat("   • Rscript flow.R\n")
  cat("   • Rscript flow.R\n")
  cat("   • Any analysis scripts in the analysis/ folder\n")
  
} else if(length(setup_errors) == 0) {
  cat("✅ GOOD! Your environment is ready with minor warnings.\n")
  cat("\n⚠️  Warnings to address:\n")
  for(warning in setup_warnings) {
    cat("   •", warning, "\n")
  }
  cat("\n✅ You can run the scripts, but consider addressing warnings.\n")
  
} else {
  cat("❌ SETUP INCOMPLETE! Please fix the following issues:\n\n")
  
  if(length(setup_errors) > 0) {
    cat("🚨 CRITICAL ERRORS:\n")
    for(error in setup_errors) {
      cat("   •", error, "\n")
    }
  }
  
  if(length(setup_warnings) > 0) {
    cat("\n⚠️  WARNINGS:\n")
    for(warning in setup_warnings) {
      cat("   •", warning, "\n")
    }
  }
  
  cat("\n🔧 NEXT STEPS:\n")
  
  # Missing packages
  missing_pkgs <- setup_errors[grepl("Missing package:", setup_errors)]
  if(length(missing_pkgs) > 0) {
    pkgs <- gsub("Missing package: ", "", missing_pkgs)
    cat("   1. Install missing packages:\n")
    cat("      install.packages(c(", paste0("'", pkgs, "'", collapse = ", "), "))\n")
  }
  
  # Missing directories
  missing_dirs <- setup_errors[grepl("Missing directory:", setup_errors)]
  if(length(missing_dirs) > 0) {
    cat("   2. Create missing directories or re-clone the repository\n")
  }
}

cat("\n=========================================================\n")
cat("📖 NEED HELP?\n")
cat("=========================================================\n")
cat("If you encounter issues:\n")
cat("1. Check the README.md file for detailed setup instructions\n")
cat("2. Review the ai/onboarding-ai.md for project-specific guidance\n") 
cat("3. Ask a team member for assistance\n")
cat("\n💡 TIP: Run this script again after making changes!\n")
cat("=========================================================\n")

# Exit with appropriate code
if(length(setup_errors) > 0) {
  quit(status = 1)
} else {
  quit(status = 0)
}
