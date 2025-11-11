#!/usr/bin/env Rscript
# Show memory system status and help
source('././ai/scripts/ai-memory-functions.R')

if (!check_memory_system()) {
  cat("ERROR: No memory system detected\n")
  cat("Run initialize_memory_system() to create one\n")
  quit(status = 1)
}

memory_status()
cat("\n")
quick_intent_scan()
cat("\n")
show_memory_help()

