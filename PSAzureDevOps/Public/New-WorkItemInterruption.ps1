
function New-WorkItemInterruption {
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