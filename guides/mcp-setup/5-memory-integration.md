# MCP Setup Guide: Memory System Integration

*How Memory MCP integrates with our five-component memory system*

## 🔗 **When to Use Memory MCP vs Wiki-Links**

### **Use Wiki-Links For:**

- **Document navigation** - Clicking between [[memory-human]], [[memory-ai]], etc.
- **Static references** - Links that don't change often
- **Human reading flow** - When you want linear, narrative connections

### **Use Memory MCP For:**

- **Dynamic relationships** - Connections that evolve over time
- **Complex associations** - Multi-way relationships between concepts
- **Searchable knowledge** - Finding patterns across all memory
- **AI analysis** - When AI needs to understand relationship networks

## 🛠️ **Simple MCP Patterns**

### **Create Key Entities**

```         
# Add major project concepts to knowledge graph
mcp_memory_create_entities([
  {name: "CEIS-NIA-2025", entityType: "project", observations: ["Net Impact Analysis implementation for 2025"]},
  {name: "TWaNG-methodology", entityType: "method", observations: ["Propensity score weighting approach"]},
  {name: "Phase-1-complete", entityType: "milestone", observations: ["Memory hub established with wiki-links"]}
])
```

### **Track Decision Evolution**

```         
# Connect decisions over time  
mcp_memory_create_relations([
  {from: "Memory-System-Evaluation", to: "Phase-1-Implementation", relationType: "led-to"},
  {from: "Phase-1-Implementation", to: "Wiki-Link-Network", relationType: "created"},
  {from: "Wiki-Link-Network", to: "Enhanced-Navigation", relationType: "enables"}
])
```

### **Search Knowledge Network**

```         
# Find all project decisions
mcp_memory_search_nodes("decision implementation phase")

# Find methodology connections  
mcp_memory_search_nodes("TWaNG methodology propensity score")
```

## 🎯 **Best Practices**

### **Keep It Simple**

-   Use MCP for **relationships**, wiki-links for **navigation**
-   Don't duplicate - if it's in \[\[project-memory\]\], just reference it in MCP
-   Focus on **concepts and connections**, not detailed content

### **Complement VS Code**

-   MCP for **discovery** ("What connects to X?")
-   Wiki-links for **navigation** ("Go to document Y")\
-   VS Code search for **content** ("Find all mentions of Z")

### **Human-Friendly Workflow**

1. **Document** in [[memory-human]] or [[memory-ai]]
2. **Navigate** with wiki-links
3. **Connect concepts** with Memory MCP when needed
4. **Search** with VS Code or MCP depending on need

*This approach keeps each tool focused on what it does best while integrating with our five-component memory system.*