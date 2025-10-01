# Script Wrappers

This directory contains small wrapper scripts that serve as bridge utilities between VS Code tasks and the main project scripts.

## Purpose

These wrappers exist to:
- Avoid PowerShell quoting issues when VS Code tasks need to pass complex arguments to R, Python, or other interpreters
- Provide simple entry points for automation without cluttering the main `scripts/` directory
- Keep VS Code task definitions clean and readable

## Current Wrappers

### `run-ai-memory-check.R`
- **Purpose**: Execute `ai_memory_check()` from `scripts/ai-memory-functions.R`
- **Used by**: VS Code task "Load Memory Functions (R)"
- **Why needed**: Avoids PowerShell `-e` argument quoting issues on Windows

## Guidelines

- Keep wrappers minimal (2-4 lines typically)
- Name them descriptively with `run-` prefix when appropriate
- Document the VS Code task or automation that uses each wrapper
- Use absolute paths relative to project root when sourcing other scripts

## Alternative Approaches

Instead of wrappers, you could:
- Set PowerShell execution policy to allow inline `-e` expressions
- Use `type: process` in VS Code tasks with careful argument escaping
- Create PowerShell `.ps1` wrappers instead of R wrappers

The wrapper approach is chosen for cross-platform compatibility and simplicity.
