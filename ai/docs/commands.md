# Commands Reference

**📍 Location**: `ai/docs/` | **🏠 Home**: [`ai/README.md`](../README.md) | **📚 Main**: [`README.md`](../../README.md)

Essential commands for working with the AI support system.


## Quick Commands Reference

**Common Operations - Direct Execution**

| User Request | Command | Notes |
|--------------|---------|-------|
| Switch to [persona] | `Rscript -e "source('ai/scripts/ai-migration-toolkit.R'); activate_[persona]()"` | Replace [persona] with: developer, project_manager, data_engineer, research_scientist, devops_engineer, frontend_architect, prompt_engineer, reporter, grapher |
| Add context file | `Rscript -e "source('ai/scripts/dynamic-context-builder.R'); add_context_file('[path/file]')"` | Use path relative to ai/ directory, omit .md extension |
| Remove context file | `Rscript -e "source('ai/scripts/dynamic-context-builder.R'); remove_context_file('[path/file]')"` | Idempotent - safe to run even if file not present |
| Check context status | `Rscript -e "source('ai/scripts/dynamic-context-builder.R'); show_context_status()"` | Shows Section 1-3 content summary |
| List available files | `Rscript -e "source('ai/scripts/dynamic-context-builder.R'); list_available_md_files()"` | Discovers all .md files in ai/ directory |
| Combined operation | `Rscript -e "source('ai/scripts/dynamic-context-builder.R'); activate_X(); add_context_file('path/file')"` | Chain multiple operations with semicolons |

---
*Updated: November 2025 | Current system functions only*