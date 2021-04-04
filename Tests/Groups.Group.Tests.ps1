BeforeDiscovery {
    $ScriptDirectoryPath = $PSScriptRoot
    $DataSourcePath = Join-Path -Path $ScriptDirectoryPath -ChildPath 'Data\Groups'
    $Set1Path = Join-Path -Path $DataSourcePath -ChildPath 'Groups-GroupsOnly-Set-1.xml'
    [xml]$Set1Data = Get-Content -Path $Set1Path
    $Set2Path = Join-Path -Path $DataSourcePath -ChildPath 'Groups-GroupsOnly-Set-2.xml'
    [xml]$Set2Data = Get-Content -Path $Set2Path
    $ModuleRootPath = Join-Path -Path $ScriptDirectoryPath -ChildPath ..\
    Import-Module -Name (Join-Path -Path $ModuleRootPath -ChildPath 'PSGPPreferences.psd1') -Force
    . (Join-Path -Path $ModuleRootPath -ChildPath 'src\Definitions\Classes.ps1')
}

Describe 'Internal functions' {
    InModuleScope PSGPPreferences {
        BeforeAll {
            $GPPSectionSet1 = Deserialize-GPPSection -InputObject $Set1Data
            $GPPSectionSet2 = Deserialize-GPPSection -InputObject $Set2Data
        }

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

        Describe 'ACCEPTANCE: Get-GPPSection' -ForEach @(
            @{
                Mode     = 'ByGPOId'
                GPOId    = 'f0a0c308-2fb0-433b-8a00-cc48b9ad1eba'
                GPOName  = 'Groups-GroupsOnly-Set-1'
                Disabled = $false
            }
            @{
                Mode     = 'ByGPOId'
                GPOId    = '4c6924d8-020a-4362-8a42-5977fcb3a06e'
                GPOName  = 'Groups-GroupsOnly-Set-2'
                Disabled = $true
            }
            @{
                Mode     = 'ByGPOName'
                GPOName  = 'Groups-GroupsOnly-Set-1'
                Disabled = $false
            }
            @{
                Mode     = 'ByGPOName'
                GPOName  = 'Groups-GroupsOnly-Set-2'
                Disabled = $true
            }
        ) {
            BeforeAll {
                Mock Get-GPPSectionFilePath {
                    $Set1Path
                } -ParameterFilter { $Type -eq 'Groups' -and $GPOId -eq 'f0a0c308-2fb0-433b-8a00-cc48b9ad1eba' }
                Mock Get-GPPSectionFilePath {
                    $Set2Path
                } -ParameterFilter { $Type -eq 'Groups' -and $GPOId -eq '4c6924d8-020a-4362-8a42-5977fcb3a06e' }

                Mock Convert-GPONameToID {
                    [guid]'f0a0c308-2fb0-433b-8a00-cc48b9ad1eba'
                } -ParameterFilter { $Type -eq 'Groups' -and $GPOName -eq 'Groups-GroupsOnly-Set-1' }
                Mock Convert-GPONameToID {
                    [guid]'4c6924d8-020a-4362-8a42-5977fcb3a06e'
                } -ParameterFilter { $Type -eq 'Groups' -and $GPOName -eq 'Groups-GroupsOnly-Set-2' }
            }

            Context '<GPOName>.<Mode>' {
                BeforeAll {
                    if ($GPOId) {
                        $GetGPPSectionParameters = @{
                            GPOId = $GPOId
                        }
                    }
                    else {
                        $GetGPPSectionParameters = @{
                            GPOName = $GPOName
                        }
                    }
                    $GPPSection = Get-GPPSection -Context 'Machine' -Type 'Groups' @GetGPPSectionParameters
                }

                Context 'GPP section properties' {
                    It 'GPP section exists' {
                        $GPPSection | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP section is of a correct type' {
                        $GPPSection | Should -BeOfType [GPPSectionGroups]
                    }
                    It 'GPP section is in a correct state' {
                        $GPPSection.disabled | Should -Be $Disabled
                    }
                    It 'GPP section has a correct number of members' {
                        $GPPSection.Members | Should -HaveCount 8
                    }
                }

                Context 'EXAMPLE\TestGroup1' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '798C5D07-11C3-45C0-B767-124DF9A369A6' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup1'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'Group action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup1'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'Administrators (built-in)' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '6F82151C-1B8A-4809-ABDD-1EA08F91C923' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Administrators (built-in)'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'Group action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'Administrators (built-in)'
                    }
                    It 'Group has a correct SID' {
                        $GPPItem.Properties.groupSid | Should -BeExactly 'S-1-5-32-544'
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'EXAMPLE\TestGroup3' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '5BFED1D1-5C42-4504-84E7-E62FA36A6E69' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup3'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Delete' {
                        $GPPItem.Properties.action | Should -BeExactly 'D'
                    }
                    It 'Group action numeric value is set to Delete' {
                        $GPPItem.Properties.action.value__ | Should -Be 3
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup3'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'EXAMPLE\TestGroup4' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'ED220833-3027-4071-80BE-0D0B50B781B3' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup4'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Create' {
                        $GPPItem.Properties.action | Should -BeExactly 'C'
                    }
                    It 'Group action numeric value is set to Create' {
                        $GPPItem.Properties.action.value__ | Should -Be 0
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup4'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'EXAMPLE\TestGroup5' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '4046D23B-4875-4E82-96B3-9920E9A9BDFF' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup5'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Replace' {
                        $GPPItem.Properties.action | Should -BeExactly 'R'
                    }
                    It 'Group action numeric value is set to Replace' {
                        $GPPItem.Properties.action.value__ | Should -Be 1
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup5'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'LocalGroup1' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '483E7907-F4DF-439C-946D-91D2FE3AFC20' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'LocalGroup1'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'Group action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'LocalGroup1'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeExactly 'LocalGroup2'
                    }
                    It 'Group has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'My Awesome Description'
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'LocalGroup3' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '52D0DA5A-91FD-472B-83C4-E70EC7CD5ACB' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'LocalGroup3'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is disabled' {
                        $GPPItem.disabled | Should -BeTrue
                    }
                    It 'Group action is set to Create' {
                        $GPPItem.Properties.action | Should -BeExactly 'C'
                    }
                    It 'Group action numeric value is set to Create' {
                        $GPPItem.Properties.action.value__ | Should -Be 0
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'LocalGroup3'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group has members' {
                        $GPPItem.Properties.Members | Should -Not -BeNullOrEmpty
                    }
                    It 'Group has 4 members' {
                        $GPPItem.Properties.Members | Should -HaveCount 4
                    }

                    Context 'EXAMPLE\Administrator' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\Administrator' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'ADD'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member does not have an SID' {
                            $Member.sid | Should -BeNullOrEmpty
                        }
                    }

                    Context 'EXAMPLE\TEST1' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST1' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'ADD'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member has an SID' {
                            $Member.sid | Should -Not -BeNullOrEmpty
                        }
                        It 'The SID is correct' {
                            $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                        }
                    }

                    Context 'EXAMPLE\TEST2' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST2' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'REMOVE'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member does not have an SID' {
                            $Member.sid | Should -BeNullOrEmpty
                        }

                        Context 'EXAMPLE\TEST3' {
                            BeforeAll {
                                $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST3' }
                            }

                            It 'Member is of a correct type' {
                                $Member | Should -BeOfType [GPPItemGroupMember]
                            }
                            It 'Member''s name has a correct case' {
                                $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                            }
                            It 'Member has a correct action' {
                                $Member.action | Should -Be 'REMOVE'
                            }
                            It 'The action is of a correct type' {
                                $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                            }
                            It 'Member has an SID' {
                                $Member.sid | Should -Not -BeNullOrEmpty
                            }
                            It 'The SID is correct' {
                                $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                            }
                        }
                    }
                }

                Context 'Backup Operators (built-in)' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '880FFE86-78C7-4E85-AFDE-608C24977161' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Backup Operators (built-in)'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Create' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'Group action numeric value is set to Create' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'Backup Operators (built-in)'
                    }
                    It 'Group has a correct SID' {
                        $GPPItem.Properties.groupSid | Should -BeExactly 'S-1-5-32-551'
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers enabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeTrue
                    }
                    It 'Group has deleteAllGroups enabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeTrue
                    }
                    It 'Group has members' {
                        $GPPItem.Properties.Members | Should -Not -BeNullOrEmpty
                    }
                    It 'Group has 4 members' {
                        $GPPItem.Properties.Members | Should -HaveCount 4
                    }

                    Context 'EXAMPLE\Administrator' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\Administrator' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'ADD'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member does not have an SID' {
                            $Member.sid | Should -BeNullOrEmpty
                        }
                    }

                    Context 'EXAMPLE\TEST1' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST1' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'ADD'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member has an SID' {
                            $Member.sid | Should -Not -BeNullOrEmpty
                        }
                        It 'The SID is correct' {
                            $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                        }
                    }

                    Context 'EXAMPLE\TEST2' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST2' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'REMOVE'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member does not have an SID' {
                            $Member.sid | Should -BeNullOrEmpty
                        }

                        Context 'EXAMPLE\TEST3' {
                            BeforeAll {
                                $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST3' }
                            }

                            It 'Member is of a correct type' {
                                $Member | Should -BeOfType [GPPItemGroupMember]
                            }
                            It 'Member''s name has a correct case' {
                                $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                            }
                            It 'Member has a correct action' {
                                $Member.action | Should -Be 'REMOVE'
                            }
                            It 'The action is of a correct type' {
                                $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                            }
                            It 'Member has an SID' {
                                $Member.sid | Should -Not -BeNullOrEmpty
                            }
                            It 'The SID is correct' {
                                $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                            }
                        }
                    }
                }
            }
        }

        <# Describe 'ACCEPTANCE: Get-GPPSection' {

        } #>

        Describe 'UNIT: Deserialize-GPPSection' {
            Context 'Groups-GroupsOnly-Set-1' {
                BeforeAll {
                    $GPPSection = $GPPSectionSet1
                }

                Context 'GPP section properties' {
                    It 'GPP section exists' {
                        $GPPSection | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP section is of a correct type' {
                        $GPPSection | Should -BeOfType [GPPSectionGroups]
                    }
                    It 'GPP section is enabled' {
                        $GPPSection.disabled | Should -BeFalse
                    }
                    It 'GPP section has a correct number of members' {
                        $GPPSection.Members | Should -HaveCount 8
                    }
                }

                Context 'EXAMPLE\TestGroup1' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '798C5D07-11C3-45C0-B767-124DF9A369A6' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup1'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'Group action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup1'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'Administrators (built-in)' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '6F82151C-1B8A-4809-ABDD-1EA08F91C923' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Administrators (built-in)'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'Group action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'Administrators (built-in)'
                    }
                    It 'Group has a correct SID' {
                        $GPPItem.Properties.groupSid | Should -BeExactly 'S-1-5-32-544'
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'EXAMPLE\TestGroup3' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '5BFED1D1-5C42-4504-84E7-E62FA36A6E69' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup3'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Delete' {
                        $GPPItem.Properties.action | Should -BeExactly 'D'
                    }
                    It 'Group action numeric value is set to Delete' {
                        $GPPItem.Properties.action.value__ | Should -Be 3
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup3'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'EXAMPLE\TestGroup4' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'ED220833-3027-4071-80BE-0D0B50B781B3' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup4'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Create' {
                        $GPPItem.Properties.action | Should -BeExactly 'C'
                    }
                    It 'Group action numeric value is set to Create' {
                        $GPPItem.Properties.action.value__ | Should -Be 0
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup4'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'EXAMPLE\TestGroup5' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '4046D23B-4875-4E82-96B3-9920E9A9BDFF' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup5'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Replace' {
                        $GPPItem.Properties.action | Should -BeExactly 'R'
                    }
                    It 'Group action numeric value is set to Replace' {
                        $GPPItem.Properties.action.value__ | Should -Be 1
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup5'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'LocalGroup1' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '483E7907-F4DF-439C-946D-91D2FE3AFC20' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'LocalGroup1'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'Group action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'LocalGroup1'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeExactly 'LocalGroup2'
                    }
                    It 'Group has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'My Awesome Description'
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'LocalGroup3' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '52D0DA5A-91FD-472B-83C4-E70EC7CD5ACB' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'LocalGroup3'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is disabled' {
                        $GPPItem.disabled | Should -BeTrue
                    }
                    It 'Group action is set to Create' {
                        $GPPItem.Properties.action | Should -BeExactly 'C'
                    }
                    It 'Group action numeric value is set to Create' {
                        $GPPItem.Properties.action.value__ | Should -Be 0
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'LocalGroup3'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group has members' {
                        $GPPItem.Properties.Members | Should -Not -BeNullOrEmpty
                    }
                    It 'Group has 4 members' {
                        $GPPItem.Properties.Members | Should -HaveCount 4
                    }

                    Context 'EXAMPLE\Administrator' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\Administrator' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'ADD'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member does not have an SID' {
                            $Member.sid | Should -BeNullOrEmpty
                        }
                    }

                    Context 'EXAMPLE\TEST1' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST1' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'ADD'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member has an SID' {
                            $Member.sid | Should -Not -BeNullOrEmpty
                        }
                        It 'The SID is correct' {
                            $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                        }
                    }

                    Context 'EXAMPLE\TEST2' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST2' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'REMOVE'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member does not have an SID' {
                            $Member.sid | Should -BeNullOrEmpty
                        }

                        Context 'EXAMPLE\TEST3' {
                            BeforeAll {
                                $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST3' }
                            }

                            It 'Member is of a correct type' {
                                $Member | Should -BeOfType [GPPItemGroupMember]
                            }
                            It 'Member''s name has a correct case' {
                                $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                            }
                            It 'Member has a correct action' {
                                $Member.action | Should -Be 'REMOVE'
                            }
                            It 'The action is of a correct type' {
                                $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                            }
                            It 'Member has an SID' {
                                $Member.sid | Should -Not -BeNullOrEmpty
                            }
                            It 'The SID is correct' {
                                $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                            }
                        }
                    }
                }

                Context 'Backup Operators (built-in)' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '880FFE86-78C7-4E85-AFDE-608C24977161' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Backup Operators (built-in)'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Create' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'Group action numeric value is set to Create' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'Backup Operators (built-in)'
                    }
                    It 'Group has a correct SID' {
                        $GPPItem.Properties.groupSid | Should -BeExactly 'S-1-5-32-551'
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers enabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeTrue
                    }
                    It 'Group has deleteAllGroups enabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeTrue
                    }
                    It 'Group has members' {
                        $GPPItem.Properties.Members | Should -Not -BeNullOrEmpty
                    }
                    It 'Group has 4 members' {
                        $GPPItem.Properties.Members | Should -HaveCount 4
                    }

                    Context 'EXAMPLE\Administrator' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\Administrator' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'ADD'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member does not have an SID' {
                            $Member.sid | Should -BeNullOrEmpty
                        }
                    }

                    Context 'EXAMPLE\TEST1' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST1' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'ADD'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member has an SID' {
                            $Member.sid | Should -Not -BeNullOrEmpty
                        }
                        It 'The SID is correct' {
                            $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                        }
                    }

                    Context 'EXAMPLE\TEST2' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST2' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'REMOVE'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member does not have an SID' {
                            $Member.sid | Should -BeNullOrEmpty
                        }

                        Context 'EXAMPLE\TEST3' {
                            BeforeAll {
                                $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST3' }
                            }

                            It 'Member is of a correct type' {
                                $Member | Should -BeOfType [GPPItemGroupMember]
                            }
                            It 'Member''s name has a correct case' {
                                $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                            }
                            It 'Member has a correct action' {
                                $Member.action | Should -Be 'REMOVE'
                            }
                            It 'The action is of a correct type' {
                                $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                            }
                            It 'Member has an SID' {
                                $Member.sid | Should -Not -BeNullOrEmpty
                            }
                            It 'The SID is correct' {
                                $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                            }
                        }
                    }
                }
            }
            Context 'Groups-GroupsOnly-Set-2' {
                BeforeAll {
                    $GPPSection = $GPPSectionSet2
                }

                Context 'GPP section properties' {
                    It 'GPP section exists' {
                        $GPPSection | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP section is of a correct type' {
                        $GPPSection | Should -BeOfType [GPPSectionGroups]
                    }
                    It 'GPP section is disabled' {
                        $GPPSection.disabled | Should -BeTrue
                    }
                    It 'GPP section has a correct number of members' {
                        $GPPSection.Members | Should -HaveCount 8
                    }
                }

                Context 'EXAMPLE\TestGroup1' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '798C5D07-11C3-45C0-B767-124DF9A369A6' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup1'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'Group action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup1'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'Administrators (built-in)' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '6F82151C-1B8A-4809-ABDD-1EA08F91C923' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Administrators (built-in)'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'Group action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'Administrators (built-in)'
                    }
                    It 'Group has a correct SID' {
                        $GPPItem.Properties.groupSid | Should -BeExactly 'S-1-5-32-544'
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'EXAMPLE\TestGroup3' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '5BFED1D1-5C42-4504-84E7-E62FA36A6E69' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup3'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Delete' {
                        $GPPItem.Properties.action | Should -BeExactly 'D'
                    }
                    It 'Group action numeric value is set to Delete' {
                        $GPPItem.Properties.action.value__ | Should -Be 3
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup3'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'EXAMPLE\TestGroup4' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'ED220833-3027-4071-80BE-0D0B50B781B3' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup4'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Create' {
                        $GPPItem.Properties.action | Should -BeExactly 'C'
                    }
                    It 'Group action numeric value is set to Create' {
                        $GPPItem.Properties.action.value__ | Should -Be 0
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup4'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'EXAMPLE\TestGroup5' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '4046D23B-4875-4E82-96B3-9920E9A9BDFF' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'EXAMPLE\TestGroup5'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Replace' {
                        $GPPItem.Properties.action | Should -BeExactly 'R'
                    }
                    It 'Group action numeric value is set to Replace' {
                        $GPPItem.Properties.action.value__ | Should -Be 1
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup5'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'LocalGroup1' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '483E7907-F4DF-439C-946D-91D2FE3AFC20' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'LocalGroup1'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'Group action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'LocalGroup1'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeExactly 'LocalGroup2'
                    }
                    It 'Group has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'My Awesome Description'
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group does not have members' {
                        $GPPItem.Properties.Members | Should -BeNullOrEmpty
                    }
                }

                Context 'LocalGroup3' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '52D0DA5A-91FD-472B-83C4-E70EC7CD5ACB' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'LocalGroup3'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is disabled' {
                        $GPPItem.disabled | Should -BeTrue
                    }
                    It 'Group action is set to Create' {
                        $GPPItem.Properties.action | Should -BeExactly 'C'
                    }
                    It 'Group action numeric value is set to Create' {
                        $GPPItem.Properties.action.value__ | Should -Be 0
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'LocalGroup3'
                    }
                    It 'Group does not have an SID defined' {
                        $GPPItem.Properties.groupSid | Should -BeNullOrEmpty
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers disabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeFalse
                    }
                    It 'Group has deleteAllGroups disabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeFalse
                    }
                    It 'Group has members' {
                        $GPPItem.Properties.Members | Should -Not -BeNullOrEmpty
                    }
                    It 'Group has 4 members' {
                        $GPPItem.Properties.Members | Should -HaveCount 4
                    }

                    Context 'EXAMPLE\Administrator' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\Administrator' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'ADD'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member does not have an SID' {
                            $Member.sid | Should -BeNullOrEmpty
                        }
                    }

                    Context 'EXAMPLE\TEST1' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST1' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'ADD'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member has an SID' {
                            $Member.sid | Should -Not -BeNullOrEmpty
                        }
                        It 'The SID is correct' {
                            $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                        }
                    }

                    Context 'EXAMPLE\TEST2' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST2' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'REMOVE'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member does not have an SID' {
                            $Member.sid | Should -BeNullOrEmpty
                        }

                        Context 'EXAMPLE\TEST3' {
                            BeforeAll {
                                $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST3' }
                            }

                            It 'Member is of a correct type' {
                                $Member | Should -BeOfType [GPPItemGroupMember]
                            }
                            It 'Member''s name has a correct case' {
                                $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                            }
                            It 'Member has a correct action' {
                                $Member.action | Should -Be 'REMOVE'
                            }
                            It 'The action is of a correct type' {
                                $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                            }
                            It 'Member has an SID' {
                                $Member.sid | Should -Not -BeNullOrEmpty
                            }
                            It 'The SID is correct' {
                                $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                            }
                        }
                    }
                }

                Context 'Backup Operators (built-in)' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '880FFE86-78C7-4E85-AFDE-608C24977161' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemGroup]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Backup Operators (built-in)'
                    }
                    It 'GPP item does not have removePolicy enabled' {
                        $GPPItem.removePolicy | Should -BeFalse
                    }
                    It 'GPP item bypasses errors' {
                        $GPPItem.bypassErrors | Should -BeTrue
                    }
                    It 'GPP item is enabled' {
                        $GPPItem.disabled | Should -BeFalse
                    }
                    It 'Group action is set to Create' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'Group action numeric value is set to Create' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'Group has a correct name' {
                        $GPPItem.Properties.groupName | Should -BeExactly 'Backup Operators (built-in)'
                    }
                    It 'Group has a correct SID' {
                        $GPPItem.Properties.groupSid | Should -BeExactly 'S-1-5-32-551'
                    }
                    It 'Group is not to be renamed' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'Group does not have a description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'Group has deleteAllUsers enabled' {
                        $GPPItem.Properties.deleteAllUsers | Should -BeTrue
                    }
                    It 'Group has deleteAllGroups enabled' {
                        $GPPItem.Properties.deleteAllGroups | Should -BeTrue
                    }
                    It 'Group has members' {
                        $GPPItem.Properties.Members | Should -Not -BeNullOrEmpty
                    }
                    It 'Group has 4 members' {
                        $GPPItem.Properties.Members | Should -HaveCount 4
                    }

                    Context 'EXAMPLE\Administrator' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\Administrator' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'ADD'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member does not have an SID' {
                            $Member.sid | Should -BeNullOrEmpty
                        }
                    }

                    Context 'EXAMPLE\TEST1' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST1' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'ADD'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member has an SID' {
                            $Member.sid | Should -Not -BeNullOrEmpty
                        }
                        It 'The SID is correct' {
                            $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                        }
                    }

                    Context 'EXAMPLE\TEST2' {
                        BeforeAll {
                            $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST2' }
                        }

                        It 'Member is of a correct type' {
                            $Member | Should -BeOfType [GPPItemGroupMember]
                        }
                        It 'Member''s name has a correct case' {
                            $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                        }
                        It 'Member has a correct action' {
                            $Member.action | Should -Be 'REMOVE'
                        }
                        It 'The action is of a correct type' {
                            $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                        }
                        It 'Member does not have an SID' {
                            $Member.sid | Should -BeNullOrEmpty
                        }

                        Context 'EXAMPLE\TEST3' {
                            BeforeAll {
                                $Member = $GPPItem.Properties.Members | Where-Object { $_.Name -eq 'EXAMPLE\TEST3' }
                            }

                            It 'Member is of a correct type' {
                                $Member | Should -BeOfType [GPPItemGroupMember]
                            }
                            It 'Member''s name has a correct case' {
                                $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                            }
                            It 'Member has a correct action' {
                                $Member.action | Should -Be 'REMOVE'
                            }
                            It 'The action is of a correct type' {
                                $Member.action | Should -BeOfType [GPPItemGroupMemberAction]
                            }
                            It 'Member has an SID' {
                                $Member.sid | Should -Not -BeNullOrEmpty
                            }
                            It 'The SID is correct' {
                                $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                            }
                        }
                    }
                }
            }
        }

        Describe 'UNIT: Serialize-GPPItem' {
            Context 'Groups-GroupsOnly-Set-<GPPSectionID>' -Foreach @(
                @{
                    GPPSectionID    = 1
                    SectionDisabled = 0
                }
                @{
                    GPPSectionID    = 2
                    SectionDisabled = 1
                }
            ) {
                BeforeAll {
                    $GPPSection = (Get-Variable -Name ('GPPSectionSet{0}' -f $GPPSectionID)).Value
                }

                Context 'GPPSectionGroups' {
                    # Serialize-GPPSectionGroups
                    BeforeAll {
                        [xml]$XMLDocument = Serialize-GPPItem -InputObject $GPPSection -RootElementName 'Groups' -SpecialSerializationTypeNames ('GPPItemGroup', 'GPPItemUser')
                    }

                    It 'XML document exists' {
                        $XMLDocument | Should -Not -BeNullOrEmpty
                    }
                    It 'XML text is correct' {
                        $XMLDocument.OuterXml | Should -Be ('<Groups clsid="{{3125e937-eb16-4b4c-9934-544fc6d24d26}}" disabled="{0}" />' -f $SectionDisabled)
                    }
                    It 'XML Groups element exists' {
                        $XMLDocument.Groups | Should -Not -BeNullOrEmpty
                    }
                    It 'Groups clsid is correct' {
                        $XMLDocument.Groups.clsid | Should -Be '{3125e937-eb16-4b4c-9934-544fc6d24d26}'
                    }
                    It 'Groups section state is correct' {
                        $XMLDocument.Groups.disabled | Should -Be $SectionDisabled
                    }
                }

                Context 'GPPItemGroup' {
                    # Serialize-GPPItemGroup

                    Context 'EXAMPLE\TestGroup1' {
                        BeforeAll {
                            $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '798C5D07-11C3-45C0-B767-124DF9A369A6' }
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Group' -SpecialSerializationTypeNames 'GPPItemPropertiesGroup'
                        }

                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Group element exists' {
                            $XMLDocument.Group | Should -Not -BeNullOrEmpty
                        }
                        It 'Group clsid attribute is correct' {
                            $XMLDocument.Group.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                        }
                        It 'Group uid is correct' {
                            $XMLDocument.Group.uid | Should -BeExactly '{798c5d07-11c3-45c0-b767-124df9a369a6}'
                        }
                        It 'Group name is correct' {
                            $XMLDocument.Group.name | Should -BeExactly 'EXAMPLE\TestGroup1'
                        }
                        It 'Group has changed date/time' {
                            $XMLDocument.Group.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'Group is enabled' {
                            $XMLDocument.Group.disabled | Should -BeExactly '0'
                        }
                        It 'Group has a correct image' {
                            $XMLDocument.Group.image | Should -BeExactly '2'
                        }
                        It 'Group bypasses errors' {
                            $XMLDocument.Group.bypassErrors | Should -BeExactly '1'
                        }
                        It 'Group has removePolicy set to 0' {
                            $XMLDocument.Group.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'Administrators (built-in)' {
                        BeforeAll {
                            $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '6F82151C-1B8A-4809-ABDD-1EA08F91C923' }
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Group' -SpecialSerializationTypeNames 'GPPItemPropertiesGroup'
                        }

                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Group element exists' {
                            $XMLDocument.Group | Should -Not -BeNullOrEmpty
                        }
                        It 'Group clsid attribute is correct' {
                            $XMLDocument.Group.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                        }
                        It 'Group uid is correct' {
                            $XMLDocument.Group.uid | Should -BeExactly '{6f82151c-1b8a-4809-abdd-1ea08f91c923}'
                        }
                        It 'Group name is correct' {
                            $XMLDocument.Group.name | Should -BeExactly 'Administrators (built-in)'
                        }
                        It 'Group has changed date/time' {
                            $XMLDocument.Group.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'Group is enabled' {
                            $XMLDocument.Group.disabled | Should -BeExactly '0'
                        }
                        It 'Group has a correct image' {
                            $XMLDocument.Group.image | Should -BeExactly '2'
                        }
                        It 'Group bypasses errors' {
                            $XMLDocument.Group.bypassErrors | Should -BeExactly '1'
                        }
                        It 'Group has removePolicy set to 0' {
                            $XMLDocument.Group.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'EXAMPLE\TestGroup3' {
                        BeforeAll {
                            $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '5BFED1D1-5C42-4504-84E7-E62FA36A6E69' }
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Group' -SpecialSerializationTypeNames 'GPPItemPropertiesGroup'
                        }

                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Group element exists' {
                            $XMLDocument.Group | Should -Not -BeNullOrEmpty
                        }
                        It 'Group clsid attribute is correct' {
                            $XMLDocument.Group.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                        }
                        It 'Group uid is correct' {
                            $XMLDocument.Group.uid | Should -BeExactly '{5bfed1d1-5c42-4504-84e7-e62fa36a6e69}'
                        }
                        It 'Group name is correct' {
                            $XMLDocument.Group.name | Should -BeExactly 'EXAMPLE\TestGroup3'
                        }
                        It 'Group has changed date/time' {
                            $XMLDocument.Group.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'Group is enabled' {
                            $XMLDocument.Group.disabled | Should -BeExactly '0'
                        }
                        It 'Group has a correct image' {
                            $XMLDocument.Group.image | Should -BeExactly '3'
                        }
                        It 'Group bypasses errors' {
                            $XMLDocument.Group.bypassErrors | Should -BeExactly '1'
                        }
                        It 'Group has removePolicy set to 0' {
                            $XMLDocument.Group.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'EXAMPLE\TestGroup4' {
                        BeforeAll {
                            $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'ED220833-3027-4071-80BE-0D0B50B781B3' }
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Group' -SpecialSerializationTypeNames 'GPPItemPropertiesGroup'
                        }

                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Group element exists' {
                            $XMLDocument.Group | Should -Not -BeNullOrEmpty
                        }
                        It 'Group clsid attribute is correct' {
                            $XMLDocument.Group.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                        }
                        It 'Group uid is correct' {
                            $XMLDocument.Group.uid | Should -BeExactly '{ed220833-3027-4071-80be-0d0b50b781b3}'
                        }
                        It 'Group name is correct' {
                            $XMLDocument.Group.name | Should -BeExactly 'EXAMPLE\TestGroup4'
                        }
                        It 'Group has changed date/time' {
                            $XMLDocument.Group.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'Group is enabled' {
                            $XMLDocument.Group.disabled | Should -BeExactly '0'
                        }
                        It 'Group has a correct image' {
                            $XMLDocument.Group.image | Should -BeExactly '0'
                        }
                        It 'Group bypasses errors' {
                            $XMLDocument.Group.bypassErrors | Should -BeExactly '1'
                        }
                        It 'Group has removePolicy set to 0' {
                            $XMLDocument.Group.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'EXAMPLE\TestGroup5' {
                        BeforeAll {
                            $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '4046D23B-4875-4E82-96B3-9920E9A9BDFF' }
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Group' -SpecialSerializationTypeNames 'GPPItemPropertiesGroup'
                        }

                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Group element exists' {
                            $XMLDocument.Group | Should -Not -BeNullOrEmpty
                        }
                        It 'Group clsid attribute is correct' {
                            $XMLDocument.Group.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                        }
                        It 'Group uid is correct' {
                            $XMLDocument.Group.uid | Should -BeExactly '{4046d23b-4875-4e82-96b3-9920e9a9bdff}'
                        }
                        It 'Group name is correct' {
                            $XMLDocument.Group.name | Should -BeExactly 'EXAMPLE\TestGroup5'
                        }
                        It 'Group has changed date/time' {
                            $XMLDocument.Group.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'Group is enabled' {
                            $XMLDocument.Group.disabled | Should -BeExactly '0'
                        }
                        It 'Group has a correct image' {
                            $XMLDocument.Group.image | Should -BeExactly '1'
                        }
                        It 'Group bypasses errors' {
                            $XMLDocument.Group.bypassErrors | Should -BeExactly '1'
                        }
                        It 'Group has removePolicy set to 0' {
                            $XMLDocument.Group.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'LocalGroup1' {
                        BeforeAll {
                            $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '483E7907-F4DF-439C-946D-91D2FE3AFC20' }
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Group' -SpecialSerializationTypeNames 'GPPItemPropertiesGroup'
                        }

                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Group element exists' {
                            $XMLDocument.Group | Should -Not -BeNullOrEmpty
                        }
                        It 'Group clsid attribute is correct' {
                            $XMLDocument.Group.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                        }
                        It 'Group uid is correct' {
                            $XMLDocument.Group.uid | Should -BeExactly '{483e7907-f4df-439c-946d-91d2fe3afc20}'
                        }
                        It 'Group name is correct' {
                            $XMLDocument.Group.name | Should -BeExactly 'LocalGroup1'
                        }
                        It 'Group has changed date/time' {
                            $XMLDocument.Group.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'Group is enabled' {
                            $XMLDocument.Group.disabled | Should -BeExactly '0'
                        }
                        It 'Group has a correct image' {
                            $XMLDocument.Group.image | Should -BeExactly '2'
                        }
                        It 'Group bypasses errors' {
                            $XMLDocument.Group.bypassErrors | Should -BeExactly '1'
                        }
                        It 'Group has removePolicy set to 0' {
                            $XMLDocument.Group.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'LocalGroup3' {
                        BeforeAll {
                            $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '52D0DA5A-91FD-472B-83C4-E70EC7CD5ACB' }
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Group' -SpecialSerializationTypeNames 'GPPItemPropertiesGroup'
                        }

                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Group element exists' {
                            $XMLDocument.Group | Should -Not -BeNullOrEmpty
                        }
                        It 'Group clsid attribute is correct' {
                            $XMLDocument.Group.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                        }
                        It 'Group uid is correct' {
                            $XMLDocument.Group.uid | Should -BeExactly '{52d0da5a-91fd-472b-83c4-e70ec7cd5acb}'
                        }
                        It 'Group name is correct' {
                            $XMLDocument.Group.name | Should -BeExactly 'LocalGroup3'
                        }
                        It 'Group has changed date/time' {
                            $XMLDocument.Group.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'Group is disabled' {
                            $XMLDocument.Group.disabled | Should -BeExactly '1'
                        }
                        It 'Group has a correct image' {
                            $XMLDocument.Group.image | Should -BeExactly '0'
                        }
                        It 'Group bypasses errors' {
                            $XMLDocument.Group.bypassErrors | Should -BeExactly '1'
                        }
                        It 'Group has removePolicy set to 0' {
                            $XMLDocument.Group.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'Backup Operators (built-in)' {
                        BeforeAll {
                            $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '880FFE86-78C7-4E85-AFDE-608C24977161' }
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Group' -SpecialSerializationTypeNames 'GPPItemPropertiesGroup'
                        }

                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Group element exists' {
                            $XMLDocument.Group | Should -Not -BeNullOrEmpty
                        }
                        It 'Group clsid attribute is correct' {
                            $XMLDocument.Group.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                        }
                        It 'Group uid is correct' {
                            $XMLDocument.Group.uid | Should -BeExactly '{880ffe86-78c7-4e85-afde-608c24977161}'
                        }
                        It 'Group name is correct' {
                            $XMLDocument.Group.name | Should -BeExactly 'Backup Operators (built-in)'
                        }
                        It 'Group has changed date/time' {
                            $XMLDocument.Group.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'Group is enabled' {
                            $XMLDocument.Group.disabled | Should -BeExactly '0'
                        }
                        It 'Group has a correct image' {
                            $XMLDocument.Group.image | Should -BeExactly '2'
                        }
                        It 'Group bypasses errors' {
                            $XMLDocument.Group.bypassErrors | Should -BeExactly '1'
                        }
                        It 'Group has removePolicy set to 0' {
                            $XMLDocument.Group.removePolicy | Should -BeExactly '0'
                        }
                    }
                }

                Context 'GPPItemPropertiesGroup' {
                    # Serialize-GPPItemPropertiesGroup
                    # $InputObject = $GPPSection
                    # $Item In $InputObject.Members
                    # $InputObject = $Item
                    # $InputObject = $InputObject.Properties
                    # Serialize-GPPItem -InputObject $InputObject -RootElementName 'Properties' -SpecialSerializationTypeNames 'GPPItemGroupMember'

                    Context 'EXAMPLE\TestGroup1' {
                        BeforeAll {
                            $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '798C5D07-11C3-45C0-B767-124DF9A369A6' }).Properties
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Properties' -SpecialSerializationTypeNames 'GPPItemGroupMember'
                        }

                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocument | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                            }
                            It 'XML Properties element exists' {
                                $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                            }
                        }

                        Context 'Content' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup1'
                            }
                            It 'Group SID is absent' {
                                $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'U'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly ''
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly ''
                            }
                            It 'deleteAllGroups set to 0' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                            }
                            It 'deleteAllUsers set to 0' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }
                    }

                    Context 'Administrators (built-in)' {
                        BeforeAll {
                            $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '6F82151C-1B8A-4809-ABDD-1EA08F91C923' }).Properties
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Properties' -SpecialSerializationTypeNames 'GPPItemGroupMember'
                        }

                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocument | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                            }
                            It 'XML Properties element exists' {
                                $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 8
                            }
                        }

                        Context 'Content' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'Administrators (built-in)'
                            }
                            It 'Group SID is correct' {
                                $XMLDocument.Properties.groupSid | Should -BeExactly 'S-1-5-32-544'
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'U'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly ''
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly ''
                            }
                            It 'deleteAllGroups set to 0' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                            }
                            It 'deleteAllUsers set to 0' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }
                    }

                    Context 'EXAMPLE\TestGroup3' {
                        BeforeAll {
                            $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '5BFED1D1-5C42-4504-84E7-E62FA36A6E69' }).Properties
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Properties' -SpecialSerializationTypeNames 'GPPItemGroupMember'
                        }

                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocument | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                            }
                            It 'XML Properties element exists' {
                                $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                            }
                        }

                        Context 'Content' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup3'
                            }
                            It 'Group SID is absent' {
                                $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'D'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly ''
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly ''
                            }
                            It 'deleteAllGroups set to 0' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                            }
                            It 'deleteAllUsers set to 0' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }
                    }

                    Context 'EXAMPLE\TestGroup4' {
                        BeforeAll {
                            $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'ED220833-3027-4071-80BE-0D0B50B781B3' }).Properties
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Properties' -SpecialSerializationTypeNames 'GPPItemGroupMember'
                        }

                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocument | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                            }
                            It 'XML Properties element exists' {
                                $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                            }
                        }

                        Context 'Content' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup4'
                            }
                            It 'Group SID is absent' {
                                $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'C'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly ''
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly ''
                            }
                            It 'deleteAllGroups set to 0' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                            }
                            It 'deleteAllUsers set to 0' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }
                    }

                    Context 'EXAMPLE\TestGroup5' {
                        BeforeAll {
                            $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '4046D23B-4875-4E82-96B3-9920E9A9BDFF' }).Properties
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Properties' -SpecialSerializationTypeNames 'GPPItemGroupMember'
                        }

                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocument | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                            }
                            It 'XML Properties element exists' {
                                $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                            }
                        }

                        Context 'Content' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup5'
                            }
                            It 'Group SID is absent' {
                                $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'R'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly ''
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly ''
                            }
                            It 'deleteAllGroups set to 0' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                            }
                            It 'deleteAllUsers set to 0' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }
                    }

                    Context 'LocalGroup1' {
                        BeforeAll {
                            $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '483E7907-F4DF-439C-946D-91D2FE3AFC20' }).Properties
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Properties' -SpecialSerializationTypeNames 'GPPItemGroupMember'
                        }

                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocument | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                            }
                            It 'XML Properties element exists' {
                                $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                            }
                        }

                        Context 'Content' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'LocalGroup1'
                            }
                            It 'Group SID is absent' {
                                $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'U'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly 'My Awesome Description'
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly 'LocalGroup2'
                            }
                            It 'deleteAllGroups set to 0' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                            }
                            It 'deleteAllUsers set to 0' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }
                    }

                    Context 'LocalGroup3' {
                        BeforeAll {
                            $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '52D0DA5A-91FD-472B-83C4-E70EC7CD5ACB' }).Properties
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Properties' -SpecialSerializationTypeNames 'GPPItemGroupMember'
                        }

                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocument | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                            }
                            It 'XML Properties element exists' {
                                $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                            }
                        }

                        Context 'Content' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'LocalGroup3'
                            }
                            It 'Group SID is absent' {
                                $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'C'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly ''
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly ''
                            }
                            It 'deleteAllGroups set to 0' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                            }
                            It 'deleteAllUsers set to 0' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }
                    }

                    Context 'Backup Operators (built-in)' {
                        BeforeAll {
                            $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '880FFE86-78C7-4E85-AFDE-608C24977161' }).Properties
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Properties' -SpecialSerializationTypeNames 'GPPItemGroupMember'
                        }

                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocument | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                            }
                            It 'XML Properties element exists' {
                                $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 8
                            }
                        }

                        Context 'Content' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'Backup Operators (built-in)'
                            }
                            It 'Group SID is correct' {
                                $XMLDocument.Properties.groupSid | Should -BeExactly 'S-1-5-32-551'
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'U'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly ''
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly ''
                            }
                            It 'deleteAllGroups set to 1' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '1'
                            }
                            It 'deleteAllUsers set to 1' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '1'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }
                    }
                }

                Context 'GPPItemGroupMember' {
                    # Serialize-GPPItemGroupMember
                    # $GroupsSection = $GPPSection
                    # $InputObject = $GroupsSection
                    # $Item In $InputObject.Members
                    # $InputObject = $Item
                    # $InputObject = $InputObject.Properties
                    # $Item In $InputObject.Members
                    # $InputObject = $Item
                    # Serialize-GPPItem -InputObject $InputObject -RootElementName 'Member'

                    Context 'LocalGroup3' {
                        BeforeAll {
                            $Members = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '52D0DA5A-91FD-472B-83C4-E70EC7CD5ACB' }).Properties.Members
                        }

                        Context 'EXAMPLE\Administrator' {
                            BeforeAll {
                                $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\Administrator' }
                                [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Member'
                            }
                            Context 'Structure' {
                                It 'XML document exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'XML document has correct number of properties' {
                                    ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                                }
                                It 'XML Properties element exists' {
                                    $XMLDocument.Member | Should -Not -BeNullOrEmpty
                                }
                                It 'XML Properties element has correct number of properties' {
                                    ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                }
                            }

                            Context 'Content' {
                                It 'Member name is correct' {
                                    $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                                }
                                It 'Action is correct' {
                                    $XMLDocument.Member.action | Should -BeExactly 'ADD'
                                }
                            }
                        }

                        Context 'EXAMPLE\TEST1' {
                            BeforeAll {
                                $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST1' }
                                [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Member'
                            }
                            Context 'Structure' {
                                It 'XML document exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'XML document has correct number of properties' {
                                    ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                                }
                                It 'XML Properties element exists' {
                                    $XMLDocument.Member | Should -Not -BeNullOrEmpty
                                }
                                It 'XML Properties element has correct number of properties' {
                                    ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                }
                            }

                            Context 'Content' {
                                It 'Member name is correct' {
                                    $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                                }
                                It 'Action is correct' {
                                    $XMLDocument.Member.action | Should -BeExactly 'ADD'
                                }
                                It 'SID is correct' {
                                    $XMLDocument.Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                                }
                            }
                        }

                        Context 'EXAMPLE\TEST2' {
                            BeforeAll {
                                $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST2' }
                                [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Member'
                            }
                            Context 'Structure' {
                                It 'XML document exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'XML document has correct number of properties' {
                                    ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                                }
                                It 'XML Properties element exists' {
                                    $XMLDocument.Member | Should -Not -BeNullOrEmpty
                                }
                                It 'XML Properties element has correct number of properties' {
                                    ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                }
                            }

                            Context 'Content' {
                                It 'Member name is correct' {
                                    $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                                }
                                It 'Action is correct' {
                                    $XMLDocument.Member.action | Should -BeExactly 'REMOVE'
                                }
                            }
                        }

                        Context 'EXAMPLE\TEST3' {
                            BeforeAll {
                                $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST3' }
                                [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Member'
                            }
                            Context 'Structure' {
                                It 'XML document exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'XML document has correct number of properties' {
                                    ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                                }
                                It 'XML Properties element exists' {
                                    $XMLDocument.Member | Should -Not -BeNullOrEmpty
                                }
                                It 'XML Properties element has correct number of properties' {
                                    ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                }
                            }

                            Context 'Content' {
                                It 'Member name is correct' {
                                    $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                                }
                                It 'Action is correct' {
                                    $XMLDocument.Member.action | Should -BeExactly 'REMOVE'
                                }
                                It 'SID is correct' {
                                    $XMLDocument.Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                                }
                            }
                        }
                    }

                    Context 'Backup Operators (built-in)' {
                        BeforeAll {
                            $Members = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '880FFE86-78C7-4E85-AFDE-608C24977161' }).Properties.Members
                        }

                        Context 'EXAMPLE\Administrator' {
                            BeforeAll {
                                $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\Administrator' }
                                [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Member'
                            }
                            Context 'Structure' {
                                It 'XML document exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'XML document has correct number of properties' {
                                    ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                                }
                                It 'XML Properties element exists' {
                                    $XMLDocument.Member | Should -Not -BeNullOrEmpty
                                }
                                It 'XML Properties element has correct number of properties' {
                                    ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                }
                            }

                            Context 'Content' {
                                It 'Member name is correct' {
                                    $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                                }
                                It 'Action is correct' {
                                    $XMLDocument.Member.action | Should -BeExactly 'ADD'
                                }
                            }
                        }

                        Context 'EXAMPLE\TEST1' {
                            BeforeAll {
                                $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST1' }
                                [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Member'
                            }
                            Context 'Structure' {
                                It 'XML document exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'XML document has correct number of properties' {
                                    ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                                }
                                It 'XML Properties element exists' {
                                    $XMLDocument.Member | Should -Not -BeNullOrEmpty
                                }
                                It 'XML Properties element has correct number of properties' {
                                    ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                }
                            }

                            Context 'Content' {
                                It 'Member name is correct' {
                                    $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                                }
                                It 'Action is correct' {
                                    $XMLDocument.Member.action | Should -BeExactly 'ADD'
                                }
                                It 'SID is correct' {
                                    $XMLDocument.Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                                }
                            }
                        }

                        Context 'EXAMPLE\TEST2' {
                            BeforeAll {
                                $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST2' }
                                [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Member'
                            }
                            Context 'Structure' {
                                It 'XML document exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'XML document has correct number of properties' {
                                    ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                                }
                                It 'XML Properties element exists' {
                                    $XMLDocument.Member | Should -Not -BeNullOrEmpty
                                }
                                It 'XML Properties element has correct number of properties' {
                                    ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                }
                            }

                            Context 'Content' {
                                It 'Member name is correct' {
                                    $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                                }
                                It 'Action is correct' {
                                    $XMLDocument.Member.action | Should -BeExactly 'REMOVE'
                                }
                            }
                        }

                        Context 'EXAMPLE\TEST3' {
                            BeforeAll {
                                $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST3' }
                                [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Member'
                            }
                            Context 'Structure' {
                                It 'XML document exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'XML document has correct number of properties' {
                                    ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                                }
                                It 'XML Properties element exists' {
                                    $XMLDocument.Member | Should -Not -BeNullOrEmpty
                                }
                                It 'XML Properties element has correct number of properties' {
                                    ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                }
                            }

                            Context 'Content' {
                                It 'Member name is correct' {
                                    $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                                }
                                It 'Action is correct' {
                                    $XMLDocument.Member.action | Should -BeExactly 'REMOVE'
                                }
                                It 'SID is correct' {
                                    $XMLDocument.Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                                }
                            }
                        }
                    }
                }
            }
        }

        Describe 'UNIT: Serialize-GPPItemGroupMember' {
            #Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
            #-InputObject $InputObject
            #-InputObject $InputObject
            #$Item in $InputObject.Members
            #-InputObject $Item
            #-InputObject $InputObject.Properties
            #$Item in $InputObject.Members
            #Serialize-GPPItemGroupMember -InputObject $Item

            BeforeAll {
                Mock Serialize-GPPItem {
                    $Path = switch ($InputObject.name) {
                        'EXAMPLE\Administrator' {
                            Join-Path -Path $DataSourcePath -ChildPath 'GPPItemGroupMember_EXAMPLE_Administrator.xml'
                        }
                        'EXAMPLE\TEST1' {
                            Join-Path -Path $DataSourcePath -ChildPath 'GPPItemGroupMember_EXAMPLE_TEST1.xml'
                        }
                        'EXAMPLE\TEST2' {
                            Join-Path -Path $DataSourcePath -ChildPath 'GPPItemGroupMember_EXAMPLE_TEST2.xml'
                        }
                        'EXAMPLE\TEST3' {
                            Join-Path -Path $DataSourcePath -ChildPath 'GPPItemGroupMember_EXAMPLE_TEST3.xml'
                        }
                    }

                    [xml]$Content = Get-Content -Path $Path
                    $Content
                }

                $GPPSection = $GPPSectionSet1
                $Members = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '52D0DA5A-91FD-472B-83C4-E70EC7CD5ACB' }).Properties.Members
            }

            Context 'EXAMPLE\Administrator' {
                BeforeAll {
                    $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\Administrator' }
                    [xml]$XMLDocument = Serialize-GPPItemGroupMember -InputObject $Item
                }
                Context 'Structure' {
                    It 'XML document exists' {
                        $XMLDocument | Should -Not -BeNullOrEmpty
                    }
                    It 'XML document has correct number of properties' {
                        ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                    }
                    It 'XML Properties element exists' {
                        $XMLDocument.Member | Should -Not -BeNullOrEmpty
                    }
                    It 'XML Properties element has correct number of properties' {
                        ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                    }
                }

                Context 'Content' {
                    It 'Member name is correct' {
                        $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                    }
                    It 'Action is correct' {
                        $XMLDocument.Member.action | Should -BeExactly 'ADD'
                    }
                }
            }

            Context 'EXAMPLE\TEST1' {
                BeforeAll {
                    $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST1' }
                    [xml]$XMLDocument = Serialize-GPPItemGroupMember -InputObject $Item
                }
                Context 'Structure' {
                    It 'XML document exists' {
                        $XMLDocument | Should -Not -BeNullOrEmpty
                    }
                    It 'XML document has correct number of properties' {
                        ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                    }
                    It 'XML Properties element exists' {
                        $XMLDocument.Member | Should -Not -BeNullOrEmpty
                    }
                    It 'XML Properties element has correct number of properties' {
                        ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                    }
                }

                Context 'Content' {
                    It 'Member name is correct' {
                        $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                    }
                    It 'Action is correct' {
                        $XMLDocument.Member.action | Should -BeExactly 'ADD'
                    }
                    It 'SID is correct' {
                        $XMLDocument.Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                    }
                }
            }

            Context 'EXAMPLE\TEST2' {
                BeforeAll {
                    $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST2' }
                    [xml]$XMLDocument = Serialize-GPPItemGroupMember -InputObject $Item
                }
                Context 'Structure' {
                    It 'XML document exists' {
                        $XMLDocument | Should -Not -BeNullOrEmpty
                    }
                    It 'XML document has correct number of properties' {
                        ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                    }
                    It 'XML Properties element exists' {
                        $XMLDocument.Member | Should -Not -BeNullOrEmpty
                    }
                    It 'XML Properties element has correct number of properties' {
                        ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                    }
                }

                Context 'Content' {
                    It 'Member name is correct' {
                        $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                    }
                    It 'Action is correct' {
                        $XMLDocument.Member.action | Should -BeExactly 'REMOVE'
                    }
                }
            }

            Context 'EXAMPLE\TEST3' {
                BeforeAll {
                    $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST3' }
                    [xml]$XMLDocument = Serialize-GPPItemGroupMember -InputObject $Item
                }
                Context 'Structure' {
                    It 'XML document exists' {
                        $XMLDocument | Should -Not -BeNullOrEmpty
                    }
                    It 'XML document has correct number of properties' {
                        ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                    }
                    It 'XML Properties element exists' {
                        $XMLDocument.Member | Should -Not -BeNullOrEmpty
                    }
                    It 'XML Properties element has correct number of properties' {
                        ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                    }
                }

                Context 'Content' {
                    It 'Member name is correct' {
                        $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                    }
                    It 'Action is correct' {
                        $XMLDocument.Member.action | Should -BeExactly 'REMOVE'
                    }
                    It 'SID is correct' {
                        $XMLDocument.Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                    }
                }
            }
        }

        Describe 'ACCEPTANCE: Serialize-GPPItemGroupMember' {
            #Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
            #-InputObject $InputObject
            #-InputObject $InputObject
            #$Item in $InputObject.Members
            #-InputObject $Item
            #-InputObject $InputObject.Properties
            #$Item in $InputObject.Members
            #Serialize-GPPItemGroupMember -InputObject $Item

            Context 'Groups-GroupsOnly-Set-<GPPSectionID>' -Foreach @(
                @{
                    GPPSectionID = 1
                }
                @{
                    GPPSectionID = 2
                }
            ) {
                BeforeAll {
                    $GPPSection = (Get-Variable -Name ('GPPSectionSet{0}' -f $GPPSectionID)).Value
                }
                Context 'LocalGroup3' {
                    BeforeAll {
                        $Members = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '52D0DA5A-91FD-472B-83C4-E70EC7CD5ACB' }).Properties.Members
                    }

                    Context 'EXAMPLE\Administrator' {
                        BeforeAll {
                            $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\Administrator' }
                            [xml]$XMLDocument = Serialize-GPPItemGroupMember -InputObject $Item
                        }
                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocument | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                            }
                            It 'XML Properties element exists' {
                                $XMLDocument.Member | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                            }
                        }

                        Context 'Content' {
                            It 'Member name is correct' {
                                $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                            }
                            It 'Action is correct' {
                                $XMLDocument.Member.action | Should -BeExactly 'ADD'
                            }
                        }
                    }

                    Context 'EXAMPLE\TEST1' {
                        BeforeAll {
                            $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST1' }
                            [xml]$XMLDocument = Serialize-GPPItemGroupMember -InputObject $Item
                        }
                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocument | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                            }
                            It 'XML Properties element exists' {
                                $XMLDocument.Member | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                            }
                        }

                        Context 'Content' {
                            It 'Member name is correct' {
                                $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                            }
                            It 'Action is correct' {
                                $XMLDocument.Member.action | Should -BeExactly 'ADD'
                            }
                            It 'SID is correct' {
                                $XMLDocument.Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                            }
                        }
                    }

                    Context 'EXAMPLE\TEST2' {
                        BeforeAll {
                            $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST2' }
                            [xml]$XMLDocument = Serialize-GPPItemGroupMember -InputObject $Item
                        }
                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocument | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                            }
                            It 'XML Properties element exists' {
                                $XMLDocument.Member | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                            }
                        }

                        Context 'Content' {
                            It 'Member name is correct' {
                                $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                            }
                            It 'Action is correct' {
                                $XMLDocument.Member.action | Should -BeExactly 'REMOVE'
                            }
                        }
                    }

                    Context 'EXAMPLE\TEST3' {
                        BeforeAll {
                            $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST3' }
                            [xml]$XMLDocument = Serialize-GPPItemGroupMember -InputObject $Item
                        }
                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocument | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                            }
                            It 'XML Properties element exists' {
                                $XMLDocument.Member | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                            }
                        }

                        Context 'Content' {
                            It 'Member name is correct' {
                                $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                            }
                            It 'Action is correct' {
                                $XMLDocument.Member.action | Should -BeExactly 'REMOVE'
                            }
                            It 'SID is correct' {
                                $XMLDocument.Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                            }
                        }
                    }
                }

                Context 'Backup Operators (built-in)' {
                    BeforeAll {
                        $Members = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '880FFE86-78C7-4E85-AFDE-608C24977161' }).Properties.Members
                    }

                    Context 'EXAMPLE\Administrator' {
                        BeforeAll {
                            $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\Administrator' }
                            [xml]$XMLDocument = Serialize-GPPItemGroupMember -InputObject $Item
                        }
                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocument | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                            }
                            It 'XML Properties element exists' {
                                $XMLDocument.Member | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                            }
                        }

                        Context 'Content' {
                            It 'Member name is correct' {
                                $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                            }
                            It 'Action is correct' {
                                $XMLDocument.Member.action | Should -BeExactly 'ADD'
                            }
                        }
                    }

                    Context 'EXAMPLE\TEST1' {
                        BeforeAll {
                            $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST1' }
                            [xml]$XMLDocument = Serialize-GPPItemGroupMember -InputObject $Item
                        }
                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocument | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                            }
                            It 'XML Properties element exists' {
                                $XMLDocument.Member | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                            }
                        }

                        Context 'Content' {
                            It 'Member name is correct' {
                                $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                            }
                            It 'Action is correct' {
                                $XMLDocument.Member.action | Should -BeExactly 'ADD'
                            }
                            It 'SID is correct' {
                                $XMLDocument.Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                            }
                        }
                    }

                    Context 'EXAMPLE\TEST2' {
                        BeforeAll {
                            $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST2' }
                            [xml]$XMLDocument = Serialize-GPPItemGroupMember -InputObject $Item
                        }
                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocument | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                            }
                            It 'XML Properties element exists' {
                                $XMLDocument.Member | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                            }
                        }

                        Context 'Content' {
                            It 'Member name is correct' {
                                $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                            }
                            It 'Action is correct' {
                                $XMLDocument.Member.action | Should -BeExactly 'REMOVE'
                            }
                        }
                    }

                    Context 'EXAMPLE\TEST3' {
                        BeforeAll {
                            $Item = $Members | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST3' }
                            [xml]$XMLDocument = Serialize-GPPItemGroupMember -InputObject $Item
                        }
                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocument | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                            }
                            It 'XML Properties element exists' {
                                $XMLDocument.Member | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                            }
                        }

                        Context 'Content' {
                            It 'Member name is correct' {
                                $XMLDocument.Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                            }
                            It 'Action is correct' {
                                $XMLDocument.Member.action | Should -BeExactly 'REMOVE'
                            }
                            It 'SID is correct' {
                                $XMLDocument.Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                            }
                        }
                    }
                }
            }
        }

        Describe 'UNIT: Serialize-GPPItemPropertiesGroup' {
            BeforeAll {
                Mock Serialize-GPPItemGroupMember {
                    $Path = switch ($InputObject.name) {
                        'EXAMPLE\Administrator' {
                            Join-Path -Path $DataSourcePath -ChildPath 'GPPItemGroupMember_EXAMPLE_Administrator.xml'
                        }
                        'EXAMPLE\TEST1' {
                            Join-Path -Path $DataSourcePath -ChildPath 'GPPItemGroupMember_EXAMPLE_TEST1.xml'
                        }
                        'EXAMPLE\TEST2' {
                            Join-Path -Path $DataSourcePath -ChildPath 'GPPItemGroupMember_EXAMPLE_TEST2.xml'
                        }
                        'EXAMPLE\TEST3' {
                            Join-Path -Path $DataSourcePath -ChildPath 'GPPItemGroupMember_EXAMPLE_TEST3.xml'
                        }
                    }

                    [xml]$Content = Get-Content -Path $Path
                    $Content
                }

                Mock Serialize-GPPItem {
                    $Path = switch ($InputObject.groupName) {
                        'EXAMPLE\TestGroup1' {
                            Join-Path -Path $DataSourcePath -ChildPath 'Serialize-GPPItemPropertiesGroup_Serialize-GPPItem_EXAMPLE_TestGroup1.xml'
                        }
                        'Administrators (built-in)' {
                            Join-Path -Path $DataSourcePath -ChildPath 'Serialize-GPPItemPropertiesGroup_Serialize-GPPItem_Administrators (built-in).xml'
                        }
                        'EXAMPLE\TestGroup3' {
                            Join-Path -Path $DataSourcePath -ChildPath 'Serialize-GPPItemPropertiesGroup_Serialize-GPPItem_EXAMPLE_TestGroup3.xml'
                        }
                        'EXAMPLE\TestGroup4' {
                            Join-Path -Path $DataSourcePath -ChildPath 'Serialize-GPPItemPropertiesGroup_Serialize-GPPItem_EXAMPLE_TestGroup4.xml'
                        }
                        'EXAMPLE\TestGroup5' {
                            Join-Path -Path $DataSourcePath -ChildPath 'Serialize-GPPItemPropertiesGroup_Serialize-GPPItem_EXAMPLE_TestGroup5.xml'
                        }
                        'LocalGroup1' {
                            Join-Path -Path $DataSourcePath -ChildPath 'Serialize-GPPItemPropertiesGroup_Serialize-GPPItem_LocalGroup1.xml'

                        }
                        'LocalGroup3' {
                            Join-Path -Path $DataSourcePath -ChildPath 'Serialize-GPPItemPropertiesGroup_Serialize-GPPItem_LocalGroup3.xml'

                        }
                        'Backup Operators (built-in)' {
                            Join-Path -Path $DataSourcePath -ChildPath 'Serialize-GPPItemPropertiesGroup_Serialize-GPPItem_Backup Operators (built-in).xml'

                        }
                    }

                    [xml]$Content = Get-Content -Path $Path
                    $Content
                }
            }

            Context 'Groups-GroupsOnly-Set-<GPPSectionID>' -Foreach @(
                @{
                    GPPSectionID = 1
                }
                @{
                    GPPSectionID = 2
                }
            ) {
                BeforeAll {
                    $GPPSection = (Get-Variable -Name ('GPPSectionSet{0}' -f $GPPSectionID)).Value
                }

                Context 'EXAMPLE\TestGroup1' {
                    BeforeAll {
                        $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '798C5D07-11C3-45C0-B767-124DF9A369A6' }).Properties
                        [xml]$XMLDocument = Serialize-GPPItemPropertiesGroup -InputObject $Item
                    }
                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                        It 'XML Properties element exists' {
                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Properties element has correct number of properties' {
                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                        }
                    }

                    Context 'Content' {
                        It 'Group name is correct' {
                            $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup1'
                        }
                        It 'Group SID is absent' {
                            $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                        }
                        It 'Action is correct' {
                            $XMLDocument.Properties.action | Should -BeExactly 'U'
                        }
                        It 'Description is correct' {
                            $XMLDocument.Properties.description | Should -BeExactly ''
                        }
                        It 'New group name is correct' {
                            $XMLDocument.Properties.newName | Should -BeExactly ''
                        }
                        It 'deleteAllGroups set to 0' {
                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                        }
                        It 'deleteAllUsers set to 0' {
                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                        }
                        It 'removeAccounts set to 0' {
                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                        }
                    }
                }

                Context 'Administrators (built-in)' {
                    BeforeAll {
                        $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '6F82151C-1B8A-4809-ABDD-1EA08F91C923' }).Properties
                        [xml]$XMLDocument = Serialize-GPPItemPropertiesGroup -InputObject $Item
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                        It 'XML Properties element exists' {
                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Properties element has correct number of properties' {
                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 8
                        }
                    }

                    Context 'Content' {
                        It 'Group name is correct' {
                            $XMLDocument.Properties.groupName | Should -BeExactly 'Administrators (built-in)'
                        }
                        It 'Group SID is correct' {
                            $XMLDocument.Properties.groupSid | Should -BeExactly 'S-1-5-32-544'
                        }
                        It 'Action is correct' {
                            $XMLDocument.Properties.action | Should -BeExactly 'U'
                        }
                        It 'Description is correct' {
                            $XMLDocument.Properties.description | Should -BeExactly ''
                        }
                        It 'New group name is correct' {
                            $XMLDocument.Properties.newName | Should -BeExactly ''
                        }
                        It 'deleteAllGroups set to 0' {
                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                        }
                        It 'deleteAllUsers set to 0' {
                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                        }
                        It 'removeAccounts set to 0' {
                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                        }
                    }
                }

                Context 'EXAMPLE\TestGroup3' {
                    BeforeAll {
                        $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '5BFED1D1-5C42-4504-84E7-E62FA36A6E69' }).Properties
                        [xml]$XMLDocument = Serialize-GPPItemPropertiesGroup -InputObject $Item
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                        It 'XML Properties element exists' {
                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Properties element has correct number of properties' {
                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                        }
                    }

                    Context 'Content' {
                        It 'Group name is correct' {
                            $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup3'
                        }
                        It 'Group SID is absent' {
                            $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                        }
                        It 'Action is correct' {
                            $XMLDocument.Properties.action | Should -BeExactly 'D'
                        }
                        It 'Description is correct' {
                            $XMLDocument.Properties.description | Should -BeExactly ''
                        }
                        It 'New group name is correct' {
                            $XMLDocument.Properties.newName | Should -BeExactly ''
                        }
                        It 'deleteAllGroups set to 0' {
                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                        }
                        It 'deleteAllUsers set to 0' {
                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                        }
                        It 'removeAccounts set to 0' {
                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                        }
                    }
                }

                Context 'EXAMPLE\TestGroup4' {
                    BeforeAll {
                        $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'ED220833-3027-4071-80BE-0D0B50B781B3' }).Properties
                        [xml]$XMLDocument = Serialize-GPPItemPropertiesGroup -InputObject $Item
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                        It 'XML Properties element exists' {
                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Properties element has correct number of properties' {
                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                        }
                    }

                    Context 'Content' {
                        It 'Group name is correct' {
                            $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup4'
                        }
                        It 'Group SID is absent' {
                            $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                        }
                        It 'Action is correct' {
                            $XMLDocument.Properties.action | Should -BeExactly 'C'
                        }
                        It 'Description is correct' {
                            $XMLDocument.Properties.description | Should -BeExactly ''
                        }
                        It 'New group name is correct' {
                            $XMLDocument.Properties.newName | Should -BeExactly ''
                        }
                        It 'deleteAllGroups set to 0' {
                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                        }
                        It 'deleteAllUsers set to 0' {
                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                        }
                        It 'removeAccounts set to 0' {
                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                        }
                    }
                }

                Context 'EXAMPLE\TestGroup5' {
                    BeforeAll {
                        $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '4046D23B-4875-4E82-96B3-9920E9A9BDFF' }).Properties
                        [xml]$XMLDocument = Serialize-GPPItemPropertiesGroup -InputObject $Item
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                        It 'XML Properties element exists' {
                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Properties element has correct number of properties' {
                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                        }
                    }

                    Context 'Content' {
                        It 'Group name is correct' {
                            $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup5'
                        }
                        It 'Group SID is absent' {
                            $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                        }
                        It 'Action is correct' {
                            $XMLDocument.Properties.action | Should -BeExactly 'R'
                        }
                        It 'Description is correct' {
                            $XMLDocument.Properties.description | Should -BeExactly ''
                        }
                        It 'New group name is correct' {
                            $XMLDocument.Properties.newName | Should -BeExactly ''
                        }
                        It 'deleteAllGroups set to 0' {
                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                        }
                        It 'deleteAllUsers set to 0' {
                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                        }
                        It 'removeAccounts set to 0' {
                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                        }
                    }
                }

                Context 'LocalGroup1' {
                    BeforeAll {
                        $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '483E7907-F4DF-439C-946D-91D2FE3AFC20' }).Properties
                        [xml]$XMLDocument = Serialize-GPPItemPropertiesGroup -InputObject $Item
                    }
                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                        It 'XML Properties element exists' {
                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Properties element has correct number of properties' {
                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                        }
                    }

                    Context 'Content' {
                        It 'Group name is correct' {
                            $XMLDocument.Properties.groupName | Should -BeExactly 'LocalGroup1'
                        }
                        It 'Group SID is absent' {
                            $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                        }
                        It 'Action is correct' {
                            $XMLDocument.Properties.action | Should -BeExactly 'U'
                        }
                        It 'Description is correct' {
                            $XMLDocument.Properties.description | Should -BeExactly 'My Awesome Description'
                        }
                        It 'New group name is correct' {
                            $XMLDocument.Properties.newName | Should -BeExactly 'LocalGroup2'
                        }
                        It 'deleteAllGroups set to 0' {
                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                        }
                        It 'deleteAllUsers set to 0' {
                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                        }
                        It 'removeAccounts set to 0' {
                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                        }
                    }
                }

                Context 'LocalGroup3' {
                    BeforeAll {
                        $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '52D0DA5A-91FD-472B-83C4-E70EC7CD5ACB' }).Properties
                        [xml]$XMLDocument = Serialize-GPPItemPropertiesGroup -InputObject $Item
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                        It 'XML Properties element exists' {
                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Properties element has correct number of properties' {
                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 8
                        }
                    }

                    Context 'Content' {
                        Context 'Common attributes' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'LocalGroup3'
                            }
                            It 'Group SID is absent' {
                                $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'C'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly ''
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly ''
                            }
                            It 'deleteAllGroups set to 0' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                            }
                            It 'deleteAllUsers set to 0' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }

                        Context 'Members' {
                            Context 'Structure' {
                                It 'Group members are present' {
                                    $XMLDocument.Properties.Members | Should -Not -BeNullOrEmpty
                                }
                                It 'Member property is present' {
                                    $XMLDocument.Properties.Members.Member | Should -Not -BeNullOrEmpty
                                }
                                It 'The number of members is correct' {
                                    $XMLDocument.Properties.Members.Member.Count | Should -Be 4
                                }
                            }

                            Context 'EXAMPLE\Administrator' {
                                BeforeAll {
                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\Administrator' }
                                }
                                Context 'Structure' {
                                    It 'XML element exists' {
                                        $Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML element has a correct number of properties' {
                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                    }
                                }

                                Context 'Content' {
                                    It 'Member name is correct' {
                                        $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                                    }
                                    It 'Action is correct' {
                                        $Member.action | Should -BeExactly 'ADD'
                                    }
                                }
                            }

                            Context 'EXAMPLE\TEST1' {
                                BeforeAll {
                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST1' }
                                }
                                Context 'Structure' {
                                    It 'XML element exists' {
                                        $Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML element has a correct number of properties' {
                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                    }
                                }

                                Context 'Content' {
                                    It 'Member name is correct' {
                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                                    }
                                    It 'SID is correct' {
                                        $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                                    }
                                    It 'Action is correct' {
                                        $Member.action | Should -BeExactly 'ADD'
                                    }
                                }
                            }

                            Context 'EXAMPLE\TEST2' {
                                BeforeAll {
                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST2' }
                                }
                                Context 'Structure' {
                                    It 'XML element exists' {
                                        $Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML element has a correct number of properties' {
                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                    }
                                }

                                Context 'Content' {
                                    It 'Member name is correct' {
                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                                    }
                                    It 'Action is correct' {
                                        $Member.action | Should -BeExactly 'REMOVE'
                                    }
                                }
                            }

                            Context 'EXAMPLE\TEST3' {
                                BeforeAll {
                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST3' }
                                }
                                Context 'Structure' {
                                    It 'XML element exists' {
                                        $Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML element has a correct number of properties' {
                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                    }
                                }

                                Context 'Content' {
                                    It 'Member name is correct' {
                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                                    }
                                    It 'SID is correct' {
                                        $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                                    }
                                    It 'Action is correct' {
                                        $Member.action | Should -BeExactly 'REMOVE'
                                    }
                                }
                            }
                        }
                    }
                }

                Context 'Backup Operators (built-in)' {
                    BeforeAll {
                        $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '880FFE86-78C7-4E85-AFDE-608C24977161' }).Properties
                        [xml]$XMLDocument = Serialize-GPPItemPropertiesGroup -InputObject $Item
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                        It 'XML Properties element exists' {
                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Properties element has correct number of properties' {
                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                        }
                    }

                    Context 'Content' {
                        Context 'Common attributes' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'Backup Operators (built-in)'
                            }
                            It 'Group SID is correct' {
                                $XMLDocument.Properties.groupSid | Should -BeExactly 'S-1-5-32-551'
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'U'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly ''
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly ''
                            }
                            It 'deleteAllGroups set to 1' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '1'
                            }
                            It 'deleteAllUsers set to 1' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '1'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }

                        Context 'Members' {
                            Context 'Structure' {
                                It 'Group members are present' {
                                    $XMLDocument.Properties.Members | Should -Not -BeNullOrEmpty
                                }
                                It 'Member property is present' {
                                    $XMLDocument.Properties.Members.Member | Should -Not -BeNullOrEmpty
                                }
                                It 'The number of members is correct' {
                                    $XMLDocument.Properties.Members.Member.Count | Should -Be 4
                                }
                            }

                            Context 'EXAMPLE\Administrator' {
                                BeforeAll {
                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\Administrator' }
                                }
                                Context 'Structure' {
                                    It 'XML element exists' {
                                        $Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML element has a correct number of properties' {
                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                    }
                                }

                                Context 'Content' {
                                    It 'Member name is correct' {
                                        $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                                    }
                                    It 'Action is correct' {
                                        $Member.action | Should -BeExactly 'ADD'
                                    }
                                }
                            }

                            Context 'EXAMPLE\TEST1' {
                                BeforeAll {
                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST1' }
                                }
                                Context 'Structure' {
                                    It 'XML element exists' {
                                        $Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML element has a correct number of properties' {
                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                    }
                                }

                                Context 'Content' {
                                    It 'Member name is correct' {
                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                                    }
                                    It 'SID is correct' {
                                        $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                                    }
                                    It 'Action is correct' {
                                        $Member.action | Should -BeExactly 'ADD'
                                    }
                                }
                            }

                            Context 'EXAMPLE\TEST2' {
                                BeforeAll {
                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST2' }
                                }
                                Context 'Structure' {
                                    It 'XML element exists' {
                                        $Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML element has a correct number of properties' {
                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                    }
                                }

                                Context 'Content' {
                                    It 'Member name is correct' {
                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                                    }
                                    It 'Action is correct' {
                                        $Member.action | Should -BeExactly 'REMOVE'
                                    }
                                }
                            }

                            Context 'EXAMPLE\TEST3' {
                                BeforeAll {
                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST3' }
                                }
                                Context 'Structure' {
                                    It 'XML element exists' {
                                        $Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML element has a correct number of properties' {
                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                    }
                                }

                                Context 'Content' {
                                    It 'Member name is correct' {
                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                                    }
                                    It 'SID is correct' {
                                        $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                                    }
                                    It 'Action is correct' {
                                        $Member.action | Should -BeExactly 'REMOVE'
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Describe 'ACCEPTANCE: Serialize-GPPItemPropertiesGroup' {
            Context 'Groups-GroupsOnly-Set-<GPPSectionID>' -Foreach @(
                @{
                    GPPSectionID = 1
                }
                @{
                    GPPSectionID = 2
                }
            ) {
                BeforeAll {
                    $GPPSection = (Get-Variable -Name ('GPPSectionSet{0}' -f $GPPSectionID)).Value
                }

                Context 'EXAMPLE\TestGroup1' {
                    BeforeAll {
                        $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '798C5D07-11C3-45C0-B767-124DF9A369A6' }).Properties
                        [xml]$XMLDocument = Serialize-GPPItemPropertiesGroup -InputObject $Item
                    }
                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                        It 'XML Properties element exists' {
                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Properties element has correct number of properties' {
                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                        }
                    }

                    Context 'Content' {
                        It 'Group name is correct' {
                            $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup1'
                        }
                        It 'Group SID is absent' {
                            $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                        }
                        It 'Action is correct' {
                            $XMLDocument.Properties.action | Should -BeExactly 'U'
                        }
                        It 'Description is correct' {
                            $XMLDocument.Properties.description | Should -BeExactly ''
                        }
                        It 'New group name is correct' {
                            $XMLDocument.Properties.newName | Should -BeExactly ''
                        }
                        It 'deleteAllGroups set to 0' {
                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                        }
                        It 'deleteAllUsers set to 0' {
                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                        }
                        It 'removeAccounts set to 0' {
                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                        }
                    }
                }

                Context 'Administrators (built-in)' {
                    BeforeAll {
                        $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '6F82151C-1B8A-4809-ABDD-1EA08F91C923' }).Properties
                        [xml]$XMLDocument = Serialize-GPPItemPropertiesGroup -InputObject $Item
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                        It 'XML Properties element exists' {
                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Properties element has correct number of properties' {
                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 8
                        }
                    }

                    Context 'Content' {
                        It 'Group name is correct' {
                            $XMLDocument.Properties.groupName | Should -BeExactly 'Administrators (built-in)'
                        }
                        It 'Group SID is correct' {
                            $XMLDocument.Properties.groupSid | Should -BeExactly 'S-1-5-32-544'
                        }
                        It 'Action is correct' {
                            $XMLDocument.Properties.action | Should -BeExactly 'U'
                        }
                        It 'Description is correct' {
                            $XMLDocument.Properties.description | Should -BeExactly ''
                        }
                        It 'New group name is correct' {
                            $XMLDocument.Properties.newName | Should -BeExactly ''
                        }
                        It 'deleteAllGroups set to 0' {
                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                        }
                        It 'deleteAllUsers set to 0' {
                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                        }
                        It 'removeAccounts set to 0' {
                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                        }
                    }
                }

                Context 'EXAMPLE\TestGroup3' {
                    BeforeAll {
                        $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '5BFED1D1-5C42-4504-84E7-E62FA36A6E69' }).Properties
                        [xml]$XMLDocument = Serialize-GPPItemPropertiesGroup -InputObject $Item
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                        It 'XML Properties element exists' {
                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Properties element has correct number of properties' {
                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                        }
                    }

                    Context 'Content' {
                        It 'Group name is correct' {
                            $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup3'
                        }
                        It 'Group SID is absent' {
                            $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                        }
                        It 'Action is correct' {
                            $XMLDocument.Properties.action | Should -BeExactly 'D'
                        }
                        It 'Description is correct' {
                            $XMLDocument.Properties.description | Should -BeExactly ''
                        }
                        It 'New group name is correct' {
                            $XMLDocument.Properties.newName | Should -BeExactly ''
                        }
                        It 'deleteAllGroups set to 0' {
                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                        }
                        It 'deleteAllUsers set to 0' {
                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                        }
                        It 'removeAccounts set to 0' {
                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                        }
                    }
                }

                Context 'EXAMPLE\TestGroup4' {
                    BeforeAll {
                        $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'ED220833-3027-4071-80BE-0D0B50B781B3' }).Properties
                        [xml]$XMLDocument = Serialize-GPPItemPropertiesGroup -InputObject $Item
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                        It 'XML Properties element exists' {
                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Properties element has correct number of properties' {
                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                        }
                    }

                    Context 'Content' {
                        It 'Group name is correct' {
                            $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup4'
                        }
                        It 'Group SID is absent' {
                            $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                        }
                        It 'Action is correct' {
                            $XMLDocument.Properties.action | Should -BeExactly 'C'
                        }
                        It 'Description is correct' {
                            $XMLDocument.Properties.description | Should -BeExactly ''
                        }
                        It 'New group name is correct' {
                            $XMLDocument.Properties.newName | Should -BeExactly ''
                        }
                        It 'deleteAllGroups set to 0' {
                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                        }
                        It 'deleteAllUsers set to 0' {
                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                        }
                        It 'removeAccounts set to 0' {
                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                        }
                    }
                }

                Context 'EXAMPLE\TestGroup5' {
                    BeforeAll {
                        $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '4046D23B-4875-4E82-96B3-9920E9A9BDFF' }).Properties
                        [xml]$XMLDocument = Serialize-GPPItemPropertiesGroup -InputObject $Item
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                        It 'XML Properties element exists' {
                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Properties element has correct number of properties' {
                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                        }
                    }

                    Context 'Content' {
                        It 'Group name is correct' {
                            $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup5'
                        }
                        It 'Group SID is absent' {
                            $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                        }
                        It 'Action is correct' {
                            $XMLDocument.Properties.action | Should -BeExactly 'R'
                        }
                        It 'Description is correct' {
                            $XMLDocument.Properties.description | Should -BeExactly ''
                        }
                        It 'New group name is correct' {
                            $XMLDocument.Properties.newName | Should -BeExactly ''
                        }
                        It 'deleteAllGroups set to 0' {
                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                        }
                        It 'deleteAllUsers set to 0' {
                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                        }
                        It 'removeAccounts set to 0' {
                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                        }
                    }
                }

                Context 'LocalGroup1' {
                    BeforeAll {
                        $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '483E7907-F4DF-439C-946D-91D2FE3AFC20' }).Properties
                        [xml]$XMLDocument = Serialize-GPPItemPropertiesGroup -InputObject $Item
                    }
                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                        It 'XML Properties element exists' {
                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Properties element has correct number of properties' {
                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                        }
                    }

                    Context 'Content' {
                        It 'Group name is correct' {
                            $XMLDocument.Properties.groupName | Should -BeExactly 'LocalGroup1'
                        }
                        It 'Group SID is absent' {
                            $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                        }
                        It 'Action is correct' {
                            $XMLDocument.Properties.action | Should -BeExactly 'U'
                        }
                        It 'Description is correct' {
                            $XMLDocument.Properties.description | Should -BeExactly 'My Awesome Description'
                        }
                        It 'New group name is correct' {
                            $XMLDocument.Properties.newName | Should -BeExactly 'LocalGroup2'
                        }
                        It 'deleteAllGroups set to 0' {
                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                        }
                        It 'deleteAllUsers set to 0' {
                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                        }
                        It 'removeAccounts set to 0' {
                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                        }
                    }
                }

                Context 'LocalGroup3' {
                    BeforeAll {
                        $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '52D0DA5A-91FD-472B-83C4-E70EC7CD5ACB' }).Properties
                        [xml]$XMLDocument = Serialize-GPPItemPropertiesGroup -InputObject $Item
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                        It 'XML Properties element exists' {
                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Properties element has correct number of properties' {
                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 8
                        }
                    }

                    Context 'Content' {
                        Context 'Common attributes' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'LocalGroup3'
                            }
                            It 'Group SID is absent' {
                                $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'C'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly ''
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly ''
                            }
                            It 'deleteAllGroups set to 0' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                            }
                            It 'deleteAllUsers set to 0' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }

                        Context 'Members' {
                            Context 'Structure' {
                                It 'Group members are present' {
                                    $XMLDocument.Properties.Members | Should -Not -BeNullOrEmpty
                                }
                                It 'Member property is present' {
                                    $XMLDocument.Properties.Members.Member | Should -Not -BeNullOrEmpty
                                }
                                It 'The number of members is correct' {
                                    $XMLDocument.Properties.Members.Member.Count | Should -Be 4
                                }
                            }

                            Context 'EXAMPLE\Administrator' {
                                BeforeAll {
                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\Administrator' }
                                }
                                Context 'Structure' {
                                    It 'XML element exists' {
                                        $Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML element has a correct number of properties' {
                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                    }
                                }

                                Context 'Content' {
                                    It 'Member name is correct' {
                                        $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                                    }
                                    It 'Action is correct' {
                                        $Member.action | Should -BeExactly 'ADD'
                                    }
                                }
                            }

                            Context 'EXAMPLE\TEST1' {
                                BeforeAll {
                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST1' }
                                }
                                Context 'Structure' {
                                    It 'XML element exists' {
                                        $Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML element has a correct number of properties' {
                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                    }
                                }

                                Context 'Content' {
                                    It 'Member name is correct' {
                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                                    }
                                    It 'SID is correct' {
                                        $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                                    }
                                    It 'Action is correct' {
                                        $Member.action | Should -BeExactly 'ADD'
                                    }
                                }
                            }

                            Context 'EXAMPLE\TEST2' {
                                BeforeAll {
                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST2' }
                                }
                                Context 'Structure' {
                                    It 'XML element exists' {
                                        $Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML element has a correct number of properties' {
                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                    }
                                }

                                Context 'Content' {
                                    It 'Member name is correct' {
                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                                    }
                                    It 'Action is correct' {
                                        $Member.action | Should -BeExactly 'REMOVE'
                                    }
                                }
                            }

                            Context 'EXAMPLE\TEST3' {
                                BeforeAll {
                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST3' }
                                }
                                Context 'Structure' {
                                    It 'XML element exists' {
                                        $Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML element has a correct number of properties' {
                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                    }
                                }

                                Context 'Content' {
                                    It 'Member name is correct' {
                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                                    }
                                    It 'SID is correct' {
                                        $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                                    }
                                    It 'Action is correct' {
                                        $Member.action | Should -BeExactly 'REMOVE'
                                    }
                                }
                            }
                        }
                    }
                }

                Context 'Backup Operators (built-in)' {
                    BeforeAll {
                        $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '880FFE86-78C7-4E85-AFDE-608C24977161' }).Properties
                        [xml]$XMLDocument = Serialize-GPPItemPropertiesGroup -InputObject $Item
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                        It 'XML Properties element exists' {
                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                        }
                        It 'XML Properties element has correct number of properties' {
                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                        }
                    }

                    Context 'Content' {
                        Context 'Common attributes' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'Backup Operators (built-in)'
                            }
                            It 'Group SID is correct' {
                                $XMLDocument.Properties.groupSid | Should -BeExactly 'S-1-5-32-551'
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'U'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly ''
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly ''
                            }
                            It 'deleteAllGroups set to 1' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '1'
                            }
                            It 'deleteAllUsers set to 1' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '1'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }

                        Context 'Members' {
                            Context 'Structure' {
                                It 'Group members are present' {
                                    $XMLDocument.Properties.Members | Should -Not -BeNullOrEmpty
                                }
                                It 'Member property is present' {
                                    $XMLDocument.Properties.Members.Member | Should -Not -BeNullOrEmpty
                                }
                                It 'The number of members is correct' {
                                    $XMLDocument.Properties.Members.Member.Count | Should -Be 4
                                }
                            }

                            Context 'EXAMPLE\Administrator' {
                                BeforeAll {
                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\Administrator' }
                                }
                                Context 'Structure' {
                                    It 'XML element exists' {
                                        $Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML element has a correct number of properties' {
                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                    }
                                }

                                Context 'Content' {
                                    It 'Member name is correct' {
                                        $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                                    }
                                    It 'Action is correct' {
                                        $Member.action | Should -BeExactly 'ADD'
                                    }
                                }
                            }

                            Context 'EXAMPLE\TEST1' {
                                BeforeAll {
                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST1' }
                                }
                                Context 'Structure' {
                                    It 'XML element exists' {
                                        $Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML element has a correct number of properties' {
                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                    }
                                }

                                Context 'Content' {
                                    It 'Member name is correct' {
                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                                    }
                                    It 'SID is correct' {
                                        $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                                    }
                                    It 'Action is correct' {
                                        $Member.action | Should -BeExactly 'ADD'
                                    }
                                }
                            }

                            Context 'EXAMPLE\TEST2' {
                                BeforeAll {
                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST2' }
                                }
                                Context 'Structure' {
                                    It 'XML element exists' {
                                        $Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML element has a correct number of properties' {
                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                    }
                                }

                                Context 'Content' {
                                    It 'Member name is correct' {
                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                                    }
                                    It 'Action is correct' {
                                        $Member.action | Should -BeExactly 'REMOVE'
                                    }
                                }
                            }

                            Context 'EXAMPLE\TEST3' {
                                BeforeAll {
                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST3' }
                                }
                                Context 'Structure' {
                                    It 'XML element exists' {
                                        $Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML element has a correct number of properties' {
                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                    }
                                }

                                Context 'Content' {
                                    It 'Member name is correct' {
                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                                    }
                                    It 'SID is correct' {
                                        $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                                    }
                                    It 'Action is correct' {
                                        $Member.action | Should -BeExactly 'REMOVE'
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        <# Describe 'UNIT: Serialize-GPPItemGroup' {
            BeforeAll {
                Mock Serialize-GPPItem {

                }
                Mock Serialize-GPPItemPropertiesGroup {

                }
            }
        } #>

        Describe 'ACCEPTANCE: Serialize-GPPItemGroup' {
            # $InputObject = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
            # [GPPSection]$InputObject
            # Item in $InputObject.Members
            # Serialize-GPPItemGroup -InputObject $Item

            Context 'Groups-GroupsOnly-Set-<GPPSectionID>' -Foreach @(
                @{
                    GPPSectionID = 1
                }
                @{
                    GPPSectionID = 2
                }
            ) {
                BeforeAll {
                    $GPPSection = (Get-Variable -Name ('GPPSectionSet{0}' -f $GPPSectionID)).Value
                }

                Context 'EXAMPLE\TestGroup1' {
                    BeforeAll {
                        $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '798C5D07-11C3-45C0-B767-124DF9A369A6' }
                        [xml]$XMLDocumentParent = Serialize-GPPItemGroup -InputObject $Item
                        $XMLDocument = $XMLDocumentParent.Group
                    }

                    Context 'Structure - parent' {
                        It 'XML document exists' {
                            $XMLDocumentParent | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocumentParent | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                        }
                    }

                    Context 'Attributes' {
                        It 'Group clsid attribute is correct' {
                            $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                        }
                        It 'Group uid is correct ' {
                            $XMLDocument.uid | Should -BeExactly '{798c5d07-11c3-45c0-b767-124df9a369a6}'
                        }
                        It 'Group name is correct' {
                            $XMLDocument.name | Should -BeExactly 'EXAMPLE\TestGroup1'
                        }
                        It 'Group has changed date/time' {
                            $XMLDocument.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'Group is enabled' {
                            $XMLDocument.disabled | Should -BeExactly '0'
                        }
                        It 'Group has a correct image' {
                            $XMLDocument.image | Should -BeExactly '2'
                        }
                        It 'Group bypasses errors' {
                            $XMLDocument.bypassErrors | Should -BeExactly '1'
                        }
                        It 'Group has removePolicy set to 0' {
                            $XMLDocument.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'Propeties' {
                        Context 'Structure' {
                            It 'XML Properties element exists' {
                                $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                            }
                        }

                        Context 'Content' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup1'
                            }
                            It 'Group SID is absent' {
                                $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'U'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly ''
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly ''
                            }
                            It 'deleteAllGroups set to 0' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                            }
                            It 'deleteAllUsers set to 0' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }
                    }
                }

                Context 'Administrators (built-in)' {
                    BeforeAll {
                        $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '6F82151C-1B8A-4809-ABDD-1EA08F91C923' }
                        [xml]$XMLDocumentParent = Serialize-GPPItemGroup -InputObject $Item
                        $XMLDocument = $XMLDocumentParent.Group
                    }

                    Context 'Structure - parent' {
                        It 'XML document exists' {
                            $XMLDocumentParent | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocumentParent | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                        }
                    }

                    Context 'Attributes' {
                        It 'Group clsid attribute is correct' {
                            $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                        }
                        It 'Group uid is correct ' {
                            $XMLDocument.uid | Should -BeExactly '{6f82151c-1b8a-4809-abdd-1ea08f91c923}'
                        }
                        It 'Group name is correct' {
                            $XMLDocument.name | Should -BeExactly 'Administrators (built-in)'
                        }
                        It 'Group has changed date/time' {
                            $XMLDocument.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'Group is enabled' {
                            $XMLDocument.disabled | Should -BeExactly '0'
                        }
                        It 'Group has a correct image' {
                            $XMLDocument.image | Should -BeExactly '2'
                        }
                        It 'Group bypasses errors' {
                            $XMLDocument.bypassErrors | Should -BeExactly '1'
                        }
                        It 'Group has removePolicy set to 0' {
                            $XMLDocument.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'Propeties' {
                        Context 'Structure' {
                            It 'XML Properties element exists' {
                                $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 8
                            }
                        }

                        Context 'Content' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'Administrators (built-in)'
                            }
                            It 'Group SID is correct' {
                                $XMLDocument.Properties.groupSid | Should -BeExactly 'S-1-5-32-544'
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'U'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly ''
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly ''
                            }
                            It 'deleteAllGroups set to 0' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                            }
                            It 'deleteAllUsers set to 0' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }
                    }
                }

                Context 'EXAMPLE\TestGroup3' {
                    BeforeAll {
                        $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '5BFED1D1-5C42-4504-84E7-E62FA36A6E69' }
                        [xml]$XMLDocumentParent = Serialize-GPPItemGroup -InputObject $Item
                        $XMLDocument = $XMLDocumentParent.Group
                    }

                    Context 'Structure - parent' {
                        It 'XML document exists' {
                            $XMLDocumentParent | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocumentParent | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                        }
                    }

                    Context 'Attributes' {
                        It 'Group clsid attribute is correct' {
                            $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                        }
                        It 'Group uid is correct ' {
                            $XMLDocument.uid | Should -BeExactly '{5bfed1d1-5c42-4504-84e7-e62fa36a6e69}'
                        }
                        It 'Group name is correct' {
                            $XMLDocument.name | Should -BeExactly 'EXAMPLE\TestGroup3'
                        }
                        It 'Group has changed date/time' {
                            $XMLDocument.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'Group is enabled' {
                            $XMLDocument.disabled | Should -BeExactly '0'
                        }
                        It 'Group has a correct image' {
                            $XMLDocument.image | Should -BeExactly '3'
                        }
                        It 'Group bypasses errors' {
                            $XMLDocument.bypassErrors | Should -BeExactly '1'
                        }
                        It 'Group has removePolicy set to 0' {
                            $XMLDocument.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'Propeties' {
                        Context 'Structure' {
                            It 'XML Properties element exists' {
                                $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                            }
                        }

                        Context 'Content' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup3'
                            }
                            It 'Group SID is absent' {
                                $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'D'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly ''
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly ''
                            }
                            It 'deleteAllGroups set to 0' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                            }
                            It 'deleteAllUsers set to 0' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }
                    }
                }

                Context 'EXAMPLE\TestGroup4' {
                    BeforeAll {
                        $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'ED220833-3027-4071-80BE-0D0B50B781B3' }
                        [xml]$XMLDocumentParent = Serialize-GPPItemGroup -InputObject $Item
                        $XMLDocument = $XMLDocumentParent.Group
                    }

                    Context 'Structure - parent' {
                        It 'XML document exists' {
                            $XMLDocumentParent | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocumentParent | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                        }
                    }

                    Context 'Attributes' {
                        It 'Group clsid attribute is correct' {
                            $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                        }
                        It 'Group uid is correct ' {
                            $XMLDocument.uid | Should -BeExactly '{ed220833-3027-4071-80be-0d0b50b781b3}'
                        }
                        It 'Group name is correct' {
                            $XMLDocument.name | Should -BeExactly 'EXAMPLE\TestGroup4'
                        }
                        It 'Group has changed date/time' {
                            $XMLDocument.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'Group is enabled' {
                            $XMLDocument.disabled | Should -BeExactly '0'
                        }
                        It 'Group has a correct image' {
                            $XMLDocument.image | Should -BeExactly '0'
                        }
                        It 'Group bypasses errors' {
                            $XMLDocument.bypassErrors | Should -BeExactly '1'
                        }
                        It 'Group has removePolicy set to 0' {
                            $XMLDocument.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'Propeties' {
                        Context 'Structure' {
                            It 'XML Properties element exists' {
                                $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                            }
                        }

                        Context 'Content' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup4'
                            }
                            It 'Group SID is absent' {
                                $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'C'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly ''
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly ''
                            }
                            It 'deleteAllGroups set to 0' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                            }
                            It 'deleteAllUsers set to 0' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }
                    }
                }

                Context 'EXAMPLE\TestGroup5' {
                    BeforeAll {
                        $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '4046D23B-4875-4E82-96B3-9920E9A9BDFF' }
                        [xml]$XMLDocumentParent = Serialize-GPPItemGroup -InputObject $Item
                        $XMLDocument = $XMLDocumentParent.Group
                    }

                    Context 'Structure - parent' {
                        It 'XML document exists' {
                            $XMLDocumentParent | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocumentParent | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                        }
                    }

                    Context 'Attributes' {
                        It 'Group clsid attribute is correct' {
                            $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                        }
                        It 'Group uid is correct ' {
                            $XMLDocument.uid | Should -BeExactly '{4046d23b-4875-4e82-96b3-9920e9a9bdff}'
                        }
                        It 'Group name is correct' {
                            $XMLDocument.name | Should -BeExactly 'EXAMPLE\TestGroup5'
                        }
                        It 'Group has changed date/time' {
                            $XMLDocument.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'Group is enabled' {
                            $XMLDocument.disabled | Should -BeExactly '0'
                        }
                        It 'Group has a correct image' {
                            $XMLDocument.image | Should -BeExactly '1'
                        }
                        It 'Group bypasses errors' {
                            $XMLDocument.bypassErrors | Should -BeExactly '1'
                        }
                        It 'Group has removePolicy set to 0' {
                            $XMLDocument.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'Propeties' {
                        Context 'Structure' {
                            It 'XML Properties element exists' {
                                $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                            }
                        }

                        Context 'Content' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup5'
                            }
                            It 'Group SID is absent' {
                                $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'R'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly ''
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly ''
                            }
                            It 'deleteAllGroups set to 0' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                            }
                            It 'deleteAllUsers set to 0' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }
                    }
                }

                Context 'LocalGroup1' {
                    BeforeAll {
                        $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '483E7907-F4DF-439C-946D-91D2FE3AFC20' }
                        [xml]$XMLDocumentParent = Serialize-GPPItemGroup -InputObject $Item
                        $XMLDocument = $XMLDocumentParent.Group
                    }

                    Context 'Structure - parent' {
                        It 'XML document exists' {
                            $XMLDocumentParent | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocumentParent | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                        }
                    }

                    Context 'Attributes' {
                        It 'XML Group element exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'Group clsid attribute is correct' {
                            $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                        }
                        It 'Group uid is correct ' {
                            $XMLDocument.uid | Should -BeExactly '{483e7907-f4df-439c-946d-91d2fe3afc20}'
                        }
                        It 'Group name is correct' {
                            $XMLDocument.name | Should -BeExactly 'LocalGroup1'
                        }
                        It 'Group has changed date/time' {
                            $XMLDocument.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'Group is enabled' {
                            $XMLDocument.disabled | Should -BeExactly '0'
                        }
                        It 'Group has a correct image' {
                            $XMLDocument.image | Should -BeExactly '2'
                        }
                        It 'Group bypasses errors' {
                            $XMLDocument.bypassErrors | Should -BeExactly '1'
                        }
                        It 'Group has removePolicy set to 0' {
                            $XMLDocument.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'Propeties' {
                        Context 'Structure' {
                            It 'XML Properties element exists' {
                                $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                            }
                        }

                        Context 'Content' {
                            It 'Group name is correct' {
                                $XMLDocument.Properties.groupName | Should -BeExactly 'LocalGroup1'
                            }
                            It 'Group SID is absent' {
                                $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                            }
                            It 'Action is correct' {
                                $XMLDocument.Properties.action | Should -BeExactly 'U'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly 'My Awesome Description'
                            }
                            It 'New group name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly 'LocalGroup2'
                            }
                            It 'deleteAllGroups set to 0' {
                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                            }
                            It 'deleteAllUsers set to 0' {
                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                            }
                            It 'removeAccounts set to 0' {
                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                            }
                        }
                    }
                }

                Context 'LocalGroup3' {
                    BeforeAll {
                        $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '52D0DA5A-91FD-472B-83C4-E70EC7CD5ACB' }
                        [xml]$XMLDocumentParent = Serialize-GPPItemGroup -InputObject $Item
                        $XMLDocument = $XMLDocumentParent.Group
                    }

                    Context 'Structure - parent' {
                        It 'XML document exists' {
                            $XMLDocumentParent | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocumentParent | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                        }
                    }

                    Context 'Attributes' {
                        It 'Group clsid attribute is correct' {
                            $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                        }
                        It 'Group uid is correct ' {
                            $XMLDocument.uid | Should -BeExactly '{52d0da5a-91fd-472b-83c4-e70ec7cd5acb}'
                        }
                        It 'Group name is correct' {
                            $XMLDocument.name | Should -BeExactly 'LocalGroup3'
                        }
                        It 'Group has changed date/time' {
                            $XMLDocument.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'Group is disabled' {
                            $XMLDocument.disabled | Should -BeExactly '1'
                        }
                        It 'Group has a correct image' {
                            $XMLDocument.image | Should -BeExactly '0'
                        }
                        It 'Group bypasses errors' {
                            $XMLDocument.bypassErrors | Should -BeExactly '1'
                        }
                        It 'Group has removePolicy set to 0' {
                            $XMLDocument.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'Propeties' {
                        Context 'Structure' {
                            It 'XML Properties element exists' {
                                $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 8
                            }
                        }

                        Context 'Content' {
                            Context 'Common attributes' {
                                It 'Group name is correct' {
                                    $XMLDocument.Properties.groupName | Should -BeExactly 'LocalGroup3'
                                }
                                It 'Group SID is absent' {
                                    $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                                }
                                It 'Action is correct' {
                                    $XMLDocument.Properties.action | Should -BeExactly 'C'
                                }
                                It 'Description is correct' {
                                    $XMLDocument.Properties.description | Should -BeExactly ''
                                }
                                It 'New group name is correct' {
                                    $XMLDocument.Properties.newName | Should -BeExactly ''
                                }
                                It 'deleteAllGroups set to 0' {
                                    $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                                }
                                It 'deleteAllUsers set to 0' {
                                    $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                                }
                                It 'removeAccounts set to 0' {
                                    $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                }
                            }

                            Context 'Members' {
                                Context 'Structure' {
                                    It 'Group members are present' {
                                        $XMLDocument.Properties.Members | Should -Not -BeNullOrEmpty
                                    }
                                    It 'Member property is present' {
                                        $XMLDocument.Properties.Members.Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'The number of members is correct' {
                                        $XMLDocument.Properties.Members.Member.Count | Should -Be 4
                                    }
                                }

                                Context 'EXAMPLE\Administrator' {
                                    BeforeAll {
                                        $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\Administrator' }
                                    }
                                    Context 'Structure' {
                                        It 'XML element exists' {
                                            $Member | Should -Not -BeNullOrEmpty
                                        }
                                        It 'XML element has a correct number of properties' {
                                            ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                        }
                                    }

                                    Context 'Content' {
                                        It 'Member name is correct' {
                                            $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                                        }
                                        It 'Action is correct' {
                                            $Member.action | Should -BeExactly 'ADD'
                                        }
                                    }
                                }

                                Context 'EXAMPLE\TEST1' {
                                    BeforeAll {
                                        $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST1' }
                                    }
                                    Context 'Structure' {
                                        It 'XML element exists' {
                                            $Member | Should -Not -BeNullOrEmpty
                                        }
                                        It 'XML element has a correct number of properties' {
                                            ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                        }
                                    }

                                    Context 'Content' {
                                        It 'Member name is correct' {
                                            $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                                        }
                                        It 'SID is correct' {
                                            $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                                        }
                                        It 'Action is correct' {
                                            $Member.action | Should -BeExactly 'ADD'
                                        }
                                    }
                                }

                                Context 'EXAMPLE\TEST2' {
                                    BeforeAll {
                                        $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST2' }
                                    }
                                    Context 'Structure' {
                                        It 'XML element exists' {
                                            $Member | Should -Not -BeNullOrEmpty
                                        }
                                        It 'XML element has a correct number of properties' {
                                            ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                        }
                                    }

                                    Context 'Content' {
                                        It 'Member name is correct' {
                                            $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                                        }
                                        It 'Action is correct' {
                                            $Member.action | Should -BeExactly 'REMOVE'
                                        }
                                    }
                                }

                                Context 'EXAMPLE\TEST3' {
                                    BeforeAll {
                                        $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST3' }
                                    }
                                    Context 'Structure' {
                                        It 'XML element exists' {
                                            $Member | Should -Not -BeNullOrEmpty
                                        }
                                        It 'XML element has a correct number of properties' {
                                            ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                        }
                                    }

                                    Context 'Content' {
                                        It 'Member name is correct' {
                                            $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                                        }
                                        It 'SID is correct' {
                                            $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                                        }
                                        It 'Action is correct' {
                                            $Member.action | Should -BeExactly 'REMOVE'
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Context 'Backup Operators (built-in)' {
                    BeforeAll {
                        $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '880FFE86-78C7-4E85-AFDE-608C24977161' }
                        [xml]$XMLDocumentParent = Serialize-GPPItemGroup -InputObject $Item
                        $XMLDocument = $XMLDocumentParent.Group
                    }

                    Context 'Structure - parent' {
                        It 'XML document exists' {
                            $XMLDocumentParent | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocumentParent | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 1
                        }
                    }

                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                        }
                    }

                    Context 'Attributes' {
                        It 'Group clsid attribute is correct' {
                            $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                        }
                        It 'Group uid is correct ' {
                            $XMLDocument.uid | Should -BeExactly '{880ffe86-78c7-4e85-afde-608c24977161}'
                        }
                        It 'Group name is correct' {
                            $XMLDocument.name | Should -BeExactly 'Backup Operators (built-in)'
                        }
                        It 'Group has changed date/time' {
                            $XMLDocument.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'Group is enabled' {
                            $XMLDocument.disabled | Should -BeExactly '0'
                        }
                        It 'Group has a correct image' {
                            $XMLDocument.image | Should -BeExactly '2'
                        }
                        It 'Group bypasses errors' {
                            $XMLDocument.bypassErrors | Should -BeExactly '1'
                        }
                        It 'Group has removePolicy set to 0' {
                            $XMLDocument.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'Propeties' {
                        Context 'Structure' {
                            It 'XML Properties element exists' {
                                $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                            }
                            It 'XML Properties element has correct number of properties' {
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                            }
                        }

                        Context 'Content' {
                            Context 'Common attributes' {
                                It 'Group name is correct' {
                                    $XMLDocument.Properties.groupName | Should -BeExactly 'Backup Operators (built-in)'
                                }
                                It 'Group SID is correct' {
                                    $XMLDocument.Properties.groupSid | Should -BeExactly 'S-1-5-32-551'
                                }
                                It 'Action is correct' {
                                    $XMLDocument.Properties.action | Should -BeExactly 'U'
                                }
                                It 'Description is correct' {
                                    $XMLDocument.Properties.description | Should -BeExactly ''
                                }
                                It 'New group name is correct' {
                                    $XMLDocument.Properties.newName | Should -BeExactly ''
                                }
                                It 'deleteAllGroups set to 1' {
                                    $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '1'
                                }
                                It 'deleteAllUsers set to 1' {
                                    $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '1'
                                }
                                It 'removeAccounts set to 0' {
                                    $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                }
                            }

                            Context 'Members' {
                                Context 'Structure' {
                                    It 'Group members are present' {
                                        $XMLDocument.Properties.Members | Should -Not -BeNullOrEmpty
                                    }
                                    It 'Member property is present' {
                                        $XMLDocument.Properties.Members.Member | Should -Not -BeNullOrEmpty
                                    }
                                    It 'The number of members is correct' {
                                        $XMLDocument.Properties.Members.Member.Count | Should -Be 4
                                    }
                                }

                                Context 'EXAMPLE\Administrator' {
                                    BeforeAll {
                                        $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\Administrator' }
                                    }
                                    Context 'Structure' {
                                        It 'XML element exists' {
                                            $Member | Should -Not -BeNullOrEmpty
                                        }
                                        It 'XML element has a correct number of properties' {
                                            ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                        }
                                    }

                                    Context 'Content' {
                                        It 'Member name is correct' {
                                            $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                                        }
                                        It 'Action is correct' {
                                            $Member.action | Should -BeExactly 'ADD'
                                        }
                                    }
                                }

                                Context 'EXAMPLE\TEST1' {
                                    BeforeAll {
                                        $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST1' }
                                    }
                                    Context 'Structure' {
                                        It 'XML element exists' {
                                            $Member | Should -Not -BeNullOrEmpty
                                        }
                                        It 'XML element has a correct number of properties' {
                                            ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                        }
                                    }

                                    Context 'Content' {
                                        It 'Member name is correct' {
                                            $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                                        }
                                        It 'SID is correct' {
                                            $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                                        }
                                        It 'Action is correct' {
                                            $Member.action | Should -BeExactly 'ADD'
                                        }
                                    }
                                }

                                Context 'EXAMPLE\TEST2' {
                                    BeforeAll {
                                        $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST2' }
                                    }
                                    Context 'Structure' {
                                        It 'XML element exists' {
                                            $Member | Should -Not -BeNullOrEmpty
                                        }
                                        It 'XML element has a correct number of properties' {
                                            ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                        }
                                    }

                                    Context 'Content' {
                                        It 'Member name is correct' {
                                            $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                                        }
                                        It 'Action is correct' {
                                            $Member.action | Should -BeExactly 'REMOVE'
                                        }
                                    }
                                }

                                Context 'EXAMPLE\TEST3' {
                                    BeforeAll {
                                        $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST3' }
                                    }
                                    Context 'Structure' {
                                        It 'XML element exists' {
                                            $Member | Should -Not -BeNullOrEmpty
                                        }
                                        It 'XML element has a correct number of properties' {
                                            ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                        }
                                    }

                                    Context 'Content' {
                                        It 'Member name is correct' {
                                            $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                                        }
                                        It 'SID is correct' {
                                            $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                                        }
                                        It 'Action is correct' {
                                            $Member.action | Should -BeExactly 'REMOVE'
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        <# Describe 'UNIT: Serialize-GPPSectionGroup' {

        } #>

        Describe 'ACCEPTANCE: Serialize-GPPSectionGroups' {
            # Serialize-GPPSectionGroups -InputObject [GPPSectionGroups]

            Context 'Groups-GroupsOnly-Set-<GPPSectionID>' -Foreach @(
                @{
                    GPPSectionID    = 1
                    SectionDisabled = 0
                }
                @{
                    GPPSectionID    = 2
                    SectionDisabled = 1
                }
            ) {
                BeforeAll {
                    $GPPSection = (Get-Variable -Name ('GPPSectionSet{0}' -f $GPPSectionID)).Value
                    $XMLDocumentRoot = Serialize-GPPSectionGroups -InputObject $GPPSection
                }

                Context 'Root element' {
                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocumentRoot | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocumentRoot | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                        }
                    }

                    Context 'Attributes' {
                        It 'xml attribute is correct' {
                            $XMLDocumentRoot.xml | Should -BeExactly 'version="1.0" encoding="utf-8"'
                        }
                    }
                }

                Context 'Groups' {
                    Context 'Structure' {
                        It 'XML document exists' {
                            $XMLDocumentRoot.Groups | Should -Not -BeNullOrEmpty
                        }
                        It 'XML document has correct number of properties' {
                            ($XMLDocumentRoot.Groups | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                        }
                    }

                    Context 'Attributes' {
                        It 'Group element exists' {
                            $XMLDocumentRoot.Groups.Group | Should -Not -BeNullOrEmpty
                        }
                        It 'clsid is correct' {
                            $XMLDocumentRoot.Groups.clsid | Should -Be '{3125e937-eb16-4b4c-9934-544fc6d24d26}'
                        }
                        It 'Element is enabled' {
                            $XMLDocumentRoot.Groups.disabled | Should -Be $SectionDisabled.ToString()
                        }
                    }

                    Context 'Group' {
                        Context 'EXAMPLE\TestGroup1' {
                            BeforeAll {
                                $XMLDocument = $XMLDocumentRoot.Groups.Group | Where-Object -FilterScript { $_.uid -eq '{798C5D07-11C3-45C0-B767-124DF9A369A6}' }
                            }

                            Context 'Structure' {
                                It 'XML document exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'XML document has correct number of properties' {
                                    ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                }
                            }

                            Context 'Attributes' {
                                It 'Group clsid attribute is correct' {
                                    $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                                }
                                It 'Group uid is correct ' {
                                    $XMLDocument.uid | Should -BeExactly '{798c5d07-11c3-45c0-b767-124df9a369a6}'
                                }
                                It 'Group name is correct' {
                                    $XMLDocument.name | Should -BeExactly 'EXAMPLE\TestGroup1'
                                }
                                It 'Group has changed date/time' {
                                    $XMLDocument.changed | Should -Not -BeNullOrEmpty
                                }
                                It 'Group is enabled' {
                                    $XMLDocument.disabled | Should -BeExactly '0'
                                }
                                It 'Group has a correct image' {
                                    $XMLDocument.image | Should -BeExactly '2'
                                }
                                It 'Group bypasses errors' {
                                    $XMLDocument.bypassErrors | Should -BeExactly '1'
                                }
                                It 'Group has removePolicy set to 0' {
                                    $XMLDocument.removePolicy | Should -BeExactly '0'
                                }
                            }

                            Context 'Propeties' {
                                Context 'Structure' {
                                    It 'XML Properties element exists' {
                                        $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML Properties element has correct number of properties' {
                                        ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                                    }
                                }

                                Context 'Content' {
                                    It 'Group name is correct' {
                                        $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup1'
                                    }
                                    It 'Group SID is absent' {
                                        $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                                    }
                                    It 'Action is correct' {
                                        $XMLDocument.Properties.action | Should -BeExactly 'U'
                                    }
                                    It 'Description is correct' {
                                        $XMLDocument.Properties.description | Should -BeExactly ''
                                    }
                                    It 'New group name is correct' {
                                        $XMLDocument.Properties.newName | Should -BeExactly ''
                                    }
                                    It 'deleteAllGroups set to 0' {
                                        $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                                    }
                                    It 'deleteAllUsers set to 0' {
                                        $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                                    }
                                    It 'removeAccounts set to 0' {
                                        $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                    }
                                }
                            }
                        }

                        Context 'Administrators (built-in)' {
                            BeforeAll {
                                $XMLDocument = $XMLDocumentRoot.Groups.Group | Where-Object -FilterScript { $_.uid -eq '{6F82151C-1B8A-4809-ABDD-1EA08F91C923}' }
                            }

                            Context 'Structure' {
                                It 'XML document exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'XML document has correct number of properties' {
                                    ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                }
                            }

                            Context 'Attributes' {
                                It 'Group clsid attribute is correct' {
                                    $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                                }
                                It 'Group uid is correct ' {
                                    $XMLDocument.uid | Should -BeExactly '{6f82151c-1b8a-4809-abdd-1ea08f91c923}'
                                }
                                It 'Group name is correct' {
                                    $XMLDocument.name | Should -BeExactly 'Administrators (built-in)'
                                }
                                It 'Group has changed date/time' {
                                    $XMLDocument.changed | Should -Not -BeNullOrEmpty
                                }
                                It 'Group is enabled' {
                                    $XMLDocument.disabled | Should -BeExactly '0'
                                }
                                It 'Group has a correct image' {
                                    $XMLDocument.image | Should -BeExactly '2'
                                }
                                It 'Group bypasses errors' {
                                    $XMLDocument.bypassErrors | Should -BeExactly '1'
                                }
                                It 'Group has removePolicy set to 0' {
                                    $XMLDocument.removePolicy | Should -BeExactly '0'
                                }
                            }

                            Context 'Propeties' {
                                Context 'Structure' {
                                    It 'XML Properties element exists' {
                                        $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML Properties element has correct number of properties' {
                                        ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 8
                                    }
                                }

                                Context 'Content' {
                                    It 'Group name is correct' {
                                        $XMLDocument.Properties.groupName | Should -BeExactly 'Administrators (built-in)'
                                    }
                                    It 'Group SID is correct' {
                                        $XMLDocument.Properties.groupSid | Should -BeExactly 'S-1-5-32-544'
                                    }
                                    It 'Action is correct' {
                                        $XMLDocument.Properties.action | Should -BeExactly 'U'
                                    }
                                    It 'Description is correct' {
                                        $XMLDocument.Properties.description | Should -BeExactly ''
                                    }
                                    It 'New group name is correct' {
                                        $XMLDocument.Properties.newName | Should -BeExactly ''
                                    }
                                    It 'deleteAllGroups set to 0' {
                                        $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                                    }
                                    It 'deleteAllUsers set to 0' {
                                        $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                                    }
                                    It 'removeAccounts set to 0' {
                                        $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                    }
                                }
                            }
                        }

                        Context 'EXAMPLE\TestGroup3' {
                            BeforeAll {
                                $XMLDocument = $XMLDocumentRoot.Groups.Group | Where-Object -FilterScript { $_.uid -eq '{5BFED1D1-5C42-4504-84E7-E62FA36A6E69}' }
                            }

                            Context 'Structure' {
                                It 'XML document exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'XML document has correct number of properties' {
                                    ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                }
                            }

                            Context 'Attributes' {
                                It 'Group clsid attribute is correct' {
                                    $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                                }
                                It 'Group uid is correct ' {
                                    $XMLDocument.uid | Should -BeExactly '{5bfed1d1-5c42-4504-84e7-e62fa36a6e69}'
                                }
                                It 'Group name is correct' {
                                    $XMLDocument.name | Should -BeExactly 'EXAMPLE\TestGroup3'
                                }
                                It 'Group has changed date/time' {
                                    $XMLDocument.changed | Should -Not -BeNullOrEmpty
                                }
                                It 'Group is enabled' {
                                    $XMLDocument.disabled | Should -BeExactly '0'
                                }
                                It 'Group has a correct image' {
                                    $XMLDocument.image | Should -BeExactly '3'
                                }
                                It 'Group bypasses errors' {
                                    $XMLDocument.bypassErrors | Should -BeExactly '1'
                                }
                                It 'Group has removePolicy set to 0' {
                                    $XMLDocument.removePolicy | Should -BeExactly '0'
                                }
                            }

                            Context 'Propeties' {
                                Context 'Structure' {
                                    It 'XML Properties element exists' {
                                        $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML Properties element has correct number of properties' {
                                        ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                                    }
                                }

                                Context 'Content' {
                                    It 'Group name is correct' {
                                        $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup3'
                                    }
                                    It 'Group SID is absent' {
                                        $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                                    }
                                    It 'Action is correct' {
                                        $XMLDocument.Properties.action | Should -BeExactly 'D'
                                    }
                                    It 'Description is correct' {
                                        $XMLDocument.Properties.description | Should -BeExactly ''
                                    }
                                    It 'New group name is correct' {
                                        $XMLDocument.Properties.newName | Should -BeExactly ''
                                    }
                                    It 'deleteAllGroups set to 0' {
                                        $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                                    }
                                    It 'deleteAllUsers set to 0' {
                                        $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                                    }
                                    It 'removeAccounts set to 0' {
                                        $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                    }
                                }
                            }
                        }

                        Context 'EXAMPLE\TestGroup4' {
                            BeforeAll {
                                $XMLDocument = $XMLDocumentRoot.Groups.Group | Where-Object -FilterScript { $_.uid -eq '{ED220833-3027-4071-80BE-0D0B50B781B3}' }
                            }

                            Context 'Structure' {
                                It 'XML document exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'XML document has correct number of properties' {
                                    ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                }
                            }

                            Context 'Attributes' {
                                It 'Group clsid attribute is correct' {
                                    $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                                }
                                It 'Group uid is correct ' {
                                    $XMLDocument.uid | Should -BeExactly '{ed220833-3027-4071-80be-0d0b50b781b3}'
                                }
                                It 'Group name is correct' {
                                    $XMLDocument.name | Should -BeExactly 'EXAMPLE\TestGroup4'
                                }
                                It 'Group has changed date/time' {
                                    $XMLDocument.changed | Should -Not -BeNullOrEmpty
                                }
                                It 'Group is enabled' {
                                    $XMLDocument.disabled | Should -BeExactly '0'
                                }
                                It 'Group has a correct image' {
                                    $XMLDocument.image | Should -BeExactly '0'
                                }
                                It 'Group bypasses errors' {
                                    $XMLDocument.bypassErrors | Should -BeExactly '1'
                                }
                                It 'Group has removePolicy set to 0' {
                                    $XMLDocument.removePolicy | Should -BeExactly '0'
                                }
                            }

                            Context 'Propeties' {
                                Context 'Structure' {
                                    It 'XML Properties element exists' {
                                        $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML Properties element has correct number of properties' {
                                        ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                                    }
                                }

                                Context 'Content' {
                                    It 'Group name is correct' {
                                        $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup4'
                                    }
                                    It 'Group SID is absent' {
                                        $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                                    }
                                    It 'Action is correct' {
                                        $XMLDocument.Properties.action | Should -BeExactly 'C'
                                    }
                                    It 'Description is correct' {
                                        $XMLDocument.Properties.description | Should -BeExactly ''
                                    }
                                    It 'New group name is correct' {
                                        $XMLDocument.Properties.newName | Should -BeExactly ''
                                    }
                                    It 'deleteAllGroups set to 0' {
                                        $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                                    }
                                    It 'deleteAllUsers set to 0' {
                                        $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                                    }
                                    It 'removeAccounts set to 0' {
                                        $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                    }
                                }
                            }
                        }

                        Context 'EXAMPLE\TestGroup5' {
                            BeforeAll {
                                $XMLDocument = $XMLDocumentRoot.Groups.Group | Where-Object -FilterScript { $_.uid -eq '{4046D23B-4875-4E82-96B3-9920E9A9BDFF}' }
                            }

                            Context 'Structure' {
                                It 'XML document exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'XML document has correct number of properties' {
                                    ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                }
                            }

                            Context 'Attributes' {
                                It 'Group clsid attribute is correct' {
                                    $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                                }
                                It 'Group uid is correct ' {
                                    $XMLDocument.uid | Should -BeExactly '{4046d23b-4875-4e82-96b3-9920e9a9bdff}'
                                }
                                It 'Group name is correct' {
                                    $XMLDocument.name | Should -BeExactly 'EXAMPLE\TestGroup5'
                                }
                                It 'Group has changed date/time' {
                                    $XMLDocument.changed | Should -Not -BeNullOrEmpty
                                }
                                It 'Group is enabled' {
                                    $XMLDocument.disabled | Should -BeExactly '0'
                                }
                                It 'Group has a correct image' {
                                    $XMLDocument.image | Should -BeExactly '1'
                                }
                                It 'Group bypasses errors' {
                                    $XMLDocument.bypassErrors | Should -BeExactly '1'
                                }
                                It 'Group has removePolicy set to 0' {
                                    $XMLDocument.removePolicy | Should -BeExactly '0'
                                }
                            }

                            Context 'Propeties' {
                                Context 'Structure' {
                                    It 'XML Properties element exists' {
                                        $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML Properties element has correct number of properties' {
                                        ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                                    }
                                }

                                Context 'Content' {
                                    It 'Group name is correct' {
                                        $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup5'
                                    }
                                    It 'Group SID is absent' {
                                        $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                                    }
                                    It 'Action is correct' {
                                        $XMLDocument.Properties.action | Should -BeExactly 'R'
                                    }
                                    It 'Description is correct' {
                                        $XMLDocument.Properties.description | Should -BeExactly ''
                                    }
                                    It 'New group name is correct' {
                                        $XMLDocument.Properties.newName | Should -BeExactly ''
                                    }
                                    It 'deleteAllGroups set to 0' {
                                        $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                                    }
                                    It 'deleteAllUsers set to 0' {
                                        $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                                    }
                                    It 'removeAccounts set to 0' {
                                        $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                    }
                                }
                            }
                        }

                        Context 'LocalGroup1' {
                            BeforeAll {
                                $XMLDocument = $XMLDocumentRoot.Groups.Group | Where-Object -FilterScript { $_.uid -eq '{483E7907-F4DF-439C-946D-91D2FE3AFC20}' }
                            }

                            Context 'Structure' {
                                It 'XML document exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'XML document has correct number of properties' {
                                    ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                }
                            }

                            Context 'Attributes' {
                                It 'XML Group element exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'Group clsid attribute is correct' {
                                    $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                                }
                                It 'Group uid is correct ' {
                                    $XMLDocument.uid | Should -BeExactly '{483e7907-f4df-439c-946d-91d2fe3afc20}'
                                }
                                It 'Group name is correct' {
                                    $XMLDocument.name | Should -BeExactly 'LocalGroup1'
                                }
                                It 'Group has changed date/time' {
                                    $XMLDocument.changed | Should -Not -BeNullOrEmpty
                                }
                                It 'Group is enabled' {
                                    $XMLDocument.disabled | Should -BeExactly '0'
                                }
                                It 'Group has a correct image' {
                                    $XMLDocument.image | Should -BeExactly '2'
                                }
                                It 'Group bypasses errors' {
                                    $XMLDocument.bypassErrors | Should -BeExactly '1'
                                }
                                It 'Group has removePolicy set to 0' {
                                    $XMLDocument.removePolicy | Should -BeExactly '0'
                                }
                            }

                            Context 'Propeties' {
                                Context 'Structure' {
                                    It 'XML Properties element exists' {
                                        $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML Properties element has correct number of properties' {
                                        ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                                    }
                                }

                                Context 'Content' {
                                    It 'Group name is correct' {
                                        $XMLDocument.Properties.groupName | Should -BeExactly 'LocalGroup1'
                                    }
                                    It 'Group SID is absent' {
                                        $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                                    }
                                    It 'Action is correct' {
                                        $XMLDocument.Properties.action | Should -BeExactly 'U'
                                    }
                                    It 'Description is correct' {
                                        $XMLDocument.Properties.description | Should -BeExactly 'My Awesome Description'
                                    }
                                    It 'New group name is correct' {
                                        $XMLDocument.Properties.newName | Should -BeExactly 'LocalGroup2'
                                    }
                                    It 'deleteAllGroups set to 0' {
                                        $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                                    }
                                    It 'deleteAllUsers set to 0' {
                                        $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                                    }
                                    It 'removeAccounts set to 0' {
                                        $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                    }
                                }
                            }
                        }

                        Context 'LocalGroup3' {
                            BeforeAll {
                                $XMLDocument = $XMLDocumentRoot.Groups.Group | Where-Object -FilterScript { $_.uid -eq '{52D0DA5A-91FD-472B-83C4-E70EC7CD5ACB}' }
                            }

                            Context 'Structure' {
                                It 'XML document exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'XML document has correct number of properties' {
                                    ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                }
                            }

                            Context 'Attributes' {
                                It 'Group clsid attribute is correct' {
                                    $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                                }
                                It 'Group uid is correct ' {
                                    $XMLDocument.uid | Should -BeExactly '{52d0da5a-91fd-472b-83c4-e70ec7cd5acb}'
                                }
                                It 'Group name is correct' {
                                    $XMLDocument.name | Should -BeExactly 'LocalGroup3'
                                }
                                It 'Group has changed date/time' {
                                    $XMLDocument.changed | Should -Not -BeNullOrEmpty
                                }
                                It 'Group is disabled' {
                                    $XMLDocument.disabled | Should -BeExactly '1'
                                }
                                It 'Group has a correct image' {
                                    $XMLDocument.image | Should -BeExactly '0'
                                }
                                It 'Group bypasses errors' {
                                    $XMLDocument.bypassErrors | Should -BeExactly '1'
                                }
                                It 'Group has removePolicy set to 0' {
                                    $XMLDocument.removePolicy | Should -BeExactly '0'
                                }
                            }

                            Context 'Propeties' {
                                Context 'Structure' {
                                    It 'XML Properties element exists' {
                                        $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML Properties element has correct number of properties' {
                                        ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 8
                                    }
                                }

                                Context 'Content' {
                                    Context 'Common attributes' {
                                        It 'Group name is correct' {
                                            $XMLDocument.Properties.groupName | Should -BeExactly 'LocalGroup3'
                                        }
                                        It 'Group SID is absent' {
                                            $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                                        }
                                        It 'Action is correct' {
                                            $XMLDocument.Properties.action | Should -BeExactly 'C'
                                        }
                                        It 'Description is correct' {
                                            $XMLDocument.Properties.description | Should -BeExactly ''
                                        }
                                        It 'New group name is correct' {
                                            $XMLDocument.Properties.newName | Should -BeExactly ''
                                        }
                                        It 'deleteAllGroups set to 0' {
                                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                                        }
                                        It 'deleteAllUsers set to 0' {
                                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                                        }
                                        It 'removeAccounts set to 0' {
                                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                        }
                                    }

                                    Context 'Members' {
                                        Context 'Structure' {
                                            It 'Group members are present' {
                                                $XMLDocument.Properties.Members | Should -Not -BeNullOrEmpty
                                            }
                                            It 'Member property is present' {
                                                $XMLDocument.Properties.Members.Member | Should -Not -BeNullOrEmpty
                                            }
                                            It 'The number of members is correct' {
                                                $XMLDocument.Properties.Members.Member.Count | Should -Be 4
                                            }
                                        }

                                        Context 'EXAMPLE\Administrator' {
                                            BeforeAll {
                                                $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\Administrator' }
                                            }
                                            Context 'Structure' {
                                                It 'XML element exists' {
                                                    $Member | Should -Not -BeNullOrEmpty
                                                }
                                                It 'XML element has a correct number of properties' {
                                                    ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                                }
                                            }

                                            Context 'Content' {
                                                It 'Member name is correct' {
                                                    $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                                                }
                                                It 'Action is correct' {
                                                    $Member.action | Should -BeExactly 'ADD'
                                                }
                                            }
                                        }

                                        Context 'EXAMPLE\TEST1' {
                                            BeforeAll {
                                                $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST1' }
                                            }
                                            Context 'Structure' {
                                                It 'XML element exists' {
                                                    $Member | Should -Not -BeNullOrEmpty
                                                }
                                                It 'XML element has a correct number of properties' {
                                                    ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                                }
                                            }

                                            Context 'Content' {
                                                It 'Member name is correct' {
                                                    $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                                                }
                                                It 'SID is correct' {
                                                    $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                                                }
                                                It 'Action is correct' {
                                                    $Member.action | Should -BeExactly 'ADD'
                                                }
                                            }
                                        }

                                        Context 'EXAMPLE\TEST2' {
                                            BeforeAll {
                                                $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST2' }
                                            }
                                            Context 'Structure' {
                                                It 'XML element exists' {
                                                    $Member | Should -Not -BeNullOrEmpty
                                                }
                                                It 'XML element has a correct number of properties' {
                                                    ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                                }
                                            }

                                            Context 'Content' {
                                                It 'Member name is correct' {
                                                    $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                                                }
                                                It 'Action is correct' {
                                                    $Member.action | Should -BeExactly 'REMOVE'
                                                }
                                            }
                                        }

                                        Context 'EXAMPLE\TEST3' {
                                            BeforeAll {
                                                $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST3' }
                                            }
                                            Context 'Structure' {
                                                It 'XML element exists' {
                                                    $Member | Should -Not -BeNullOrEmpty
                                                }
                                                It 'XML element has a correct number of properties' {
                                                    ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                                }
                                            }

                                            Context 'Content' {
                                                It 'Member name is correct' {
                                                    $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                                                }
                                                It 'SID is correct' {
                                                    $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                                                }
                                                It 'Action is correct' {
                                                    $Member.action | Should -BeExactly 'REMOVE'
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Context 'Backup Operators (built-in)' {
                            BeforeAll {
                                $XMLDocument = $XMLDocumentRoot.Groups.Group | Where-Object -FilterScript { $_.uid -eq '{880FFE86-78C7-4E85-AFDE-608C24977161}' }
                            }

                            Context 'Structure' {
                                It 'XML document exists' {
                                    $XMLDocument | Should -Not -BeNullOrEmpty
                                }
                                It 'XML document has correct number of properties' {
                                    ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                }
                            }

                            Context 'Attributes' {
                                It 'Group clsid attribute is correct' {
                                    $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                                }
                                It 'Group uid is correct ' {
                                    $XMLDocument.uid | Should -BeExactly '{880ffe86-78c7-4e85-afde-608c24977161}'
                                }
                                It 'Group name is correct' {
                                    $XMLDocument.name | Should -BeExactly 'Backup Operators (built-in)'
                                }
                                It 'Group has changed date/time' {
                                    $XMLDocument.changed | Should -Not -BeNullOrEmpty
                                }
                                It 'Group is enabled' {
                                    $XMLDocument.disabled | Should -BeExactly '0'
                                }
                                It 'Group has a correct image' {
                                    $XMLDocument.image | Should -BeExactly '2'
                                }
                                It 'Group bypasses errors' {
                                    $XMLDocument.bypassErrors | Should -BeExactly '1'
                                }
                                It 'Group has removePolicy set to 0' {
                                    $XMLDocument.removePolicy | Should -BeExactly '0'
                                }
                            }

                            Context 'Propeties' {
                                Context 'Structure' {
                                    It 'XML Properties element exists' {
                                        $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML Properties element has correct number of properties' {
                                        ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                    }
                                }

                                Context 'Content' {
                                    Context 'Common attributes' {
                                        It 'Group name is correct' {
                                            $XMLDocument.Properties.groupName | Should -BeExactly 'Backup Operators (built-in)'
                                        }
                                        It 'Group SID is correct' {
                                            $XMLDocument.Properties.groupSid | Should -BeExactly 'S-1-5-32-551'
                                        }
                                        It 'Action is correct' {
                                            $XMLDocument.Properties.action | Should -BeExactly 'U'
                                        }
                                        It 'Description is correct' {
                                            $XMLDocument.Properties.description | Should -BeExactly ''
                                        }
                                        It 'New group name is correct' {
                                            $XMLDocument.Properties.newName | Should -BeExactly ''
                                        }
                                        It 'deleteAllGroups set to 1' {
                                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '1'
                                        }
                                        It 'deleteAllUsers set to 1' {
                                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '1'
                                        }
                                        It 'removeAccounts set to 0' {
                                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                        }
                                    }

                                    Context 'Members' {
                                        Context 'Structure' {
                                            It 'Group members are present' {
                                                $XMLDocument.Properties.Members | Should -Not -BeNullOrEmpty
                                            }
                                            It 'Member property is present' {
                                                $XMLDocument.Properties.Members.Member | Should -Not -BeNullOrEmpty
                                            }
                                            It 'The number of members is correct' {
                                                $XMLDocument.Properties.Members.Member.Count | Should -Be 4
                                            }
                                        }

                                        Context 'EXAMPLE\Administrator' {
                                            BeforeAll {
                                                $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\Administrator' }
                                            }
                                            Context 'Structure' {
                                                It 'XML element exists' {
                                                    $Member | Should -Not -BeNullOrEmpty
                                                }
                                                It 'XML element has a correct number of properties' {
                                                    ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                                }
                                            }

                                            Context 'Content' {
                                                It 'Member name is correct' {
                                                    $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                                                }
                                                It 'Action is correct' {
                                                    $Member.action | Should -BeExactly 'ADD'
                                                }
                                            }
                                        }

                                        Context 'EXAMPLE\TEST1' {
                                            BeforeAll {
                                                $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST1' }
                                            }
                                            Context 'Structure' {
                                                It 'XML element exists' {
                                                    $Member | Should -Not -BeNullOrEmpty
                                                }
                                                It 'XML element has a correct number of properties' {
                                                    ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                                }
                                            }

                                            Context 'Content' {
                                                It 'Member name is correct' {
                                                    $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                                                }
                                                It 'SID is correct' {
                                                    $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                                                }
                                                It 'Action is correct' {
                                                    $Member.action | Should -BeExactly 'ADD'
                                                }
                                            }
                                        }

                                        Context 'EXAMPLE\TEST2' {
                                            BeforeAll {
                                                $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST2' }
                                            }
                                            Context 'Structure' {
                                                It 'XML element exists' {
                                                    $Member | Should -Not -BeNullOrEmpty
                                                }
                                                It 'XML element has a correct number of properties' {
                                                    ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                                }
                                            }

                                            Context 'Content' {
                                                It 'Member name is correct' {
                                                    $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                                                }
                                                It 'Action is correct' {
                                                    $Member.action | Should -BeExactly 'REMOVE'
                                                }
                                            }
                                        }

                                        Context 'EXAMPLE\TEST3' {
                                            BeforeAll {
                                                $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST3' }
                                            }
                                            Context 'Structure' {
                                                It 'XML element exists' {
                                                    $Member | Should -Not -BeNullOrEmpty
                                                }
                                                It 'XML element has a correct number of properties' {
                                                    ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                                }
                                            }

                                            Context 'Content' {
                                                It 'Member name is correct' {
                                                    $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                                                }
                                                It 'SID is correct' {
                                                    $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                                                }
                                                It 'Action is correct' {
                                                    $Member.action | Should -BeExactly 'REMOVE'
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        <# Describe 'UNIT: Serialize-GPPSection' {
        } #>

        Describe 'ACCEPTANCE: Serialize-GPPSection' {
            Context 'Groups-GroupsOnly-Set-<GPPSectionID>' -Foreach @(
                @{
                    GPPSectionID    = 1
                    SectionDisabled = 0
                }
                @{
                    GPPSectionID    = 2
                    SectionDisabled = 1
                }
            ) {
                BeforeAll {
                    $GPPSection = (Get-Variable -Name ('GPPSectionSet{0}' -f $GPPSectionID)).Value
                    $TypedResult = Serialize-GPPSection -InputObject $GPPSection -IncludeType
                    $NonTypedResult = Serialize-GPPSection -InputObject $GPPSection
                }

                Context '<Name>' -Foreach @(
                    @{
                        Name = 'Typed'
                    }
                    @{
                        Name = 'Non-Typed'
                    }
                ) {
                    BeforeAll {
                        if ($Name -eq 'Typed') {
                            $XMLDocumentRoot = $TypedResult.XMLDocument
                        }
                        else {
                            $XMLDocumentRoot = $NonTypedResult
                        }
                    }

                    Context 'Root element' {
                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocumentRoot | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocumentRoot | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                            }
                        }

                        Context 'Attributes' {
                            It 'xml attribute is correct' {
                                $XMLDocumentRoot.xml | Should -BeExactly 'version="1.0" encoding="utf-8"'
                            }
                        }
                    }

                    Context 'Groups' {
                        Context 'Structure' {
                            It 'XML document exists' {
                                $XMLDocumentRoot.Groups | Should -Not -BeNullOrEmpty
                            }
                            It 'XML document has correct number of properties' {
                                ($XMLDocumentRoot.Groups | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                            }
                        }

                        Context 'Attributes' {
                            It 'Group element exists' {
                                $XMLDocumentRoot.Groups.Group | Should -Not -BeNullOrEmpty
                            }
                            It 'clsid is correct' {
                                $XMLDocumentRoot.Groups.clsid | Should -Be '{3125e937-eb16-4b4c-9934-544fc6d24d26}'
                            }
                            It 'Element is enabled' {
                                $XMLDocumentRoot.Groups.disabled | Should -Be $SectionDisabled.ToString()
                            }
                        }

                        Context 'Group' {
                            Context 'EXAMPLE\TestGroup1' {
                                BeforeAll {
                                    $XMLDocument = $XMLDocumentRoot.Groups.Group | Where-Object -FilterScript { $_.uid -eq '{798C5D07-11C3-45C0-B767-124DF9A369A6}' }
                                }

                                Context 'Structure' {
                                    It 'XML document exists' {
                                        $XMLDocument | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML document has correct number of properties' {
                                        ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                    }
                                }

                                Context 'Attributes' {
                                    It 'Group clsid attribute is correct' {
                                        $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                                    }
                                    It 'Group uid is correct ' {
                                        $XMLDocument.uid | Should -BeExactly '{798c5d07-11c3-45c0-b767-124df9a369a6}'
                                    }
                                    It 'Group name is correct' {
                                        $XMLDocument.name | Should -BeExactly 'EXAMPLE\TestGroup1'
                                    }
                                    It 'Group has changed date/time' {
                                        $XMLDocument.changed | Should -Not -BeNullOrEmpty
                                    }
                                    It 'Group is enabled' {
                                        $XMLDocument.disabled | Should -BeExactly '0'
                                    }
                                    It 'Group has a correct image' {
                                        $XMLDocument.image | Should -BeExactly '2'
                                    }
                                    It 'Group bypasses errors' {
                                        $XMLDocument.bypassErrors | Should -BeExactly '1'
                                    }
                                    It 'Group has removePolicy set to 0' {
                                        $XMLDocument.removePolicy | Should -BeExactly '0'
                                    }
                                }

                                Context 'Propeties' {
                                    Context 'Structure' {
                                        It 'XML Properties element exists' {
                                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                                        }
                                        It 'XML Properties element has correct number of properties' {
                                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                                        }
                                    }

                                    Context 'Content' {
                                        It 'Group name is correct' {
                                            $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup1'
                                        }
                                        It 'Group SID is absent' {
                                            $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                                        }
                                        It 'Action is correct' {
                                            $XMLDocument.Properties.action | Should -BeExactly 'U'
                                        }
                                        It 'Description is correct' {
                                            $XMLDocument.Properties.description | Should -BeExactly ''
                                        }
                                        It 'New group name is correct' {
                                            $XMLDocument.Properties.newName | Should -BeExactly ''
                                        }
                                        It 'deleteAllGroups set to 0' {
                                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                                        }
                                        It 'deleteAllUsers set to 0' {
                                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                                        }
                                        It 'removeAccounts set to 0' {
                                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                        }
                                    }
                                }
                            }

                            Context 'Administrators (built-in)' {
                                BeforeAll {
                                    $XMLDocument = $XMLDocumentRoot.Groups.Group | Where-Object -FilterScript { $_.uid -eq '{6F82151C-1B8A-4809-ABDD-1EA08F91C923}' }
                                }

                                Context 'Structure' {
                                    It 'XML document exists' {
                                        $XMLDocument | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML document has correct number of properties' {
                                        ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                    }
                                }

                                Context 'Attributes' {
                                    It 'Group clsid attribute is correct' {
                                        $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                                    }
                                    It 'Group uid is correct ' {
                                        $XMLDocument.uid | Should -BeExactly '{6f82151c-1b8a-4809-abdd-1ea08f91c923}'
                                    }
                                    It 'Group name is correct' {
                                        $XMLDocument.name | Should -BeExactly 'Administrators (built-in)'
                                    }
                                    It 'Group has changed date/time' {
                                        $XMLDocument.changed | Should -Not -BeNullOrEmpty
                                    }
                                    It 'Group is enabled' {
                                        $XMLDocument.disabled | Should -BeExactly '0'
                                    }
                                    It 'Group has a correct image' {
                                        $XMLDocument.image | Should -BeExactly '2'
                                    }
                                    It 'Group bypasses errors' {
                                        $XMLDocument.bypassErrors | Should -BeExactly '1'
                                    }
                                    It 'Group has removePolicy set to 0' {
                                        $XMLDocument.removePolicy | Should -BeExactly '0'
                                    }
                                }

                                Context 'Propeties' {
                                    Context 'Structure' {
                                        It 'XML Properties element exists' {
                                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                                        }
                                        It 'XML Properties element has correct number of properties' {
                                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 8
                                        }
                                    }

                                    Context 'Content' {
                                        It 'Group name is correct' {
                                            $XMLDocument.Properties.groupName | Should -BeExactly 'Administrators (built-in)'
                                        }
                                        It 'Group SID is correct' {
                                            $XMLDocument.Properties.groupSid | Should -BeExactly 'S-1-5-32-544'
                                        }
                                        It 'Action is correct' {
                                            $XMLDocument.Properties.action | Should -BeExactly 'U'
                                        }
                                        It 'Description is correct' {
                                            $XMLDocument.Properties.description | Should -BeExactly ''
                                        }
                                        It 'New group name is correct' {
                                            $XMLDocument.Properties.newName | Should -BeExactly ''
                                        }
                                        It 'deleteAllGroups set to 0' {
                                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                                        }
                                        It 'deleteAllUsers set to 0' {
                                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                                        }
                                        It 'removeAccounts set to 0' {
                                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                        }
                                    }
                                }
                            }

                            Context 'EXAMPLE\TestGroup3' {
                                BeforeAll {
                                    $XMLDocument = $XMLDocumentRoot.Groups.Group | Where-Object -FilterScript { $_.uid -eq '{5BFED1D1-5C42-4504-84E7-E62FA36A6E69}' }
                                }

                                Context 'Structure' {
                                    It 'XML document exists' {
                                        $XMLDocument | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML document has correct number of properties' {
                                        ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                    }
                                }

                                Context 'Attributes' {
                                    It 'Group clsid attribute is correct' {
                                        $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                                    }
                                    It 'Group uid is correct ' {
                                        $XMLDocument.uid | Should -BeExactly '{5bfed1d1-5c42-4504-84e7-e62fa36a6e69}'
                                    }
                                    It 'Group name is correct' {
                                        $XMLDocument.name | Should -BeExactly 'EXAMPLE\TestGroup3'
                                    }
                                    It 'Group has changed date/time' {
                                        $XMLDocument.changed | Should -Not -BeNullOrEmpty
                                    }
                                    It 'Group is enabled' {
                                        $XMLDocument.disabled | Should -BeExactly '0'
                                    }
                                    It 'Group has a correct image' {
                                        $XMLDocument.image | Should -BeExactly '3'
                                    }
                                    It 'Group bypasses errors' {
                                        $XMLDocument.bypassErrors | Should -BeExactly '1'
                                    }
                                    It 'Group has removePolicy set to 0' {
                                        $XMLDocument.removePolicy | Should -BeExactly '0'
                                    }
                                }

                                Context 'Propeties' {
                                    Context 'Structure' {
                                        It 'XML Properties element exists' {
                                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                                        }
                                        It 'XML Properties element has correct number of properties' {
                                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                                        }
                                    }

                                    Context 'Content' {
                                        It 'Group name is correct' {
                                            $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup3'
                                        }
                                        It 'Group SID is absent' {
                                            $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                                        }
                                        It 'Action is correct' {
                                            $XMLDocument.Properties.action | Should -BeExactly 'D'
                                        }
                                        It 'Description is correct' {
                                            $XMLDocument.Properties.description | Should -BeExactly ''
                                        }
                                        It 'New group name is correct' {
                                            $XMLDocument.Properties.newName | Should -BeExactly ''
                                        }
                                        It 'deleteAllGroups set to 0' {
                                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                                        }
                                        It 'deleteAllUsers set to 0' {
                                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                                        }
                                        It 'removeAccounts set to 0' {
                                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                        }
                                    }
                                }
                            }

                            Context 'EXAMPLE\TestGroup4' {
                                BeforeAll {
                                    $XMLDocument = $XMLDocumentRoot.Groups.Group | Where-Object -FilterScript { $_.uid -eq '{ED220833-3027-4071-80BE-0D0B50B781B3}' }
                                }

                                Context 'Structure' {
                                    It 'XML document exists' {
                                        $XMLDocument | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML document has correct number of properties' {
                                        ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                    }
                                }

                                Context 'Attributes' {
                                    It 'Group clsid attribute is correct' {
                                        $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                                    }
                                    It 'Group uid is correct ' {
                                        $XMLDocument.uid | Should -BeExactly '{ed220833-3027-4071-80be-0d0b50b781b3}'
                                    }
                                    It 'Group name is correct' {
                                        $XMLDocument.name | Should -BeExactly 'EXAMPLE\TestGroup4'
                                    }
                                    It 'Group has changed date/time' {
                                        $XMLDocument.changed | Should -Not -BeNullOrEmpty
                                    }
                                    It 'Group is enabled' {
                                        $XMLDocument.disabled | Should -BeExactly '0'
                                    }
                                    It 'Group has a correct image' {
                                        $XMLDocument.image | Should -BeExactly '0'
                                    }
                                    It 'Group bypasses errors' {
                                        $XMLDocument.bypassErrors | Should -BeExactly '1'
                                    }
                                    It 'Group has removePolicy set to 0' {
                                        $XMLDocument.removePolicy | Should -BeExactly '0'
                                    }
                                }

                                Context 'Propeties' {
                                    Context 'Structure' {
                                        It 'XML Properties element exists' {
                                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                                        }
                                        It 'XML Properties element has correct number of properties' {
                                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                                        }
                                    }

                                    Context 'Content' {
                                        It 'Group name is correct' {
                                            $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup4'
                                        }
                                        It 'Group SID is absent' {
                                            $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                                        }
                                        It 'Action is correct' {
                                            $XMLDocument.Properties.action | Should -BeExactly 'C'
                                        }
                                        It 'Description is correct' {
                                            $XMLDocument.Properties.description | Should -BeExactly ''
                                        }
                                        It 'New group name is correct' {
                                            $XMLDocument.Properties.newName | Should -BeExactly ''
                                        }
                                        It 'deleteAllGroups set to 0' {
                                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                                        }
                                        It 'deleteAllUsers set to 0' {
                                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                                        }
                                        It 'removeAccounts set to 0' {
                                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                        }
                                    }
                                }
                            }

                            Context 'EXAMPLE\TestGroup5' {
                                BeforeAll {
                                    $XMLDocument = $XMLDocumentRoot.Groups.Group | Where-Object -FilterScript { $_.uid -eq '{4046D23B-4875-4E82-96B3-9920E9A9BDFF}' }
                                }

                                Context 'Structure' {
                                    It 'XML document exists' {
                                        $XMLDocument | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML document has correct number of properties' {
                                        ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                    }
                                }

                                Context 'Attributes' {
                                    It 'Group clsid attribute is correct' {
                                        $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                                    }
                                    It 'Group uid is correct ' {
                                        $XMLDocument.uid | Should -BeExactly '{4046d23b-4875-4e82-96b3-9920e9a9bdff}'
                                    }
                                    It 'Group name is correct' {
                                        $XMLDocument.name | Should -BeExactly 'EXAMPLE\TestGroup5'
                                    }
                                    It 'Group has changed date/time' {
                                        $XMLDocument.changed | Should -Not -BeNullOrEmpty
                                    }
                                    It 'Group is enabled' {
                                        $XMLDocument.disabled | Should -BeExactly '0'
                                    }
                                    It 'Group has a correct image' {
                                        $XMLDocument.image | Should -BeExactly '1'
                                    }
                                    It 'Group bypasses errors' {
                                        $XMLDocument.bypassErrors | Should -BeExactly '1'
                                    }
                                    It 'Group has removePolicy set to 0' {
                                        $XMLDocument.removePolicy | Should -BeExactly '0'
                                    }
                                }

                                Context 'Propeties' {
                                    Context 'Structure' {
                                        It 'XML Properties element exists' {
                                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                                        }
                                        It 'XML Properties element has correct number of properties' {
                                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                                        }
                                    }

                                    Context 'Content' {
                                        It 'Group name is correct' {
                                            $XMLDocument.Properties.groupName | Should -BeExactly 'EXAMPLE\TestGroup5'
                                        }
                                        It 'Group SID is absent' {
                                            $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                                        }
                                        It 'Action is correct' {
                                            $XMLDocument.Properties.action | Should -BeExactly 'R'
                                        }
                                        It 'Description is correct' {
                                            $XMLDocument.Properties.description | Should -BeExactly ''
                                        }
                                        It 'New group name is correct' {
                                            $XMLDocument.Properties.newName | Should -BeExactly ''
                                        }
                                        It 'deleteAllGroups set to 0' {
                                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                                        }
                                        It 'deleteAllUsers set to 0' {
                                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                                        }
                                        It 'removeAccounts set to 0' {
                                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                        }
                                    }
                                }
                            }

                            Context 'LocalGroup1' {
                                BeforeAll {
                                    $XMLDocument = $XMLDocumentRoot.Groups.Group | Where-Object -FilterScript { $_.uid -eq '{483E7907-F4DF-439C-946D-91D2FE3AFC20}' }
                                }

                                Context 'Structure' {
                                    It 'XML document exists' {
                                        $XMLDocument | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML document has correct number of properties' {
                                        ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                    }
                                }

                                Context 'Attributes' {
                                    It 'XML Group element exists' {
                                        $XMLDocument | Should -Not -BeNullOrEmpty
                                    }
                                    It 'Group clsid attribute is correct' {
                                        $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                                    }
                                    It 'Group uid is correct ' {
                                        $XMLDocument.uid | Should -BeExactly '{483e7907-f4df-439c-946d-91d2fe3afc20}'
                                    }
                                    It 'Group name is correct' {
                                        $XMLDocument.name | Should -BeExactly 'LocalGroup1'
                                    }
                                    It 'Group has changed date/time' {
                                        $XMLDocument.changed | Should -Not -BeNullOrEmpty
                                    }
                                    It 'Group is enabled' {
                                        $XMLDocument.disabled | Should -BeExactly '0'
                                    }
                                    It 'Group has a correct image' {
                                        $XMLDocument.image | Should -BeExactly '2'
                                    }
                                    It 'Group bypasses errors' {
                                        $XMLDocument.bypassErrors | Should -BeExactly '1'
                                    }
                                    It 'Group has removePolicy set to 0' {
                                        $XMLDocument.removePolicy | Should -BeExactly '0'
                                    }
                                }

                                Context 'Propeties' {
                                    Context 'Structure' {
                                        It 'XML Properties element exists' {
                                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                                        }
                                        It 'XML Properties element has correct number of properties' {
                                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 7
                                        }
                                    }

                                    Context 'Content' {
                                        It 'Group name is correct' {
                                            $XMLDocument.Properties.groupName | Should -BeExactly 'LocalGroup1'
                                        }
                                        It 'Group SID is absent' {
                                            $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                                        }
                                        It 'Action is correct' {
                                            $XMLDocument.Properties.action | Should -BeExactly 'U'
                                        }
                                        It 'Description is correct' {
                                            $XMLDocument.Properties.description | Should -BeExactly 'My Awesome Description'
                                        }
                                        It 'New group name is correct' {
                                            $XMLDocument.Properties.newName | Should -BeExactly 'LocalGroup2'
                                        }
                                        It 'deleteAllGroups set to 0' {
                                            $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                                        }
                                        It 'deleteAllUsers set to 0' {
                                            $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                                        }
                                        It 'removeAccounts set to 0' {
                                            $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                        }
                                    }
                                }
                            }

                            Context 'LocalGroup3' {
                                BeforeAll {
                                    $XMLDocument = $XMLDocumentRoot.Groups.Group | Where-Object -FilterScript { $_.uid -eq '{52D0DA5A-91FD-472B-83C4-E70EC7CD5ACB}' }
                                }

                                Context 'Structure' {
                                    It 'XML document exists' {
                                        $XMLDocument | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML document has correct number of properties' {
                                        ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                    }
                                }

                                Context 'Attributes' {
                                    It 'Group clsid attribute is correct' {
                                        $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                                    }
                                    It 'Group uid is correct ' {
                                        $XMLDocument.uid | Should -BeExactly '{52d0da5a-91fd-472b-83c4-e70ec7cd5acb}'
                                    }
                                    It 'Group name is correct' {
                                        $XMLDocument.name | Should -BeExactly 'LocalGroup3'
                                    }
                                    It 'Group has changed date/time' {
                                        $XMLDocument.changed | Should -Not -BeNullOrEmpty
                                    }
                                    It 'Group is disabled' {
                                        $XMLDocument.disabled | Should -BeExactly '1'
                                    }
                                    It 'Group has a correct image' {
                                        $XMLDocument.image | Should -BeExactly '0'
                                    }
                                    It 'Group bypasses errors' {
                                        $XMLDocument.bypassErrors | Should -BeExactly '1'
                                    }
                                    It 'Group has removePolicy set to 0' {
                                        $XMLDocument.removePolicy | Should -BeExactly '0'
                                    }
                                }

                                Context 'Propeties' {
                                    Context 'Structure' {
                                        It 'XML Properties element exists' {
                                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                                        }
                                        It 'XML Properties element has correct number of properties' {
                                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 8
                                        }
                                    }

                                    Context 'Content' {
                                        Context 'Common attributes' {
                                            It 'Group name is correct' {
                                                $XMLDocument.Properties.groupName | Should -BeExactly 'LocalGroup3'
                                            }
                                            It 'Group SID is absent' {
                                                $XMLDocument.Properties.groupSid | Should -BeNullOrEmpty
                                            }
                                            It 'Action is correct' {
                                                $XMLDocument.Properties.action | Should -BeExactly 'C'
                                            }
                                            It 'Description is correct' {
                                                $XMLDocument.Properties.description | Should -BeExactly ''
                                            }
                                            It 'New group name is correct' {
                                                $XMLDocument.Properties.newName | Should -BeExactly ''
                                            }
                                            It 'deleteAllGroups set to 0' {
                                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '0'
                                            }
                                            It 'deleteAllUsers set to 0' {
                                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '0'
                                            }
                                            It 'removeAccounts set to 0' {
                                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                            }
                                        }

                                        Context 'Members' {
                                            Context 'Structure' {
                                                It 'Group members are present' {
                                                    $XMLDocument.Properties.Members | Should -Not -BeNullOrEmpty
                                                }
                                                It 'Member property is present' {
                                                    $XMLDocument.Properties.Members.Member | Should -Not -BeNullOrEmpty
                                                }
                                                It 'The number of members is correct' {
                                                    $XMLDocument.Properties.Members.Member.Count | Should -Be 4
                                                }
                                            }

                                            Context 'EXAMPLE\Administrator' {
                                                BeforeAll {
                                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\Administrator' }
                                                }
                                                Context 'Structure' {
                                                    It 'XML element exists' {
                                                        $Member | Should -Not -BeNullOrEmpty
                                                    }
                                                    It 'XML element has a correct number of properties' {
                                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                                    }
                                                }

                                                Context 'Content' {
                                                    It 'Member name is correct' {
                                                        $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                                                    }
                                                    It 'Action is correct' {
                                                        $Member.action | Should -BeExactly 'ADD'
                                                    }
                                                }
                                            }

                                            Context 'EXAMPLE\TEST1' {
                                                BeforeAll {
                                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST1' }
                                                }
                                                Context 'Structure' {
                                                    It 'XML element exists' {
                                                        $Member | Should -Not -BeNullOrEmpty
                                                    }
                                                    It 'XML element has a correct number of properties' {
                                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                                    }
                                                }

                                                Context 'Content' {
                                                    It 'Member name is correct' {
                                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                                                    }
                                                    It 'SID is correct' {
                                                        $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                                                    }
                                                    It 'Action is correct' {
                                                        $Member.action | Should -BeExactly 'ADD'
                                                    }
                                                }
                                            }

                                            Context 'EXAMPLE\TEST2' {
                                                BeforeAll {
                                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST2' }
                                                }
                                                Context 'Structure' {
                                                    It 'XML element exists' {
                                                        $Member | Should -Not -BeNullOrEmpty
                                                    }
                                                    It 'XML element has a correct number of properties' {
                                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                                    }
                                                }

                                                Context 'Content' {
                                                    It 'Member name is correct' {
                                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                                                    }
                                                    It 'Action is correct' {
                                                        $Member.action | Should -BeExactly 'REMOVE'
                                                    }
                                                }
                                            }

                                            Context 'EXAMPLE\TEST3' {
                                                BeforeAll {
                                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST3' }
                                                }
                                                Context 'Structure' {
                                                    It 'XML element exists' {
                                                        $Member | Should -Not -BeNullOrEmpty
                                                    }
                                                    It 'XML element has a correct number of properties' {
                                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                                    }
                                                }

                                                Context 'Content' {
                                                    It 'Member name is correct' {
                                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                                                    }
                                                    It 'SID is correct' {
                                                        $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                                                    }
                                                    It 'Action is correct' {
                                                        $Member.action | Should -BeExactly 'REMOVE'
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Context 'Backup Operators (built-in)' {
                                BeforeAll {
                                    $XMLDocument = $XMLDocumentRoot.Groups.Group | Where-Object -FilterScript { $_.uid -eq '{880FFE86-78C7-4E85-AFDE-608C24977161}' }
                                }

                                Context 'Structure' {
                                    It 'XML document exists' {
                                        $XMLDocument | Should -Not -BeNullOrEmpty
                                    }
                                    It 'XML document has correct number of properties' {
                                        ($XMLDocument | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                    }
                                }

                                Context 'Attributes' {
                                    It 'Group clsid attribute is correct' {
                                        $XMLDocument.clsid | Should -Be '{6d4a79e4-529c-4481-abd0-f5bd7ea93ba7}'
                                    }
                                    It 'Group uid is correct ' {
                                        $XMLDocument.uid | Should -BeExactly '{880ffe86-78c7-4e85-afde-608c24977161}'
                                    }
                                    It 'Group name is correct' {
                                        $XMLDocument.name | Should -BeExactly 'Backup Operators (built-in)'
                                    }
                                    It 'Group has changed date/time' {
                                        $XMLDocument.changed | Should -Not -BeNullOrEmpty
                                    }
                                    It 'Group is enabled' {
                                        $XMLDocument.disabled | Should -BeExactly '0'
                                    }
                                    It 'Group has a correct image' {
                                        $XMLDocument.image | Should -BeExactly '2'
                                    }
                                    It 'Group bypasses errors' {
                                        $XMLDocument.bypassErrors | Should -BeExactly '1'
                                    }
                                    It 'Group has removePolicy set to 0' {
                                        $XMLDocument.removePolicy | Should -BeExactly '0'
                                    }
                                }

                                Context 'Propeties' {
                                    Context 'Structure' {
                                        It 'XML Properties element exists' {
                                            $XMLDocument.Properties | Should -Not -BeNullOrEmpty
                                        }
                                        It 'XML Properties element has correct number of properties' {
                                            ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 9
                                        }
                                    }

                                    Context 'Content' {
                                        Context 'Common attributes' {
                                            It 'Group name is correct' {
                                                $XMLDocument.Properties.groupName | Should -BeExactly 'Backup Operators (built-in)'
                                            }
                                            It 'Group SID is correct' {
                                                $XMLDocument.Properties.groupSid | Should -BeExactly 'S-1-5-32-551'
                                            }
                                            It 'Action is correct' {
                                                $XMLDocument.Properties.action | Should -BeExactly 'U'
                                            }
                                            It 'Description is correct' {
                                                $XMLDocument.Properties.description | Should -BeExactly ''
                                            }
                                            It 'New group name is correct' {
                                                $XMLDocument.Properties.newName | Should -BeExactly ''
                                            }
                                            It 'deleteAllGroups set to 1' {
                                                $XMLDocument.Properties.deleteAllGroups | Should -BeExactly '1'
                                            }
                                            It 'deleteAllUsers set to 1' {
                                                $XMLDocument.Properties.deleteAllUsers | Should -BeExactly '1'
                                            }
                                            It 'removeAccounts set to 0' {
                                                $XMLDocument.Properties.removeAccounts | Should -BeExactly '0'
                                            }
                                        }

                                        Context 'Members' {
                                            Context 'Structure' {
                                                It 'Group members are present' {
                                                    $XMLDocument.Properties.Members | Should -Not -BeNullOrEmpty
                                                }
                                                It 'Member property is present' {
                                                    $XMLDocument.Properties.Members.Member | Should -Not -BeNullOrEmpty
                                                }
                                                It 'The number of members is correct' {
                                                    $XMLDocument.Properties.Members.Member.Count | Should -Be 4
                                                }
                                            }

                                            Context 'EXAMPLE\Administrator' {
                                                BeforeAll {
                                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\Administrator' }
                                                }
                                                Context 'Structure' {
                                                    It 'XML element exists' {
                                                        $Member | Should -Not -BeNullOrEmpty
                                                    }
                                                    It 'XML element has a correct number of properties' {
                                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                                    }
                                                }

                                                Context 'Content' {
                                                    It 'Member name is correct' {
                                                        $Member.name | Should -BeExactly 'EXAMPLE\Administrator'
                                                    }
                                                    It 'Action is correct' {
                                                        $Member.action | Should -BeExactly 'ADD'
                                                    }
                                                }
                                            }

                                            Context 'EXAMPLE\TEST1' {
                                                BeforeAll {
                                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST1' }
                                                }
                                                Context 'Structure' {
                                                    It 'XML element exists' {
                                                        $Member | Should -Not -BeNullOrEmpty
                                                    }
                                                    It 'XML element has a correct number of properties' {
                                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                                    }
                                                }

                                                Context 'Content' {
                                                    It 'Member name is correct' {
                                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST1'
                                                    }
                                                    It 'SID is correct' {
                                                        $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1620'
                                                    }
                                                    It 'Action is correct' {
                                                        $Member.action | Should -BeExactly 'ADD'
                                                    }
                                                }
                                            }

                                            Context 'EXAMPLE\TEST2' {
                                                BeforeAll {
                                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST2' }
                                                }
                                                Context 'Structure' {
                                                    It 'XML element exists' {
                                                        $Member | Should -Not -BeNullOrEmpty
                                                    }
                                                    It 'XML element has a correct number of properties' {
                                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 2
                                                    }
                                                }

                                                Context 'Content' {
                                                    It 'Member name is correct' {
                                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST2'
                                                    }
                                                    It 'Action is correct' {
                                                        $Member.action | Should -BeExactly 'REMOVE'
                                                    }
                                                }
                                            }

                                            Context 'EXAMPLE\TEST3' {
                                                BeforeAll {
                                                    $Member = $XMLDocument.Properties.Members.Member | Where-Object -FilterScript { $_.name -eq 'EXAMPLE\TEST3' }
                                                }
                                                Context 'Structure' {
                                                    It 'XML element exists' {
                                                        $Member | Should -Not -BeNullOrEmpty
                                                    }
                                                    It 'XML element has a correct number of properties' {
                                                        ($Member | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 3
                                                    }
                                                }

                                                Context 'Content' {
                                                    It 'Member name is correct' {
                                                        $Member.name | Should -BeExactly 'EXAMPLE\TEST3'
                                                    }
                                                    It 'SID is correct' {
                                                        $Member.sid | Should -BeExactly 'S-1-5-21-2571216883-1601522099-2002488368-1622'
                                                    }
                                                    It 'Action is correct' {
                                                        $Member.action | Should -BeExactly 'REMOVE'
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Context 'Typed Root object' {
                    Context 'Structure' {
                        It 'Object exists' {
                            $TypedResult | Should -Not -BeNullOrEmpty
                        }
                        It 'Object has correct type' {
                            $TypedResult | Should -BeOfType [System.Collections.Hashtable]
                        }
                    }

                    Context 'Attributes' {
                        Context 'Type' {
                            It 'Type has correct type' {
                                $TypedResult.Type | Should -BeOfType [GPPType]
                            }
                            It 'Type has correct value' {
                                $TypedResult.Type | Should -Be ([GPPType]::Groups)
                            }
                        }
                    }
                }
            }
        }

        <#Describe 'UNIT: Set-GPPSection' {
            BeforeAll {
                Mock Convert-GPONameToID {
                    [guid]::new('f0a0c308-2fb0-433b-8a00-cc48b9ad1eba')
                }
                Mock Convert-GPONameToID {
                    [guid]::new('f0a0c308-2fb0-433b-8a00-cc48b9ad1eba')
                }
                Mock Get-GPPSectionFilePath {
                    $Set1PathNEW
                } -ParameterFilter { $Type -eq 'Groups' -and $GPOId -eq 'f0a0c308-2fb0-433b-8a00-cc48b9ad1eba' }
                Mock Get-GPPSectionFilePath {
                    $Set2PathNEW
                } -ParameterFilter { $Type -eq 'Groups' -and $GPOId -eq '4c6924d8-020a-4362-8a42-5977fcb3a06e' }
            }

            Set-GPPSection
        }#>

        <# Describe 'ACCEPTANCE: Set-GPPSection' {

        } #>
    }
}