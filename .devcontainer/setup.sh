#!/bin/bash

# ADOWrapper Development Container Setup Script
echo "🚀 Setting up ADOWrapper development environment..."

# Update package lists
sudo apt-get update

# Install additional tools that might be useful
sudo apt-get install -y \
    curl \
    wget \
    unzip \
    jq

# Ensure PowerShell is available and up to date
echo "📦 Configuring PowerShell..."
pwsh -c "Write-Host 'PowerShell Version:' -ForegroundColor Cyan; $PSVersionTable.PSVersion"

# Install required PowerShell modules
echo "📦 Installing PowerShell modules..."
pwsh -c "
    # Set PSGallery as trusted to avoid prompts
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    
    # Install Pester (latest version)
    Write-Host 'Installing Pester...' -ForegroundColor Yellow
    Install-Module -Name Pester -Force -SkipPublisherCheck -Scope AllUsers
    
    # Install PSScriptAnalyzer for code quality
    Write-Host 'Installing PSScriptAnalyzer...' -ForegroundColor Yellow
    Install-Module -Name PSScriptAnalyzer -Force -Scope AllUsers
    
    # Install platyPS for help generation
    Write-Host 'Installing platyPS...' -ForegroundColor Yellow
    Install-Module -Name platyPS -Force -Scope AllUsers
    
    # Verify installations
    Write-Host 'Installed Modules:' -ForegroundColor Green
    Get-Module -ListAvailable Pester, PSScriptAnalyzer, platyPS | Select-Object Name, Version
    
    Write-Host 'Pester Version Details:' -ForegroundColor Green
    Import-Module Pester -Force
    Get-Module Pester | Select-Object Name, Version, Path
"

# Install Azure CLI DevOps extension
echo "🔧 Installing Azure CLI DevOps extension..."
az extension add --name azure-devops --yes

# Set up git configuration (if not already configured)
echo "🔧 Configuring Git..."
if [ -z "$(git config --global user.name)" ]; then
    echo "Git user.name not set. Please configure it later with: git config --global user.name 'Your Name'"
fi

if [ -z "$(git config --global user.email)" ]; then
    echo "Git user.email not set. Please configure it later with: git config --global user.email 'your.email@example.com'"
fi

# Create a PowerShell profile for the development environment
echo "📝 Setting up PowerShell profile..."
pwsh -c "
    # Create profile directory if it doesn't exist
    \$profileDir = Split-Path \$PROFILE -Parent
    if (!(Test-Path \$profileDir)) {
        New-Item -ItemType Directory -Path \$profileDir -Force
    }
    
    # Create a basic profile with useful aliases and functions
    @'
# ADOWrapper Development Profile
Write-Host \"ADOWrapper Development Environment Loaded\" -ForegroundColor Green

# Import Pester module
Import-Module Pester -Force

# Useful aliases for development
Set-Alias -Name test -Value Invoke-Pester
Set-Alias -Name analyze -Value Invoke-ScriptAnalyzer

# Function to run tests with coverage
function Test-Module {
    param([string]\$Path = './ADOWrapper/Tests/')
    Invoke-Pester -Path \$Path -CodeCoverage './ADOWrapper/Public/*.ps1' -OutputFormat NUnitXml -OutputFile 'TestResults.xml'
}

# Function to analyze code quality
function Test-CodeQuality {
    param([string]\$Path = './ADOWrapper/')
    Invoke-ScriptAnalyzer -Path \$Path -Recurse -Severity Warning,Error
}

# Function to show module information
function Show-ModuleInfo {
    Get-Module ADOWrapper -ListAvailable | Format-List
}

Write-Host \"Available commands: Test-Module, Test-CodeQuality, Show-ModuleInfo\" -ForegroundColor Cyan
'@ | Out-File -FilePath \$PROFILE -Encoding UTF8
"

echo "✅ ADOWrapper development environment setup complete!"
echo ""
echo "🎯 Next steps:"
echo "   1. Open the workspace in VS Code"
echo "   2. Run 'Test-Module' to execute Pester tests"
echo "   3. Run 'Test-CodeQuality' to analyze code"
echo "   4. Configure Azure CLI: az login"
echo ""
echo "📚 Useful commands:"
echo "   - test ./ADOWrapper/Tests/  # Run Pester tests"
echo "   - analyze ./ADOWrapper/    # Analyze code quality"
echo "   - az devops configure --list  # Check Azure DevOps config"