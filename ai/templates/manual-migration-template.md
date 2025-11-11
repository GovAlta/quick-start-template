# Manual Migration Template
# AI Support System Migration for Mixed-Language Research Repositories
# Compatible with: RAnalysisSkeleton-style projects

## Pre-Migration Checklist

### Target Repository Requirements
- [ ] Repository has `config.yml`
- [ ] Repository has `flow.R` 
- [ ] Repository has `README.md`
- [ ] Repository is a mixed-language research project (R, Python, etc.)
- [ ] You have backup of target repository

### Source Repository Assessment
- [ ] AI support system components identified
- [ ] Components selected for migration:
  - [ ] Persona system
  - [ ] Context management
  - [ ] Memory system
  - [ ] VSCode tasks integration
- [ ] Dependencies verified (R packages: yaml, config)

## Migration Impact Assessment

### Files to be Created
```
target-repo/
├── .copilot-persona                    # Persona tracking
├── .github/
│   └── copilot-instructions.md         # Dynamic AI context
├── ai-support-system/                  # Main AI support directory
│   ├── ai-support-config.yml          # Configuration
│   ├── README.md                       # Documentation
│   ├── core/
│   │   └── base-instructions.md        # Core AI instructions
│   ├── personas/                       # AI personas (selected)
│   │   ├── developer.md
│   │   ├── project-manager.md
│   │   └── [other selected personas]
│   ├── scripts/                        # Portable logic
│   │   ├── ai-migration-toolkit.R     # Context switching
│   │   ├── ai-memory-functions.R       # Memory management
│   │   └── update-copilot-context.R    # Context updates
│   ├── memory/                         # Memory system templates
│   │   ├── memory-hub.md
│   │   ├── memory-ai.md
│   │   ├── memory-human.md
│   │   ├── memory-guide.md
│   │   └── log/
│   └── vscode/
│       └── tasks-template.json         # VSCode task templates
```

### Files to be Modified
- [ ] `config.yml` - Add ai_support section (minimal)
- [ ] `.vscode/tasks.json` - Add AI-related tasks (if VSCode integration selected)
- [ ] Optional: `flow.R` - Add AI support integration (minimal)

### Potential Conflicts
- [ ] Check for existing `.copilot-persona` file
- [ ] Check for existing `.github/copilot-instructions.md`
- [ ] Check for existing `ai/` or `ai-support-system/` directories
- [ ] Check for conflicting VSCode task names

## Migration Steps

### Step 1: Pre-Migration Validation
```r
# In source repository
source("ai-support-system/scripts/ai-migration-toolkit.R")
assessment <- generate_migration_assessment(
  source_path = ".",
  target_path = "/path/to/target/repo",
  components = c("personas", "context", "memory", "vscode")
)
```

**Review Assessment Results:**
- [ ] All requirements met
- [ ] Conflicts identified and resolved
- [ ] Impact understood and approved

### Step 2: Directory Structure Creation
```powershell
# In target repository
New-Item -ItemType Directory -Path "ai-support-system" -Force
New-Item -ItemType Directory -Path "ai-support-system\core" -Force
New-Item -ItemType Directory -Path "ai-support-system\personas" -Force
New-Item -ItemType Directory -Path "ai-support-system\scripts" -Force
New-Item -ItemType Directory -Path "ai-support-system\memory" -Force
New-Item -ItemType Directory -Path "ai-support-system\vscode" -Force
New-Item -ItemType Directory -Path ".github" -Force
```

**Verification:**
- [ ] All directories created successfully
- [ ] No permission errors encountered

### Step 3: Core System Files
Copy these files from source to target:

```powershell
# Configuration and documentation
Copy-Item "ai-support-system\ai-support-config.yml" "target-repo\ai-support-system\"
Copy-Item "ai-support-system\README.md" "target-repo\ai-support-system\"
Copy-Item "ai-support-system\core\base-instructions.md" "target-repo\ai-support-system\core\"
```

**Verification:**
- [ ] Configuration file copied
- [ ] Documentation copied  
- [ ] Base instructions copied

### Step 4: Persona System Migration
```powershell
# Copy selected personas
Copy-Item "ai-support-system\personas\developer.md" "target-repo\ai-support-system\personas\"
Copy-Item "ai-support-system\personas\project-manager.md" "target-repo\ai-support-system\personas\"
# Add other personas as selected...
```

**Verification:**
- [ ] All selected personas copied
- [ ] Persona files readable and valid

