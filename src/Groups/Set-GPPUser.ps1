function Set-GPPUser {
    [OutputType('GPPItemUser')]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameObject', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObject', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword', Mandatory)]
        [GPPItemUser]$InputObject,
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
        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralNameUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUserUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUserUserMustChangePassword')]
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
            if ($PSBoundParameters.ContainsKey('Action')) {
                $InputObject.Properties.Action = switch ($Action) {
                ([GPPItemUserActionDisplay]::Update) {
                        [GPPItemAction]::U
                    }
                ([GPPItemUserActionDisplay]::Delete) {
                        [GPPItemAction]::D
                    }
                }
            }

            if ($InputObject.Properties.Action -ne [GPPItemAction]::D) {
                if ($PSBoundParameters.ContainsKey('UserMustChangePassword')) {
                    if ($UserMustChangePassword) {
                        $InputObject.Properties.noChange = $null
                        $InputObject.Properties.neverExpires = $null
                    }
                    $InputObject.Properties.changeLogon = $UserMustChangePassword
                }
                elseif ($PSBoundParameters.ContainsKey('PasswordNeverExpires') -or $PSBoundParameters.ContainsKey('UserMayNotChangePassword')) {
                    if ($PasswordNeverExpires -or $UserMayNotChangePassword) {
                        $InputObject.Properties.changeLogon = $null
                    }
                    if ($PSBoundParameters.ContainsKey('PasswordNeverExpires')) {
                        $InputObject.Properties.neverExpires = $PasswordNeverExpires
                    }
                    if ($PSBoundParameters.ContainsKey('UserMayNotChangePassword')) {
                        $InputObject.Properties.noChange = $UserMayNotChangePassword
                    }
                }

                if ($PSBoundParameters.ContainsKey('NewName')) {
                    $InputObject.Properties.newName = $NewName
                }
                if ($PSBoundParameters.ContainsKey('FullName')) {
                    $InputObject.Properties.fullName = $FullName
                }
                if ($PSBoundParameters.ContainsKey('Description')) {
                    $InputObject.Properties.description = $Description
                }
                if ($PSBoundParameters.ContainsKey('AccountDisabled')) {
                    $InputObject.Properties.acctDisabled = $AccountDisabled
                }
                if ($PSBoundParameters.ContainsKey('AccountExpires')) {
                    $InputObject.Properties.expires = Convert-DateTimeToGPPExpirationDate -DateTime $AccountExpires
                }
            }
            else {
                $InputObject.Properties.newName = $null
                $InputObject.Properties.fullName = $null
                $InputObject.Properties.description = $null
                $InputObject.Properties.changeLogon = $null
                $InputObject.Properties.noChange = $null
                $InputObject.Properties.neverExpires = $null
                $InputObject.Properties.acctDisabled = $null
                $InputObject.Properties.subAuthority = $null
                $InputObject.Properties.expires = $null
            }

            if ($PSBoundParameters.ContainsKey('Disable')) {
                $InputObject.disabled = $Disable
            }

            $InputObject.image = $InputObject.Properties.action.value__ # Fixes up the item's icon in case we changed its action

            $NewGPPSection = Remove-GPPUser -GPPSection $GPPSection -UID $InputObject.uid

            if ($NewGPPSection) {
                $NewGPPSection.Members.Add($InputObject)
            }
            else {
                $NewGPPSection = [GPPSectionGroups]::new($InputObject, $false)
            }

            if ($PassThru) {
                $InputObject
            }
            Set-GPPSection -InputObject $NewGPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
        }
    }
}