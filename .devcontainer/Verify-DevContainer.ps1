# Verify-DevContainer.ps1
# Script to verify the development container setup

Write-Host "🔍 PSAzureDevOps Development Container Verification" -ForegroundColor Cyan
Write-Host "=" * 50

# Check PowerShell Version
Write-Host "`n📊 PowerShell Information:" -ForegroundColor Yellow
$PSVersionTable | Format-Table -AutoSize

# Check Pester Installation
Write-Host "`n🧪 Pester Information:" -ForegroundColor Yellow
try {
    Import-Module Pester -Force
    $pesterVersion = Get-Module Pester | Select-Object Name, Version, Path
    $pesterVersion | Format-Table -AutoSize
    
    if ($pesterVersion.Version -ge [Version]"5.0.0") {
        Write-Host "✅ Pester 5.x+ detected - Modern syntax supported" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Pester version is older than 5.x - Consider updating" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Pester not found or failed to import: $_" -ForegroundColor Red
}

# Check PSScriptAnalyzer
Write-Host "`n🔍 PSScriptAnalyzer Information:" -ForegroundColor Yellow
try {
    Import-Module PSScriptAnalyzer -Force
    Get-Module PSScriptAnalyzer | Select-Object Name, Version | Format-Table -AutoSize
    Write-Host "✅ PSScriptAnalyzer is available" -ForegroundColor Green
} catch {
    Write-Host "❌ PSScriptAnalyzer not found: $_" -ForegroundColor Red
}

# Check Azure CLI
Write-Host "`n☁️  Azure CLI Information:" -ForegroundColor Yellow
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Host "Azure CLI Version: $($azVersion.'azure-cli')" -ForegroundColor White
    
    # Check for Azure DevOps extension
    $extensions = az extension list --output json | ConvertFrom-Json
    $devopsExt = $extensions | Where-Object { $_.name -eq 'azure-devops' }
    if ($devopsExt) {
        Write-Host "✅ Azure DevOps extension installed: $($devopsExt.version)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Azure DevOps extension not found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Azure CLI not found or not configured: $_" -ForegroundColor Red
}

# Check Git
Write-Host "`n📂 Git Information:" -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host $gitVersion -ForegroundColor White
    Write-Host "✅ Git is available" -ForegroundColor Green
} catch {
    Write-Host "❌ Git not found: $_" -ForegroundColor Red
}

# Test module import
Write-Host "`n📦 PSAzureDevOps Module Test:" -ForegroundColor Yellow
$modulePath = "./PSAzureDevOps/PSAzureDevOps.psm1"
if (Test-Path $modulePath) {
    try {
        Import-Module $modulePath -Force
        $module = Get-Module PSAzureDevOps
        if ($module) {
            Write-Host "✅ PSAzureDevOps module imported successfully" -ForegroundColor Green
            Write-Host "   Exported Functions: $($module.ExportedFunctions.Keys -join ', ')" -ForegroundColor White
            Write-Host "   Exported Aliases: $($module.ExportedAliases.Keys -join ', ')" -ForegroundColor White
        } else {
            Write-Host "❌ Module import failed - no module object returned" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Failed to import PSAzureDevOps module: $_" -ForegroundColor Red
    }
} else {
    Write-Host "❌ PSAzureDevOps.psm1 not found at $modulePath" -ForegroundColor Red
}

# Test basic functionality
Write-Host "`n🧪 Basic Functionality Test:" -ForegroundColor Yellow
if (Test-Path "./PSAzureDevOps/Tests/PSAzureDevOps.Tests.ps1") {
    try {
        $testResult = Invoke-Pester -Path "./PSAzureDevOps/Tests/PSAzureDevOps.Tests.ps1" -PassThru -Show None
        if ($testResult.FailedCount -eq 0) {
            Write-Host "✅ All tests passed ($($testResult.PassedCount) passed)" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Some tests failed ($($testResult.FailedCount) failed, $($testResult.PassedCount) passed)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Test execution failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Test file not found" -ForegroundColor Red
}

Write-Host "`n🎯 Development Environment Status:" -ForegroundColor Cyan
Write-Host "   Ready for PSAzureDevOps development!" -ForegroundColor Green
Write-Host "`n💡 Quick Commands:" -ForegroundColor Cyan
Write-Host "   Test-Module          # Run all tests with coverage" -ForegroundColor White
Write-Host "   Test-CodeQuality     # Analyze code quality" -ForegroundColor White
Write-Host "   Show-ModuleInfo      # Display module information" -ForegroundColor White