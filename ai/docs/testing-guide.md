# AI Support System Testing Suite

## Overview

The AI Support System includes comprehensive testing and verification components to ensure system integrity and functionality. All testing components are located in `ai/scripts/tests/` and are fully exportable with the rest of the system.

## Test Components

### 1. Individual Component Tests

#### Developer Integration Test (`test-developer-integration.R`)
- **Purpose**: Tests developer persona activation and functionality
- **Coverage**: Persona file existence, activation functions, content validation
- **Key Validations**: 
  - Persona file presence at expected location
  - Function availability for activation
  - Successful persona switching
  - Required persona sections (Role, Objective/Task, Tools/Capabilities, Rules/Constraints)

#### Project Manager Integration Test (`test-project-manager-integration.R`)
- **Purpose**: Tests project manager persona and context loading system
- **Coverage**: Full context loading, architectural separation testing
- **Key Validations**:
  - Project context files (mission.md, method.md, glossary.md)
  - Persona activation and content validation
  - Context size differences between personas (PM > Developer)
  - Architectural separation verification

#### Mini-EDA System Test (`test-mini-eda-system.R`)
- **Purpose**: Tests the mini-EDA JSON generation functionality
- **Coverage**: Silent mini-EDA system, JSON output validation
- **Key Validations**:
  - Silent mini-EDA function execution
  - JSON file generation and writing
  - Content validation and data integrity

### 2. Integration Tests

#### Context Management Integration
- **Purpose**: Tests cross-component persona switching
- **Coverage**: Context management loading, persona switching, content changes
- **Key Validations**:
  - AI context management script loading
  - Persona switching produces context changes
  - System state consistency

#### Memory System Integration  
- **Purpose**: Tests memory system functionality
- **Coverage**: Memory functions loading, basic operations
- **Key Validations**:
  - Memory functions script loading
  - Memory status operations
  - System integrity checks

### 3. Comprehensive Test Runner (`run-all-tests.R`)

Provides automated execution of all test components with:
- **Safe Test Execution**: Error handling with detailed reporting
- **Component Organization**: Individual and integration test separation  
- **Detailed Reporting**: Pass/fail status with error details
- **Summary Statistics**: Total, passed, and failed test counts

#### Usage
```r
# Run all tests
source('ai/scripts/tests/run-all-tests.R')

# Run specific test categories
run_ai_support_tests(individual_tests = TRUE, integration_tests = FALSE)
```

#### Sample Output
```
AI SUPPORT SYSTEM TEST SUITE
Starting comprehensive testing...

>>> INDIVIDUAL COMPONENT TESTS <<<
============================================================
RUNNING: Developer Integration Test
============================================================
Test 1: Persona file existence...
Developer persona file found
[... detailed test output ...]
RESULT: PASSED
============================================================

TEST SUMMARY
================================================================================
developer                      PASS
project_manager               PASS  
mini_eda                      PASS
context_management            PASS
memory_system                 PASS
--------------------------------------------------------------------------------
Total Tests: 5 | Passed: 5 | Failed: 0
ALL TESTS PASSED - AI Support System is fully operational!
================================================================================
```

## VSCode Integration

The testing suite integrates with VSCode through a dedicated task:

```json
{
  "label": "Test AI Support System",
  "type": "process", 
  "command": "Rscript",
  "args": ["-e", "source('ai/scripts/tests/run-all-tests.R')"],
  "group": "test"
}
```

**Access**: `Ctrl+Shift+P` → "Tasks: Run Task" → "Test AI Support System"

## Export Compatibility

All testing components are designed for easy export:

- **Auto-detection**: Tests automatically locate AI support system components
- **Path Resolution**: Handles both legacy and new AI support structure locations
- **ASCII-only**: All test files follow ASCII-only standards for cross-platform compatibility
- **Modular Design**: Individual tests can be exported separately if needed

## Integration with CI/CD

The test suite is designed to integrate with continuous integration workflows:

- **Exit Codes**: Proper success/failure exit codes
- **Structured Output**: Machine-readable test results
- **Error Reporting**: Detailed error messages for debugging
- **Headless Execution**: Runs without user interaction

## Quality Assurance

The testing suite ensures:

- **Component Integrity**: All AI support components function correctly
- **Cross-Component Communication**: Integration between personas, memory, and context systems
- **Portability**: System works correctly in different repository environments  
- **Regression Prevention**: Catches issues introduced by system changes

## Best Practices

When extending the test suite:

1. **Follow ASCII-only standards** for PowerShell compatibility
2. **Use auto-detection patterns** for script loading
3. **Implement safe test execution** with proper error handling
4. **Provide detailed validation output** for debugging
5. **Maintain export compatibility** with portable path resolution

This testing framework ensures the AI Support System maintains high quality and reliability across different research repository environments.