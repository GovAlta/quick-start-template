# MCP Setup Guide: Preliminaries

## Quick Overview

**What**: Model Context Protocol (MCP) servers provide AI assistants with secure, standardized access to local resources (files, databases, APIs).

**Why**: Extends your existing `./ai/` documentation framework with dynamic capabilities - AI can now execute actions, not just read context.

**Security**: MCP adds new attack vectors. Solution: restrict access to non-sensitive paths only (`data-public/`, `analysis/`, `ai/`). Keep `data-private/` excluded.

**Enterprise Challenge**: Node.js installed but not in PATH. Solution: session-based setup scripts + VS Code tasks.

**Status**: ✅ Node.js v22.12.0 installed, ✅ automated setup system created, ⏳ MCP servers pending.

**Next**: Install file system MCP server with restricted permissions for safe experimentation.

------------------------------------------------------------------------

## Detailed Implementation

### Problem Context

-   **Current System**: Human-curated `./ai/` files provide AI with project context and methodology
-   **Limitation**: AI can only read what humans manually share - no direct file/data access
-   **Goal**: Add dynamic capabilities while maintaining security and epistemological control

### MCP Architecture

```         
AI Assistant ↔ VS Code (MCP Client) ↔ MCP Server ↔ Local Resources
```

**Key Insight**: MCP provides "hands" (execution) to complement `./ai/` "brain" (knowledge framework).

### Security Analysis

**New Risk Vectors**: - Direct file system access beyond curated content - Potential data exfiltration to external AI services - Privilege escalation through user permissions

**Mitigation Strategy**:

```         
HIGH SENSITIVITY → Manual curation via ./ai/ system (current approach)
LOW SENSITIVITY → MCP access (new capability)
```

**Recommended Access Pattern**

-   ✅ `./data-public/` - Safe for MCP
-   ✅ `./analysis/` - Safe for MCP
-   ✅ `./ai/` - Safe for MCP
-   ❌ `./data-private/` - Manual curation only

### Enterprise Installation Challenges

**Issue**: Node.js v22.12.0 installed by enterprise but not added to system PATH.

**Solution**: Session-based setup with automation:

1.  **Smart Setup Script** (`setup-nodejs.ps1`):
    -   Checks if Node.js already available in session
    -   Adds to PATH only if needed
    -   Provides status feedback
2.  **Automated Project Status** (`project-status.ps1`):
    -   Automatically ensures Node.js setup
    -   Validates project structure
    -   Checks MCP server status
    -   Reports git status
3.  **VS Code Integration**:
    -   Tasks for one-click execution
    -   Keyboard shortcuts (`Ctrl+Shift+S` for status)
    -   Automatic environment preparation

### Technical Implementation

**Files Created**: - `setup-nodejs.ps1` - Smart Node.js environment setup - `project-status.ps1` - Comprehensive project status with auto-setup - `.vscode/tasks.json` - VS Code task definitions - `.vscode/keybindings.json` - Keyboard shortcuts

**Usage Pattern**:

``` powershell
# Manual (any session)
.\setup-nodejs.ps1

# Automated (VS Code)
Ctrl+Shift+S  # Full project status + Node.js setup
Ctrl+Shift+N  # Node.js setup only
```

### Next Phase: MCP Server Installation

**Planned Approach**: 1. Install file system MCP server with restricted permissions 2. Configure access limited to safe directories 3. Test with non-sensitive analysis workflows 4. Validate security boundaries 5. Document integration with existing `./ai/` framework

**Success Criteria**: - AI can access analysis code and public data - Private data remains protected - Existing methodology documentation continues to guide AI behavior - No degradation of epistemological control