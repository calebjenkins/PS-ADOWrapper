# PSAzureDevOps

A set of PowerShell commands to wrap Azure DevOps CLI, making it easier to work with from the command line.

## Overview

PSAzureDevOps is a PowerShell module that provides convenient wrapper functions around the Azure DevOps CLI (`az devops`), simplifying common Azure DevOps operations.

## Prerequisites

- PowerShell 5.1 or higher (PowerShell 7+ recommended)
- Azure CLI with DevOps extension (`az devops`)

## Installation

### From Source

Clone the repository and run the build script:

```powershell
# Clone the repository
git clone https://github.com/calebjenkins/PSAzureDevOps.git
cd PSAzureDevOps

# Install the module locally
./build.ps1 -Task Install

# Import the module
Import-Module PSAzureDevOps
```

## Usage

### Check Azure DevOps CLI Version

```powershell
Get-AzDoVersion
```

### Test Azure DevOps Connection

```powershell
Test-AzDoConnection
```

## Building and Testing

The module includes a build script for common tasks:

```powershell
# Build the module
./build.ps1 -Task Build

# Run tests
./build.ps1 -Task Test

# Clean build artifacts
./build.ps1 -Task Clean

# Install locally
./build.ps1 -Task Install
```

## Project Structure

```
PSAzureDevOps/
├── PSAzureDevOps/          # Module directory
│   ├── Public/             # Public functions (exported)
│   ├── Private/            # Private functions (internal use)
│   ├── PSAzureDevOps.psd1  # Module manifest
│   └── PSAzureDevOps.psm1  # Root module file
├── Tests/                  # Pester tests
├── build.ps1               # Build script
└── README.md               # This file
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

See [LICENSE](LICENSE) file for details.

