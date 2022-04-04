function New-GPPGroupMember {
    [OutputType('GPPItemGroupMember')]
    Param (
        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [string]$Name,
        [Parameter(ParameterSetName = 'BySID', Mandatory)]
        [System.Security.Principal.SecurityIdentifier]$SID,
        [Parameter(ParameterSetName = 'ByName')]
        [Parameter(ParameterSetName = 'BySID')]
        [GPPItemGroupMemberAction]$Action
    )

    if ($Name) {
        try {
            $SID = ([System.Security.Principal.NTAccount]::new($Name)).Translate([System.Security.Principal.SecurityIdentifier]).Value
        }
        catch {
            # https://github.com/exchange12rocks/PSGPPreferences/issues/31
            # Not all names should be resolved into SIDs. Especially names with GPP variables in them.

            $SID = $null
            if ($_.FullyQualifiedErrorId -ne 'IdentityNotMappedException') {
                throw $_
            }
        }
    }
    else {
        $Name = [System.Security.Principal.SecurityIdentifier]::new($SID).Translate([System.Security.Principal.NTAccount]).Value
    }

    [GPPItemGroupMember]::new($Action, $Name, $SID)
}