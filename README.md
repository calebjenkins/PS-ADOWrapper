# ADOWrapper
[![Test ADOWrapper Module](https://github.com/calebjenkins/PS-ADOWrapper/actions/workflows/test.yml/badge.svg)](https://github.com/calebjenkins/PS-ADOWrapper/actions/workflows/test.yml)

A PowerShell module that Wraps ADO Workitems and simplifies working with Azure DevOps CLI by providing convenient wrapper functions and pre-set scenarios for common tasks. ADO CLI is fantastic for being able to script and adutomate parts of Azure DevOps, but it can be extremely cumbersome as a direct CLI interface with ADO WorkItems. ADO Wrapper helps solve make simple things easier to do. 

![ADO Wrapper](./docs/resources/ADO_Wrapper_clear_bling.png "ADO Wrapper")

## Features

- **SetUpADO**: One-time setup to store Azure DevOps credentials and configuration locally
- **wi (New-WorkItem)**: Create general work items with flexible options
- **wi-i (New-WorkItemInterruption)**: Quick command to create work items tagged as interruptions and auto-assigned to you
- **Cross-platform**: Works on Windows, Linux, and macOS
- **Secure storage**: PAT tokens are stored as secure strings

<!-- <video width="640" height="360" controls autoplay>
  <source src="./docs/resources/screen-wi-i.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video> -->


## Prerequisites

- PowerShell 5.1 or later (PowerShell 7+ recommended)
- Azure CLI with Azure DevOps extension installed
  ```powershell
  az extension add --name azure-devops
  ```

## Installation

### Development Container (Recommended)

For the best development experience with consistent tooling:

1. **Prerequisites**: VS Code with Dev Containers extension and Docker Desktop
2. **Clone and Open**:
   ```bash
   git clone https://github.com/calebjenkins/ADOWrapper.git
   cd ADOWrapper
   code .
   ```
3. **Reopen in Container**: `Ctrl+Shift+P` → `Dev Containers: Reopen in Container`

The devcontainer includes:
- PowerShell 7+ with latest Pester (5.x+)
- Azure CLI with DevOps extension
- PSScriptAnalyzer for code quality
- Pre-configured VS Code extensions and settings

### From Source
1. Clone the repository:
   ```powershell
   git clone https://github.com/calebjenkins/ADOWrapper.git
   ```

2. Import the module:
   ```powershell
   Import-Module ./ADOWrapper/ADOWrapper.psm1
   ```

### Manual Installation
Copy the `ADOWrapper` folder to one of your PowerShell module paths:
```powershell
# View your module paths
$env:PSModulePath -split [IO.Path]::PathSeparator

# Copy to user module path (example)
Copy-Item -Path ./ADOWrapper -Destination "$HOME/Documents/PowerShell/Modules/" -Recurse
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

Configuration is stored in `~/.adowrapper/config.json` and credentials are encrypted.

### Creating Work Items

The module provides two main functions for creating work items:

#### General Work Items

Use the `wi` command (alias for `New-WorkItem`) to create any type of work item:

```powershell
# Create a basic work item
wi "Fix login bug"

# Create with specific type and description
New-WorkItem -Title "Update documentation" -Type "Task" -Description "Update API docs"

# Create with custom tags
New-WorkItem -Title "Review PR" -Tags "Review;High-Priority"
```

#### Interruption Work Items

Use the `wi-i` command (alias for `New-WorkItemInterruption`) to quickly create work items tagged as interruptions:

```powershell
# Quick syntax for interruptions
wi-i "Urgent customer call"

# Full command with options
New-WorkItemInterruption -Title "Production bug fix" -Type "Bug" -Description "Critical issue in production"
```

Both functions automatically:
- Create a work item in your configured Azure DevOps project
- Assign it to you (if configured)
- Return the work item details including a URL

The interruption variant additionally:
- Tags the work item with "Interruption"
- Combines with any other tags you specify

### Examples

```powershell
# Set up Azure DevOps connection (first time only)
SetUpADO

# Create a general work item
wi "Update user documentation"

# Create a work item with specific type
New-WorkItem -Title "Performance optimization" -Type "Task" -Description "Optimize database queries"

# Create a simple interruption
wi-i "Meeting with stakeholder"

# Create an interruption with description and custom tags
New-WorkItemInterruption -Title "Code review request" -Description "Review PR #123" -Tags "Urgent"

# Create a bug as an interruption
New-WorkItemInterruption -Title "Fix login issue" -Type "Bug"
```

## Available Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `SetUpADO` | - | Configure Azure DevOps connection and store credentials |
| `New-WorkItem` | `wi` | Create a general work item with flexible options |
| `New-WorkItemInterruption` | `wi-i` | Create a work item tagged as interruption and assigned to you |

## Testing

The module includes comprehensive Pester tests to ensure functionality and reliability. 

### Prerequisites for Testing

1. **Install Pester** (if not already installed):
   ```powershell
   Install-Module -Name Pester -Scope CurrentUser -Force
   ```

2. **Verify Pester Installation**:
   ```powershell
   Get-Module -Name Pester -ListAvailable
   ```

### Running Tests Locally

#### Basic Test Execution

```powershell
# Navigate to the project root directory
cd c:\path\to\ADOWrapper

# Run all tests with default output
Invoke-Pester -Path .\ADOWrapper\Tests\ADOWrapper.Tests.ps1
```

#### Advanced Test Options

```powershell
# Run tests with detailed output
Invoke-Pester -Path .\ADOWrapper\Tests\ADOWrapper.Tests.ps1 -Output Detailed

# Run tests and generate a test report
Invoke-Pester -Path .\ADOWrapper\Tests\ADOWrapper.Tests.ps1 -OutputFormat NUnitXml -OutputFile "TestResults.xml"

# Run specific test contexts (examples)
Invoke-Pester -Path .\ADOWrapper\Tests\ADOWrapper.Tests.ps1 -Tag "ModuleLoading"
```

#### Test Coverage and Validation

The test suite covers:
- **Module Loading**: Verifies the module imports correctly and exports expected functions
- **Function Availability**: Ensures all public functions and aliases are properly defined
- **Help Documentation**: Validates that functions have proper help documentation
- **Parameter Validation**: Checks function parameters and their attributes
- **Configuration Management**: Tests configuration file handling and error scenarios

#### Troubleshooting Tests

If tests fail, try these steps:

1. **Clean Module Import**:
   ```powershell
   Remove-Module ADOWrapper -ErrorAction SilentlyContinue
   Import-Module .\ADOWrapper\ADOWrapper.psm1 -Force
   ```

2. **Check PowerShell Execution Policy**:
   ```powershell
   Get-ExecutionPolicy
   # If restricted, set to allow script execution:
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Verify Module Path**:
   ```powershell
   Test-Path .\ADOWrapper\ADOWrapper.psm1
   ```

### Continuous Integration

These tests are designed to run in CI/CD pipelines and will automatically validate the module's functionality across different environments.

## Configuration File Location

- **Windows**: `%USERPROFILE%\.adowrapper\config.json`
- **Linux/macOS**: `~/.adowrapper/config.json`

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

[Caleb Jenkins](https://github.com/calebjenkins/)
