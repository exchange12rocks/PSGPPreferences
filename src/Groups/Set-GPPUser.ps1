function Set-GPPUser {
    [OutputType('GPPItemUser')]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameObject', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObject', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword', Mandatory)]
        [GPPItemUser[]]$InputObject,
        [Parameter(ParameterSetName = 'ByGPONameItemName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemNameUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemNameUserMustChangePassword', Mandatory)]
        [string]$Name,
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralNameUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralNameUserMustChangePassword', Mandatory)]
        [string]$LiteralName,
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUserUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUserUserMustChangePassword', Mandatory)]
        [GPPItemUserSubAuthorityDisplay]$BuiltInUser,
        [Parameter(ParameterSetName = 'ByGPONameObject', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemNameUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralNameUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUserUserMustChangePassword', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ByGPOIdObject', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemNameUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralNameUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUserUserMustChangePassword', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUserUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUserUserMustChangePassword')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUserUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUserUserMustChangePassword')]
        [GPPItemUserActionDisplay]$Action,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUserUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUserUserMustChangePassword')]
        [string]$NewName,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUserUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUserUserMustChangePassword')]
        [string]$FullName,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUserUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUserUserMustChangePassword')]
        [string]$Description,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUserUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUserUserMustChangePassword')]
        [bool]$AccountDisabled,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUserUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUserUserMustChangePassword')]
        [datetime]$AccountExpires,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [bool]$PasswordNeverExpires,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [bool]$UserMayNotChangePassword,
        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemNameUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemNameUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralNameUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralNameUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUserUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUserUserMustChangePassword', Mandatory)]
        [bool]$UserMustChangePassword,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUserUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUserUserMustChangePassword')]
        [bool]$Disable,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUserUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUserUserMustChangePassword')]
        [switch]$PassThru
    )

    if (-not $GPOId) {
        $GPOId = Convert-GPONameToID -Name $GPOName
    }
    $GPPSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)

    if ($GPPSection) {
        if (-not $InputObject) {
            $GetFunctionParameters = @{}

            if ($BuiltInUser) {
                $GetFunctionParameters.Add('BuiltInUser', $BuiltInUser)
            }
            elseif ($LiteralName) {
                $GetFunctionParameters.Add('LiteralName', $LiteralName)
            }
            else {
                $GetFunctionParameters.Add('Name', $Name)
            }

            $InputObject = Get-GPPUser @GetFunctionParameters -GPPSection $GPPSection
        }

        if ($InputObject) {
            foreach ($UserObject in $InputObject) {
                if ($PSBoundParameters.ContainsKey('Action')) {
                    $UserObject.Properties.Action = switch ($Action) {
                        ([GPPItemUserActionDisplay]::Update) {
                            [GPPItemAction]::U
                        }
                        ([GPPItemUserActionDisplay]::Delete) {
                            [GPPItemAction]::D
                        }
                    }
                }

                if ($UserObject.Properties.Action -ne [GPPItemAction]::D) {
                    if ($PSBoundParameters.ContainsKey('UserMustChangePassword')) {
                        if ($UserMustChangePassword) {
                            $UserObject.Properties.noChange = $null
                            $UserObject.Properties.neverExpires = $null
                        }
                        $UserObject.Properties.changeLogon = $UserMustChangePassword
                    }
                    elseif ($PSBoundParameters.ContainsKey('PasswordNeverExpires') -or $PSBoundParameters.ContainsKey('UserMayNotChangePassword')) {
                        if ($PasswordNeverExpires -or $UserMayNotChangePassword) {
                            $UserObject.Properties.changeLogon = $null
                        }
                        if ($PSBoundParameters.ContainsKey('PasswordNeverExpires')) {
                            $UserObject.Properties.neverExpires = $PasswordNeverExpires
                        }
                        if ($PSBoundParameters.ContainsKey('UserMayNotChangePassword')) {
                            $UserObject.Properties.noChange = $UserMayNotChangePassword
                        }
                    }

                    if ($PSBoundParameters.ContainsKey('NewName')) {
                        $UserObject.Properties.newName = $NewName
                    }
                    if ($PSBoundParameters.ContainsKey('FullName')) {
                        $UserObject.Properties.fullName = $FullName
                    }
                    if ($PSBoundParameters.ContainsKey('Description')) {
                        $UserObject.Properties.description = $Description
                    }
                    if ($PSBoundParameters.ContainsKey('AccountDisabled')) {
                        $UserObject.Properties.acctDisabled = $AccountDisabled
                    }
                    if ($PSBoundParameters.ContainsKey('AccountExpires')) {
                        $UserObject.Properties.expires = Convert-DateTimeToGPPExpirationDate -DateTime $AccountExpires
                    }
                }
                else {
                    $UserObject.Properties.newName = $null
                    $UserObject.Properties.fullName = $null
                    $UserObject.Properties.description = $null
                    $UserObject.Properties.changeLogon = $null
                    $UserObject.Properties.noChange = $null
                    $UserObject.Properties.neverExpires = $null
                    $UserObject.Properties.acctDisabled = $null
                    $UserObject.Properties.subAuthority = $null
                    $UserObject.Properties.expires = $null
                }

                if ($PSBoundParameters.ContainsKey('Disable')) {
                    $UserObject.disabled = $Disable
                }

                $UserObject.image = $UserObject.Properties.action.value__ # Fixes up the item's icon in case we changed its action

                $NewGPPSection = Remove-GPPUser -GPPSection $GPPSection -UID $UserObject.uid

                if ($NewGPPSection) {
                    $NewGPPSection.Members.Add($UserObject)
                }
                else {
                    $NewGPPSection = [GPPSectionGroups]::new($UserObject, $false)
                }

                if ($PassThru) {
                    $UserObject
                }
                Set-GPPSection -InputObject $NewGPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
            }
        }
    }
}