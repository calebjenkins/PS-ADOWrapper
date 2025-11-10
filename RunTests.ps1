#Requires -Version 5.1
<#
.SYNOPSIS
    Runs all Pester tests for the PSAzureDevOps module.

.DESCRIPTION
    This script runs all Pester tests for the PSAzureDevOps module with comprehensive
    output formatting, error handling, and optional code coverage analysis.

.PARAMETER CodeCoverage
    Include code coverage analysis in the test run.

.PARAMETER OutputFile
    Path to save test results in NUnit XML format.

.PARAMETER Detailed
    Show detailed test output instead of summary.

.PARAMETER PassThru
    Return the Pester test results object.

.PARAMETER Tags
    Run only tests with specific tags.

.EXAMPLE
    .\RunTests.ps1
    Runs all tests with standard output.

.EXAMPLE
    .\RunTests.ps1 -CodeCoverage
    Runs all tests with code coverage analysis.

.EXAMPLE
    .\RunTests.ps1 -OutputFile "TestResults.xml" -CodeCoverage
    Runs tests with coverage and saves results to XML file.

.EXAMPLE
    .\RunTests.ps1 -Detailed
    Runs tests with detailed output showing individual test results.

.NOTES
    Author: PSAzureDevOps Team
    Requires: Pester 5.0+
#>

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$CodeCoverage,
    
    [Parameter()]
    [string]$OutputFile,
    
    [Parameter()]
    [switch]$Detailed,
    
    [Parameter()]
    [switch]$PassThru,
    
    [Parameter()]
    [string[]]$Tags
)

# Set strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Script variables
$ProjectRoot = $PSScriptRoot
$ModulePath = Join-Path $ProjectRoot "PSAzureDevOps"
$TestPath = Join-Path $ModulePath "Tests"
$PublicPath = Join-Path $ModulePath "Public"

Write-Host "🧪 PSAzureDevOps Test Runner" -ForegroundColor Cyan
Write-Host "=" * 50
Write-Host "Project Root: $ProjectRoot" -ForegroundColor Gray
Write-Host "Test Path: $TestPath" -ForegroundColor Gray
Write-Host ""

# Verify prerequisites
Write-Host "🔍 Checking Prerequisites..." -ForegroundColor Yellow

# Check if test directory exists
if (-not (Test-Path $TestPath)) {
    Write-Error "Test directory not found: $TestPath"
    exit 1
}

# Check if Pester is available
try {
    Import-Module Pester -Force -ErrorAction Stop
    $pesterVersion = Get-Module Pester | Select-Object -ExpandProperty Version
    Write-Host "✅ Pester $pesterVersion loaded" -ForegroundColor Green
    
    if ($pesterVersion -lt [Version]"5.0.0") {
        Write-Warning "⚠️  Pester version is $pesterVersion. Version 5.0+ is recommended for best results."
    }
} catch {
    Write-Error "❌ Failed to import Pester module: $_"
    Write-Host "💡 Install Pester with: Install-Module -Name Pester -Force" -ForegroundColor Yellow
    exit 1
}

# Check if module can be imported
$moduleFile = Join-Path $ModulePath "PSAzureDevOps.psm1"
if (-not (Test-Path $moduleFile)) {
    Write-Error "❌ Module file not found: $moduleFile"
    exit 1
}

Write-Host "✅ All prerequisites met" -ForegroundColor Green
Write-Host ""

# Configure Pester
Write-Host "⚙️  Configuring Test Run..." -ForegroundColor Yellow

$pesterConfig = [PesterConfiguration]::Default
$pesterConfig.Run.Path = $TestPath
$pesterConfig.Run.PassThru = $true

# Set output verbosity
if ($Detailed) {
    $pesterConfig.Output.Verbosity = 'Detailed'
} else {
    $pesterConfig.Output.Verbosity = 'Normal'
}

