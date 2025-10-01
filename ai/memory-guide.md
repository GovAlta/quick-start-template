# Memory System Guide

*Five-component architecture for research-focused project memory*

## Quick Reference

**For Users**: 
- 📝 `memory-human.md` - Your thoughts, decisions, and reasoning (recent entries first)
- 🤖 `memory-ai.md` - AI technical status and implementation notes (recent entries first)  
- 🧭 `memory-hub.md` - Navigation center with wiki-links
- 📖 `memory-guide.md` - This guide (system structure and optimization rules)

**For AI**: Follow the optimization rules in Section 3 below for consistent memory functioning.

---

## 1. System Structure & Intended Use

**Design Principle**: Minimal, purposeful components that don't interfere with each other while serving distinct needs in research collaboration.

**Target**: Research teams emphasizing clarity, human language, and collaborative decision-making.

---

## The Five Components

### 1. **`memory-human.md` - Human Intent & Narrative** 📝
**Purpose**: Human-authored chronicle of project thinking and decision evolution  
**Owner**: Human team members  
**Organization**: **Reverse chronological order (recent entries first)**
**Content**: 
- Why decisions were made (rationale, context)
- Research questions and evolving hypotheses
- Methodological considerations and changes
- Collaboration notes and team insights
- Informal observations and "what if" thinking

**Format**: Natural language, chronological entries, no technical constraints  
**Usage**: Primary record of human reasoning and project narrative  

### 2. **`memory-ai.md` - AI Technical Brief** 🤖
**Purpose**: AI-maintained technical status for briefing humans on project state  
**Owner**: AI systems (GitHub Copilot, etc.)  
**Organization**: **Reverse chronological order (recent entries first)**
**Content**:
- Implementation status and technical decisions
- Code changes and their implications
- Data pipeline status and issues
- Integration points and dependencies
- Technical debt and automation status

**Format**: Structured, factual, AI-readable and human-scannable  
**Usage**: AI context for consistent assistance across sessions  

### 3. **`memory-hub.md` - Navigation Center** 🧭
**Purpose**: Simple navigation hub using wiki-links  
**Owner**: Maintained collaboratively  
**Content**:
- Links to all memory components
- Quick status overview
- Navigation shortcuts to key project areas
- Cross-reference index

**Format**: Wiki-link based navigation with minimal text  
**Usage**: Entry point for memory exploration  

### 4. **`ai/log/` - Detailed Change Documentation** 📋
**Purpose**: Comprehensive reports of significant changes, implementations, and analyses
**Owner**: AI systems (auto-generated) + Human documentation  
**Organization**: **Date-keyword naming** (e.g., `2025-08-15-mpm-migration.md`)
**Content**:
- Detailed implementation reports
- Step-by-step change documentation
- Analysis results and methodology notes
- Provisional documents and draft analyses
- Technical deep-dives and troubleshooting logs

**Format**: Markdown reports with full technical detail  
**Usage**: Historical record, troubleshooting reference, detailed documentation archive

### 5. **Memory MCP - Dynamic Knowledge Graph** 🔗
**Purpose**: Complex relationship tracking and semantic connections  
**Owner**: AI systems via MCP protocol  
**Content**:
- Entity relationships and connections
- Temporal tracking of concept evolution
- Semantic analysis of project progression
- Dynamic cross-references between concepts

**Format**: Graph-based, queryable knowledge structure  
**Usage**: Advanced AI reasoning and relationship discovery  

---

## Integration Strategy

### Clear Boundaries
**Non-Interference Principle**: Each component serves distinct purposes without overlap or redundancy.

```
Human Thinking ────→ memory-human.md (narrative, rationale, recent first)
                         │
                         ▼
Technical Status ────→ memory-ai.md (implementation facts, recent first)
                         │
                         ▼
Navigation ──────────→ memory-hub.md (wiki-links, shortcuts)
                         │
                         ▼
Detailed Reports ────→ ai/log/ (comprehensive documentation)
                         │
                         ▼
Relationships ───────→ Memory MCP (dynamic connections)
```

