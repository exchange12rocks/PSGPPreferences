function Deserialize-GPPItemPropertiesUser {
    Param (
        [Parameter(Mandatory)]
        $XMLNode
    )

    $GPPItemPropertiesElement = $XMLNode

    $UserMustChangePassword = if ($GPPItemPropertiesElement.changeLogon -eq 1) {
        $true
    }
    else {
        $false
    }
    $UserMayNotChangePassword = if ($GPPItemPropertiesElement.noChange -eq 1) {
        $true
    }
    else {
        $false
    }
    $PasswordNeverExpires = if ($GPPItemPropertiesElement.neverExpires -eq 1) {
        $true
    }
    else {
        $false
    }
    $AccountDisabled = if ($GPPItemPropertiesElement.acctDisabled -eq 1) {
        $true
    }
    else {
        $false
    }

    if ($GPPItemPropertiesElement.subAuthority) {
        [GPPItemUserSubAuthority]$BuiltInUser = $GPPItemPropertiesElement.subAuthority
    }
    else {
        if ($null -ne $BuiltInUser) {
            # When in the XML-file, we have a built-in user item and then a regular user item, the $BuiltInUser variable will still have its value when processing the regular user.
            # This confuses the constructor. And we cannot use $BuiltInUser = $null, because the type of this variable does not allow that.
            Remove-Variable -Name 'BuiltInUser'
        }
    }

    if ($UserMustChangePassword) {
        [GPPItemPropertiesUser]::new($GPPItemPropertiesElement.action, $BuiltInUser, $GPPItemPropertiesElement.userName, $GPPItemPropertiesElement.newName, $GPPItemPropertiesElement.fullName, $GPPItemPropertiesElement.description, $UserMustChangePassword, $AccountDisabled, $GPPItemPropertiesElement.expires)
    }
    else {
        [GPPItemPropertiesUser]::new($GPPItemPropertiesElement.action, $BuiltInUser, $GPPItemPropertiesElement.userName, $GPPItemPropertiesElement.newName, $GPPItemPropertiesElement.fullName, $GPPItemPropertiesElement.description, $UserMayNotChangePassword, $PasswordNeverExpires, $AccountDisabled, $GPPItemPropertiesElement.expires)
    }
}