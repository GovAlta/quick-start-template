#!/usr/bin/env Rscript
# Wrapper to execute add_core_context() from the repo's AI memory helpers

# Source the script that defines add_core_context()
suppressPackageStartupMessages({
  source("scripts/update-copilot-context.R")
})

if (!exists("add_core_context")) {
  stop("add_core_context() not found. Check that scripts/ai-memory-functions.R defines it and that working dir is project root.")
}

cat("Running add_core_context()...\n")
res <- tryCatch({
  add_core_context()
}, error = function(e) {
  stop("add_core_context() failed: ", conditionMessage(e))
})

cat("add_core_context() finished.\n")
