function Get-ADOConfig {
    <#
    .SYNOPSIS
        Retrieves the stored Azure DevOps configuration.
    
    .DESCRIPTION
        Internal function to load the Azure DevOps configuration from the user's profile.
    
    .OUTPUTS
        Hashtable containing the ADO configuration.
    #>
    [CmdletBinding()]
    param()
    
    $userProfile = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
    $configDir = Join-Path $userProfile ".adowrapper"
    $configPath = Join-Path $configDir "config.json"
    
    if (-not (Test-Path $configPath)) {
        throw "Azure DevOps configuration not found. Please run 'SetUpADO' first to configure your settings."
    }
    
    try {
        $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
        
        # Convert PAT back to SecureString and set environment variable
        if ($config.PAT) {
            $BSTR = $null
            try {
                $securePatString = $config.PAT | ConvertTo-SecureString
                $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePatString)
                $plainPat = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
                
                # Set environment variable for Azure DevOps CLI
                # Note: This exposes the PAT to child processes during this session
                $env:AZURE_DEVOPS_EXT_PAT = $plainPat
            }
            finally {
                # Always clean up sensitive data from memory
                if ($BSTR -ne $null) {
                    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
                }
            }
        }
        
        return $config
    }
    catch {
        throw "Failed to load Azure DevOps configuration: $_"
    }
}
