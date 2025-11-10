# ADOWrapper - Usage Examples

This document provides practical examples of using the ADOWrapper module.

## Installation

### Quick Install
```powershell
# Clone the repository
git clone https://github.com/calebjenkins/ADOWrapper.git
cd ADOWrapper

# Run the installer
./Install-Module.ps1
```

### Manual Installation
```powershell
# Import the module directly
Import-Module ./ADOWrapper/ADOWrapper.psd1
```

## First-Time Setup

Before using the module, run the setup command:

```powershell
SetUpADO
```

This will prompt you for:
```
Azure DevOps CLI Setup
======================

Enter your Azure DevOps Organization URL (e.g., https://dev.azure.com/yourorg): https://dev.azure.com/contoso
Enter your default Project name: MyProject
Enter your Personal Access Token (PAT): ********
Enter your name/email for work item assignment (optional): john.doe@contoso.com

Configuration saved successfully!
Config location: /home/user/.adowrapper/config.json

Azure DevOps CLI configured with defaults.

Setup complete! You can now use Azure DevOps commands without specifying these details every time.
```

## Creating Work Items

### Quick Interruption Work Item
```powershell
# Using the alias (shortest form)
wi-i "Customer called about urgent issue"

# Output:
# Creating interruption work item...
# 
# Work item created successfully!
# ID: 123
# Title: Customer called about urgent issue
# Type: Task
# Tags: Interruption
# Assigned To: John Doe
# URL: https://dev.azure.com/contoso/MyProject/_workitems/edit/123
```

### Work Item with Description
```powershell
New-InterruptionWorkItem -Title "Production deployment issue" `
                         -Description "Database migration failed during deployment"

# Output:
# Creating interruption work item...
# 
# Work item created successfully!
# ID: 124
# Title: Production deployment issue
# Type: Task
# Tags: Interruption
# Assigned To: John Doe
# URL: https://dev.azure.com/contoso/MyProject/_workitems/edit/124
```

### Bug as Interruption
```powershell
New-InterruptionWorkItem -Title "Critical bug in payment flow" `
                         -Type "Bug" `
                         -Description "Users unable to complete checkout"

# Output:
# Creating interruption work item...
# 
# Work item created successfully!
# ID: 125
# Title: Critical bug in payment flow
# Type: Bug
# Tags: Interruption
# Assigned To: John Doe
# URL: https://dev.azure.com/contoso/MyProject/_workitems/edit/125
```

## Real-World Scenarios

### Scenario 1: Quick Task for Unexpected Meeting
```powershell
wi-i "Stakeholder meeting about Q4 roadmap"
```

### Scenario 2: Production Incident
```powershell
New-InterruptionWorkItem -Title "P0: Service outage in EU region" `
                         -Type "Bug" `
                         -Description "EU users cannot access the service. Error 503 reported."
```

### Scenario 3: Code Review Request
```powershell
wi-i "Review PR #456 - Critical security fix"
```

### Scenario 4: Documentation Update
```powershell
New-InterruptionWorkItem -Title "Update API docs for new endpoints" `
                         -Description "Add documentation for /api/v2/users endpoints"
```

## Getting Help

### View Command Help
```powershell
# Get help for SetUpADO
Get-Help SetUpADO -Full

# Get help for New-InterruptionWorkItem
Get-Help New-InterruptionWorkItem -Examples

# List all available commands
Get-Command -Module ADOWrapper
```

### Module Information
```powershell
# Get module details
Get-Module ADOWrapper | Format-List

# Test if module is loaded
Get-Module -Name ADOWrapper
```

## Configuration Management

### View Current Configuration
Configuration is stored in: `~/.adowrapper/config.json`

```powershell
# On Linux/macOS
cat ~/.adowrapper/config.json

# On Windows
Get-Content $env:USERPROFILE\.adowrapper\config.json
```

### Reconfigure
To update your configuration, simply run `SetUpADO` again:

```powershell
SetUpADO
```

This will overwrite your previous configuration.

## Troubleshooting

### Module Not Found
```powershell
# Verify module location
$env:PSModulePath -split [IO.Path]::PathSeparator

# Import module explicitly
Import-Module /path/to/ADOWrapper/ADOWrapper.psd1
```

### Configuration Not Found
```powershell
# Error: "Azure DevOps configuration not found"
# Solution: Run SetUpADO first
SetUpADO
```

### Azure CLI Not Found
```powershell
# Verify Azure CLI is installed
az --version

# Install Azure DevOps extension if needed
az extension add --name azure-devops
```

## Advanced Usage

### Using in Scripts
```powershell
# script.ps1
Import-Module ADOWrapper

# Create multiple work items
$items = @(
    "Investigate slow query performance",
    "Update deployment documentation",
    "Review security scan results"
)

foreach ($item in $items) {
    wi-i $item
    Start-Sleep -Seconds 1  # Rate limiting
}
```

### Pipeline Integration
```yaml
# Azure Pipeline example
steps:
- pwsh: |
    Import-Module ADOWrapper
    wi-i "Pipeline failed: $($env:BUILD_BUILDNUMBER)"
  displayName: 'Create interruption work item'
  condition: failed()
```

## Tips and Best Practices

1. **Keep PAT secure**: Never commit your PAT or configuration file to source control
2. **Use descriptive titles**: Make work items easy to identify later
3. **Regular setup**: Re-run SetUpADO when you rotate your PAT
4. **Tag consistently**: The "Interruption" tag helps track unplanned work
5. **Review regularly**: Check your interruption work items to identify patterns

## More Information

- [GitHub Repository](https://github.com/calebjenkins/ADOWrapper)
- [Azure DevOps CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/service-page/azure%20devops)
- [PowerShell Gallery](https://www.powershellgallery.com/) (coming soon)
