# PSAzureDevOps

A PowerShell module that simplifies working with Azure DevOps CLI by providing convenient wrapper functions and preset scenarios for common tasks.

## Features

- **SetUpADO**: One-time setup to store Azure DevOps credentials and configuration locally
- **wi-i (New-InterruptionWorkItem)**: Quick command to create work items tagged as interruptions and auto-assigned to you
- **Cross-platform**: Works on Windows, Linux, and macOS
- **Secure storage**: PAT tokens are stored as secure strings

## Prerequisites

- PowerShell 5.1 or later (PowerShell 7+ recommended)
- Azure CLI with Azure DevOps extension installed
  ```powershell
  az extension add --name azure-devops
  ```

## Installation

### From Source
1. Clone the repository:
   ```powershell
   git clone https://github.com/calebjenkins/PSAzureDevOps.git
   ```

2. Import the module:
   ```powershell
   Import-Module ./PSAzureDevOps/PSAzureDevOps.psm1
   ```

### Manual Installation
Copy the `PSAzureDevOps` folder to one of your PowerShell module paths:
```powershell
# View your module paths
$env:PSModulePath -split [IO.Path]::PathSeparator

# Copy to user module path (example)
Copy-Item -Path ./PSAzureDevOps -Destination "$HOME/Documents/PowerShell/Modules/" -Recurse
```

## Usage

### Initial Setup

Before using the module, run the setup command to configure your Azure DevOps connection:

```powershell
SetUpADO
```

This will prompt you for:
- **Organization URL**: Your Azure DevOps organization URL (e.g., `https://dev.azure.com/yourorg`)
- **Project Name**: Your default project name
- **Personal Access Token (PAT)**: Your Azure DevOps PAT (stored securely)
- **User Name/Email**: Your name or email for work item assignment (optional)

Configuration is stored in `~/.psazuredevops/config.json` and credentials are encrypted.

### Creating Interruption Work Items

Use the `wi-i` command (alias for `New-InterruptionWorkItem`) to quickly create work items:

```powershell
# Quick syntax
wi-i "Urgent customer call"

# Full command with options
New-InterruptionWorkItem -Title "Production bug fix" -Type "Bug" -Description "Critical issue in production"
```

This automatically:
- Creates a work item in your configured Azure DevOps project
- Tags it with "Interruption"
- Assigns it to you (if configured)
- Returns the work item details including a URL

### Examples

```powershell
# Set up Azure DevOps connection (first time only)
SetUpADO

# Create a simple interruption
wi-i "Meeting with stakeholder"

# Create an interruption with description
New-InterruptionWorkItem -Title "Code review request" -Description "Review PR #123"

# Create a bug as an interruption
New-InterruptionWorkItem -Title "Fix login issue" -Type "Bug"
```

## Available Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `SetUpADO` | - | Configure Azure DevOps connection and store credentials |
| `New-InterruptionWorkItem` | `wi-i` | Create a work item tagged as interruption and assigned to you |

## Testing

The module includes comprehensive Pester tests. To run the tests:

```powershell
# Navigate to the module directory
cd PSAzureDevOps

# Run tests
Invoke-Pester -Path ./Tests/PSAzureDevOps.Tests.ps1
```

## Configuration File Location

- **Windows**: `%USERPROFILE%\.psazuredevops\config.json`
- **Linux/macOS**: `~/.psazuredevops/config.json`

## Security Notes

- PAT tokens are stored as encrypted secure strings in the configuration file
- The PAT is temporarily exposed as an environment variable (`AZURE_DEVOPS_EXT_PAT`) when using Azure DevOps CLI commands, which is required by the Azure CLI
- Memory cleanup is properly handled using try-finally blocks to prevent sensitive data leaks
- The configuration file should have restricted permissions
- Never commit your PAT token to source control
- Regularly rotate your PAT tokens according to your organization's security policy

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

See the [LICENSE](LICENSE) file for details.

## Author

Caleb Jenkins
