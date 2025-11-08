# MCP Testing & Integration Status

## Status

After installation, verify the filesystem server and any additional servers operate correctly and only expose intended directories.

## Basic Tests

1. **Server Launch** (manual): Start server pointing at `data-public/` and confirm no errors.
2. **VS Code Recognition**: Open workspace; confirm no unexpected prompts or errors.
3. **Restricted Scope**: Attempt access to `data-private/` via MCP (should be denied / not listed).

## Diagnostic Checklist

| Test | Expected | Result |
|------|----------|--------|
| Node.js session available | `node -v` outputs version | TBD |
| Filesystem MCP installed | `npm list -g @modelcontextprotocol/server-filesystem` shows version | TBD |
| VS Code settings loaded | Persona tasks visible | TBD |
| Sensitive dirs excluded | `data-private/` absent from MCP scope | TBD |

## Next Steps

- Integrate Memory / Sequential Thinking servers if required.
- Add internal documentation of approved MCP usage patterns.
- Periodically audit exposed paths for drift.

---
*Extend this file with concrete results after first validation run.*