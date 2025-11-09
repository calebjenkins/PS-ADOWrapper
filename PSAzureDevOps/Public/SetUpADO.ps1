function SetUpADO {
    <#
    .SYNOPSIS
        Sets up Azure DevOps CLI configuration by prompting for and storing credentials locally.
    
    .DESCRIPTION
        This function prompts the user for Azure DevOps organization URL, project name, and Personal Access Token (PAT).
        It stores these values locally so they don't need to be supplied with every CLI command.
        The configuration is stored in the user's profile directory in a JSON file.
    
    .EXAMPLE
        SetUpADO
        Prompts for ADO organization, project, and PAT, then stores them locally.
    
    .NOTES
        The PAT is stored as a secure string in the configuration file.
    #>
    [CmdletBinding()]
    param()
    
    Write-Host "Azure DevOps CLI Setup" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor Cyan
    Write-Host ""
    
    # Prompt for Organization URL
    $orgUrl = Read-Host "Enter your Azure DevOps Organization URL (e.g., https://dev.azure.com/yourorg)"
    while ([string]::IsNullOrWhiteSpace($orgUrl)) {
        Write-Host "Organization URL is required." -ForegroundColor Yellow
        $orgUrl = Read-Host "Enter your Azure DevOps Organization URL"
    }
    
    # Prompt for Project Name
    $project = Read-Host "Enter your default Project name"
    while ([string]::IsNullOrWhiteSpace($project)) {
        Write-Host "Project name is required." -ForegroundColor Yellow
        $project = Read-Host "Enter your default Project name"
    }
    
    # Prompt for PAT
    $pat = Read-Host "Enter your Personal Access Token (PAT)" -AsSecureString
    
    # Get current user email/name for work items
    $userName = Read-Host "Enter your name/email for work item assignment (optional)"
    
    # Create configuration directory if it doesn't exist (cross-platform)
    $userProfile = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
    $configDir = Join-Path $userProfile ".psazuredevops"
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
    
    # Create configuration object
    $config = @{
        OrganizationUrl = $orgUrl
        Project = $project
        PAT = ConvertFrom-SecureString -SecureString $pat
        UserName = $userName
        ConfiguredDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    # Save configuration to file
    $configPath = Join-Path $configDir "config.json"
    $config | ConvertTo-Json | Set-Content -Path $configPath -Force
    
    Write-Host ""
    Write-Host "Configuration saved successfully!" -ForegroundColor Green
    Write-Host "Config location: $configPath" -ForegroundColor Gray
    Write-Host ""
    
    # Configure Azure DevOps CLI defaults
    $BSTR = $null
    try {
        # Convert SecureString back to plain text for az devops configure
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pat)
        $plainPat = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        
        # Set defaults for az devops CLI
        az devops configure --defaults organization=$orgUrl project=$project --use-git-aliases true 2>&1 | Out-Null
        
        # Login with PAT (environment variable is used by Azure DevOps CLI)
        # Note: This exposes the PAT to child processes during this session
        $env:AZURE_DEVOPS_EXT_PAT = $plainPat
        Write-Host "Azure DevOps CLI configured with defaults." -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to configure Azure DevOps CLI: $_"
        Write-Host "You may need to run 'az login' manually." -ForegroundColor Yellow
    }
    finally {
        # Always clean up sensitive data from memory
        if ($BSTR -ne $null) {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        }
    }
    
    Write-Host ""
    Write-Host "Setup complete! You can now use Azure DevOps commands without specifying these details every time." -ForegroundColor Green
}
