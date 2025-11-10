# ADOWrapper PowerShell Module

This directory contains the ADOWrapper PowerShell module files.

## Project Structure

```
ADOWrapper/
├── ADOWrapper/           # Module directory
│   ├── ADOWrapper.psd1   # Module manifest
│   ├── ADOWrapper.psm1   # Main module file
│   ├── Public/              # Exported functions
│   ├── Private/             # Internal helper functions
│   └── Tests/               # Pester tests
├── Install-Module.ps1       # Installation script
├── Install-Prereqs.ps1      # Checks for and installs prereqs - Azure CLI and ADO extension
├── Demo.ps1                 # Demo script
└── README.md                # Main documentation
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
