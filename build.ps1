#Requires -Version 5.1

<#
.SYNOPSIS
    Build script for PSAzureDevOps module

.DESCRIPTION
    This script helps build, test, and validate the PSAzureDevOps PowerShell module

.PARAMETER Task
    The build task to execute: Test, Clean, Build

.EXAMPLE
    ./build.ps1 -Task Test
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('Test', 'Clean', 'Build', 'Install')]
    [string]$Task = 'Build'
)

$ErrorActionPreference = 'Stop'

$ModuleName = 'PSAzureDevOps'
$ModulePath = Join-Path $PSScriptRoot $ModuleName

Write-Host "==> Starting build task: $Task" -ForegroundColor Green

switch ($Task) {
    'Test' {
        Write-Host "Running Pester tests..." -ForegroundColor Cyan
        
        # Install Pester if not available
        if (-not (Get-Module -ListAvailable -Name Pester)) {
            Write-Host "Installing Pester..." -ForegroundColor Yellow
            Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
        }
        
        # Import Pester
        Import-Module Pester -MinimumVersion 5.0.0 -Force
        
        # Run tests
        $config = New-PesterConfiguration
        $config.Run.Path = Join-Path $PSScriptRoot 'Tests'
        $config.Run.PassThru = $true
        $config.Output.Verbosity = 'Detailed'
        
        $result = Invoke-Pester -Configuration $config
        
        if ($result.FailedCount -gt 0) {
            throw "Pester tests failed: $($result.FailedCount) test(s) failed"
        }
        
        Write-Host "All tests passed!" -ForegroundColor Green
    }
    
    'Clean' {
        Write-Host "Cleaning build artifacts..." -ForegroundColor Cyan
        # Add cleanup logic here if needed
        Write-Host "Clean complete!" -ForegroundColor Green
    }
    
    'Build' {
        Write-Host "Building module..." -ForegroundColor Cyan
        
        # Test module manifest
        Write-Host "Testing module manifest..." -ForegroundColor Cyan
        $manifestPath = Join-Path $ModulePath "$ModuleName.psd1"
        Test-ModuleManifest -Path $manifestPath -ErrorAction Stop | Out-Null
        
        Write-Host "Module manifest is valid!" -ForegroundColor Green
        
        # Import module
        Write-Host "Importing module..." -ForegroundColor Cyan
        Import-Module $manifestPath -Force
        
        # Verify exported functions
        $exportedFunctions = (Get-Module $ModuleName).ExportedFunctions.Keys
        Write-Host "Exported functions: $($exportedFunctions -join ', ')" -ForegroundColor Cyan
        
        Write-Host "Build complete!" -ForegroundColor Green
    }
    
    'Install' {
        Write-Host "Installing module..." -ForegroundColor Cyan
        
        # Find user module path
        $userModulePath = $env:PSModulePath -split [System.IO.Path]::PathSeparator | 
            Where-Object { $_ -like "*$env:USERNAME*" -or $_ -like "*CurrentUser*" } | 
            Select-Object -First 1
            
        if (-not $userModulePath) {
            $userModulePath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Modules'
        }
        
        $installPath = Join-Path $userModulePath $ModuleName
        
        # Remove old version if exists
        if (Test-Path $installPath) {
            Write-Host "Removing old version..." -ForegroundColor Yellow
            Remove-Item -Path $installPath -Recurse -Force
        }
        
        # Copy module
        Write-Host "Copying module to $installPath..." -ForegroundColor Cyan
        Copy-Item -Path $ModulePath -Destination $installPath -Recurse -Force
        
        Write-Host "Module installed successfully!" -ForegroundColor Green
        Write-Host "You can now use: Import-Module $ModuleName" -ForegroundColor Cyan
    }
}

Write-Host "==> Task '$Task' completed successfully!" -ForegroundColor Green
