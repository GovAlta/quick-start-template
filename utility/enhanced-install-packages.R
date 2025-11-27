# Enhanced Package Installation with Version Constraints
# This extends the original install-packages.R with optional version control
# Maintains backward compatibility with existing package-dependency-list.csv

#Clear memory from previous runs.
base::rm(list=base::ls(all=TRUE))

path_csv <- "utility/package-dependency-list.csv"

if( !file.exists(path_csv)) {
  base::stop("The path `", path_csv, "` was not found.  Make sure the working directory is set to the root of the repository.")
}

# Install required packages for enhanced functionality
if( !base::requireNamespace("devtools") ) {
  utils::install.packages("devtools", repos="https://cran.rstudio.com")
}

if( !base::requireNamespace("remotes") ) {
  utils::install.packages("remotes", repos="https://cran.rstudio.com")
}

# Enhanced package installation function
install_package_with_version <- function(pkg_name, min_version = NULL, max_version = NULL, 
                                        exact_version = NULL, github_username = NULL, 
                                        on_cran = TRUE, force_install = FALSE) {
  
  cat("Checking package:", pkg_name, "\n")
  
  # Check if package is already installed
  if (requireNamespace(pkg_name, quietly = TRUE) && !force_install) {
    current_version <- as.character(packageVersion(pkg_name))
    cat("  Currently installed:", current_version, "\n")
    
    # Check version constraints
    version_ok <- TRUE
    
    if (!is.null(exact_version) && !is.na(exact_version) && exact_version != "") {
      version_ok <- current_version == exact_version
      if (!version_ok) {
        cat("  ❌ Exact version", exact_version, "required, found", current_version, "\n")
      }
    } else {
      if (!is.null(min_version) && !is.na(min_version) && min_version != "") {
        if (utils::compareVersion(current_version, min_version) < 0) {
          version_ok <- FALSE
          cat("  ❌ Minimum version", min_version, "required, found", current_version, "\n")
        }
      }
      
      if (!is.null(max_version) && !is.na(max_version) && max_version != "") {
        if (utils::compareVersion(current_version, max_version) > 0) {
          version_ok <- FALSE
          cat("  ❌ Maximum version", max_version, "required, found", current_version, "\n")
        }
      }
    }
    
    if (version_ok) {
      cat("  ✅ Version constraints satisfied\n")
      return(TRUE)
    }
  }
  
  # Install or reinstall the package
  cat("  Installing", pkg_name, "...\n")
  
  tryCatch({
    if (!is.null(github_username) && !is.na(github_username) && github_username != "") {
      # Install from GitHub
      if (!is.null(exact_version) && !is.na(exact_version) && exact_version != "") {
        remotes::install_github(paste0(github_username, "/", pkg_name, "@v", exact_version), 
                               force = TRUE, quiet = TRUE)
      } else {
        remotes::install_github(paste0(github_username, "/", pkg_name), 
                               force = TRUE, quiet = TRUE)
      }
    } else {
      # Install from CRAN
      if (!is.null(exact_version) && !is.na(exact_version) && exact_version != "") {
        # For exact versions, use remotes::install_version
        remotes::install_version(pkg_name, version = exact_version, 
                                repos = "https://cran.rstudio.com", 
                                quiet = TRUE)
      } else {
        utils::install.packages(pkg_name, repos = "https://cran.rstudio.com", quiet = TRUE)
      }
    }
    
    cat("  ✅ Successfully installed", pkg_name, "\n")
    return(TRUE)
    
  }, error = function(e) {
    cat("  ❌ Failed to install", pkg_name, ":", as.character(e), "\n")
    return(FALSE)
  })
}

# Read and process the CSV file
cat("=========================================================\n")
cat("📦 ENHANCED PACKAGE INSTALLATION\n") 
cat("=========================================================\n")

pkg_data <- read.csv(path_csv, stringsAsFactors = FALSE)

# Handle both old and new CSV formats
if (!"min_version" %in% names(pkg_data)) {
  pkg_data$min_version <- NA
  pkg_data$max_version <- NA
  pkg_data$exact_version <- NA
}

# Filter for packages marked for installation
packages_to_install <- pkg_data[pkg_data$install == TRUE & !is.na(pkg_data$package_name) & pkg_data$package_name != "", ]

if (nrow(packages_to_install) == 0) {
  cat("No packages marked for installation.\n")
  quit()
}

cat("Found", nrow(packages_to_install), "packages to process:\n\n")

# Install packages with version constraints
success_count <- 0
failure_count <- 0

for (i in 1:nrow(packages_to_install)) {
  pkg <- packages_to_install[i, ]
  
  result <- install_package_with_version(
    pkg_name = pkg$package_name,
    min_version = pkg$min_version,
    max_version = pkg$max_version, 
    exact_version = pkg$exact_version,
    github_username = pkg$github_username,
    on_cran = pkg$on_cran
  )
  
  if (result) {
    success_count <- success_count + 1
  } else {
    failure_count <- failure_count + 1
  }
  
  cat("\n")
}

# Summary
cat("=========================================================\n")
cat("📋 INSTALLATION SUMMARY\n")
cat("=========================================================\n")
cat("✅ Successful:", success_count, "\n")
cat("❌ Failed:", failure_count, "\n")

if (failure_count == 0) {
  cat("🎉 All packages installed successfully!\n")
} else {
  cat("⚠️  Some packages failed to install. Check the messages above.\n")
}

cat("=========================================================\n")