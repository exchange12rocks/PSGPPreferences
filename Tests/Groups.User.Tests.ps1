BeforeDiscovery {
    $ScriptDirectoryPath = $PSScriptRoot
    $DataSourcePath = Join-Path -Path $ScriptDirectoryPath -ChildPath 'Data\Groups'
    $Set1Path = Join-Path -Path $DataSourcePath -ChildPath 'Groups-UserOnly-Set-1.xml'
    [xml]$Set1Data = Get-Content -Path $Set1Path
    $Set2Path = Join-Path -Path $DataSourcePath -ChildPath 'Groups-UserOnly-Set-2.xml'
    [xml]$Set2Data = Get-Content -Path $Set2Path
    $ModuleRootPath = Join-Path -Path $ScriptDirectoryPath -ChildPath ..\src\
    Import-Module -Name (Join-Path -Path $ModuleRootPath -ChildPath 'PSGPPreferences.psd1') -Force
    . (Join-Path -Path $ModuleRootPath -ChildPath 'Definitions\Classes.ps1')
}

Describe 'Internal functions' {
    InModuleScope PSGPPreferences {
        BeforeAll {
            $GPPSectionSet1 = Deserialize-GPPSection -InputObject $Set1Data
            $GPPSectionSet2 = Deserialize-GPPSection -InputObject $Set2Data
        }

        Describe 'ACCEPTANCE: Get-GPPSection' -ForEach @(
            @{
                Mode     = 'ByGPOId'
                GPOId    = 'f0a0c308-2fb0-433b-8a00-cc48b9ad1eba'
                GPOName  = 'Groups-UserOnly-Set-1'
                Disabled = $false
            }
            @{
                Mode     = 'ByGPOId'
                GPOId    = '4c6924d8-020a-4362-8a42-5977fcb3a06e'
                GPOName  = 'Groups-UserOnly-Set-2'
                Disabled = $true
            }
            @{
                Mode     = 'ByGPOName'
                GPOName  = 'Groups-UserOnly-Set-1'
                Disabled = $false
            }
            @{
                Mode     = 'ByGPOName'
                GPOName  = 'Groups-UserOnly-Set-2'
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
                } -ParameterFilter { $Type -eq 'Groups' -and $GPOName -eq 'Groups-UserOnly-Set-1' }
                Mock Convert-GPONameToID {
                    [guid]'4c6924d8-020a-4362-8a42-5977fcb3a06e'
                } -ParameterFilter { $Type -eq 'Groups' -and $GPOName -eq 'Groups-UserOnly-Set-2' }
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

                Context 'Disabled-User' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '868E37FD-3A7C-4D17-BF77-2F9A1663B3FD' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Disabled-User'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'My Description'
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'Disabled-User'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeExactly 'New name'
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeExactly 'Full Name'
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User must change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeTrue
                    }
                    It 'User can change password' {
                        $GPPItem.Properties.noChange | Should -BeFalse
                    }
                    It 'User''s pasword expires' {
                        $GPPItem.Properties.neverExpires | Should -BeFalse
                    }
                    It 'User is disabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeTrue
                    }
                    It 'User is not built-in' {
                        $GPPItem.Properties.subAuthority | Should -BeNullOrEmpty
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }

                Context 'NoExpire' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'B0BD4312-90F3-41E5-BC2C-3F37818233B1' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'NoExpire'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'NoExpire description'
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'NoExpire'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeExactly 'NoExpire New Name'
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeExactly 'NoExpire Full Name'
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User must change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User cannot change password' {
                        $GPPItem.Properties.noChange | Should -BeTrue
                    }
                    It 'User''s password does not expire' {
                        $GPPItem.Properties.neverExpires | Should -BeTrue
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is not built-in' {
                        $GPPItem.Properties.subAuthority | Should -BeNullOrEmpty
                    }
                    It 'User GPP item expires on 2021-04-16' {
                        $GPPItem.Properties.expires | Should -BeExactly '2021-04-16'
                    }
                }

                Context 'NoExpireD' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '1C4A9E83-3480-4C29-AC94-802DD2EB7974' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'NoExpireD'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'NoExpire description'
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'NoExpireD'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeExactly 'NoExpire New Name'
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeExactly 'NoExpire Full Name'
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User must change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User cannot change password' {
                        $GPPItem.Properties.noChange | Should -BeTrue
                    }
                    It 'User''s password does not expire' {
                        $GPPItem.Properties.neverExpires | Should -BeTrue
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is not built-in' {
                        $GPPItem.Properties.subAuthority | Should -BeNullOrEmpty
                    }
                    It 'User GPP item expires on 2021-04-16' {
                        $GPPItem.Properties.expires | Should -BeExactly '2021-04-16'
                    }
                }

                Context 'Guest (built-in)' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '004D9C20-5740-41C2-93D3-6950F1FB1FD9' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Guest (built-in)'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'Guest (built-in)'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeExactly 'NewGuest'
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeNullOrEmpty
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User does not have to change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User can change password' {
                        $GPPItem.Properties.noChange | Should -BeFalse
                    }
                    It 'User''s password does not expire' {
                        $GPPItem.Properties.neverExpires | Should -BeTrue
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is built-in GUEST' {
                        $GPPItem.Properties.subAuthority | Should -BeExactly 'RID_GUEST'
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }

                Context 'Administrator (built-in)' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '99D76A31-862D-4487-A220-2D315A60A9A8' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Administrator (built-in)'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'My Admin'
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'Administrator (built-in)'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeNullOrEmpty
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User does not have to change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User cannot change password' {
                        $GPPItem.Properties.noChange | Should -BeTrue
                    }
                    It 'User''s password expires' {
                        $GPPItem.Properties.neverExpires | Should -BeFalse
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is built-in GUEST' {
                        $GPPItem.Properties.subAuthority | Should -BeExactly 'RID_ADMIN'
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }

                Context 'Administrator (built-in)' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'B6D975A2-A835-4583-B424-3CE49A20C2E9' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Administrator (built-in)'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'My Admin'
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'Administrator (built-in)'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeNullOrEmpty
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User does not have to change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User cannot change password' {
                        $GPPItem.Properties.noChange | Should -BeTrue
                    }
                    It 'User''s password expires' {
                        $GPPItem.Properties.neverExpires | Should -BeFalse
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is built-in GUEST' {
                        $GPPItem.Properties.subAuthority | Should -BeExactly 'RID_ADMIN'
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }

                Context 'User 1' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '669E9728-64EC-41E0-9A74-B1BD1179D025' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'User 1'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'User 1'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeNullOrEmpty
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User does not have to change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User can change password' {
                        $GPPItem.Properties.noChange | Should -BeFalse
                    }
                    It 'User''s pasword expires' {
                        $GPPItem.Properties.neverExpires | Should -BeFalse
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is not built-in' {
                        $GPPItem.Properties.subAuthority | Should -BeNullOrEmpty
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }

                Context 'User 1 Delete' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '9AC1238A-8F03-4CAE-B2FC-26680E463AD8' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'User 1 Delete'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'D'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 3
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'User 1'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeNullOrEmpty
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User does not have to change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User can change password' {
                        $GPPItem.Properties.noChange | Should -BeFalse
                    }
                    It 'User''s pasword expires' {
                        $GPPItem.Properties.neverExpires | Should -BeFalse
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is not built-in' {
                        $GPPItem.Properties.subAuthority | Should -BeNullOrEmpty
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }
            }
        }

        Describe 'UNIT: Deserialize-GPPSection' {
            Context 'Groups-UserOnly-Set-1' {
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

                Context 'Disabled-User' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '868E37FD-3A7C-4D17-BF77-2F9A1663B3FD' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Disabled-User'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'My Description'
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'Disabled-User'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeExactly 'New name'
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeExactly 'Full Name'
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User must change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeTrue
                    }
                    It 'User can change password' {
                        $GPPItem.Properties.noChange | Should -BeFalse
                    }
                    It 'User''s pasword expires' {
                        $GPPItem.Properties.neverExpires | Should -BeFalse
                    }
                    It 'User is disabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeTrue
                    }
                    It 'User is not built-in' {
                        $GPPItem.Properties.subAuthority | Should -BeNullOrEmpty
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }

                Context 'NoExpire' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'B0BD4312-90F3-41E5-BC2C-3F37818233B1' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'NoExpire'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'NoExpire description'
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'NoExpire'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeExactly 'NoExpire New Name'
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeExactly 'NoExpire Full Name'
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User must change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User cannot change password' {
                        $GPPItem.Properties.noChange | Should -BeTrue
                    }
                    It 'User''s password does not expire' {
                        $GPPItem.Properties.neverExpires | Should -BeTrue
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is not built-in' {
                        $GPPItem.Properties.subAuthority | Should -BeNullOrEmpty
                    }
                    It 'User GPP item expires on 2021-04-16' {
                        $GPPItem.Properties.expires | Should -BeExactly '2021-04-16'
                    }
                }

                Context 'NoExpireD' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '1C4A9E83-3480-4C29-AC94-802DD2EB7974' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'NoExpireD'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'NoExpire description'
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'NoExpireD'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeExactly 'NoExpire New Name'
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeExactly 'NoExpire Full Name'
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User must change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User cannot change password' {
                        $GPPItem.Properties.noChange | Should -BeTrue
                    }
                    It 'User''s password does not expire' {
                        $GPPItem.Properties.neverExpires | Should -BeTrue
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is not built-in' {
                        $GPPItem.Properties.subAuthority | Should -BeNullOrEmpty
                    }
                    It 'User GPP item expires on 2021-04-16' {
                        $GPPItem.Properties.expires | Should -BeExactly '2021-04-16'
                    }
                }

                Context 'Guest (built-in)' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '004D9C20-5740-41C2-93D3-6950F1FB1FD9' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Guest (built-in)'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'Guest (built-in)'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeExactly 'NewGuest'
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeNullOrEmpty
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User does not have to change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User can change password' {
                        $GPPItem.Properties.noChange | Should -BeFalse
                    }
                    It 'User''s password does not expire' {
                        $GPPItem.Properties.neverExpires | Should -BeTrue
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is built-in GUEST' {
                        $GPPItem.Properties.subAuthority | Should -BeExactly 'RID_GUEST'
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }

                Context 'Administrator (built-in)' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '99D76A31-862D-4487-A220-2D315A60A9A8' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Administrator (built-in)'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'My Admin'
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'Administrator (built-in)'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeNullOrEmpty
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User does not have to change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User cannot change password' {
                        $GPPItem.Properties.noChange | Should -BeTrue
                    }
                    It 'User''s password expires' {
                        $GPPItem.Properties.neverExpires | Should -BeFalse
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is built-in GUEST' {
                        $GPPItem.Properties.subAuthority | Should -BeExactly 'RID_ADMIN'
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }

                Context 'Administrator (built-in)' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'B6D975A2-A835-4583-B424-3CE49A20C2E9' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Administrator (built-in)'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'My Admin'
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'Administrator (built-in)'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeNullOrEmpty
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User does not have to change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User cannot change password' {
                        $GPPItem.Properties.noChange | Should -BeTrue
                    }
                    It 'User''s password expires' {
                        $GPPItem.Properties.neverExpires | Should -BeFalse
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is built-in GUEST' {
                        $GPPItem.Properties.subAuthority | Should -BeExactly 'RID_ADMIN'
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }

                Context 'User 1' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '669E9728-64EC-41E0-9A74-B1BD1179D025' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'User 1'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'User 1'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeNullOrEmpty
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User does not have to change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User can change password' {
                        $GPPItem.Properties.noChange | Should -BeFalse
                    }
                    It 'User''s pasword expires' {
                        $GPPItem.Properties.neverExpires | Should -BeFalse
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is not built-in' {
                        $GPPItem.Properties.subAuthority | Should -BeNullOrEmpty
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }

                Context 'User 1 Delete' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '9AC1238A-8F03-4CAE-B2FC-26680E463AD8' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'User 1 Delete'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'D'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 3
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'User 1'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeNullOrEmpty
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User does not have to change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User can change password' {
                        $GPPItem.Properties.noChange | Should -BeFalse
                    }
                    It 'User''s pasword expires' {
                        $GPPItem.Properties.neverExpires | Should -BeFalse
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is not built-in' {
                        $GPPItem.Properties.subAuthority | Should -BeNullOrEmpty
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }
            }
            Context 'Groups-UserOnly-Set-2' {
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

                Context 'Disabled-User' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '868E37FD-3A7C-4D17-BF77-2F9A1663B3FD' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Disabled-User'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'My Description'
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'Disabled-User'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeExactly 'New name'
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeExactly 'Full Name'
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User must change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeTrue
                    }
                    It 'User can change password' {
                        $GPPItem.Properties.noChange | Should -BeFalse
                    }
                    It 'User''s pasword expires' {
                        $GPPItem.Properties.neverExpires | Should -BeFalse
                    }
                    It 'User is disabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeTrue
                    }
                    It 'User is not built-in' {
                        $GPPItem.Properties.subAuthority | Should -BeNullOrEmpty
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }

                Context 'NoExpire' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'B0BD4312-90F3-41E5-BC2C-3F37818233B1' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'NoExpire'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'NoExpire description'
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'NoExpire'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeExactly 'NoExpire New Name'
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeExactly 'NoExpire Full Name'
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User must change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User cannot change password' {
                        $GPPItem.Properties.noChange | Should -BeTrue
                    }
                    It 'User''s password does not expire' {
                        $GPPItem.Properties.neverExpires | Should -BeTrue
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is not built-in' {
                        $GPPItem.Properties.subAuthority | Should -BeNullOrEmpty
                    }
                    It 'User GPP item expires on 2021-04-16' {
                        $GPPItem.Properties.expires | Should -BeExactly '2021-04-16'
                    }
                }

                Context 'NoExpireD' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '1C4A9E83-3480-4C29-AC94-802DD2EB7974' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'NoExpireD'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'NoExpire description'
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'NoExpireD'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeExactly 'NoExpire New Name'
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeExactly 'NoExpire Full Name'
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User must change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User cannot change password' {
                        $GPPItem.Properties.noChange | Should -BeTrue
                    }
                    It 'User''s password does not expire' {
                        $GPPItem.Properties.neverExpires | Should -BeTrue
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is not built-in' {
                        $GPPItem.Properties.subAuthority | Should -BeNullOrEmpty
                    }
                    It 'User GPP item expires on 2021-04-16' {
                        $GPPItem.Properties.expires | Should -BeExactly '2021-04-16'
                    }
                }

                Context 'Guest (built-in)' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '004D9C20-5740-41C2-93D3-6950F1FB1FD9' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Guest (built-in)'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'Guest (built-in)'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeExactly 'NewGuest'
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeNullOrEmpty
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User does not have to change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User can change password' {
                        $GPPItem.Properties.noChange | Should -BeFalse
                    }
                    It 'User''s password does not expire' {
                        $GPPItem.Properties.neverExpires | Should -BeTrue
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is built-in GUEST' {
                        $GPPItem.Properties.subAuthority | Should -BeExactly 'RID_GUEST'
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }

                Context 'Administrator (built-in)' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '99D76A31-862D-4487-A220-2D315A60A9A8' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Administrator (built-in)'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'My Admin'
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'Administrator (built-in)'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeNullOrEmpty
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User does not have to change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User cannot change password' {
                        $GPPItem.Properties.noChange | Should -BeTrue
                    }
                    It 'User''s password expires' {
                        $GPPItem.Properties.neverExpires | Should -BeFalse
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is built-in GUEST' {
                        $GPPItem.Properties.subAuthority | Should -BeExactly 'RID_ADMIN'
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }

                Context 'Administrator (built-in)' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'B6D975A2-A835-4583-B424-3CE49A20C2E9' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'Administrator (built-in)'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeExactly 'My Admin'
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'Administrator (built-in)'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeNullOrEmpty
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User does not have to change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User cannot change password' {
                        $GPPItem.Properties.noChange | Should -BeTrue
                    }
                    It 'User''s password expires' {
                        $GPPItem.Properties.neverExpires | Should -BeFalse
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is built-in GUEST' {
                        $GPPItem.Properties.subAuthority | Should -BeExactly 'RID_ADMIN'
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }

                Context 'User 1' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '669E9728-64EC-41E0-9A74-B1BD1179D025' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'User 1'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'U'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 2
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'User 1'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeNullOrEmpty
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User does not have to change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User can change password' {
                        $GPPItem.Properties.noChange | Should -BeFalse
                    }
                    It 'User''s pasword expires' {
                        $GPPItem.Properties.neverExpires | Should -BeFalse
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is not built-in' {
                        $GPPItem.Properties.subAuthority | Should -BeNullOrEmpty
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }

                Context 'User 1 Delete' {
                    BeforeAll {
                        $GPPItem = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '9AC1238A-8F03-4CAE-B2FC-26680E463AD8' }
                    }

                    It 'GPP item exists' {
                        $GPPItem | Should -Not -BeNullOrEmpty
                    }
                    It 'GPP item is of a correct type' {
                        $GPPItem | Should -BeOfType [GPPItemUser]
                    }
                    It 'GPP item has a correct name' {
                        $GPPItem.name | Should -BeExactly 'User 1 Delete'
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
                    It 'GPP item action is set to Update' {
                        $GPPItem.Properties.action | Should -BeExactly 'D'
                    }
                    It 'GPP item action numeric value is set to Update' {
                        $GPPItem.Properties.action.value__ | Should -Be 3
                    }
                    It 'GPP item has a correct description' {
                        $GPPItem.Properties.description | Should -BeNullOrEmpty
                    }
                    It 'User has a correct name' {
                        $GPPItem.Properties.userName | Should -BeExactly 'User 1'
                    }
                    It 'User to be renamed correctly' {
                        $GPPItem.Properties.newName | Should -BeNullOrEmpty
                    }
                    It 'User has a correct full name' {
                        $GPPItem.Properties.fullName | Should -BeNullOrEmpty
                    }
                    It 'User must not have a password' {
                        $GPPItem.Properties.cpassword | Should -BeNullOrEmpty
                    }
                    It 'User does not have to change password at next logon' {
                        $GPPItem.Properties.changeLogon | Should -BeFalse
                    }
                    It 'User can change password' {
                        $GPPItem.Properties.noChange | Should -BeFalse
                    }
                    It 'User''s pasword expires' {
                        $GPPItem.Properties.neverExpires | Should -BeFalse
                    }
                    It 'User is enabled' {
                        $GPPItem.Properties.acctDisabled | Should -BeFalse
                    }
                    It 'User is not built-in' {
                        $GPPItem.Properties.subAuthority | Should -BeNullOrEmpty
                    }
                    It 'User GPP item does not expire' {
                        $GPPItem.Properties.expires | Should -BeNullOrEmpty
                    }
                }
            }
        }

        Describe 'UNIT: Serialize-GPPItem' {
            Context 'Groups-UserOnly-Set-<GPPSectionID>' -ForEach @(
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

                Context 'GPPItemUser' {
                    # Serialize-GPPItemUser

                    Context 'Disabled-User' {
                        BeforeAll {
                            $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '868E37FD-3A7C-4D17-BF77-2F9A1663B3FD' }
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'User' -SpecialSerializationTypeNames 'GPPItemPropertiesUser'
                        }

                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML GPP item element exists' {
                            $XMLDocument.User | Should -Not -BeNullOrEmpty
                        }
                        It 'GPP item clsid attribute is correct' {
                            $XMLDocument.User.clsid | Should -Be '{DF5F1855-51E5-4d24-8B1A-D9BDE98BA1D1}'
                        }
                        It 'GPP item uid is correct' {
                            $XMLDocument.User.uid | Should -BeExactly '{868e37fd-3a7c-4d17-bf77-2f9a1663b3fd}'
                        }
                        It 'GPP item name is correct' {
                            $XMLDocument.User.name | Should -BeExactly 'Disabled-User'
                        }
                        It 'GPP item has changed date/time' {
                            $XMLDocument.User.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'GPP item is enabled' {
                            $XMLDocument.User.disabled | Should -BeExactly '0'
                        }
                        It 'GPP item has a correct image' {
                            $XMLDocument.User.image | Should -BeExactly '2'
                        }
                        It 'GPP item bypasses errors' {
                            $XMLDocument.User.bypassErrors | Should -BeExactly '1'
                        }
                        It 'GPP item has removePolicy set to 0' {
                            $XMLDocument.User.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'NoExpire' {
                        BeforeAll {
                            $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'B0BD4312-90F3-41E5-BC2C-3F37818233B1' }
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'User' -SpecialSerializationTypeNames 'GPPItemPropertiesUser'
                        }

                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML GPP item element exists' {
                            $XMLDocument.User | Should -Not -BeNullOrEmpty
                        }
                        It 'GPP item clsid attribute is correct' {
                            $XMLDocument.User.clsid | Should -Be '{DF5F1855-51E5-4d24-8B1A-D9BDE98BA1D1}'
                        }
                        It 'GPP item uid is correct' {
                            $XMLDocument.User.uid | Should -BeExactly '{b0bd4312-90f3-41e5-bc2c-3f37818233b1}'
                        }
                        It 'GPP item name is correct' {
                            $XMLDocument.User.name | Should -BeExactly 'NoExpire'
                        }
                        It 'GPP item has changed date/time' {
                            $XMLDocument.User.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'GPP item is enabled' {
                            $XMLDocument.User.disabled | Should -BeExactly '0'
                        }
                        It 'GPP item has a correct image' {
                            $XMLDocument.User.image | Should -BeExactly '2'
                        }
                        It 'GPP item bypasses errors' {
                            $XMLDocument.User.bypassErrors | Should -BeExactly '1'
                        }
                        It 'GPP item has removePolicy set to 0' {
                            $XMLDocument.User.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'NoExpireD' {
                        BeforeAll {
                            $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '1C4A9E83-3480-4C29-AC94-802DD2EB7974' }
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'User' -SpecialSerializationTypeNames 'GPPItemPropertiesUser'
                        }

                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML GPP item element exists' {
                            $XMLDocument.User | Should -Not -BeNullOrEmpty
                        }
                        It 'GPP item clsid attribute is correct' {
                            $XMLDocument.User.clsid | Should -Be '{DF5F1855-51E5-4d24-8B1A-D9BDE98BA1D1}'
                        }
                        It 'GPP item uid is correct' {
                            $XMLDocument.User.uid | Should -BeExactly '{1c4a9e83-3480-4c29-ac94-802dd2eb7974}'
                        }
                        It 'GPP item name is correct' {
                            $XMLDocument.User.name | Should -BeExactly 'NoExpireD'
                        }
                        It 'GPP item has changed date/time' {
                            $XMLDocument.User.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'GPP item is disabled' {
                            $XMLDocument.User.disabled | Should -BeExactly '1'
                        }
                        It 'GPP item has a correct image' {
                            $XMLDocument.User.image | Should -BeExactly '2'
                        }
                        It 'GPP item bypasses errors' {
                            $XMLDocument.User.bypassErrors | Should -BeExactly '1'
                        }
                        It 'GPP item has removePolicy set to 0' {
                            $XMLDocument.User.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'Guest (built-in)' {
                        BeforeAll {
                            $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '004D9C20-5740-41C2-93D3-6950F1FB1FD9' }
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'User' -SpecialSerializationTypeNames 'GPPItemPropertiesUser'
                        }

                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML GPP item element exists' {
                            $XMLDocument.User | Should -Not -BeNullOrEmpty
                        }
                        It 'GPP item clsid attribute is correct' {
                            $XMLDocument.User.clsid | Should -Be '{DF5F1855-51E5-4d24-8B1A-D9BDE98BA1D1}'
                        }
                        It 'GPP item uid is correct' {
                            $XMLDocument.User.uid | Should -BeExactly '{004d9c20-5740-41c2-93d3-6950f1fb1fd9}'
                        }
                        It 'GPP item name is correct' {
                            $XMLDocument.User.name | Should -BeExactly 'Guest (built-in)'
                        }
                        It 'GPP item has changed date/time' {
                            $XMLDocument.User.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'GPP item is enabled' {
                            $XMLDocument.User.disabled | Should -BeExactly '0'
                        }
                        It 'GPP item has a correct image' {
                            $XMLDocument.User.image | Should -BeExactly '2'
                        }
                        It 'GPP item bypasses errors' {
                            $XMLDocument.User.bypassErrors | Should -BeExactly '1'
                        }
                        It 'GPP item has removePolicy set to 0' {
                            $XMLDocument.User.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'Administrator (built-in)' {
                        BeforeAll {
                            $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '99D76A31-862D-4487-A220-2D315A60A9A8' }
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'User' -SpecialSerializationTypeNames 'GPPItemPropertiesUser'
                        }

                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML GPP item element exists' {
                            $XMLDocument.User | Should -Not -BeNullOrEmpty
                        }
                        It 'GPP item clsid attribute is correct' {
                            $XMLDocument.User.clsid | Should -Be '{DF5F1855-51E5-4d24-8B1A-D9BDE98BA1D1}'
                        }
                        It 'GPP item uid is correct' {
                            $XMLDocument.User.uid | Should -BeExactly '{99d76a31-862d-4487-a220-2d315a60a9a8}'
                        }
                        It 'GPP item name is correct' {
                            $XMLDocument.User.name | Should -BeExactly 'Administrator (built-in)'
                        }
                        It 'GPP item has changed date/time' {
                            $XMLDocument.User.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'GPP item is enabled' {
                            $XMLDocument.User.disabled | Should -BeExactly '0'
                        }
                        It 'GPP item has a correct image' {
                            $XMLDocument.User.image | Should -BeExactly '2'
                        }
                        It 'GPP item bypasses errors' {
                            $XMLDocument.User.bypassErrors | Should -BeExactly '1'
                        }
                        It 'GPP item has removePolicy set to 0' {
                            $XMLDocument.User.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'Administrator (built-in)' {
                        BeforeAll {
                            $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq 'B6D975A2-A835-4583-B424-3CE49A20C2E9' }
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'User' -SpecialSerializationTypeNames 'GPPItemPropertiesUser'
                        }

                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML GPP item element exists' {
                            $XMLDocument.User | Should -Not -BeNullOrEmpty
                        }
                        It 'GPP item clsid attribute is correct' {
                            $XMLDocument.User.clsid | Should -Be '{DF5F1855-51E5-4d24-8B1A-D9BDE98BA1D1}'
                        }
                        It 'GPP item uid is correct' {
                            $XMLDocument.User.uid | Should -BeExactly '{b6d975a2-a835-4583-b424-3ce49a20c2e9}'
                        }
                        It 'GPP item name is correct' {
                            $XMLDocument.User.name | Should -BeExactly 'Administrator (built-in)'
                        }
                        It 'GPP item has changed date/time' {
                            $XMLDocument.User.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'GPP item is disabled' {
                            $XMLDocument.User.disabled | Should -BeExactly '1'
                        }
                        It 'GPP item has a correct image' {
                            $XMLDocument.User.image | Should -BeExactly '2'
                        }
                        It 'GPP item bypasses errors' {
                            $XMLDocument.User.bypassErrors | Should -BeExactly '1'
                        }
                        It 'GPP item has removePolicy set to 0' {
                            $XMLDocument.User.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'User 1' {
                        BeforeAll {
                            $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '669E9728-64EC-41E0-9A74-B1BD1179D025' }
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'User' -SpecialSerializationTypeNames 'GPPItemPropertiesUser'
                        }

                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML GPP item element exists' {
                            $XMLDocument.User | Should -Not -BeNullOrEmpty
                        }
                        It 'GPP item clsid attribute is correct' {
                            $XMLDocument.User.clsid | Should -Be '{DF5F1855-51E5-4d24-8B1A-D9BDE98BA1D1}'
                        }
                        It 'GPP item uid is correct' {
                            $XMLDocument.User.uid | Should -BeExactly '{669e9728-64ec-41e0-9a74-b1bd1179d025}'
                        }
                        It 'GPP item name is correct' {
                            $XMLDocument.User.name | Should -BeExactly 'User 1'
                        }
                        It 'GPP item has changed date/time' {
                            $XMLDocument.User.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'GPP item is enabled' {
                            $XMLDocument.User.disabled | Should -BeExactly '0'
                        }
                        It 'GPP item has a correct image' {
                            $XMLDocument.User.image | Should -BeExactly '2'
                        }
                        It 'GPP item bypasses errors' {
                            $XMLDocument.User.bypassErrors | Should -BeExactly '1'
                        }
                        It 'GPP item has removePolicy set to 0' {
                            $XMLDocument.User.removePolicy | Should -BeExactly '0'
                        }
                    }

                    Context 'User 1 Delete' {
                        BeforeAll {
                            $Item = $GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '9AC1238A-8F03-4CAE-B2FC-26680E463AD8' }
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'User' -SpecialSerializationTypeNames 'GPPItemPropertiesUser'
                        }

                        It 'XML document exists' {
                            $XMLDocument | Should -Not -BeNullOrEmpty
                        }
                        It 'XML GPP item element exists' {
                            $XMLDocument.User | Should -Not -BeNullOrEmpty
                        }
                        It 'GPP item clsid attribute is correct' {
                            $XMLDocument.User.clsid | Should -Be '{DF5F1855-51E5-4d24-8B1A-D9BDE98BA1D1}'
                        }
                        It 'GPP item uid is correct' {
                            $XMLDocument.User.uid | Should -BeExactly '{9ac1238a-8f03-4cae-b2fc-26680e463ad8}'
                        }
                        It 'GPP item name is correct' {
                            $XMLDocument.User.name | Should -BeExactly 'User 1 Delete'
                        }
                        It 'GPP item has changed date/time' {
                            $XMLDocument.User.changed | Should -Not -BeNullOrEmpty
                        }
                        It 'GPP item is enabled' {
                            $XMLDocument.User.disabled | Should -BeExactly '0'
                        }
                        It 'GPP item has a correct image' {
                            $XMLDocument.User.image | Should -BeExactly '3'
                        }
                        It 'GPP item bypasses errors' {
                            $XMLDocument.User.bypassErrors | Should -BeExactly '1'
                        }
                        It 'GPP item has removePolicy set to 0' {
                            $XMLDocument.User.removePolicy | Should -BeExactly '0'
                        }
                    }
                }

                Context 'GPPItemPropertiesUser' {
                    # Serialize-GPPItemPropertiesUser
                    # $InputObject = $GPPSection
                    # $Item In $InputObject.Members
                    # $InputObject = $Item
                    # $InputObject = $InputObject.Properties
                    # Serialize-GPPItem -InputObject $InputObject -RootElementName 'Properties'

                    Context 'Disabled-User' {
                        BeforeAll {
                            $Item = ($GPPSection.Members | Where-Object -FilterScript { $_.uid -eq '868E37FD-3A7C-4D17-BF77-2F9A1663B3FD' }).Properties
                            [xml]$XMLDocument = Serialize-GPPItem -InputObject $Item -RootElementName 'Properties'
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
                                ($XMLDocument.Properties | Get-Member | Where-Object -FilterScript { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Count | Should -Be 10
                            }
                        }

                        Context 'Content' {
                            It 'Action is Update' {
                                $XMLDocument.Properties.action | Should -BeExactly 'U'
                            }
                            It 'Description is correct' {
                                $XMLDocument.Properties.description | Should -BeExactly 'My Description'
                            }
                            It 'User name is correct' {
                                $XMLDocument.Properties.userName | Should -BeExactly 'Disabled-User'
                            }
                            It 'User''s new name is correct' {
                                $XMLDocument.Properties.newName | Should -BeExactly 'New name'
                            }
                            It 'User has a correct full name' {
                                $XMLDocument.Properties.fullName | Should -BeExactly 'Full Name'
                            }
                            It 'User must not have a password' {
                                $XMLDocument.Properties.cpassword | Should -BeNullOrEmpty
                            }
                            It 'User must change password at next logon' {
                                $XMLDocument.Properties.changeLogon | Should -BeExactly '1'
                            }
                            It 'User can change password' {
                                $XMLDocument.Properties.noChange | Should -BeExactly '0'
                            }
                            It 'User''s pasword expires' {
                                $XMLDocument.Properties.neverExpires | Should -BeExactly '0'
                            }
                            It 'User is disabled' {
                                $XMLDocument.Properties.acctDisabled | Should -BeExactly '1'
                            }
                            It 'User is not built-in' {
                                $XMLDocument.Properties.subAuthority | Should -BeNullOrEmpty
                            }
                            It 'User GPP item does not expire' {
                                $XMLDocument.Properties.expires | Should -BeExactly ''
                            }

                        }
                    }

                }
            }
        }
    }
}