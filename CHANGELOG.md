# Changelog

All notable changes to the PSAzureDevOps module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-06

### Added
- Initial release of PSAzureDevOps module
- `SetUpADO` function to configure Azure DevOps connection and store credentials locally
- `New-InterruptionWorkItem` function (alias `wi-i`) to create work items tagged as interruptions
- Secure credential storage in `~/.psazuredevops/config.json`
- Cross-platform support (Windows, Linux, macOS)
- Comprehensive Pester tests (11 tests covering all functionality)
- Full documentation with examples and help text
- Installation script (`Install-Module.ps1`) for easy setup
- GitHub Actions workflow for automated testing
- Demo script to showcase module functionality

### Features
- Prompts for and stores Azure DevOps organization URL, project name, and PAT
- Automatically configures Azure DevOps CLI defaults
- Creates work items with preset attributes (assigned to user, tagged as "Interruption")
- Secure PAT storage using PowerShell SecureString
- Cross-platform configuration directory handling

### Documentation
- Comprehensive README with usage examples
- Comment-based help for all public functions
- Module README in the PSAzureDevOps directory
- CONTRIBUTING guide for developers
- Demo script with usage examples

### Testing
- 11 Pester tests covering:
  - Module loading and function availability
  - Command aliases
  - Help documentation
  - Parameter validation
  - Configuration management
  - Error handling

## [Unreleased]

### Planned Features
- Additional work item creation shortcuts
- Bulk work item operations
- Query functionality for work items
- Integration with Azure DevOps boards
- Additional tagging options
- Custom work item templates
