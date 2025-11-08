# MCP Installation & Configuration

## Quick Overview

**Goal**: Install a filesystem MCP server and configure VS Code to expose only non-sensitive project areas.

**Scope**: Public data (`data-public/`), analysis code (`analysis/`), AI support system (`ai/`).

## Installation Steps

```
# 1. Ensure Node.js available in current session
./setup-nodejs.ps1

# 2. Install filesystem MCP server (global)
npm install -g @modelcontextprotocol/server-filesystem
```

## VS Code Configuration (Example)

Add to `.vscode/settings.json` (use absolute paths on Windows if PATH issues):

```json
{
  "mcp": {
    "servers": {
      "filesystem": {
        "type": "process",
        "command": "C:\\Program Files\\nodejs\\node.exe",
        "args": [
          "C:\\Users\\<USER>\\AppData\\Roaming\\npm\\node_modules\\@modelcontextprotocol\\server-filesystem\\dist\\index.js",
          "${workspaceFolder}\\data-public",
          "${workspaceFolder}\\analysis",
          "${workspaceFolder}\\ai"
        ]
      }
    }
  }
}
```

## Security Notes

- Exclude `data-private/` to prevent accidental exposure.
- Keep server arguments limited to required directories only.
- Prefer explicit paths over relying on environment configuration.

## Validation

```
# Test server manually
"C:\\Program Files\\node.exe" "C:\\Users\\<USER>\\AppData\\Roaming\\npm\\node_modules\\@modelcontextprotocol\\server-filesystem\\dist\\index.js" "$(Get-Location)\\data-public"
```

Expected output: server starts and announces readiness on stdio.

---
*Adapt paths and scope before production use; integrate additional MCP servers as needed.*