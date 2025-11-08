# MCP Setup Guide: Memory System Integration

## When to Use Memory MCP vs Static Files

### Use Static Memory Files For
- Narrative logging (`ai/memory-human.md`)
- Persistent AI observations (`ai/memory-ai.md`)
- Glossary of terms (`ai/project/glossary.md`)

### Use Memory MCP For
- Dynamic entity/relationship capture
- Cross-field association queries
- Lightweight graph exploration

## Simple Patterns

```
# Create entities (pseudo-code if MCP tools available)
mcp_memory_create_entities([
  {name: "Template-Initialization", entityType: "milestone", observations: ["Base AI system scaffold ready"]}
])

# Relate decisions
mcp_memory_create_relations([
  {from: "Template-Initialization", to: "Persona-System", relationType: "enables"}
])

# Search knowledge
mcp_memory_search_nodes("persona system")
```

## Best Practices
- Avoid duplicating full text from static files.
- Capture summarised concepts and link them.
- Periodically export or snapshot if long-term retention required.

---
*Extend with concrete examples once MCP memory tooling is active.*