### Step 5: Scripts and Logic Migration
```powershell
# Copy portable logic
Copy-Item "ai-support-system\scripts\ai-migration-toolkit.R" "target-repo\ai-support-system\scripts\"
Copy-Item "ai-support-system\scripts\ai-memory-functions.R" "target-repo\ai-support-system\scripts\"
Copy-Item "ai-support-system\scripts\update-copilot-context.R" "target-repo\ai-support-system\scripts\"
```

**Verification:**
- [ ] All scripts copied
- [ ] R scripts have correct syntax

### Step 6: Memory System Initialization
```r
# In target repository
source("ai-support-system/scripts/ai-memory-functions.R")
initialize_memory_system(project_root = ".", system_type = "ai-support-system")
```

**Verification:**
- [ ] Memory directory structure created
- [ ] Basic memory files initialized
- [ ] Memory system functional

### Step 7: Context Management Setup
```powershell
# Create GitHub Copilot integration
New-Item -ItemType File -Path ".github\copilot-instructions.md" -Force
New-Item -ItemType File -Path ".copilot-persona" -Force
```

```r
# Initialize context system
source("ai-support-system/scripts/ai-migration-toolkit.R")
activate_default()  # Sets up initial context
```

**Verification:**
- [ ] Copilot instructions file created
- [ ] Persona tracking file created
- [ ] Context system responds correctly

### Step 8: VSCode Integration (Optional)
```powershell
# Merge VSCode tasks
# Manual process - review existing .vscode/tasks.json and add AI tasks
```

**Verification:**
- [ ] VSCode tasks added without conflicts
- [ ] All AI tasks execute successfully

### Step 9: Configuration Integration
Edit `config.yml` to add:
```yaml
# AI Support System Configuration
ai_support:
  enabled: true
  system_type: "ai-support-system"
  personas_enabled: true
  memory_enabled: true
  context_management: true
```

**Verification:**
- [ ] Config file updated successfully
- [ ] YAML syntax valid
- [ ] No conflicts with existing configuration

## Post-Migration Testing

### Functionality Tests
```r
# Test persona system
source("ai-support-system/scripts/ai-migration-toolkit.R")
show_context_status()

# Test different personas
activate_developer()
activate_project_manager()
activate_default()
```

**Verification:**
- [ ] All personas activate successfully
- [ ] Context switching works
- [ ] No error messages

### Memory System Tests
```r
# Test memory system
source("ai-support-system/scripts/ai-memory-functions.R")
ai_memory_check()

# Test memory updates
simple_memory_update("Migration test entry")
human_memory_update("Migration completed successfully")
```

**Verification:**
- [ ] Memory system operational
- [ ] Memory updates work
- [ ] Files created correctly

### Integration Tests
```r
# Test full system integration
source("ai-support-system/scripts/ai-migration-toolkit.R")
source("ai-support-system/scripts/ai-memory-functions.R")

show_context_status()
ai_memory_check()
```

**Verification:**
- [ ] No conflicts between components
- [ ] All systems work together
- [ ] Performance acceptable

## Rollback Procedure

If migration fails or causes issues:

### Quick Rollback
```powershell
# Remove AI support system
Remove-Item -Recurse -Force "ai-support-system"
Remove-Item -Force ".copilot-persona"
Remove-Item -Force ".github\copilot-instructions.md"
```

### Restore from Backup
- [ ] Restore entire repository from backup
- [ ] Verify restoration complete
- [ ] Test core functionality

## Success Criteria

Migration is successful when:
- [ ] All selected components function correctly
- [ ] No conflicts with existing repository functionality
- [ ] AI support system enhances workflow without disruption
- [ ] Documentation and memory systems are operational
- [ ] VSCode integration works (if selected)
- [ ] Performance impact is minimal

## Troubleshooting

### Common Issues
1. **Persona switching fails**: Check file paths and permissions
2. **Memory system not found**: Verify directory structure and initialization
3. **VSCode tasks don't work**: Check task syntax and R path configuration
4. **Context updates fail**: Verify GitHub Copilot integration

### Getting Help
- Review `ai-support-system/README.md`
- Check error messages in R console
- Use `show_context_status()` for diagnostics
- Examine log files in `ai-support-system/memory/log/`

---

**Migration Template Version**: 1.0.0  
**Compatible with**: AI Support System v1.0.0  
**Target**: Mixed-language research repositories (RAnalysisSkeleton-style)
