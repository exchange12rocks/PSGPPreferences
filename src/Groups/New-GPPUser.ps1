function New-GPPUser {
    [OutputType('GPPItemUser', ParameterSetName = ('ByObjectNameUpdate', 'BuiltInUserUpdate', 'ByObjectNameDelete', 'ByObjectNameUpdateUserMustChangePassword', 'BuiltInUserUpdateUserMustChangePassword'))]
    Param (
        [Parameter(ParameterSetName = 'ByObjectNameUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByObjectNameDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword', Mandatory)]
        [string]$Name,
        [Parameter(ParameterSetName = 'BuiltInUserUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword', Mandatory)]
        [GPPItemUserSubAuthority]$BuiltInUser,
        [Parameter(ParameterSetName = 'ByObjectNameUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword', Mandatory)]
        [switch]$Update,
        [Parameter(ParameterSetName = 'ByObjectNameDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameDelete', Mandatory)]
        [switch]$Delete,
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameDelete')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameDelete')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext,
        [Parameter(ParameterSetName = 'ByObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword')]
        [string]$NewName,
        [Parameter(ParameterSetName = 'ByObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword')]
        [string]$FullName,
        [Parameter(ParameterSetName = 'ByObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword')]
        [string]$Description,
        [Parameter(ParameterSetName = 'ByObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword')]
        [switch]$AccountDisabled,
        [Parameter(ParameterSetName = 'ByObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword')]
        [datetime]$AccountExpires,
        [Parameter(ParameterSetName = 'ByObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [switch]$PasswordNeverExpires,
        [Parameter(ParameterSetName = 'ByObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [switch]$UserMayNotChangePassword,
        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword', Mandatory)]
        [switch]$UserMustChangePassword,
        [Parameter(ParameterSetName = 'ByObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByObjectNameDelete')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameDelete')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameDelete')]
        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword')]
        [switch]$Disable,
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameDelete')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameDelete')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword')]
        [switch]$PassThru
    )

    $Action = if ($Update) {
        [GPPItemAction]::U
    }
    else {
        [GPPItemAction]::D
    }

    $Properties = if ($PSBoundParameters.ContainsKey('BuiltInUser')) {
        if ($PSBoundParameters.ContainsKey('UserMustChangePassword')) {
            [GPPItemPropertiesUser]::new($Action, $BuiltInUser, $NewName, $FullName, $Description, $UserMustChangePassword, $AccountDisabled, $AccountExpires)
        }
        else {
            [GPPItemPropertiesUser]::new($Action, $BuiltInUser, $NewName, $FullName, $Description, $UserMayNotChangePassword, $PasswordNeverExpires, $AccountDisabled, $AccountExpires)
        }
    }
    else {
        if ($PSBoundParameters.ContainsKey('UserMustChangePassword')) {
            [GPPItemPropertiesUser]::new($Action, $Name, $NewName, $FullName, $Description, $UserMustChangePassword, $AccountDisabled, $AccountExpires)
        }
        else {
            [GPPItemPropertiesUser]::new($Action, $Name, $NewName, $FullName, $Description, $UserMayNotChangePassword, $PasswordNeverExpires, $AccountDisabled, $AccountExpires)
        }
    }

    $User = [GPPItemUser]::new($Properties, $Disable)

    if ($GPOName -or $GPOId) {
        $ParametersAddGPPUser = @{
            InputObject = $User
            Context     = $Context
        }

        if ($GPOId) {
            $ParametersAddGPPUser.Add('GPOId', $GPOId)
        }
        else {
            $ParametersAddGPPUser.Add('GPOName', $GPOName)
        }

        if ($PassThru) {
            $User
        }
        Add-GPPUser @ParametersAddGPPUser
    }
    else {
        $User
    }
}

New-GPPUser -Update -AccountExpires (Get-Date) -BuiltInUser RID_ADMIN