
function New-WorkItemInterruption {
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

    .PARAMETER Tags
        Tags to associate with the work item.

    .EXAMPLE
        New-WorkItem -Title "Fix production bug"
        Creates a new interruption work item with the specified title.
    
    .EXAMPLE
        wi "Urgent customer call"
        Uses the alias to quickly create a work item.
    
    .NOTES
        This function requires SetUpADO to be run first to configure Azure DevOps settings.
    #>
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Title,

        [Parameter(Mandatory = $false)]
        [string]$Type = "Task",

        [Parameter(Mandatory = $false)]
        [string]$Description = "",

        [Parameter(Mandatory = $false)]
        [string]$Tags = ""
    )

    # Add the "Interruption" tag to the existing tags
    if ($PSBoundParameters.ContainsKey('Tags')) {
        $PSBoundParameters['Tags'] = if ([string]::IsNullOrWhiteSpace($PSBoundParameters['Tags'])) {
            "Interruption"
        }
        else {
            $PSBoundParameters['Tags'] + ";Interruption"
        }
    }
    else {
        $PSBoundParameters['Tags'] = "Interruption"
    }

    New-WorkItem @PSBoundParameters
}

# Create alias for quick access
Set-Alias -Name wi-i -Value New-WorkItemInterruption