BeforeDiscovery {
    $ScriptDirectoryPath = $PSScriptRoot
    $ModuleRootPath = Join-Path -Path $ScriptDirectoryPath -ChildPath ..\src\
    Import-Module -Name (Join-Path -Path $ModuleRootPath -ChildPath 'PSGPPreferences.psd1') -Force
    . (Join-Path -Path $ModuleRootPath -ChildPath 'Definitions\Classes.ps1')
}

Describe 'Internal functions' {
    InModuleScope PSGPPreferences {
        Describe 'UNIT: Get-GPPSectionFilePath' {
            BeforeAll {
                Mock Get-CimInstance {
                    [PSCustomObject]@{
                        Domain = 'test.example.com'
                    }
                }

                $GPOId = [guid]::new('70f86590-588a-4659-8880-3d2374604811')
            }

            It 'Esures the function forms a correct path with string values as parameters' {
                Get-GPPSectionFilePath -GPOId $GPOId.Guid -Context 'Machine' -Type 'Groups' |
                Should -Be '\\test.example.com\SYSVOL\test.example.com\Policies\{70f86590-588a-4659-8880-3d2374604811}\Machine\Preferences\Groups\Groups.xml'
            }

            It 'Esures the function forms a correct path with typed values' {
                Get-GPPSectionFilePath -GPOId $GPOId -Context ([GPPContext]::Machine) -Type ([GPPType]::Groups) |
                Should -Be '\\test.example.com\SYSVOL\test.example.com\Policies\{70f86590-588a-4659-8880-3d2374604811}\Machine\Preferences\Groups\Groups.xml'
            }
        }
    }
}