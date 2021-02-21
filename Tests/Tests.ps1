BeforeDiscovery {
    Import-Module -Name .\PSGPPreferences.psd1
}

Describe 'Internal functions' {
    InModuleScope PSGPPreferences {
        Describe 'UNIT: Initialize-GPPSection' {

            $InitializeGPPSectionOutput = Initialize-GPPSection
            $TestCases = @(
                @{
                    InitializeGPPSectionOutput = $InitializeGPPSectionOutput
                }
            )
            It 'Ensures the result is an XML document' -TestCases $TestCases {
                $InitializeGPPSectionOutput -is [System.Xml.XmlDocument] | Should -Be $true
            }

            It 'Ensures the XML document is correct' -TestCases $TestCases {
                ($InitializeGPPSectionOutput).outerXml | Should -Be '<?xml version="1.0" encoding="utf-8"?>'
            }
        }

        Describe 'UNIT: Get-GPPSectionFilePath' {
            BeforeAll {
                Mock Get-CimInstance {[PSCustomObject]@{
                        Domain = 'test.example.com'
                    }
                }
            }

            BeforeDiscovery {
                $TestCases = @(
                    @{
                        GPOId = [guid]::new('70f86590-588a-4659-8880-3d2374604811')
                    }
                )
            }

            It 'Esures the function forms a correct path with string values as parameters' -TestCases $TestCases {
                Get-GPPSectionFilePath -GPOId $GPOId.Guid -Context 'Machine' -Type 'Groups' |
                Should -Be '\\test.example.com\SYSVOL\test.example.com\Policies\{70f86590-588a-4659-8880-3d2374604811}\Machine\Preferences\Groups\Groups.xml'
            }
            <# This does not work yet, don't know why
            It 'Esures the function forms a correct path with typed values' -TestCases $TestCases {
                Get-GPPSectionFilePath -GPOId $GPOId -Context [GPPContext]::Machine -Type [GPPType]::Groups |
                Should -Be '\\test.example.com\SYSVOL\test.example.com\Policies\{70f86590-588a-4659-8880-3d2374604811}\Machine\Preferences\Groups\Groups.xml'
            } #>
        }
    }
}