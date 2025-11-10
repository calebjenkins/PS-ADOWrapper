#Requires -Version 5.1
<#
.SYNOPSIS
    Installs prerequisites for the ADOWrapper module.

.DESCRIPTION
    This script checks for and installs the Azure CLI and Azure DevOps extension
    on both Windows and macOS platforms. It verifies existing installations and
    only installs missing components.

.PARAMETER Force
    Forces reinstallation of Azure CLI even if already installed.

.PARAMETER SkipAzureDevOpsExtension
    Skip installation of the Azure DevOps CLI extension.

.EXAMPLE
    .\Install-Prereqs.ps1
    Checks and installs Azure CLI and Azure DevOps extension if needed.

.EXAMPLE
    .\Install-Prereqs.ps1 -Force
    Reinstalls Azure CLI even if already present.

.NOTES
    Author: ADOWrapper Team
    Requires: PowerShell 5.1+ (PowerShell 7+ recommended for cross-platform)
    Platforms: Windows, macOS
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [switch]$Force,
    
    [Parameter()]
    [switch]$SkipAzureDevOpsExtension
)

# Set strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "🔧 ADOWrapper Prerequisites Installer" -ForegroundColor Cyan
Write-Host "=" * 50
Write-Host ""

# Detect OS
$onWindows = $PSVersionTable.PSVersion.Major -lt 6 -or $IsWindows
$onMacOS = $PSVersionTable.PSVersion.Major -ge 6 -and $IsMacOS
$onLinux = $PSVersionTable.PSVersion.Major -ge 6 -and $IsLinux

if ($onLinux) {
    Write-Warning "This script currently supports Windows and macOS. For Linux, please install Azure CLI manually:"
    Write-Host "https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux" -ForegroundColor Yellow
    exit 1
}

Write-Host "📊 Platform: $(if ($onWindows) { 'Windows' } elseif ($onMacOS) { 'macOS' } else { 'Unknown' })" -ForegroundColor White
Write-Host ""

#region Azure CLI Installation

Write-Host "🔍 Checking Azure CLI installation..." -ForegroundColor Yellow

$azCliInstalled = $false
$azCliVersion = $null

try {
    $azOutput = az version --output json 2>$null | ConvertFrom-Json
    $azCliVersion = $azOutput.'azure-cli'
    $azCliInstalled = $true
    Write-Host "✅ Azure CLI is already installed (version $azCliVersion)" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI is not installed" -ForegroundColor Red
}

