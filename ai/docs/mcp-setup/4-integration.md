# MCP Integration with ./ai/ Framework

## Philosophy

Use MCP capabilities (execution, retrieval) to complement the curated `./ai/` knowledge base. Treat `./ai/` as the stable, human-authored source of truth; treat MCP as dynamic assistance with guardrails.

## Patterns

### Enhanced Project Memory

- Keep decisions in `ai/memory-human.md`.
- Use Memory MCP (if available) to capture relationships across entities.

### Structured Analysis Workflow

1. Review `ai/project/mission.md` and `method.md`.
2. Use MCP tools for technical lookups or file access.
3. Update memory files with decisions and rationale.

### Technical Documentation Access

- Use a documentation MCP (if available) to query current library docs.
- Apply findings to code in `analysis/` or `scripts/`.

## Security Model

| Sensitivity | Channel |
|------------|---------|
| High       | Manual curation via `./ai/` |
| Low        | MCP (restricted to approved directories) |

## Practical Tips

- Prefer explicit absolute paths in VS Code settings on Windows.
- Keep `data-private/` completely outside MCP scope.
- Document MCP usage decisions in `ai/memory-human.md` for auditability.

---
*Adapt integration depth to organizational policy and risk tolerance.*