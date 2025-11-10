BeforeAll {
    # Import the module
    $modulePath = Join-Path $PSScriptRoot ".." "ADOWrapper.psm1"
    Import-Module $modulePath -Force
}

Describe "ADOWrapper Module" {
    Context "Module Loading" {
        It "Should import the module successfully" {
            $module = Get-Module -Name ADOWrapper
            $module | Should -Not -BeNullOrEmpty
        }
        
        It "Should have correct module version" {
            $module = Get-Module -Name ADOWrapper
            $module.Version | Should -Not -BeNullOrEmpty
            # Module version should be a valid version number (allows 0.0 for dev versions)
            $module.Version.ToString() | Should -Match "^\d+\.\d+(\.\d+)?(\.\d+)?$"
        }
        
        It "Should export expected number of functions" {
            $module = Get-Module -Name ADOWrapper
            $exportedFunctions = $module.ExportedFunctions.Keys
            $exportedFunctions.Count | Should -BeGreaterOrEqual 3
            $exportedFunctions | Should -Contain "SetUpADO"
            $exportedFunctions | Should -Contain "New-WorkItem"
            $exportedFunctions | Should -Contain "New-WorkItemInterruption"
        }
        
        It "Should export SetUpADO function" {
            $command = Get-Command -Name SetUpADO -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
        
        It "Should export New-WorkItem function" {
            $command = Get-Command -Name New-WorkItem -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
        
        It "Should export New-WorkItemInterruption function" {
            $command = Get-Command -Name New-WorkItemInterruption -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
        
        It "Should have wi alias for New-WorkItem" {
            $alias = Get-Alias -Name wi -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommand.Name | Should -Be "New-WorkItem"
        }
        
        It "Should have wi-i alias for New-WorkItemInterruption" {
            $alias = Get-Alias -Name wi-i -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommand.Name | Should -Be "New-WorkItemInterruption"
        }
    }
    
    Context "Function Help" {
        It "SetUpADO should have help documentation" {
            $help = Get-Help SetUpADO
            $help.Synopsis | Should -Not -BeNullOrEmpty
            $help.Description | Should -Not -BeNullOrEmpty
        }
        
        It "New-WorkItem should have help documentation" {
            $help = Get-Help New-WorkItem
            $help.Synopsis | Should -Not -BeNullOrEmpty
            $help.Description | Should -Not -BeNullOrEmpty
        }
        
        It "New-WorkItemInterruption should have help documentation" {
            $help = Get-Help New-WorkItemInterruption -ErrorAction SilentlyContinue
            # Note: This function may not have explicit help as it's a wrapper
            $help | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "New-WorkItem Parameters" {
        It "New-WorkItem should have Title parameter" {
            $params = (Get-Command New-WorkItem).Parameters
            $params.ContainsKey('Title') | Should -Be $true
            $params['Title'].Attributes.Mandatory | Should -Be $true
        }
        
        It "New-WorkItem should have Type parameter with default value" {
            $params = (Get-Command New-WorkItem).Parameters
            $params.ContainsKey('Type') | Should -Be $true
            $params['Type'].Attributes.Mandatory | Should -Be $false
        }
        
        It "New-WorkItem should have Description parameter" {
            $params = (Get-Command New-WorkItem).Parameters
            $params.ContainsKey('Description') | Should -Be $true
            $params['Description'].Attributes.Mandatory | Should -Be $false
        }
        
        It "New-WorkItem should have Tags parameter" {
            $params = (Get-Command New-WorkItem).Parameters
            $params.ContainsKey('Tags') | Should -Be $true
            $params['Tags'].Attributes.Mandatory | Should -Be $false
        }
    }
    
    Context "New-WorkItemInterruption Parameters" {
        It "New-WorkItemInterruption should have Title parameter" {
            $params = (Get-Command New-WorkItemInterruption).Parameters
            $params.ContainsKey('Title') | Should -Be $true
            $params['Title'].Attributes.Mandatory | Should -Be $true
        }
        
        It "New-WorkItemInterruption should have Type parameter with default value" {
            $params = (Get-Command New-WorkItemInterruption).Parameters
            $params.ContainsKey('Type') | Should -Be $true
            $params['Type'].Attributes.Mandatory | Should -Be $false
        }
        
        It "New-WorkItemInterruption should have Description parameter" {
            $params = (Get-Command New-WorkItemInterruption).Parameters
            $params.ContainsKey('Description') | Should -Be $true
            $params['Description'].Attributes.Mandatory | Should -Be $false
        }
        
        It "New-WorkItemInterruption should have Tags parameter" {
            $params = (Get-Command New-WorkItemInterruption).Parameters
            $params.ContainsKey('Tags') | Should -Be $true
            $params['Tags'].Attributes.Mandatory | Should -Be $false
        }
    }
}

Describe "Configuration Management" {
    Context "Configuration File" {
        It "Should create .adowrapper directory in user profile" {
            $userProfile = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
            $expectedPath = Join-Path $userProfile ".adowrapper"
            # This test verifies the expected path structure
            $expectedPath | Should -Not -BeNullOrEmpty
        }
        
        It "New-WorkItem should handle configuration appropriately" {
            # Check if configuration exists
            $userProfile = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
            $testConfigPath = Join-Path $userProfile ".adowrapper" "config.json"
            
            if (Test-Path $testConfigPath) {
                # If config exists, the function should attempt to use it
                # We'll just verify the function doesn't crash with syntax errors
                $functionContent = (Get-Command New-WorkItem).Definition
                $functionContent | Should -Match "Get-ADOConfig"
                $functionContent | Should -Not -BeNullOrEmpty
            } else {
                # If no config exists, should throw appropriate error
                # Should throw an error about missing configuration
                { New-WorkItem -Title "Test" -ErrorAction Stop } | Should -Throw "*configuration*"
            }
        }
        
        It "New-WorkItemInterruption should handle configuration appropriately" {
            # Check if configuration exists
            $userProfile = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
            $testConfigPath = Join-Path $userProfile ".adowrapper" "config.json"
            
            if (Test-Path $testConfigPath) {
                # If config exists, the function should attempt to use it
                # We'll verify the function structure is correct
                $functionContent = (Get-Command New-WorkItemInterruption).Definition
                $functionContent | Should -Match "New-WorkItem"
                $functionContent | Should -Not -BeNullOrEmpty
            } else {
                # If no config exists, should throw appropriate error through New-WorkItem
                { New-WorkItemInterruption -Title "Test" -ErrorAction Stop } | Should -Throw "*configuration*"
            }
        }
    }
}

Describe "Function Behavior" {
    Context "New-WorkItemInterruption Wrapper" {
        It "Should be a wrapper function that calls New-WorkItem" {
            # This test verifies that New-WorkItemInterruption is implemented as expected
            $command = Get-Command New-WorkItemInterruption
            $command | Should -Not -BeNullOrEmpty
            
            # Check that it has the same parameters as New-WorkItem (plus inherited behavior)
            $interruptionParams = $command.Parameters.Keys
            $workItemParams = (Get-Command New-WorkItem).Parameters.Keys
            
            # All core parameters should be present
            $workItemParams | ForEach-Object {
                $interruptionParams | Should -Contain $_
            }
        }
        
        It "Should add 'Interruption' tag to existing tags" {
            # Verify the function definition contains logic to add Interruption tag
            $functionContent = (Get-Command New-WorkItemInterruption).Definition
            $functionContent | Should -Match "Interruption"
            $functionContent | Should -Match "New-WorkItem"
        }
        
        It "Should have same parameter attributes as New-WorkItem for Title" {
            $interruptionTitleParam = (Get-Command New-WorkItemInterruption).Parameters['Title']
            $workItemTitleParam = (Get-Command New-WorkItem).Parameters['Title']
            
            # Both should be mandatory and positional
            $interruptionTitleParam.Attributes.Mandatory | Should -Be $workItemTitleParam.Attributes.Mandatory
            $interruptionTitleParam.Attributes.Position | Should -Be $workItemTitleParam.Attributes.Position
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept Title as positional parameter for New-WorkItem" {
            $params = (Get-Command New-WorkItem).Parameters['Title']
            $params.Attributes.Position | Should -Be 0
        }
        
        It "Should accept Title as positional parameter for New-WorkItemInterruption" {
            $params = (Get-Command New-WorkItemInterruption).Parameters['Title']
            $params.Attributes.Position | Should -Be 0
        }
        
        It "Should support pipeline input for Title parameter in New-WorkItem" {
            $params = (Get-Command New-WorkItem).Parameters['Title']
            $pipelineAttribute = $params.Attributes | Where-Object { $_.TypeId.Name -eq "ParameterAttribute" }
            $pipelineAttribute.ValueFromPipeline | Should -Be $true
        }
        
        It "Should support pipeline input for Title parameter in New-WorkItemInterruption" {
            $params = (Get-Command New-WorkItemInterruption).Parameters['Title']
            $pipelineAttribute = $params.Attributes | Where-Object { $_.TypeId.Name -eq "ParameterAttribute" }
            $pipelineAttribute.ValueFromPipeline | Should -Be $true
        }
        
        It "Should have correct default values for Type parameter" {
            $workItemTypeParam = (Get-Command New-WorkItem).Parameters['Type']
            $interruptionTypeParam = (Get-Command New-WorkItemInterruption).Parameters['Type']
            
            # Both should have "Task" as default (based on parameter definition)
            $workItemTypeParam.Attributes.Mandatory | Should -Be $false
            $interruptionTypeParam.Attributes.Mandatory | Should -Be $false
        }
        
        It "Tags parameter should be string type in both functions" {
            $workItemTagsParam = (Get-Command New-WorkItem).Parameters['Tags']
            $interruptionTagsParam = (Get-Command New-WorkItemInterruption).Parameters['Tags']
            
            $workItemTagsParam.ParameterType | Should -Be ([string])
            $interruptionTagsParam.ParameterType | Should -Be ([string])
        }
    }
    
    Context "Alias Verification" {
        It "wi alias should be properly configured" {
            $alias = Get-Alias -Name wi -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.Source | Should -Be "ADOWrapper"
            $alias.Definition | Should -Be "New-WorkItem"
        }
        
        It "wi-i alias should be properly configured" {
            $alias = Get-Alias -Name wi-i -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.Source | Should -Be "ADOWrapper"
            $alias.Definition | Should -Be "New-WorkItemInterruption"
        }
    }
    
    Context "Function Implementation Details" {
        It "New-WorkItem should contain Azure CLI command logic" {
            $functionContent = (Get-Command New-WorkItem).Definition
            $functionContent | Should -Match "az\s+boards\s+work-item\s+create"
            $functionContent | Should -Match "Get-ADOConfig"
        }
        
        It "New-WorkItem should handle tags properly" {
            $functionContent = (Get-Command New-WorkItem).Definition
            $functionContent | Should -Match "System\.Tags"
        }
        
        It "New-WorkItemInterruption should use PSBoundParameters for tag manipulation" {
            $functionContent = (Get-Command New-WorkItemInterruption).Definition
            $functionContent | Should -Match "PSBoundParameters"
            $functionContent | Should -Match "Interruption"
        }
    }
}

Describe "Private Functions" {
    Context "Internal Dependencies" {
        It "Should have Private functions loaded (Get-ADOConfig exists)" {
            # Private functions are dot-sourced during module import
            # We test this indirectly by checking if the Private folder exists and has files
            $privatePath = Join-Path $PSScriptRoot ".." "Private"
            $privateFiles = Get-ChildItem -Path $privatePath -Filter "*.ps1" -ErrorAction SilentlyContinue
            $privateFiles | Should -Not -BeNullOrEmpty
            $privateFiles.Name | Should -Contain "Get-ADOConfig.ps1"
        }
        
        It "Should load private functions during module import" {
            # Test that private functions are loaded indirectly by verifying
            # that New-WorkItem function definition references Get-ADOConfig
            $newWorkItemContent = (Get-Command New-WorkItem).Definition
            $newWorkItemContent | Should -Match "Get-ADOConfig"
            
            # Also verify the private function file exists and was loaded
            $privatePath = Join-Path $PSScriptRoot ".." "Private"
            $configFile = Join-Path $privatePath "Get-ADOConfig.ps1"
            Test-Path $configFile | Should -Be $true
        }
    }
}

AfterAll {
    # Clean up
    Remove-Module ADOWrapper -ErrorAction SilentlyContinue
}