if (-not $azCliInstalled -or $Force) {
    if ($Force -and $azCliInstalled) {
        Write-Host "🔄 Force flag set - reinstalling Azure CLI..." -ForegroundColor Yellow
    } else {
        Write-Host "📦 Installing Azure CLI..." -ForegroundColor Yellow
    }
    
    if ($onWindows) {
        # Windows installation using winget
        Write-Host "   Checking for winget..." -ForegroundColor White
        
        $wingetInstalled = $false
        try {
            $wingetVersion = winget --version 2>$null
            $wingetInstalled = $true
            Write-Host "   ✅ winget is available (version $wingetVersion)" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ winget is not available" -ForegroundColor Red
        }
        
        if ($wingetInstalled) {
            Write-Host "   Installing Azure CLI via winget..." -ForegroundColor White
            if ($PSCmdlet.ShouldProcess("Azure CLI", "Install via winget")) {
                try {
                    # Use winget to install Azure CLI
                    $wingetArgs = @('install', 'Microsoft.AzureCLI', '--accept-package-agreements', '--accept-source-agreements')
                    if ($Force) {
                        $wingetArgs += '--force'
                    }
                    
                    $process = Start-Process -FilePath "winget" -ArgumentList $wingetArgs -Wait -NoNewWindow -PassThru
                    
                    if ($process.ExitCode -eq 0) {
                        Write-Host "✅ Azure CLI installed successfully!" -ForegroundColor Green
                        
                        # Refresh environment variables
                        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
                        
                        Write-Host "   ⚠️  You may need to restart your terminal for the PATH changes to take effect." -ForegroundColor Yellow
                    } else {
                        Write-Warning "winget installation returned exit code: $($process.ExitCode)"
                    }
                } catch {
                    Write-Error "Failed to install Azure CLI via winget: $_"
                }
            }
        } else {
            # Fallback to MSI installer if winget is not available
            Write-Host "   Falling back to MSI installer..." -ForegroundColor Yellow
            Write-Host "   💡 Tip: Install winget (App Installer) from Microsoft Store for easier updates" -ForegroundColor Cyan
            
            $installerUrl = "https://aka.ms/installazurecliwindows"
            $installerPath = Join-Path $env:TEMP "AzureCLI.msi"
            
            try {
                # Download installer
                Write-Host "   Downloading from $installerUrl..." -ForegroundColor Gray
                Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
                
                # Install Azure CLI
                Write-Host "   Running installer (this may take a few minutes)..." -ForegroundColor Gray
                if ($PSCmdlet.ShouldProcess("Azure CLI", "Install via MSI")) {
                    $installProcess = Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /qn /norestart" -Wait -PassThru
                    
                    if ($installProcess.ExitCode -eq 0) {
                        Write-Host "✅ Azure CLI installed successfully!" -ForegroundColor Green
                        
                        # Refresh environment variables
                        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
                        
                        Write-Host "   ⚠️  You may need to restart your terminal for the PATH changes to take effect." -ForegroundColor Yellow
                    } else {
                        Write-Error "Azure CLI installation failed with exit code: $($installProcess.ExitCode)"
                    }
                }
                
                # Clean up installer
                if (Test-Path $installerPath) {
                    Remove-Item $installerPath -Force
                }
            } catch {
                Write-Error "Failed to install Azure CLI: $_"
            }
        }
    } elseif ($onMacOS) {
        # macOS installation using Homebrew
        Write-Host "   Checking for Homebrew..." -ForegroundColor White
        
        $brewInstalled = $false
        try {
            $null = brew --version 2>$null
            $brewInstalled = $true
            Write-Host "   ✅ Homebrew is installed" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ Homebrew is not installed" -ForegroundColor Red
        }
        
        if ($brewInstalled) {
            Write-Host "   Installing Azure CLI via Homebrew..." -ForegroundColor White
            if ($PSCmdlet.ShouldProcess("Azure CLI", "Install via Homebrew")) {
                try {
                    $null = brew install azure-cli 2>&1
                    Write-Host "✅ Azure CLI installed successfully!" -ForegroundColor Green
                } catch {
                    Write-Error "Failed to install Azure CLI via Homebrew: $_"
                }
            }
        } else {
            # Fallback to pip if Homebrew is not available
            Write-Host "   Checking for pip (Python package manager)..." -ForegroundColor White
            
            $pipInstalled = $false
            $pipCommand = $null
            
            # Check for pip3 first (preferred), then pip
            foreach ($cmd in @('pip3', 'pip')) {
                try {
                    $null = & $cmd --version 2>$null
                    $pipInstalled = $true
                    $pipCommand = $cmd
                    Write-Host "   ✅ $cmd is available" -ForegroundColor Green
                    break
                } catch {
                    # Continue checking
                }
            }
            
            if ($pipInstalled) {
                Write-Host "   Installing Azure CLI via pip..." -ForegroundColor White
                Write-Host "   💡 Tip: Install Homebrew for easier package management: https://brew.sh" -ForegroundColor Cyan
                
                if ($PSCmdlet.ShouldProcess("Azure CLI", "Install via pip")) {
                    try {
                        # Install Azure CLI using pip
                        $pipArgs = @('install', 'azure-cli')
                        if ($Force) {
                            $pipArgs += '--upgrade'
                        }
                        
                        $process = Start-Process -FilePath $pipCommand -ArgumentList $pipArgs -Wait -NoNewWindow -PassThru
                        
                        if ($process.ExitCode -eq 0) {
                            Write-Host "✅ Azure CLI installed successfully!" -ForegroundColor Green
                        } else {
                            Write-Warning "pip installation returned exit code: $($process.ExitCode)"
                            Write-Host "   Trying with --user flag..." -ForegroundColor Yellow
                            
                            # Retry with --user flag for user-level installation
                            $pipArgs += '--user'
                            $process = Start-Process -FilePath $pipCommand -ArgumentList $pipArgs -Wait -NoNewWindow -PassThru
                            
                            if ($process.ExitCode -eq 0) {
                                Write-Host "✅ Azure CLI installed successfully!" -ForegroundColor Green
                                Write-Host "   ⚠️  Installed to user directory. You may need to add ~/.local/bin to your PATH" -ForegroundColor Yellow
                            } else {
                                Write-Error "pip installation failed with exit code: $($process.ExitCode)"
                            }
                        }
                    } catch {
                        Write-Error "Failed to install Azure CLI via pip: $_"
                    }
                }
            } else {
                Write-Host "   ❌ Neither Homebrew nor pip is available" -ForegroundColor Red
                Write-Host ""
                Write-Host "   Please install one of the following:" -ForegroundColor Yellow
                Write-Host "   1. Homebrew (recommended):" -ForegroundColor Yellow
                Write-Host '      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' -ForegroundColor White
                Write-Host ""
                Write-Host "   2. Python/pip:" -ForegroundColor Yellow
                Write-Host "      brew install python" -ForegroundColor White
                Write-Host "      - OR download from https://www.python.org/downloads/" -ForegroundColor White
                Write-Host ""
                Write-Host "   3. Install Azure CLI manually from: https://aka.ms/installazureclimacos" -ForegroundColor Yellow
                exit 1
            }
        }
    }
    
    # Verify installation
    Start-Sleep -Seconds 2
    try {
        $azOutput = az version --output json 2>$null | ConvertFrom-Json
        $azCliVersion = $azOutput.'azure-cli'
        Write-Host "✅ Verified: Azure CLI version $azCliVersion is now available" -ForegroundColor Green
    } catch {
        Write-Warning "Azure CLI was installed but cannot be verified. You may need to restart your terminal."
    }
}

