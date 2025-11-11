# AI Support System

**Exportable AI-augmented research infrastructure for reproducible research projects**

## Overview

This system provides a portable, modular AI support infrastructure designed for mixed-language research repositories (R, Python, etc.). It separates AI support functionality from core research reproducibility, enabling easy migration between projects while maintaining scientific rigor.

## Architecture Principles

- **Storage/Logic Separation**: Memory artifacts remain project-specific; memory logic is portable
- **Minimal Target Disruption**: Light integration with existing `config.yml`, `flow.R`, and VSCode configurations  
- **Mandatory Assessment**: Built-in migration impact analysis prevents disruption
- **Component Modularity**: Export only the components you need (personas, memory, tasks, etc.)

## Core Components (Priority Order)

### 1. Persona System 🎭
**Location**: `personas/`  
**Priority**: Highest  
**Exportable**: ✅

Specialized AI personas for different research roles:
- `developer.md` - Backend systems and reproducible infrastructure
- `project_manager.md` - Strategic oversight and coordination  
# Removed: casenote_analyst.md - Domain-specific, not suitable for generic template
- `data_engineer.md` - Data pipeline architecture
- `research_scientist.md` - Scientific methodology and analysis
- And 7 more specialized personas...

**Integration Points**:
- `.github/copilot-instructions.md` (dynamic context switching)
- `.copilot-persona` (active persona tracking)
- VSCode tasks for persona activation

### 2. Context Management 🔄
**Location**: `core/`  
**Priority**: High  
**Exportable**: ✅

Dynamic AI context management system:
- Automatic persona switching via `dynamic-context-builder.R`
- Context status monitoring and validation
- GitHub Copilot instruction updates with file mapping
- Cross-session context preservation
- Portable persona switching with auto-detection

**Key Files**:
- `base-instructions.md` - Core AI behavioral guidelines
- `dynamic-context-builder.R` - Core context building engine (63KB)
- Context management scripts in `scripts/`

### 3. Memory System 🧠
**Location**: `scripts/` (logic) + `memory/` (storage)  
**Priority**: Medium  
**Exportable**: ✅ (logic only)

**Storage/Logic Separation**:
- **Exportable Logic**: Memory management functions, validation, integration
- **Project-Specific Storage**: Actual memory files (`memory-ai.md`, `memory-human.md`, etc.)

This design allows memory functionality to be portable while keeping project memories isolated.

### 4. Testing & Verification 🧪
**Location**: `scripts/tests/`  
**Priority**: Medium  
**Exportable**: ✅

Comprehensive testing suite for AI support system components:
- Individual component tests (personas, memory, context)  
- Integration tests (cross-component functionality)
- Automated test runner with detailed reporting
- VSCode task integration for easy execution

**Test Coverage**:
- Persona activation and switching
- Context management system integrity
- Mini-EDA system functionality  
- Memory system operations
- Cross-component integration validation

### 5. VSCode Integration ⚙️
**Location**: `vscode/`  
**Priority**: Medium  
**Exportable**: ✅

Pre-configured VSCode tasks for:
- Persona activation (12 specialized personas)
- Memory system management
- Context status monitoring  
- System validation and testing

## Migration Options

### Manual Migration (with Mandatory Assessment)
1. **Pre-migration Check**: Validates target repository compatibility
2. **Impact Assessment**: Detailed analysis of changes and potential conflicts
3. **Manual Review**: Human approval required before proceeding
4. **Guided Installation**: Step-by-step installation with validation
5. **Post-migration Testing**: Ensures all components work correctly

### AI-Assisted Migration
- Automatic compatibility detection
- Smart conflict resolution
- Adaptive integration based on target repo structure
- Built-in rollback capability

## Target Repository Compatibility

**Primary Target**: Mixed-language research repositories (RAnalysisSkeleton-style)

**Required Structure**:
- `config.yml`
- `flow.R` 
- `README.md`

**Optional Enhancements**:
- `.vscode/tasks.json`
- `.github/` directory
- Existing AI support (will be assessed for conflicts)

## Installation Impact

**Minimal Disruption Approach**:
- `config.yml`: Additions only (new `ai_support` section)
- `flow.R`: Optional minimal modifications
- `.vscode/tasks.json`: Task additions only
- New directories: `ai/` (enhanced structure)

## Usage Examples

### Exporting Persona System Only
```r
# Export just the persona system to another repo
export_ai_components(
  components = "personas",
  target_repo = "path/to/target",
  mode = "manual"  # Triggers mandatory assessment
)
```

### Full AI Support Migration
```r
# Migrate entire AI support system
migrate_ai_support(
  from = "source-repository",
  to = "target-repository", 
  mode = "ai_assisted",
  components = c("personas", "context", "memory", "vscode")
)
```

## Quick Start

1. **Assessment**: Run compatibility check on target repository
2. **Selection**: Choose components to export (personas, memory, tasks, etc.)
3. **Review**: Examine impact assessment (mandatory for manual mode)
4. **Install**: Execute migration with chosen method
5. **Validate**: Confirm all components work in target environment

## File Structure

```
ai/
├── ai-support-config.yml      # Main configuration
├── README.md                  # This file
├── core/                      # Context management
│   └── base-instructions.md
├── personas/                  # AI personas (12 specialized)
│   ├── developer.md
│   ├── project_manager.md
│   └── ...
├── scripts/                   # Portable logic
│   ├── dynamic-context-builder.R   # Core context building engine
│   ├── ai-migration-toolkit.R      # Portable persona switching & migration tools
│   ├── ai-memory-functions.R       # Memory system with storage/logic separation
│   ├── migration-utilities.R       # Export/import tools
│   ├── tests/                      # Testing & verification
│   │   ├── run-all-tests.R         # Comprehensive test runner
│   │   ├── test-developer-integration.R     # Developer persona tests
│   │   ├── test-project-manager-integration.R  # Project manager tests
│   │   └── test-mini-eda-system.R  # Mini-EDA system tests
│   └── wrappers/                   # VSCode task wrapper scripts
│       ├── run-ai-memory-check.R
│       ├── run-add-core-context.R
│       └── test-context-management.R
├── memory/                    # Memory system templates
├── templates/                 # Migration templates
│   ├── manual-migration/
│   └── ai-assisted-migration/
├── vscode/                    # VSCode integration
│   └── tasks-template.json
└── docs/                      # Documentation
    ├── migration-guide.md
    └── troubleshooting.md
```

## Philosophy

This system embodies the principle that **AI support infrastructure should be as portable and reusable as research methodology itself**. By separating concerns and maintaining minimal integration footprints, researchers can evolve their AI-augmented workflows across projects while preserving the scientific integrity of their core research processes.

---

*For detailed migration instructions, see `docs/migration-guide.md`*  
*For troubleshooting, see `docs/troubleshooting.md`*
