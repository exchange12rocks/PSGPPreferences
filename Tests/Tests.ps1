BeforeDiscovery {
    $ScriptDirectoryPath = $PSScriptRoot
    $ModuleRootPath = Join-Path -Path $ScriptDirectoryPath -ChildPath ..\
    Import-Module -Name (Join-Path -Path $ModuleRootPath -ChildPath 'PSGPPreferences.psd1')-Force
    . (Join-Path -Path $ModuleRootPath -ChildPath 'Definitions\Classes.ps1')
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
                Mock Get-CimInstance {
                    [PSCustomObject]@{
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

        Describe 'UNIT: Convert-GPONameToID' {
            # Impossible to test due to dependency on the System.DirectoryServices.DirectorySearcher class and we can't mock classes yet.
        }

        Describe "UNIT: Deserialize-GPPSection" {
            BeforeAll {
                $SourcePath = $PSScriptRoot
            }
            Context 'Groups-GroupsOnly-Set-1' {
                BeforeAll {
                    $FilePath = Join-Path -Path $SourcePath -ChildPath 'Groups-GroupsOnly-Set-1.xml'
                    [xml]$Data = Get-Content -Path $FilePath
                    $GPPSection = Deserialize-GPPSection -InputObject $Data
                    $Global:GS = $GPPSection
                }
                Context "GPP section properties" {
                     
                    It "GPP section exists" {
                        $GPPSection | Should -Not -BeNullOrEmpty
                    }
                    It "GPP section is of a correct type" {
                        $GPPSection | Should -BeOfType [GPPSectionGroups]
                    }
                    It "GPP section is enabled" {
                        $GPPSection.disable | Should -BeFalse
                    }
                    It "GPP section has a correct number of members" {
                        $GPPSection.Members | Should -HaveCount 8
                    }
                }

                Context "EXAMPLE\TestGroup1" {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '798C5D07-11C3-45C0-B767-124DF9A369A6' }
                    }

                    It "GPP item exists" {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It "GPP item is of a correct type" {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It "GPP item has a correct name" {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup1'
                    }
                    It "GPP item does not have removePolicy enabled" {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It "GPP item bypasses errors" {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It "GPP item is enabled" {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It "Group action is set to Update" {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It "Group action numeric value is set to Update" {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It "Group has a correct name" {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup1'
                    }
                    It "Group does not have an SID defined" {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It "Group is not to be renamed" {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It "Group does not have a description" {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It "Group has deleteAllUsers disabled" {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It "Group has deleteAllGroups disabled" {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It "Group does not have members" {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context "Administrators (built-in)" {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '6F82151C-1B8A-4809-ABDD-1EA08F91C923' }
                    }

                    It "GPP item exists" {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It "GPP item is of a correct type" {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It "GPP item has a correct name" {
                        $GPPItem.name | Should -BeExactly 'Administrators (built-in)'
                    }
                    It "GPP item does not have removePolicy enabled" {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It "GPP item bypasses errors" {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It "GPP item is enabled" {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It "Group action is set to Update" {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It "Group action numeric value is set to Update" {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It "Group has a correct name" {
                        $GPPItem.Properties.groupName | Should -BeExactly 'Administrators (built-in)'
                    }
                    It "Group has a correct SID" {
                        $GPPItem.Properties.groupSid | Should -BeExactly 'S-1-5-32-544'
                    }
                    It "Group is not to be renamed" {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It "Group does not have a description" {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It "Group has deleteAllUsers disabled" {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It "Group has deleteAllGroups disabled" {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It "Group does not have members" {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context "EXAMPLE\TestGroup3" {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '5BFED1D1-5C42-4504-84E7-E62FA36A6E69' }
                    }

                    It "GPP item exists" {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It "GPP item is of a correct type" {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It "GPP item has a correct name" {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup3'
                    }
                    It "GPP item does not have removePolicy enabled" {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It "GPP item bypasses errors" {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It "GPP item is enabled" {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It "Group action is set to Delete" {
                        $GPPItem.Properties.action | Should -BeExactly 'D'
                    }
                    It "Group action numeric value is set to Delete" {
                        $GPPItem.Properties.action.value__ | Should -Be 3
                    }
                    It "Group has a correct name" {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup3'
                    }
                    It "Group does not have an SID defined" {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It "Group is not to be renamed" {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It "Group does not have a description" {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It "Group has deleteAllUsers disabled" {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It "Group has deleteAllGroups disabled" {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It "Group does not have members" {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context "EXAMPLE\TestGroup4" {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'ED220833-3027-4071-80BE-0D0B50B781B3' }
                    }

                    It "GPP item exists" {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It "GPP item is of a correct type" {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It "GPP item has a correct name" {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup4'
                    }
                    It "GPP item does not have removePolicy enabled" {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It "GPP item bypasses errors" {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It "GPP item is enabled" {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It "Group action is set to Create" {
                        $GPPItem.Properties.action | Should -BeExactly 'C'
                    }
                    It "Group action numeric value is set to Create" {
                        $GPPItem.Properties.action.value__ | Should -Be 0
                    }
                    It "Group has a correct name" {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup4'
                    }
                    It "Group does not have an SID defined" {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It "Group is not to be renamed" {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It "Group does not have a description" {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It "Group has deleteAllUsers disabled" {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It "Group has deleteAllGroups disabled" {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It "Group does not have members" {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context "EXAMPLE\TestGroup5" {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '4046D23B-4875-4E82-96B3-9920E9A9BDFF' }
                    }

                    It "GPP item exists" {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It "GPP item is of a correct type" {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It "GPP item has a correct name" {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup5'
                    }
                    It "GPP item does not have removePolicy enabled" {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It "GPP item bypasses errors" {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It "GPP item is enabled" {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It "Group action is set to Replace" {
                        $GPPItem.Properties.action | Should -BeExactly 'R'
                    }
                    It "Group action numeric value is set to Replace" {
                        $GPPItem.Properties.action.value__ | Should -Be 1
                    }
                    It "Group has a correct name" {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup5'
                    }
                    It "Group does not have an SID defined" {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It "Group is not to be renamed" {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It "Group does not have a description" {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It "Group has deleteAllUsers disabled" {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It "Group has deleteAllGroups disabled" {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It "Group does not have members" {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context "LocalGroup1" {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '483E7907-F4DF-439C-946D-91D2FE3AFC20' }
                    }

                    It "GPP item exists" {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It "GPP item is of a correct type" {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It "GPP item has a correct name" {
                        $GPPItem.name | Should -BeExactly 'LocalGroup1'
                    }
                    It "GPP item does not have removePolicy enabled" {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It "GPP item bypasses errors" {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It "GPP item is enabled" {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It "Group action is set to Update" {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It "Group action numeric value is set to Update" {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It "Group has a correct name" {
                        $GPPItem.Properties.groupName | Should -BeExactly 'LocalGroup1'
                    }
                    It "Group does not have an SID defined" {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It "Group to be renamed correctly" {
                        $GPPItem.Properties.newName | Should -BeExactly 'LocalGroup2'
                    }
                    It "Group has a correct description" {
                        $GPPItem.Properties.description | Should -BeExactly 'My Awesome Description'
                    }
                    It "Group has deleteAllUsers disabled" {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It "Group has deleteAllGroups disabled" {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It "Group does not have members" {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context "LocalGroup3" {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '52D0DA5A-91FD-472B-83C4-E70EC7CD5ACB' }
                    }

                    It "GPP item exists" {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It "GPP item is of a correct type" {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It "GPP item has a correct name" {
                        $GPPItem.name | Should -BeExactly 'LocalGroup3'
                    }
                    It "GPP item does not have removePolicy enabled" {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It "GPP item bypasses errors" {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It "GPP item is disabled" {
                        $GPPItem.disabled | Should -BeTrue
                    }
                    It "Group action is set to Create" {
                        $GPPItem.Properties.action | Should -BeExactly 'C'
                    }
                    It "Group action numeric value is set to Create" {
                        $GPPItem.Properties.action.value__ | Should -Be 0
                    }
                    It "Group has a correct name" {
                        $GPPItem.Properties.groupName | Should -BeExactly 'LocalGroup3'
                    }
                    It "Group does not have an SID defined" {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It "Group is not to be renamed" {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It "Group does not have a description" {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It "Group has deleteAllUsers disabled" {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It "Group has deleteAllGroups disabled" {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It "Group has members" {
                        $GPPItem.Properties.Members | Should -Not -BeNullOrEmpty
                    }
                    It "Group has 4 members" {
                        $GPPItem.Properties.Members | Should -HaveCount 4
                    }

                    Context "EXAMPLE\Administrator" {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\Administrator' }
                        }

                        It "Member is of a correct type" {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It "Member's name has a correct case" {
                            $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                        }
                        It "Member has a correct action" {
                            $Member.action | Should -Be 'ADD'
                        }
                        It "The action is of a correct type" {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It "Member does not have an SID" {
                            $Member.sid | Should -BeNullOrEmpty
                        }
                    }

                    Context "EXAMPLE\TEST1" {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST1' }
                        }

                        It "Member is of a correct type" {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It "Member's name has a correct case" {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                        }
                        It "Member has a correct action" {
                            $Member.action | Should -Be 'ADD'
                        }
                        It "The action is of a correct type" {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It "Member has an SID" {
                            $Member.sid | Should -Not -BeNullOrEmpty
                        }
                        It "The SID is correct" {
                            $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                        }
                    }

                    Context "EXAMPLE\TEST2" {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST2' }
                        }

                        It "Member is of a correct type" {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It "Member's name has a correct case" {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                        }
                        It "Member has a correct action" {
                            $Member.action | Should -Be 'REMOVE'
                        }
                        It "The action is of a correct type" {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It "Member does not have an SID" {
                            $Member.sid | Should -BeNullOrEmpty
                        }

                        Context "EXAMPLE\TEST3" {
                            BeforeAll {
                                $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST3' }
                            }

                            It "Member is of a correct type" {
                                $Member | Should -BeOfType [GPPItemGroupMember]
                            }
                            It "Member's name has a correct case" {
                                $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                            }
                            It "Member has a correct action" {
                                $Member.action | Should -Be 'REMOVE'
                            }
                            It "The action is of a correct type" {
                                $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                            }
                            It "Member has an SID" {
                                $Member.sid | Should -Not -BeNullOrEmpty
                            }
                            It "The SID is correct" {
                                $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                            }
                        }
                    }
                }

                Context "Backup Operators (built-in)" {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '880FFE86-78C7-4E85-AFDE-608C24977161' }
                    }

                    It "GPP item exists" {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It "GPP item is of a correct type" {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It "GPP item has a correct name" {
                        $GPPItem.name | Should -BeExactly 'Backup Operators (built-in)'
                    }
                    It "GPP item does not have removePolicy enabled" {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It "GPP item bypasses errors" {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It "GPP item is enabled" {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It "Group action is set to Create" {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It "Group action numeric value is set to Create" {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It "Group has a correct name" {
                        $GPPItem.Properties.groupName | Should -BeExactly 'Backup Operators (built-in)'
                    }
                    It "Group has a correct SID" {
                        $GPPItem.Properties.groupSid | Should -BeExactly 'S-1-5-32-551'
                    }
                    It "Group is not to be renamed" {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It "Group does not have a description" {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It "Group has deleteAllUsers enabled" {
                        $GPPItem.Properties.deleteAllUsers | Should -BeTrue
                    }
                    It "Group has deleteAllGroups enabled" {
                        $GPPItem.Properties.deleteAllGroups | Should -BeTrue
                    }
                    It "Group has members" {
                        $GPPItem.Properties.Members | Should -Not -BeNullOrEmpty
                    }
                    It "Group has 4 members" {
                        $GPPItem.Properties.Members | Should -HaveCount 4
                    }

                    Context "EXAMPLE\Administrator" {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\Administrator' }
                        }

                        It "Member is of a correct type" {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It "Member's name has a correct case" {
                            $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                        }
                        It "Member has a correct action" {
                            $Member.action | Should -Be 'ADD'
                        }
                        It "The action is of a correct type" {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It "Member does not have an SID" {
                            $Member.sid | Should -BeNullOrEmpty
                        }
                    }

                    Context "EXAMPLE\TEST1" {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST1' }
                        }

                        It "Member is of a correct type" {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It "Member's name has a correct case" {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                        }
                        It "Member has a correct action" {
                            $Member.action | Should -Be 'ADD'
                        }
                        It "The action is of a correct type" {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It "Member has an SID" {
                            $Member.sid | Should -Not -BeNullOrEmpty
                        }
                        It "The SID is correct" {
                            $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                        }
                    }

                    Context "EXAMPLE\TEST2" {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST2' }
                        }

                        It "Member is of a correct type" {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It "Member's name has a correct case" {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                        }
                        It "Member has a correct action" {
                            $Member.action | Should -Be 'REMOVE'
                        }
                        It "The action is of a correct type" {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It "Member does not have an SID" {
                            $Member.sid | Should -BeNullOrEmpty
                        }

                        Context "EXAMPLE\TEST3" {
                            BeforeAll {
                                $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST3' }
                            }

                            It "Member is of a correct type" {
                                $Member | Should -BeOfType [GPPItemGroupMember]
                            }
                            It "Member's name has a correct case" {
                                $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                            }
                            It "Member has a correct action" {
                                $Member.action | Should -Be 'REMOVE'
                            }
                            It "The action is of a correct type" {
                                $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                            }
                            It "Member has an SID" {
                                $Member.sid | Should -Not -BeNullOrEmpty
                            }
                            It "The SID is correct" {
                                $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                            }
                        }
                    }
                }
            }
            Context 'Groups-GroupsOnly-Set-2' {
                BeforeAll {
                    $FilePath = Join-Path -Path $SourcePath -ChildPath 'Groups-GroupsOnly-Set-2.xml'
                    [xml]$Data = Get-Content -Path $FilePath
                    $GPPSection = Deserialize-GPPSection -InputObject $Data
                    $Global:GS = $GPPSection
                }
                Context "GPP section properties" {
                     
                    It "GPP section exists" {
                        $GPPSection | Should -Not -BeNullOrEmpty
                    }
                    It "GPP section is of a correct type" {
                        $GPPSection | Should -BeOfType [GPPSectionGroups]
                    }
                    It "GPP section is disabled" {
                        $GPPSection.disable | Should -BeTrue
                    }
                    It "GPP section has a correct number of members" {
                        $GPPSection.Members | Should -HaveCount 8
                    }
                }

                Context "EXAMPLE\TestGroup1" {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '798C5D07-11C3-45C0-B767-124DF9A369A6' }
                    }

                    It "GPP item exists" {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It "GPP item is of a correct type" {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It "GPP item has a correct name" {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup1'
                    }
                    It "GPP item does not have removePolicy enabled" {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It "GPP item bypasses errors" {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It "GPP item is enabled" {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It "Group action is set to Update" {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It "Group action numeric value is set to Update" {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It "Group has a correct name" {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup1'
                    }
                    It "Group does not have an SID defined" {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It "Group is not to be renamed" {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It "Group does not have a description" {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It "Group has deleteAllUsers disabled" {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It "Group has deleteAllGroups disabled" {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It "Group does not have members" {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context "Administrators (built-in)" {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '6F82151C-1B8A-4809-ABDD-1EA08F91C923' }
                    }

                    It "GPP item exists" {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It "GPP item is of a correct type" {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It "GPP item has a correct name" {
                        $GPPItem.name | Should -BeExactly 'Administrators (built-in)'
                    }
                    It "GPP item does not have removePolicy enabled" {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It "GPP item bypasses errors" {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It "GPP item is enabled" {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It "Group action is set to Update" {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It "Group action numeric value is set to Update" {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It "Group has a correct name" {
                        $GPPItem.Properties.groupName | Should -BeExactly 'Administrators (built-in)'
                    }
                    It "Group has a correct SID" {
                        $GPPItem.Properties.groupSid | Should -BeExactly 'S-1-5-32-544'
                    }
                    It "Group is not to be renamed" {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It "Group does not have a description" {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It "Group has deleteAllUsers disabled" {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It "Group has deleteAllGroups disabled" {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It "Group does not have members" {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context "EXAMPLE\TestGroup3" {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '5BFED1D1-5C42-4504-84E7-E62FA36A6E69' }
                    }

                    It "GPP item exists" {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It "GPP item is of a correct type" {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It "GPP item has a correct name" {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup3'
                    }
                    It "GPP item does not have removePolicy enabled" {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It "GPP item bypasses errors" {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It "GPP item is enabled" {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It "Group action is set to Delete" {
                        $GPPItem.Properties.action | Should -BeExactly 'D'
                    }
                    It "Group action numeric value is set to Delete" {
                        $GPPItem.Properties.action.value__ | Should -Be 3
                    }
                    It "Group has a correct name" {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup3'
                    }
                    It "Group does not have an SID defined" {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It "Group is not to be renamed" {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It "Group does not have a description" {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It "Group has deleteAllUsers disabled" {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It "Group has deleteAllGroups disabled" {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It "Group does not have members" {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context "EXAMPLE\TestGroup4" {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'ED220833-3027-4071-80BE-0D0B50B781B3' }
                    }

                    It "GPP item exists" {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It "GPP item is of a correct type" {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It "GPP item has a correct name" {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup4'
                    }
                    It "GPP item does not have removePolicy enabled" {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It "GPP item bypasses errors" {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It "GPP item is enabled" {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It "Group action is set to Create" {
                        $GPPItem.Properties.action | Should -BeExactly 'C'
                    }
                    It "Group action numeric value is set to Create" {
                        $GPPItem.Properties.action.value__ | Should -Be 0
                    }
                    It "Group has a correct name" {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup4'
                    }
                    It "Group does not have an SID defined" {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It "Group is not to be renamed" {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It "Group does not have a description" {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It "Group has deleteAllUsers disabled" {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It "Group has deleteAllGroups disabled" {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It "Group does not have members" {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context "EXAMPLE\TestGroup5" {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '4046D23B-4875-4E82-96B3-9920E9A9BDFF' }
                    }

                    It "GPP item exists" {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It "GPP item is of a correct type" {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It "GPP item has a correct name" {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup5'
                    }
                    It "GPP item does not have removePolicy enabled" {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It "GPP item bypasses errors" {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It "GPP item is enabled" {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It "Group action is set to Replace" {
                        $GPPItem.Properties.action | Should -BeExactly 'R'
                    }
                    It "Group action numeric value is set to Replace" {
                        $GPPItem.Properties.action.value__ | Should -Be 1
                    }
                    It "Group has a correct name" {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup5'
                    }
                    It "Group does not have an SID defined" {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It "Group is not to be renamed" {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It "Group does not have a description" {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It "Group has deleteAllUsers disabled" {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It "Group has deleteAllGroups disabled" {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It "Group does not have members" {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context "LocalGroup1" {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '483E7907-F4DF-439C-946D-91D2FE3AFC20' }
                    }

                    It "GPP item exists" {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It "GPP item is of a correct type" {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It "GPP item has a correct name" {
                        $GPPItem.name | Should -BeExactly 'LocalGroup1'
                    }
                    It "GPP item does not have removePolicy enabled" {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It "GPP item bypasses errors" {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It "GPP item is enabled" {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It "Group action is set to Update" {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It "Group action numeric value is set to Update" {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It "Group has a correct name" {
                        $GPPItem.Properties.groupName | Should -BeExactly 'LocalGroup1'
                    }
                    It "Group does not have an SID defined" {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It "Group to be renamed correctly" {
                        $GPPItem.Properties.newName | Should -BeExactly 'LocalGroup2'
                    }
                    It "Group has a correct description" {
                        $GPPItem.Properties.description | Should -BeExactly 'My Awesome Description'
                    }
                    It "Group has deleteAllUsers disabled" {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It "Group has deleteAllGroups disabled" {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It "Group does not have members" {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context "LocalGroup3" {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '52D0DA5A-91FD-472B-83C4-E70EC7CD5ACB' }
                    }

                    It "GPP item exists" {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It "GPP item is of a correct type" {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It "GPP item has a correct name" {
                        $GPPItem.name | Should -BeExactly 'LocalGroup3'
                    }
                    It "GPP item does not have removePolicy enabled" {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It "GPP item bypasses errors" {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It "GPP item is disabled" {
                        $GPPItem.disabled | Should -BeTrue
                    }
                    It "Group action is set to Create" {
                        $GPPItem.Properties.action | Should -BeExactly 'C'
                    }
                    It "Group action numeric value is set to Create" {
                        $GPPItem.Properties.action.value__ | Should -Be 0
                    }
                    It "Group has a correct name" {
                        $GPPItem.Properties.groupName | Should -BeExactly 'LocalGroup3'
                    }
                    It "Group does not have an SID defined" {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It "Group is not to be renamed" {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It "Group does not have a description" {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It "Group has deleteAllUsers disabled" {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It "Group has deleteAllGroups disabled" {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It "Group has members" {
                        $GPPItem.Properties.Members | Should -Not -BeNullOrEmpty
                    }
                    It "Group has 4 members" {
                        $GPPItem.Properties.Members | Should -HaveCount 4
                    }

                    Context "EXAMPLE\Administrator" {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\Administrator' }
                        }

                        It "Member is of a correct type" {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It "Member's name has a correct case" {
                            $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                        }
                        It "Member has a correct action" {
                            $Member.action | Should -Be 'ADD'
                        }
                        It "The action is of a correct type" {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It "Member does not have an SID" {
                            $Member.sid | Should -BeNullOrEmpty
                        }
                    }

                    Context "EXAMPLE\TEST1" {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST1' }
                        }

                        It "Member is of a correct type" {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It "Member's name has a correct case" {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                        }
                        It "Member has a correct action" {
                            $Member.action | Should -Be 'ADD'
                        }
                        It "The action is of a correct type" {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It "Member has an SID" {
                            $Member.sid | Should -Not -BeNullOrEmpty
                        }
                        It "The SID is correct" {
                            $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                        }
                    }

                    Context "EXAMPLE\TEST2" {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST2' }
                        }

                        It "Member is of a correct type" {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It "Member's name has a correct case" {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                        }
                        It "Member has a correct action" {
                            $Member.action | Should -Be 'REMOVE'
                        }
                        It "The action is of a correct type" {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It "Member does not have an SID" {
                            $Member.sid | Should -BeNullOrEmpty
                        }

                        Context "EXAMPLE\TEST3" {
                            BeforeAll {
                                $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST3' }
                            }

                            It "Member is of a correct type" {
                                $Member | Should -BeOfType [GPPItemGroupMember]
                            }
                            It "Member's name has a correct case" {
                                $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                            }
                            It "Member has a correct action" {
                                $Member.action | Should -Be 'REMOVE'
                            }
                            It "The action is of a correct type" {
                                $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                            }
                            It "Member has an SID" {
                                $Member.sid | Should -Not -BeNullOrEmpty
                            }
                            It "The SID is correct" {
                                $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                            }
                        }
                    }
                }

                Context "Backup Operators (built-in)" {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '880FFE86-78C7-4E85-AFDE-608C24977161' }
                    }

                    It "GPP item exists" {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It "GPP item is of a correct type" {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It "GPP item has a correct name" {
                        $GPPItem.name | Should -BeExactly 'Backup Operators (built-in)'
                    }
                    It "GPP item does not have removePolicy enabled" {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It "GPP item bypasses errors" {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It "GPP item is enabled" {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It "Group action is set to Create" {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It "Group action numeric value is set to Create" {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It "Group has a correct name" {
                        $GPPItem.Properties.groupName | Should -BeExactly 'Backup Operators (built-in)'
                    }
                    It "Group has a correct SID" {
                        $GPPItem.Properties.groupSid | Should -BeExactly 'S-1-5-32-551'
                    }
                    It "Group is not to be renamed" {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It "Group does not have a description" {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It "Group has deleteAllUsers enabled" {
                        $GPPItem.Properties.deleteAllUsers | Should -BeTrue
                    }
                    It "Group has deleteAllGroups enabled" {
                        $GPPItem.Properties.deleteAllGroups | Should -BeTrue
                    }
                    It "Group has members" {
                        $GPPItem.Properties.Members | Should -Not -BeNullOrEmpty
                    }
                    It "Group has 4 members" {
                        $GPPItem.Properties.Members | Should -HaveCount 4
                    }

                    Context "EXAMPLE\Administrator" {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\Administrator' }
                        }

                        It "Member is of a correct type" {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It "Member's name has a correct case" {
                            $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                        }
                        It "Member has a correct action" {
                            $Member.action | Should -Be 'ADD'
                        }
                        It "The action is of a correct type" {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It "Member does not have an SID" {
                            $Member.sid | Should -BeNullOrEmpty
                        }
                    }

                    Context "EXAMPLE\TEST1" {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST1' }
                        }

                        It "Member is of a correct type" {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It "Member's name has a correct case" {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                        }
                        It "Member has a correct action" {
                            $Member.action | Should -Be 'ADD'
                        }
                        It "The action is of a correct type" {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It "Member has an SID" {
                            $Member.sid | Should -Not -BeNullOrEmpty
                        }
                        It "The SID is correct" {
                            $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                        }
                    }

                    Context "EXAMPLE\TEST2" {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST2' }
                        }

                        It "Member is of a correct type" {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It "Member's name has a correct case" {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                        }
                        It "Member has a correct action" {
                            $Member.action | Should -Be 'REMOVE'
                        }
                        It "The action is of a correct type" {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It "Member does not have an SID" {
                            $Member.sid | Should -BeNullOrEmpty
                        }

                        Context "EXAMPLE\TEST3" {
                            BeforeAll {
                                $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST3' }
                            }

                            It "Member is of a correct type" {
                                $Member | Should -BeOfType [GPPItemGroupMember]
                            }
                            It "Member's name has a correct case" {
                                $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                            }
                            It "Member has a correct action" {
                                $Member.action | Should -Be 'REMOVE'
                            }
                            It "The action is of a correct type" {
                                $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                            }
                            It "Member has an SID" {
                                $Member.sid | Should -Not -BeNullOrEmpty
                            }
                            It "The SID is correct" {
                                $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                            }
                        }
                    }
                }
            }
        }

        Describe 'TODO: UNIT: Get-GPPSection' {
            BeforeAll {
                $SourcePath = $PSScriptRoot
                Mock Convert-GPONameToID {
                    [guid]::new('f0a0c308-2fb0-433b-8a00-cc48b9ad1eba')
                }
                Mock Get-GPPSectionFilePath {
                    $DataFileName = 'Groups-GroupsOnly-Set-1.xml'
                    Join-Path -Path $SourcePath -ChildPath $DataFileName
                } -ParameterFilter { $Type -eq 'Groups' -and $GPOId -eq 'f0a0c308-2fb0-433b-8a00-cc48b9ad1eba' }
                Mock Get-GPPSectionFilePath {
                    $DataFileName = 'Groups-GroupsOnly-Set-2.xml'
                    Join-Path -Path $SourcePath -ChildPath $DataFileName
                } -ParameterFilter { $Type -eq 'Groups' -and $GPOId -eq '4c6924d8-020a-4362-8a42-5977fcb3a06e' }

                $GroupsSection = Get-GPPSection -GPOId 'f0a0c308-2fb0-433b-8a00-cc48b9ad1eba' -Context 'Machine' -Type 'Groups'
            }
        }
    }
}