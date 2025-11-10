# ADOWrapper PowerShell Module

This directory contains the ADOWrapper PowerShell module files.

## Structure

```
ADOWrapper/
├── ADOWrapper.psd1          # Module manifest
├── ADOWrapper.psm1          # Main module file
├── Public/                  # Exported functions
│   ├── SetUpADO.ps1        # Setup Azure DevOps configuration
│   └── New-InterruptionWorkItem.ps1  # Create interruption work items (wi-i)
├── Private/                 # Internal helper functions
│   └── Get-ADOConfig.ps1   # Load configuration
└── Tests/                   # Pester tests
    └── ADOWrapper.Tests.ps1
```

## Installation

Import the module:
```powershell
Import-Module ./ADOWrapper.psm1
```

Or install to your PowerShell modules directory for automatic loading:
```powershell
Copy-Item -Path . -Destination "$HOME/Documents/PowerShell/Modules/ADOWrapper" -Recurse
Import-Module ADOWrapper
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
