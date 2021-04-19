function Set-GPPUser {
    [OutputType('GPPItemUser')]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameObject', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObject', Mandatory)]
        [GPPItemUser]$InputObject,
        [Parameter(ParameterSetName = 'ByGPONameItemName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemName', Mandatory)]
        [string]$Name,
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName', Mandatory)]
        [string]$LiteralName,
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser', Mandatory)]
        [GPPItemUserSubAuthorityDisplay]$BuiltInUser,
        [Parameter(ParameterSetName = 'ByGPONameObject', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ByGPOIdObject', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [GPPItemUserActionDisplay]$Action,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [string]$NewName,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [string]$FullName,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [string]$Description,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [bool]$AccountDisabled,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
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
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [bool]$UserMustChangePassword,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [bool]$Disable,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [switch]$PassThru
    )

    if (-not $GPOId) {
        $GPOId = Convert-GPONameToID -Name $GPOName
    }
    $GPPSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)

    if ($GPPSection) {
        $InternalAction = if ($PSBoundParameters.ContainsKey('Action')) {
            switch ($Action) {
                ([GPPItemUserActionDisplay]::Update) {
                    [GPPItemAction]::U
                }
                ([GPPItemUserActionDisplay]::Delete) {
                    [GPPItemAction]::D
                }
            }
        }
        else {
            [GPPItemAction]::U
        }

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

        if ($PSBoundParameters.ContainsKey('Action')) {
            $InputObject.Properties.Action = $InternalAction
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
            $InputObject.Properties.userName = $null
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