### Information Flow
1. **Humans document thinking** in `memory-human.md` (no technical constraints, recent first)
2. **AI updates technical status** in `memory-ai.md` (implementation-focused, recent first)
3. **Both reference each other** through `memory-hub.md` navigation
4. **Memory MCP tracks relationships** between concepts across all sources

### Cross-Component Protocols

**From Human to AI**:
- Humans note decisions in `memory-human.md`
- AI reads and implements technical implications in `memory-ai.md`
- MCP captures semantic connections between human intent and technical implementation

**From AI to Human**:
- AI updates technical status in `memory-ai.md`
- AI suggests `memory-hub.md` navigation updates
- Humans access AI insights through hub navigation, not direct technical files

**Navigation Maintenance**:
- `memory-hub.md` updated when new significant entries added to either primary document
- Wiki-links provide bidirectional navigation without complex automation
- MCP provides advanced querying when needed

---

## Implementation Guidelines

### What to Keep Simple
- **`memory-human.md`**: Pure human language, no formatting requirements
- **`memory-hub.md`**: Basic wiki-links, minimal automation
- **Cross-references**: Manual and intentional, not automated

### What to Leverage Technology For
- **`memory-ai.md`**: AI-maintained technical precision
- **Memory MCP**: Complex relationship analysis and temporal tracking
- **Search**: VS Code native search across all components

### What to Avoid
- **Automated synchronization** between components (causes fragility)
- **Complex R functions** for memory management (creates technical debt)
- **Multiple visualization formats** (creates maintenance burden)
- **Overlapping content** between components (causes confusion)

---

## 2. Performance Tips for Users

### For Research Teams 📝
**Effective `memory-human.md` Usage**:
- Write entries as if explaining to a colleague who's been away
- Include **context** - what prompted this decision/insight?
- Note **alternatives considered** and why they were rejected
- Use **section headers** with dates for easy scanning
- Keep **recent entries at top** for immediate visibility

**Navigation Best Practices**:
- Start with `memory-hub.md` for overview
- Use Ctrl+F within documents for quick searching
- Reference wiki-links [[like-this]] for cross-navigation
- Update hub when adding significant new entries

### For AI Assistance 🤖
**Getting Better AI Support**:
- Review `memory-ai.md` recent entries before asking questions
- Reference specific dates/entries when discussing past decisions
- Ask AI to update technical status after implementation work
- Use Memory MCP for complex relationship queries

### For Collaboration 👥
**Team Workflow Optimization**:
- Assign `memory-human.md` ownership to lead researcher
- Have AI systems maintain `memory-ai.md` consistently
- Use `memory-hub.md` for onboarding new team members
- Establish regular review cycles for memory content accuracy

---

## 3. AI Optimization Rules

### Core AI Directives 🎯

**Rule 1: Reverse Chronological Order**
- **ALWAYS** add new entries to the **TOP** of `memory-ai.md`
- Use format: `## YYYY-MM-DD: [Brief Title]` for new sections
- Keep recent information immediately visible
- Archive older entries by moving down, never delete

**Rule 2: Recency Prioritization**  
- When referencing memory contents, prioritize information from recent entries
- If conflicting information exists, newer entries take precedence
- Flag outdated information rather than removing it
- Maintain temporal context in all technical updates

**Rule 3: Component Boundaries**
- **NEVER** add human reasoning to `memory-ai.md` - reference `memory-human.md` instead
- **NEVER** add technical implementation details to human components
- Use `memory-hub.md` only for navigation, not content storage
- Let Memory MCP handle complex relationships, not markdown files

**Rule 4: Structured Technical Updates**
```markdown
## YYYY-MM-DD: [Technical Change/Status]

**Context**: Brief explanation of what prompted this update
**Implementation**: What was actually done/changed
**Impact**: How this affects the project
**Dependencies**: What other components are affected
**Status**: Current state (Complete/In Progress/Blocked)
**Files**: List of specific files modified
```

**Rule 5: Cross-Reference Protocol**
- Reference human decisions using format: "Per human decision in [[memory-human]] (YYYY-MM-DD)"
- Update `memory-hub.md` when significant entries are added to primary components
- Suggest Memory MCP queries for complex relationship analysis
- Maintain wiki-link integrity when reorganizing content

