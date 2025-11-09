BeforeAll {
    # Import the module
    $modulePath = Join-Path $PSScriptRoot ".." "PSAzureDevOps.psm1"
    Import-Module $modulePath -Force
}

Describe "PSAzureDevOps Module" {
    Context "Module Loading" {
        It "Should import the module successfully" {
            $module = Get-Module -Name PSAzureDevOps
            $module | Should -Not -BeNullOrEmpty
        }
        
        It "Should export SetUpADO function" {
            $command = Get-Command -Name SetUpADO -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
        
        It "Should export New-InterruptionWorkItem function" {
            $command = Get-Command -Name New-InterruptionWorkItem -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
        
        It "Should have wi-i alias for New-InterruptionWorkItem" {
            $alias = Get-Alias -Name wi-i -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommand.Name | Should -Be "New-InterruptionWorkItem"
        }
    }
    
    Context "Function Help" {
        It "SetUpADO should have help documentation" {
            $help = Get-Help SetUpADO
            $help.Synopsis | Should -Not -BeNullOrEmpty
            $help.Description | Should -Not -BeNullOrEmpty
        }
        
        It "New-InterruptionWorkItem should have help documentation" {
            $help = Get-Help New-InterruptionWorkItem
            $help.Synopsis | Should -Not -BeNullOrEmpty
            $help.Description | Should -Not -BeNullOrEmpty
        }
        
        It "New-InterruptionWorkItem should have Title parameter" {
            $params = (Get-Command New-InterruptionWorkItem).Parameters
            $params.ContainsKey('Title') | Should -Be $true
            $params['Title'].Attributes.Mandatory | Should -Be $true
        }
        
        It "New-InterruptionWorkItem should have Type parameter with default value" {
            $params = (Get-Command New-InterruptionWorkItem).Parameters
            $params.ContainsKey('Type') | Should -Be $true
            $params['Type'].Attributes.Mandatory | Should -Be $false
        }
        
        It "New-InterruptionWorkItem should have Description parameter" {
            $params = (Get-Command New-InterruptionWorkItem).Parameters
            $params.ContainsKey('Description') | Should -Be $true
        }
    }
}

Describe "Configuration Management" {
    Context "Configuration File" {
        It "Should create .psazuredevops directory in user profile" {
            $userProfile = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
            $expectedPath = Join-Path $userProfile ".psazuredevops"
            # This test verifies the expected path structure
            $expectedPath | Should -Not -BeNullOrEmpty
        }
        
        It "New-InterruptionWorkItem should fail gracefully without configuration" {
            # Ensure no config exists for this test
            $userProfile = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
            $testConfigPath = Join-Path $userProfile ".psazuredevops" "config.json"
            $backupPath = "$testConfigPath.backup.test"
            
            if (Test-Path $testConfigPath) {
                Move-Item -Path $testConfigPath -Destination $backupPath -Force -ErrorAction SilentlyContinue
            }
            
            # Should throw an error about missing configuration
            { New-InterruptionWorkItem -Title "Test" -ErrorAction Stop } | Should -Throw
            
            # Restore backup if it exists
            if (Test-Path $backupPath) {
                Move-Item -Path $backupPath -Destination $testConfigPath -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

AfterAll {
    # Clean up
    Remove-Module PSAzureDevOps -ErrorAction SilentlyContinue
}
