BeforeAll {
    # Import the module
    $ModulePath = Join-Path $PSScriptRoot '..' 'PSAzureDevOps' 'PSAzureDevOps.psd1'
    Import-Module $ModulePath -Force
}

Describe 'PSAzureDevOps Module' {
    Context 'Module Import' {
        It 'Should import the module successfully' {
            $module = Get-Module -Name PSAzureDevOps
            $module | Should -Not -BeNullOrEmpty
        }
        
        It 'Should export Get-AzDoVersion function' {
            $command = Get-Command -Name Get-AzDoVersion -Module PSAzureDevOps -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
        
        It 'Should export Test-AzDoConnection function' {
            $command = Get-Command -Name Test-AzDoConnection -Module PSAzureDevOps -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
    }
    
    Context 'Get-AzDoVersion' {
        It 'Should be defined' {
            { Get-Command Get-AzDoVersion -ErrorAction Stop } | Should -Not -Throw
        }
    }
    
    Context 'Test-AzDoConnection' {
        It 'Should be defined' {
            { Get-Command Test-AzDoConnection -ErrorAction Stop } | Should -Not -Throw
        }
    }
}

AfterAll {
    Remove-Module -Name PSAzureDevOps -Force -ErrorAction SilentlyContinue
}
