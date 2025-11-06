# PSAzureDevOps PowerShell Module

This directory contains the PSAzureDevOps PowerShell module files.

## Structure

```
PSAzureDevOps/
├── PSAzureDevOps.psd1          # Module manifest
├── PSAzureDevOps.psm1          # Main module file
├── Public/                      # Exported functions
│   ├── SetUpADO.ps1            # Setup Azure DevOps configuration
│   └── New-InterruptionWorkItem.ps1  # Create interruption work items (wi-i)
├── Private/                     # Internal helper functions
│   └── Get-ADOConfig.ps1       # Load configuration
└── Tests/                       # Pester tests
    └── PSAzureDevOps.Tests.ps1
```

## Installation

Import the module:
```powershell
Import-Module ./PSAzureDevOps.psm1
```

Or install to your PowerShell modules directory for automatic loading:
```powershell
Copy-Item -Path . -Destination "$HOME/Documents/PowerShell/Modules/PSAzureDevOps" -Recurse
Import-Module PSAzureDevOps
```

## Quick Start

1. Run setup:
   ```powershell
   SetUpADO
   ```

2. Create interruption work items:
   ```powershell
   wi-i "Your work item title"
   ```

See the main [README.md](../README.md) for full documentation.
