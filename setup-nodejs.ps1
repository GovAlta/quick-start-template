# setup-nodejs.ps1
# Smart Node.js PATH setup for current PowerShell session
# Only sets up if Node.js is not already accessible

# Check if Node.js is already available
$nodeAvailable = $false
try {
    $null = Get-Command node -ErrorAction Stop
    $nodeAvailable = $true
} catch {
    $nodeAvailable = $false
}

if ($nodeAvailable) {
    Write-Host "✅ Node.js is already available in this session" -ForegroundColor Green
    Write-Host "Node.js version: " -NoNewline -ForegroundColor Yellow
    node --version
    Write-Host "npm version: " -NoNewline -ForegroundColor Yellow  
    npm --version
} else {
    Write-Host "🔧 Setting up Node.js for current session..." -ForegroundColor Cyan
    
    # Add Node.js to PATH for current session
    $env:PATH += ";C:\Program Files\nodejs"
    
    # Verify installation
    try {
        Write-Host "Node.js version: " -NoNewline -ForegroundColor Yellow
        node --version
        Write-Host "npm version: " -NoNewline -ForegroundColor Yellow
        npm --version
        Write-Host "✅ Node.js is now ready for this session!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to setup Node.js. Check installation path." -ForegroundColor Red
        exit 1
    }
}

# Export a function to check Node.js status
function Test-NodeJSSetup {
    try {
        $nodeVersion = node --version
        $npmVersion = npm --version
        return @{
            Available = $true
            NodeVersion = $nodeVersion
            NpmVersion = $npmVersion
        }
    } catch {
        return @{
            Available = $false
            NodeVersion = $null
            NpmVersion = $null
        }
    }
}
