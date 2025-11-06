#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installs the PSAzureDevOps module to your PowerShell modules directory.

.DESCRIPTION
    This script copies the PSAzureDevOps module to your user PowerShell modules directory,
    making it available for automatic loading in any PowerShell session.

.PARAMETER Scope
    Installation scope: 'User' (default) or 'System'
    - User: Installs to user modules directory (no admin required)
    - System: Installs to system modules directory (requires admin)

.EXAMPLE
    ./Install-Module.ps1
    Installs the module to the user modules directory.

.EXAMPLE
    ./Install-Module.ps1 -Scope System
    Installs the module to the system modules directory (requires admin).
#>
[CmdletBinding()]
param(
    [ValidateSet('User', 'System')]
    [string]$Scope = 'User'
)

$ErrorActionPreference = 'Stop'

Write-Host "PSAzureDevOps Module Installer" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
Write-Host ""

# Determine source and destination paths
$sourcePath = Join-Path $PSScriptRoot "PSAzureDevOps"

if ($Scope -eq 'User') {
    if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
        $destBasePath = Join-Path $HOME "Documents\PowerShell\Modules"
    } else {
        $destBasePath = Join-Path $HOME ".local/share/powershell/Modules"
    }
} else {
    if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
        $destBasePath = Join-Path $env:ProgramFiles "PowerShell\Modules"
    } else {
        $destBasePath = "/usr/local/share/powershell/Modules"
    }
}

$destPath = Join-Path $destBasePath "PSAzureDevOps"

# Check if source exists
if (-not (Test-Path $sourcePath)) {
    Write-Error "Source module not found at: $sourcePath"
    exit 1
}

# Create destination directory if it doesn't exist
if (-not (Test-Path $destBasePath)) {
    Write-Host "Creating modules directory: $destBasePath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $destBasePath -Force | Out-Null
}

# Remove existing installation if present
if (Test-Path $destPath) {
    Write-Host "Removing existing installation..." -ForegroundColor Yellow
    Remove-Item -Path $destPath -Recurse -Force
}

# Copy module files
Write-Host "Installing PSAzureDevOps module to: $destPath" -ForegroundColor Green
Copy-Item -Path $sourcePath -Destination $destBasePath -Recurse -Force

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "To start using the module, run:" -ForegroundColor Cyan
Write-Host "  Import-Module PSAzureDevOps" -ForegroundColor White
Write-Host ""
Write-Host "Then set up your Azure DevOps connection:" -ForegroundColor Cyan
Write-Host "  SetUpADO" -ForegroundColor White
Write-Host ""

# Test import
try {
    Import-Module $destPath -Force
    Write-Host "Module imported successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Available commands:" -ForegroundColor Cyan
    Get-Command -Module PSAzureDevOps | Format-Table -AutoSize
} catch {
    Write-Warning "Module installed but import failed: $_"
}
