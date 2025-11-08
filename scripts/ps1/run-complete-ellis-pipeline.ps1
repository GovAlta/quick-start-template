# run-analysis-pipeline.ps1
# Analysis Pipeline Execution Script for AIM 2025 Sandbox
# Runs the main analysis workflow

Write-Host "STARTING AIM 2025 SANDBOX ANALYSIS" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""

Write-Host "Running main analysis flow..." -ForegroundColor Yellow
Write-Host "Running: flow.R" -ForegroundColor Gray

try {
    Rscript flow.R
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Analysis completed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "ANALYSIS PIPELINE FINISHED SUCCESSFULLY!" -ForegroundColor Green -BackgroundColor Black
        Write-Host "Check the analysis/ directory for generated reports" -ForegroundColor Green
        Write-Host ""
        Write-Host "Pipeline execution completed at $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
    } else {
        Write-Host "Analysis failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "Analysis failed with error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