**Rule 6: Error Handling**
- If memory files are corrupted/missing, recreate using this guide structure
- If conflicting information found, document the conflict rather than choosing
- If human input contradicts technical status, defer to human input and note discrepancy
- If automation fails, fall back to manual memory management

**Rule 7: Content Quality Standards**
- Keep technical language precise but human-readable
- Include sufficient context for future AI sessions to understand decisions
- Link to specific files/code when referencing implementation details
- Maintain professional tone while being concise

**Rule 8: Detailed Documentation Protocol**
- For significant changes/implementations, create comprehensive report in `ai/log/`
- Use naming convention: `YYYY-MM-DD-brief-description.md`
- Include: Context, Implementation steps, Impact, Files modified, Dependencies
- Link to log reports from brief entries in `memory-ai.md`
- Use `ai/log/` for provisional documents, drafts, and technical deep-dives

**Rule 9: Log Management**
- Keep memory files (memory-human.md, memory-ai.md) focused on current status
- Move detailed analysis, step-by-step processes, and comprehensive reports to `ai/log/`
- Reference log files from memory files using format: "Detailed report: [[ai/log/YYYY-MM-DD-description]]"
- Use log folder for troubleshooting documentation and methodology notes

### Performance Optimization 🚀

**For Speed**:
- Read only recent entries unless specifically requested to go deeper
- Use `memory-hub.md` for quick orientation before diving into details
- Cache frequently referenced information in session context
- Prioritize actionable information over historical context

**For Accuracy**:
- Cross-reference human reasoning in `memory-human.md` before making technical assumptions
- Verify technical status in `memory-ai.md` before claiming implementation completion
- Use Memory MCP for complex relationship verification
- Flag uncertainties rather than making assumptions

**For Usability**:
- Always provide navigation suggestions when adding memory content
- Keep memory updates focused and scannable
- Use consistent formatting for easier human review
- Suggest when memory content should be reviewed/updated by humans

---

## 4. Previous Implementation Benefits

### For Research Teams
- **Clear ownership**: Humans own narrative, AI owns technical tracking
- **Natural workflow**: Fits existing research documentation patterns
- **Collaboration-friendly**: Non-technical team members can contribute to `memory-human.md`
- **Scalable**: Components can grow independently without interference
- **Recency-optimized**: Recent information always visible first

### For AI Assistance
- **Consistent context**: `memory-ai.md` provides reliable technical state
- **Relationship awareness**: Memory MCP enables sophisticated connection analysis
- **Human insight access**: Can reference human reasoning from `memory-human.md`
- **Navigation support**: Can guide users through `memory-hub.md`
- **Temporal accuracy**: Recent entries prioritized for current context

### For Project Maintenance
- **Minimal technical debt**: Simple components, clear boundaries
- **Fault tolerance**: If one component fails, others continue functioning
- **Easy onboarding**: New team members can understand system quickly
- **Export-friendly**: Standard markdown works with any future tools
- **Chronological integrity**: Reverse order maintains project timeline clarity

---

## Potential Concerns & Mitigations

### ⚠️ **Risk: Information Silos**
**Concern**: Components might become disconnected  
**Mitigation**: `memory-hub.md` provides central navigation; Memory MCP tracks cross-component relationships

### ⚠️ **Risk: Manual Maintenance Burden**
**Concern**: Navigation updates might be forgotten  
**Mitigation**: Keep `memory-hub.md` simple enough that updates are quick; use MCP for complex relationship tracking

### ⚠️ **Risk: AI Context Loss**
**Concern**: AI might lose track of human reasoning  
**Mitigation**: AI trained to reference `memory-human.md` for human context; MCP maintains semantic connections

### ⚠️ **Risk: Duplicate Information**
**Concern**: Same information might appear in multiple places  
**Mitigation**: Clear component boundaries; focus on different aspects rather than same content

### ⚠️ **Risk: Chronological Confusion**
**Concern**: Recent information might get buried over time  
**Mitigation**: Strict reverse chronological order; AI rules enforce recent-first organization

---
