#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Demo script showing ADOWrapper module usage.

.DESCRIPTION
    This script demonstrates the main features of the ADOWrapper module.
    Note: This is a demo script and won't actually connect to Azure DevOps
    without valid credentials.
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ADOWrapper Module Demo" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Import the module
Write-Host "1. Importing ADOWrapper module..." -ForegroundColor Yellow
Import-Module ./ADOWrapper/ADOWrapper.psd1 -Force
Write-Host "   ✓ Module imported successfully" -ForegroundColor Green
Write-Host ""

# Show available commands
Write-Host "2. Available commands:" -ForegroundColor Yellow
Get-Command -Module ADOWrapper | Format-Table -AutoSize
Write-Host ""

# Show help for SetUpADO
Write-Host "3. Help for SetUpADO command:" -ForegroundColor Yellow
Get-Help SetUpADO -Detailed | Select-Object -First 20
Write-Host ""

# Show help for wi-i
Write-Host "4. Help for New-WorkItem (wi-i) command:" -ForegroundColor Yellow
Get-Help New-WorkItem -Examples
Write-Host ""

# Show module details
Write-Host "5. Module information:" -ForegroundColor Yellow
Get-Module ADOWrapper | Format-List Name, Version, Description, Author, ModuleType, ExportedFunctions, ExportedAliases
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Demo Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To use the module:" -ForegroundColor Yellow
Write-Host "  1. Run: SetUpADO" -ForegroundColor White
Write-Host "     (This will prompt for your Azure DevOps details)" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Create interruption work items: wi-i 'Your title here'" -ForegroundColor White
Write-Host "     (This creates a work item tagged as interruption)" -ForegroundColor Gray
Write-Host ""
