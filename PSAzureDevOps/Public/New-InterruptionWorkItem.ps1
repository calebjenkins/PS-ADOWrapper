function New-InterruptionWorkItem {
    <#
    .SYNOPSIS
        Creates a new work item tagged as an interruption and assigned to you.
    
    .DESCRIPTION
        This function creates a new work item in Azure DevOps, automatically assigned to you
        and tagged with "Interruption". You only need to provide the title.
    
    .PARAMETER Title
        The title of the work item.
    
    .PARAMETER Type
        The type of work item to create. Defaults to "Task".
    
    .PARAMETER Description
        Optional description for the work item.
    
    .EXAMPLE
        New-InterruptionWorkItem -Title "Fix production bug"
        Creates a new interruption work item with the specified title.
    
    .EXAMPLE
        wi-i "Urgent customer call"
        Uses the alias to quickly create an interruption work item.
    
    .NOTES
        This function requires SetUpADO to be run first to configure Azure DevOps settings.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Title,
        
        [Parameter(Mandatory = $false)]
        [string]$Type = "Task",
        
        [Parameter(Mandatory = $false)]
        [string]$Description = ""
    )
    
    try {
        # Load configuration
        $config = Get-ADOConfig
        
        Write-Host "Creating interruption work item..." -ForegroundColor Cyan
        
        # Build the az boards work-item create command
        $args = @(
            "boards", "work-item", "create",
            "--title", $Title,
            "--type", $Type,
            "--organization", $config.OrganizationUrl,
            "--project", $config.Project
        )
        
        # Add description if provided
        if (-not [string]::IsNullOrWhiteSpace($Description)) {
            $args += "--description"
            $args += $Description
        }
        
        # Add tags
        $args += "--fields"
        $args += "System.Tags=Interruption"
        
        # Add assignment if user name is configured
        if (-not [string]::IsNullOrWhiteSpace($config.UserName)) {
            $args += "System.AssignedTo=$($config.UserName)"
        }
        
        # Execute the command
        $result = & az @args 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            $workItem = $result | ConvertFrom-Json
            Write-Host ""
            Write-Host "Work item created successfully!" -ForegroundColor Green
            Write-Host "ID: $($workItem.id)" -ForegroundColor White
            Write-Host "Title: $($workItem.fields.'System.Title')" -ForegroundColor White
            Write-Host "Type: $($workItem.fields.'System.WorkItemType')" -ForegroundColor White
            Write-Host "Tags: $($workItem.fields.'System.Tags')" -ForegroundColor White
            
            if ($workItem.fields.'System.AssignedTo') {
                Write-Host "Assigned To: $($workItem.fields.'System.AssignedTo'.displayName)" -ForegroundColor White
            }
            
            Write-Host "URL: $($workItem._links.html.href)" -ForegroundColor Cyan
            Write-Host ""
            
            return $workItem
        }
        else {
            Write-Error "Failed to create work item: $result"
        }
    }
    catch {
        Write-Error "Error creating work item: $_"
    }
}

# Create alias for quick access
Set-Alias -Name wi-i -Value New-InterruptionWorkItem
