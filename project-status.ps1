# project-status.ps1
# Clean PowerShell script for project status with memory system support
# Adapted for Books of Ukraine project context

param(
    [switch]$Detailed,
    [switch]$MemoryCheck
)

Write-Host "BOOKS OF UKRAINE PROJECT STATUS CHECK" -ForegroundColor Magenta
Write-Host "=====================================" -ForegroundColor Magenta

# 1. Check project structure
Write-Host ""
Write-Host "Step 1: Project Structure" -ForegroundColor Cyan
$criticalPaths = @(
    "ai/mission.md",
    "ai/glossary.md", 
    "ai/memory-human.md",
    "data-public",
    "data-private",
    "analysis",
    "manipulation/0-ellis.R",
    "config.yml",
    "books-of-ukraine.Rproj"
)

foreach ($path in $criticalPaths) {
    if (Test-Path $path) {
        Write-Host "OK $path" -ForegroundColor Green
    } else {
        Write-Host "MISSING $path" -ForegroundColor Red
    }
}

# 2. Data availability checks
Write-Host ""
Write-Host "Step 2: Data Availability" -ForegroundColor Cyan

# Check data directories
$dataPaths = @(
    "data-private",
    "data-public"
)

foreach ($path in $dataPaths) {
    if (Test-Path $path) {
        Write-Host "OK $path" -ForegroundColor Green
    } else {
        Write-Host "MISSING $path" -ForegroundColor Red
    }
}

# Check for any existing data files
if (Test-Path "data-private/*") {
    $dataCount = (Get-ChildItem -Path "data-private" -Recurse -File).Count
    Write-Host "OK data-private contains $dataCount files" -ForegroundColor Green
} else {
    Write-Host "WARNING: data-private appears empty" -ForegroundColor Yellow
}

# Check for database files
Write-Host ""
Write-Host "Available Databases:" -ForegroundColor Yellow
$databases = @(
    "data-private/derived/manipulation/SQLite/books-of-ukraine.sqlite",
    "data-private/derived/manipulation/SQLite/books-of-ukraine-2.sqlite"
)

$dbNames = @("Main (analysis-ready)", "Stage 2 (books + admin + extra)")

for ($i = 0; $i -lt $databases.Length; $i++) {
    $db = $databases[$i]
    $name = $dbNames[$i]
    if (Test-Path $db) {
        $size = [math]::Round((Get-Item $db).Length / 1MB, 2)
        Write-Host "OK $name ($size MB)" -ForegroundColor Green
    } else {
        Write-Host "MISSING $name" -ForegroundColor Red
    }
}



# 3. Git status
Write-Host ""
Write-Host "Step 3: Git Status" -ForegroundColor Cyan
try {
    $gitBranch = git branch --show-current 2>$null
    $gitStatus = git status --porcelain 2>$null
    
    if ($gitBranch) {
        Write-Host "Current branch: $gitBranch" -ForegroundColor Green
        if ($gitStatus) {
            Write-Host "WARNING: Uncommitted changes detected" -ForegroundColor Yellow
        } else {
            Write-Host "Working directory clean" -ForegroundColor Green
        }
    } else {
        Write-Host "Not a git repository or git not available" -ForegroundColor Red
    }
} catch {
    Write-Host "Git status check failed" -ForegroundColor Red
}

# 4. Workspace validation
Write-Host ""
Write-Host "Step 4: Workspace Configuration" -ForegroundColor Cyan
$workspaceFiles = Get-ChildItem -Name "*.code-workspace"
if ($workspaceFiles) {
    Write-Host "Workspace file detected: $($workspaceFiles -join ', ')" -ForegroundColor Green
} else {
    Write-Host "WARNING: Workspace file not found" -ForegroundColor Yellow
}

# Check R project file
if (Test-Path "books-of-ukraine.Rproj") {
    Write-Host "OK R Project file found" -ForegroundColor Green
} else {
    Write-Host "WARNING: R Project file missing" -ForegroundColor Yellow
}

# 5. Project memory
Write-Host ""
Write-Host "Step 5: Project Memory System" -ForegroundColor Cyan
$memoryFiles = @(
    "ai/memory-ai.md",
    "ai/memory-human.md", 
    "ai/memory-hub.md",
    "ai/memory-guide.md"
)

$foundMemoryFiles = @()
foreach ($memFile in $memoryFiles) {
    if (Test-Path $memFile) {
        $foundMemoryFiles += $memFile
    }
}

if ($foundMemoryFiles.Count -gt 0) {
    Write-Host "Multi-file memory system active" -ForegroundColor Green
    Write-Host "Memory files found: $($foundMemoryFiles.Count)/$($memoryFiles.Count)" -ForegroundColor Gray
    foreach ($file in $foundMemoryFiles) {
        $fileName = Split-Path $file -Leaf
        Write-Host "   $fileName" -ForegroundColor Green
    }
} else {
    Write-Host "WARNING: No memory files found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "AIM 2025 SANDBOX PROJECT STATUS CHECK COMPLETE" -ForegroundColor Magenta

# Optional detailed output
if ($Detailed) {
    Write-Host ""
    Write-Host "=== DETAILED PROJECT INFORMATION ===" -ForegroundColor Cyan
    
    # Analysis directories
    if (Test-Path "analysis") {
        $analysisDir = Get-ChildItem "analysis" -Directory
        Write-Host "Analysis directories: $($analysisDir.Count)" -ForegroundColor Gray
        foreach ($dir in $analysisDir) {
            Write-Host "  - $($dir.Name)" -ForegroundColor Gray
        }
    }
    
    # Recent log files
    if (Test-Path "ai/log") {
        $logFiles = Get-ChildItem "ai/log" -Filter "*.md" | Sort-Object LastWriteTime -Descending | Select-Object -First 3
        if ($logFiles.Count -gt 0) {
            Write-Host "Recent log files:" -ForegroundColor Gray
            foreach ($log in $logFiles) {
                $age = [math]::Round(((Get-Date) - $log.LastWriteTime).TotalHours, 1)
                Write-Host "  - $($log.Name) ($age hrs old)" -ForegroundColor Gray
            }
        }
    }
}
