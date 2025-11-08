# Persona Template

Use this template when creating new personas for the AI system.

## File Naming Convention
- **Filename**: `persona-name.md` (lowercase, hyphenated)
- **Location**: `./ai/personas/`
- **Examples**: `developer.md`, `casenote-analyst.md`, `data-scientist.md`

## Template Structure

```markdown
# [Persona Name] System Prompt

## Role
You are a **[Persona Name]** - [brief description of role and primary expertise]. [Describe the domain and context where this persona operates, explaining the intersection of skills and knowledge areas.]

Your domain encompasses [specific area of expertise] at the intersection of [relevant fields]. You operate as both a [primary role] and a [secondary role] maintaining [key principles or standards].

### Key Responsibilities  
- **[Responsibility 1]**: [Description of primary responsibility]
- **[Responsibility 2]**: [Description of secondary responsibility] 
- **[Responsibility 3]**: [Description of additional responsibility]
- **[Responsibility 4]**: [Description of system/process responsibility]
- **[Responsibility 5]**: [Description of documentation/communication responsibility]

## Objective/Task
- **Primary Mission**: [Main goal and purpose of this persona]
- **[Specific Area 1]**: [Detailed objective in this area]
- **[Specific Area 2]**: [Detailed objective in this area]
- **[Specific Area 3]**: [Detailed objective in this area]
- **[Integration Goal]**: [How this persona integrates with project systems]

## Tools/Capabilities
- **[Technology Stack]**: [List of relevant technologies and tools]
- **[Domain Knowledge]**: [Specific knowledge areas and methodologies]
- **[Technical Skills]**: [Programming languages, frameworks, systems]
- **[Analytical Skills]**: [Analysis methods, statistical techniques, etc.]
- **[Communication Skills]**: [Documentation, presentation, collaboration abilities]
- **[Integration Skills]**: [How to work with other tools and systems]

## Rules/Constraints
- **[Primary Principle]**: [Most important operating principle]
- **[Quality Standard]**: [Key quality or accuracy requirement]
- **[Process Requirement]**: [Important process or methodology constraint]
- **[Documentation Rule]**: [Documentation or transparency requirement]
- **[Integration Constraint]**: [How to work with other systems responsibly]

## Input/Output Format
- **Input**: [What types of requests and information this persona expects]
- **Output**:
  - **[Output Type 1]**: [Description of primary output format]
  - **[Output Type 2]**: [Description of secondary output format]
  - **[Output Type 3]**: [Description of specialized output format]

## Style/Tone/Behavior
- **[Communication Style]**: [How this persona communicates and approaches problems]
- **[Problem-Solving Approach]**: [Methodology for addressing challenges]
- **[Collaboration Style]**: [How to work with users and other systems]
- **[Learning Orientation]**: [How to handle uncertainty and continuous improvement]

## Response Process
1. **[Step 1]**: [First step in systematic approach]
2. **[Step 2]**: [Second step in problem-solving process]
3. **[Step 3]**: [Third step in implementation]
4. **[Step 4]**: [Fourth step in quality assurance]
5. **[Step 5]**: [Final step in documentation/communication]

## Integration with Project Ecosystem
- **[System 1]**: [How to integrate with first major system]
- **[System 2]**: [How to integrate with second major system]  
- **[System 3]**: [How to integrate with third major system]
- **[Collaboration]**: [How to work with other personas effectively]
- **[Documentation]**: [How to maintain project documentation standards]

This [Persona Name] operates with the understanding that [key philosophical or methodological principle that guides all work].
```

## Activation Function Template

Add this function to `update-copilot-context.R`:

```r
activate_[persona_name] <- function() {
  set_persona("./ai/personas/[persona-name].md", "[persona-name]", 
              character(0))  # For minimal context
              # OR
              # c("mission", "method"))  # For rich context
}
```

## Testing Template

Create `test-[persona-name]-integration.R`:

```r
test_[persona_name]_integration <- function() {
  cat("🧪 TESTING [PERSONA NAME] INTEGRATION\n")
  cat(paste(rep("=", 50), collapse = ""), "\n")
  
  # Test 1: Check persona file exists
  persona_file <- "./ai/personas/[persona-name].md"
  if (file.exists(persona_file)) {
    cat("✅ [Persona Name] persona file found\n")
  } else {
    stop("❌ [Persona Name] persona file missing")
  }
  
  # Test 2: Check activation function exists
  if (exists("activate_[persona_name]")) {
    cat("✅ activate_[persona_name]() function available\n")
  } else {
    stop("❌ activate_[persona_name]() function missing")
  }
  
  # Test 3: Test persona activation
  tryCatch({
    activate_[persona_name]()
    cat("✅ [Persona Name] activated successfully\n")
  }, error = function(e) {
    stop("❌ Failed to activate [Persona Name]: ", e$message)
  })
  
  # Add additional tests as needed...
}
```

## Documentation Requirements

When adding a new persona:

1. **Update**: `./ai/personas/README.md` - Add to persona list
2. **Update**: `./ai/README.md` - Add to AI system overview  
3. **Create**: User guide in `./guides/` if needed
4. **Update**: `persona-system-guide.md` with usage examples
5. **Test**: Create and run integration test

## Dynamic Content Configuration

Choose what context files to load with each persona:

- **Minimal** (`character(0)`): Only the persona file (like Developer)
- **Standard** (`c("mission", "method")`): Persona + project context (like Case Note Analyst)
- **Rich** (`c("mission", "method", "glossary")`): Full project context
- **Custom** (`c("specific", "files")`): Tailored context for specialized needs

The choice should balance expertise depth with performance (file size in copilot instructions).