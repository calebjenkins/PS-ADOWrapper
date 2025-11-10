# Contributing to ADOWrapper

Thank you for your interest in contributing to ADOWrapper! This document provides guidelines and information for contributors.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a feature branch
4. Make your changes
5. Test your changes
6. Submit a pull request

## Development Setup

### Prerequisites
- PowerShell 5.1 or later (PowerShell 7+ recommended)
- Azure CLI with Azure DevOps extension
- Pester 5.x for testing

### Installing Dependencies
```powershell
# Install Pester if not already installed
Install-Module -Name Pester -Force -SkipPublisherCheck

# Install Azure CLI (if needed)
# See: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

# Install Azure DevOps extension
az extension add --name azure-devops
```

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
├── Demo.ps1                 # Demo script
└── README.md                # Main documentation
```

## Coding Standards

### PowerShell Best Practices
- Follow [PowerShell Best Practices and Style Guide](https://poshcode.gitbook.io/powershell-practice-and-style/)
- Use approved verbs for function names (`Get-Verb` to list)
- Include comment-based help for all public functions
- Use `[CmdletBinding()]` for advanced functions
- Include proper parameter validation

### Function Structure
```powershell
function Verb-Noun {
    <#
    .SYNOPSIS
        Brief description
    
    .DESCRIPTION
        Detailed description
    
    .PARAMETER ParameterName
        Parameter description
    
    .EXAMPLE
        Example usage
    
    .NOTES
        Additional notes
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ParameterName
    )
    
    # Function implementation
}
```

## Testing

### Running Tests
```powershell
# Run all tests
Invoke-Pester -Path ./ADOWrapper/Tests/

# Run specific test file
Invoke-Pester -Path ./ADOWrapper/Tests/ADOWrapper.Tests.ps1

# Run with detailed output
Invoke-Pester -Path ./ADOWrapper/Tests/ -Output Detailed
```

### Writing Tests
- Write tests using Pester 5.x syntax
- Place tests in the `Tests/` directory
- Name test files with `.Tests.ps1` suffix
- Test both success and failure scenarios
- Mock external dependencies (like `az` CLI calls)

### Test Coverage
Aim for comprehensive test coverage including:
- Function existence and availability
- Parameter validation
- Help documentation
- Error handling
- Edge cases

## Pull Request Process

1. **Update documentation**: Ensure README and help text are updated
2. **Add tests**: Include tests for new functionality
3. **Run tests**: Ensure all tests pass
4. **Update version**: Follow semantic versioning in the module manifest
5. **Write clear commit messages**: Use descriptive commit messages
6. **Submit PR**: Create a pull request with a clear description

### Pull Request Checklist
- [ ] Code follows project style guidelines
- [ ] Tests pass locally
- [ ] Documentation is updated
- [ ] Help text is complete and accurate
- [ ] CHANGELOG is updated (if applicable)
- [ ] Version number is updated (for releases)

## Adding New Features

### Public Functions
1. Create a new `.ps1` file in `Public/` directory
2. Include complete comment-based help
3. Follow naming conventions (Verb-Noun)
4. Add to `FunctionsToExport` in module manifest
5. Create corresponding tests
6. Update README with usage examples

### Private Functions
1. Create a new `.ps1` file in `Private/` directory
2. Include minimal help documentation
3. These are not exported to users
4. Test indirectly through public functions

## Versioning

We use [Semantic Versioning](https://semver.org/):
- MAJOR version for incompatible API changes
- MINOR version for new functionality (backwards compatible)
- PATCH version for bug fixes (backwards compatible)

## Code of Conduct

### Our Pledge
We are committed to providing a welcoming and inclusive experience for everyone.

### Expected Behavior
- Be respectful and considerate
- Welcome diverse perspectives
- Accept constructive criticism gracefully
- Focus on what's best for the community

### Unacceptable Behavior
- Harassment or discriminatory language
- Personal attacks or trolling
- Publishing others' private information
- Other conduct inappropriate in a professional setting

## Getting Help

- Open an issue for bugs or feature requests
- Start a discussion for questions or ideas
- Check existing issues before creating new ones

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).

## Questions?

Feel free to open an issue with questions or reach out to the maintainers.

Thank you for contributing! 🎉
