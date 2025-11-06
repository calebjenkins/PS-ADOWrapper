function Get-AzDoVersion {
    <#
    .SYNOPSIS
        Gets the version of Azure DevOps CLI
    
    .DESCRIPTION
        Retrieves the installed version of the Azure DevOps CLI (az devops)
    
    .EXAMPLE
        Get-AzDoVersion
        
        Returns the Azure DevOps CLI version
    #>
    [CmdletBinding()]
    param()
    
    try {
        $version = az devops --version 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0 -and $version) {
            return $version.Trim()
        }
        else {
            Write-Warning "Azure DevOps CLI is not installed or not in PATH"
            return $null
        }
    }
    catch {
        Write-Error "Failed to get Azure DevOps CLI version: $_"
        return $null
    }
}
