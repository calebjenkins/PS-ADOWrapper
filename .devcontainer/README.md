# ADOWrapper Development Container

This directory contains the development container configuration for the ADOWrapper project. The devcontainer ensures a consistent development environment with the correct versions of PowerShell, Pester, and other required tools.

## What's Included

### Base Image
- **PowerShell Latest**: Uses Microsoft's official PowerShell devcontainer image
- **Ubuntu 22.04**: Based on Ubuntu LTS for stability

### PowerShell Modules
- **Pester**: Latest version for testing (5.x+)
- **PSScriptAnalyzer**: Code quality and style analysis
- **platyPS**: Help documentation generation

### Tools
- **Azure CLI**: With Azure DevOps extension
- **Git**: Version control
- **VS Code Extensions**: PowerShell, Azure DevOps, Pester Test Explorer

### VS Code Configuration
- PowerShell as default terminal
- Recommended extensions auto-installed
- Optimized settings for PowerShell development

## Quick Start

1. **Prerequisites**:
   - VS Code with Dev Containers extension
   - Docker Desktop

2. **Open in Container**:
   ```
   Command Palette → Dev Containers: Reopen in Container
   ```

3. **Verify Setup**:
   ```powershell
   # Check PowerShell version
   $PSVersionTable
   
   # Check Pester version
   Get-Module Pester -ListAvailable
   
   # Run tests
   Test-Module
   ```

## Development Workflow

### Running Tests
```powershell
# Run all tests
Invoke-Pester -Path ./ADOWrapper/Tests/

# Run tests with coverage
Test-Module

# Run specific test
Invoke-Pester -Path ./ADOWrapper/Tests/ADOWrapper.Tests.ps1 -Output Detailed
```

### Code Quality
```powershell
# Analyze code quality
Test-CodeQuality

# Or manually
Invoke-ScriptAnalyzer -Path ./ADOWrapper/ -Recurse
```

### Azure DevOps Setup
```bash
# Login to Azure
az login

# Configure Azure DevOps
az devops configure --defaults organization=https://dev.azure.com/yourorg project=yourproject
```

## Container Features

### Environment Variables
- `POWERSHELL_DISTRIBUTION_CHANNEL`: Identifies container environment

### Mounted Volumes
- `~/.azure`: Preserves Azure CLI authentication between container rebuilds

### Port Forwarding
- Ready for any ports your development might need

## Customization

### Adding Extensions
Edit `.devcontainer/devcontainer.json`:
```json
"extensions": [
  "ms-vscode.powershell",
  "your-new-extension"
]
```

### Adding PowerShell Modules
Edit `.devcontainer/setup.sh`:
```bash
pwsh -c "Install-Module -Name YourModule -Force -Scope AllUsers"
```

### VS Code Settings
Modify the `customizations.vscode.settings` section in `devcontainer.json`.

## Troubleshooting

### Container Won't Start
1. Ensure Docker Desktop is running
2. Check Docker has sufficient resources allocated
3. Try rebuilding: `Dev Containers: Rebuild Container`

### PowerShell Module Issues
```powershell
# Refresh module cache
Import-Module PowerShellGet -Force
Update-Module PowerShellGet

# Reinstall Pester
Install-Module Pester -Force -SkipPublisherCheck
```

### Azure CLI Issues
```bash
# Reinstall Azure DevOps extension
az extension remove --name azure-devops
az extension add --name azure-devops
```

## Performance Tips

1. **Use bind mounts** for frequently accessed files
2. **Exclude node_modules, .git** from file watching if needed
3. **Allocate sufficient RAM** to Docker (4GB+ recommended)

## Security Notes

- The container runs as non-root user (`vscode`)
- Azure credentials are mounted from host (`~/.azure`)
- No sensitive data is baked into the container image
- PowerShell execution policy is configured for development use

## Version Pinning

The devcontainer uses `latest` tags for flexibility, but for production CI/CD, consider pinning specific versions:

```json
"image": "mcr.microsoft.com/devcontainers/powershell:7.4-ubuntu-22.04"
```