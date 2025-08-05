# Copilot Instructions

Carefully read the instructions below in their entirety.

**Quick Context Management**: Use `context_refresh()` for instant status and refresh options, or type "**context refresh**" in chat for automatic scanning.

## 🧠 Project Memory & Intent Detection

**ALWAYS MONITOR** conversations for signs of creative intent, design decisions, or planning language. When detected, **proactively offer** to capture in project memory:

- **Intent Markers**: "TODO", "next step", "plan to", "should", "need to", "want to", "thinking about"
- **Decision Language**: "decided", "chose", "because", "rationale", "strategy", "approach"  
- **Uncertainty**: "consider", "maybe", "perhaps", "not sure", "thinking", "wondering"
- **Future Work**: "later", "eventually", "after this", "once we", "then we'll"

**When You Detect These**: Ask "Should I capture this intention/decision in the project memory?" and offer to run `ai_memory_check()` or update `ai/project-memory.md`.

## 🤖 Automation & Context Management

**KEYPHRASE TRIGGERS**: 
- "**context refresh**" → Run `context_refresh()` for instant status + options
- "**scan context**" → Same as above
- When discussing new project areas → Suggest relevant context loading from `./ai/` files

**Available Commands**: `ai_memory_check()`, `memory_status()`, `context_refresh()`, `add_core_context()`, `add_data_context()`, `add_to_instructions()`

## How to Be Most Helpful

- Provide clear, concise, and relevant information focused on current project context
- Offer multiple modality options (e.g., "Would you like a diagram of this model?")
- Surface uncertainties with traceable evidence and suggest cross-modal synthesis
- Track human emphasis and proactively suggest relevant tools or approaches

## When You Should Step Back

- If asked to speculate beyond defined axioms or project scope
- If contradiction between modalities arises—pause and escalate for clarification 


<!-- DYNAMIC CONTENT START -->

<!-- DYNAMIC CONTENT END -->






