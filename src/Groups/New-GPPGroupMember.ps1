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
        $SID = ([System.Security.Principal.NTAccount]::new($Name)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    }
    else {
        $Name = [System.Security.Principal.SecurityIdentifier]::new($SID).Translate([System.Security.Principal.NTAccount]).Value
    }

    [GPPItemGroupMember]::new($Action, $Name, $SID)
}