# Configure code coverage if requested
if ($CodeCoverage) {
    Write-Host "📊 Code coverage analysis enabled" -ForegroundColor Blue
    $pesterConfig.CodeCoverage.Enabled = $true
    $pesterConfig.CodeCoverage.Path = "$PublicPath\*.ps1"
    $pesterConfig.CodeCoverage.OutputFormat = 'JaCoCo'
    $pesterConfig.CodeCoverage.OutputPath = Join-Path $ProjectRoot "coverage.xml"
}

# Configure output file if specified
if ($OutputFile) {
    Write-Host "📄 Test results will be saved to: $OutputFile" -ForegroundColor Blue
    $pesterConfig.TestResult.Enabled = $true
    $pesterConfig.TestResult.OutputFormat = 'NUnitXml'
    $pesterConfig.TestResult.OutputPath = $OutputFile
}

# Configure tags if specified
if ($Tags) {
    Write-Host "🏷️  Running tests with tags: $($Tags -join ', ')" -ForegroundColor Blue
    $pesterConfig.Filter.Tag = $Tags
}

Write-Host ""

# Run tests
Write-Host "🚀 Running Tests..." -ForegroundColor Yellow
Write-Host ""

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

try {
    # Clean up any existing module imports to ensure fresh test run
    Remove-Module PSAzureDevOps -ErrorAction SilentlyContinue
    
    # Run Pester tests
    $testResults = Invoke-Pester -Configuration $pesterConfig
    
    $stopwatch.Stop()
    
    # Display results summary
    Write-Host ""
    Write-Host "📋 Test Results Summary" -ForegroundColor Cyan
    Write-Host "=" * 30
    
    $duration = $stopwatch.Elapsed.ToString("mm\:ss\.fff")
    Write-Host "⏱️  Duration: $duration" -ForegroundColor White
    Write-Host "📊 Total Tests: $($testResults.TotalCount)" -ForegroundColor White
    
    if ($testResults.PassedCount -gt 0) {
        Write-Host "✅ Passed: $($testResults.PassedCount)" -ForegroundColor Green
    }
    
    if ($testResults.FailedCount -gt 0) {
        Write-Host "❌ Failed: $($testResults.FailedCount)" -ForegroundColor Red
    }
    
    if ($testResults.SkippedCount -gt 0) {
        Write-Host "⏭️  Skipped: $($testResults.SkippedCount)" -ForegroundColor Yellow
    }
    
    if ($testResults.NotRunCount -gt 0) {
        Write-Host "⏸️  Not Run: $($testResults.NotRunCount)" -ForegroundColor Gray
    }
    
    # Show code coverage if enabled
    if ($CodeCoverage -and $testResults.CodeCoverage) {
        Write-Host ""
        Write-Host "📊 Code Coverage Summary" -ForegroundColor Cyan
        Write-Host "=" * 25
        
        $coverage = $testResults.CodeCoverage
        
        # Handle different Pester versions' code coverage object structures
        if ($coverage.CoveragePercent) {
            # Pester 5.x structure
            $coveragePercent = [Math]::Round($coverage.CoveragePercent, 2)
            Write-Host "📈 Overall Coverage: $coveragePercent%" -ForegroundColor $(
                if ($coveragePercent -ge 80) { 'Green' }
                elseif ($coveragePercent -ge 60) { 'Yellow' }
                else { 'Red' }
            )
            
            if ($coverage.CommandsAnalyzedCount) {
                Write-Host "🎯 Commands Analyzed: $($coverage.CommandsAnalyzedCount)" -ForegroundColor White
            }
            if ($coverage.CommandsExecutedCount) {
                Write-Host "✅ Commands Executed: $($coverage.CommandsExecutedCount)" -ForegroundColor White
            }
            if ($coverage.CommandsMissedCount) {
                Write-Host "❌ Commands Missed: $($coverage.CommandsMissedCount)" -ForegroundColor White
            }
        } elseif ($coverage.NumberOfCommandsAnalyzed) {
            # Older Pester structure
            $coveragePercent = [Math]::Round(($coverage.NumberOfCommandsExecuted / $coverage.NumberOfCommandsAnalyzed) * 100, 2)
            Write-Host "📈 Overall Coverage: $coveragePercent%" -ForegroundColor $(
                if ($coveragePercent -ge 80) { 'Green' }
                elseif ($coveragePercent -ge 60) { 'Yellow' }
                else { 'Red' }
            )
            Write-Host "🎯 Commands Analyzed: $($coverage.NumberOfCommandsAnalyzed)" -ForegroundColor White
            Write-Host "✅ Commands Executed: $($coverage.NumberOfCommandsExecuted)" -ForegroundColor White
            Write-Host "❌ Commands Missed: $($coverage.NumberOfCommandsMissed)" -ForegroundColor White
        } else {
            # Fallback - just show what we can from the coverage object
            Write-Host "📊 Code coverage data available (structure not recognized)" -ForegroundColor Yellow
            $coverage | Get-Member -MemberType Properties | ForEach-Object {
                $propName = $_.Name
                $propValue = $coverage.$propName
                if ($propValue -ne $null -and $propValue -isnot [array] -and $propValue -isnot [hashtable]) {
                    Write-Host "   $propName`: $propValue" -ForegroundColor Gray
                }
            }
        }
        
        # Show missed commands if available
        try {
            if ($coverage.MissedCommands -and $coverage.MissedCommands.Count -gt 0) {
                Write-Host ""
                Write-Host "⚠️  Missed Commands:" -ForegroundColor Yellow
                $coverage.MissedCommands | ForEach-Object {
                    if ($_.File -and $_.Line) {
                        Write-Host "   $($_.File):$($_.Line)" -ForegroundColor Gray
                    } else {
                        Write-Host "   $($_)" -ForegroundColor Gray
                    }
                }
            }
        } catch {
            # MissedCommands property may not exist in all Pester versions
        }
        
        if (Test-Path $pesterConfig.CodeCoverage.OutputPath) {
            Write-Host "📄 Coverage report saved to: $($pesterConfig.CodeCoverage.OutputPath)" -ForegroundColor Blue
        }
    }
    
    # Show failed tests details
    if ($testResults.FailedCount -gt 0) {
        Write-Host ""
        Write-Host "❌ Failed Test Details" -ForegroundColor Red
        Write-Host "=" * 20
        
        $testResults.Failed | ForEach-Object {
            Write-Host ""
            Write-Host "📍 $($_.ExpandedPath)" -ForegroundColor Red
            Write-Host "   $($_.ErrorRecord.Exception.Message)" -ForegroundColor White
            if ($_.ErrorRecord.ScriptStackTrace) {
                Write-Host "   Stack: $($_.ErrorRecord.ScriptStackTrace -split "`n" | Select-Object -First 1)" -ForegroundColor Gray
            }
        }
    }
    
    # Final status
    Write-Host ""
    if ($testResults.FailedCount -eq 0) {
        Write-Host "🎉 All tests passed successfully!" -ForegroundColor Green
        $exitCode = 0
    } else {
        Write-Host "💥 Some tests failed. Please review the failures above." -ForegroundColor Red
        $exitCode = 1
    }
    
    # Show output file location
    if ($OutputFile -and (Test-Path $OutputFile)) {
        Write-Host "📄 Test results saved to: $OutputFile" -ForegroundColor Blue
    }
    
    # Return results if requested
    if ($PassThru) {
        return $testResults
    }
    
    exit $exitCode
    
} catch {
    $stopwatch.Stop()
    Write-Host ""
    Write-Host "💥 Test execution failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor White
    
    if ($_.Exception.InnerException) {
        Write-Host "Inner Exception: $($_.Exception.InnerException.Message)" -ForegroundColor Gray
    }
    
    Write-Host "Stack Trace:" -ForegroundColor Gray
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    
    exit 1
} finally {
    # Clean up
    Remove-Module PSAzureDevOps -ErrorAction SilentlyContinue
}