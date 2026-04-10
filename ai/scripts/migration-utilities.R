# AI Support System — Migration Utilities
# Lightweight helpers for validating and backing up ai/ directories during migration.
# The migration workflow is driven by ai/migration.md (read by an AI agent or human).
# These functions assist with validation and safety — they are NOT the migration engine.

#' Validate ai/ Directory Structure
#'
#' Check that a path contains the expected ai/ subdirectories and key files.
#' Returns a list with $valid (logical) and $details (character vector of findings).
validate_ai_structure <- function(path = ".") {
  ai_dir <- file.path(path, "ai")
  details <- character(0)

  expected_dirs <- c("core", "personas", "scripts", "memory", "project", "docs")
  expected_files <- c(
    "core/base-instructions.md",
    "scripts/dynamic-context-builder.R",
    "scripts/ai-config-utils.R"
  )

  if (!dir.exists(ai_dir)) {
    return(list(valid = FALSE, details = "ai/ directory not found"))
  }

  for (d in expected_dirs) {
    full <- file.path(ai_dir, d)
    if (dir.exists(full)) {
      details <- c(details, paste0("  [ok] ", d, "/"))
    } else {
      details <- c(details, paste0("  [missing] ", d, "/"))
    }
  }

  for (f in expected_files) {
    full <- file.path(ai_dir, f)
    if (file.exists(full)) {
      details <- c(details, paste0("  [ok] ", f))
    } else {
      details <- c(details, paste0("  [missing] ", f))
    }
  }

  missing <- grepl("\\[missing\\]", details)
  valid <- !any(missing[seq_along(expected_dirs)])  # dirs are critical

  list(valid = valid, details = details)
}

#' List ai/ Components
#'
#' Enumerate all ai/ subdirectories with file counts and total sizes.
#' Useful for the AI agent's comparison step.
list_ai_components <- function(path = ".") {
  ai_dir <- file.path(path, "ai")
  if (!dir.exists(ai_dir)) {
    cat("ai/ directory not found at:", path, "\n")
    return(invisible(NULL))
  }

  subdirs <- list.dirs(ai_dir, recursive = FALSE, full.names = TRUE)
  result <- data.frame(
    component = basename(subdirs),
    files     = vapply(subdirs, function(d) length(list.files(d, recursive = TRUE)), integer(1)),
    size_kb   = vapply(subdirs, function(d) {
      fls <- list.files(d, recursive = TRUE, full.names = TRUE)
      if (length(fls) == 0) return(0)
      round(sum(file.info(fls)$size, na.rm = TRUE) / 1024, 1)
    }, numeric(1)),
    stringsAsFactors = FALSE
  )

  cat("ai/ components at:", path, "\n")
  print(result, row.names = FALSE)
  invisible(result)
}

#' Create Migration Backup
#'
#' Create a timestamped copy of the target's ai/ directory before applying changes.
#' Returns the backup path.
create_migration_backup <- function(path = ".", backup_dir = NULL) {
  ai_dir <- file.path(path, "ai")
  if (!dir.exists(ai_dir)) {
    cat("Nothing to back up: ai/ not found at", path, "\n")
    return(invisible(NULL))
  }

  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  if (is.null(backup_dir)) {
    backup_path <- file.path(path, paste0("ai_backup_", timestamp))
  } else {
    backup_path <- file.path(backup_dir, paste0("ai_backup_", timestamp))
  }

  dir.create(backup_path, recursive = TRUE, showWarnings = FALSE)
  file.copy(ai_dir, backup_path, recursive = TRUE)

  cat("Backup created:", backup_path, "\n")
  return(invisible(backup_path))
}

#' Restore from Backup
#'
#' Replace the current ai/ directory with a previously created backup.
#' Requires confirmation because it is destructive.
restore_from_backup <- function(backup_path, target_path = ".") {
  backed_up_ai <- file.path(backup_path, "ai")
  if (!dir.exists(backed_up_ai)) {
    cat("Backup not found or does not contain ai/:", backup_path, "\n")
    return(invisible(FALSE))
  }

  target_ai <- file.path(target_path, "ai")
  if (dir.exists(target_ai)) {
    unlink(target_ai, recursive = TRUE)
  }

  file.copy(backed_up_ai, target_path, recursive = TRUE)
  cat("Restored ai/ from backup:", backup_path, "\n")
  return(invisible(TRUE))
}

