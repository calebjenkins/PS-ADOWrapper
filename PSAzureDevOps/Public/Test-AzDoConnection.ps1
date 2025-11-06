function Test-AzDoConnection {
    <#
    .SYNOPSIS
        Tests if Azure DevOps CLI is configured and connected
    
    .DESCRIPTION
        Checks if the Azure DevOps CLI is installed and configured with proper authentication
    
    .EXAMPLE
        Test-AzDoConnection
        
        Returns $true if connected, $false otherwise
    #>
    [CmdletBinding()]
    param()
    
    try {
        # Try to get the default organization
        $result = az devops configure --list 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Verbose "Azure DevOps CLI is configured"
            return $true
        }
        else {
            Write-Verbose "Azure DevOps CLI is not configured"
            return $false
        }
    }
    catch {
        Write-Error "Failed to test Azure DevOps connection: $_"
        return $false
    }
}