#endregion

#region Azure DevOps Extension

Write-Host ""
Write-Host "🔍 Checking Azure DevOps CLI extension..." -ForegroundColor Yellow

if ($SkipAzureDevOpsExtension) {
    Write-Host "⏭️  Skipping Azure DevOps extension installation (SkipAzureDevOpsExtension flag set)" -ForegroundColor Yellow
} else {
    $adoExtensionInstalled = $false
    $adoExtensionVersion = $null
    
    try {
        $extensions = az extension list --output json 2>$null | ConvertFrom-Json
        $adoExtension = $extensions | Where-Object { $_.name -eq 'azure-devops' }
        
        if ($adoExtension) {
            $adoExtensionInstalled = $true
            $adoExtensionVersion = $adoExtension.version
            Write-Host "✅ Azure DevOps extension is already installed (version $adoExtensionVersion)" -ForegroundColor Green
        } else {
            Write-Host "❌ Azure DevOps extension is not installed" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Unable to check Azure DevOps extension status" -ForegroundColor Red
    }
    
    if (-not $adoExtensionInstalled) {
        Write-Host "📦 Installing Azure DevOps CLI extension..." -ForegroundColor Yellow
        
        if ($PSCmdlet.ShouldProcess("Azure DevOps CLI Extension", "Install")) {
            try {
                $null = az extension add --name azure-devops 2>&1
                Write-Host "✅ Azure DevOps extension installed successfully!" -ForegroundColor Green
                
                # Verify installation
                Start-Sleep -Seconds 1
                $extensions = az extension list --output json 2>$null | ConvertFrom-Json
                $adoExtension = $extensions | Where-Object { $_.name -eq 'azure-devops' }
                if ($adoExtension) {
                    Write-Host "✅ Verified: Azure DevOps extension version $($adoExtension.version) is now available" -ForegroundColor Green
                }
            } catch {
                Write-Error "Failed to install Azure DevOps extension: $_"
            }
        }
    } elseif ($Force) {
        Write-Host "🔄 Updating Azure DevOps CLI extension..." -ForegroundColor Yellow
        
        if ($PSCmdlet.ShouldProcess("Azure DevOps CLI Extension", "Update")) {
            try {
                $null = az extension update --name azure-devops 2>&1
                Write-Host "✅ Azure DevOps extension updated successfully!" -ForegroundColor Green
            } catch {
                Write-Warning "Failed to update Azure DevOps extension: $_"
            }
        }
    }
}

#endregion

#region Summary

Write-Host ""
Write-Host "🎉 Prerequisites Check Complete!" -ForegroundColor Green
Write-Host "=" * 50
Write-Host ""
Write-Host "📋 Summary:" -ForegroundColor Cyan

if ($azCliVersion) {
    Write-Host "   ✅ Azure CLI: $azCliVersion" -ForegroundColor Green
} else {
    Write-Host "   ❌ Azure CLI: Not available" -ForegroundColor Red
}

if (-not $SkipAzureDevOpsExtension) {
    if ($adoExtension) {
        Write-Host "   ✅ Azure DevOps Extension: $($adoExtension.version)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Azure DevOps Extension: Not available" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "💡 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Run 'az login' to authenticate with Azure" -ForegroundColor White
Write-Host "   2. Run 'SetUpADO' to configure Azure DevOps connection" -ForegroundColor White
Write-Host "   3. Start using ADOWrapper commands!" -ForegroundColor White
Write-Host ""

#endregion
