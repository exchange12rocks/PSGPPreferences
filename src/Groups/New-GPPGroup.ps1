function New-GPPGroup {
    [OutputType('GPPItemGroup', ParameterSetName = ('ByGroupNameCreate', 'ByGroupNameReplace', 'ByGroupNameUpdate', 'ByGroupNameDelete', 'ByGroupSIDCreate', 'ByGroupSIDReplace', 'ByGroupSIDUpdate', 'ByGroupSIDDelete'))]
    Param (
        [Parameter(ParameterSetName = 'ByGroupNameCreate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGroupNameReplace', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace', Mandatory)]
        [Parameter(ParameterSetName = 'ByGroupNameUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGroupNameDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameDelete', Mandatory)]
        [string]$Name,
        [Parameter(ParameterSetName = 'ByGroupSIDCreate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGroupSIDReplace', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace', Mandatory)]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGroupSIDDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDDelete', Mandatory)]
        [System.Security.Principal.SecurityIdentifier]$SID,
        [Parameter(ParameterSetName = 'ByGroupNameCreate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGroupSIDCreate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate', Mandatory)]
        [switch]$Create,
        [Parameter(ParameterSetName = 'ByGroupNameReplace', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace', Mandatory)]
        [Parameter(ParameterSetName = 'ByGroupSIDReplace', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace', Mandatory)]
        [switch]$Replace,
        [Parameter(ParameterSetName = 'ByGroupNameUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate', Mandatory)]
        [switch]$Update,
        [Parameter(ParameterSetName = 'ByGroupNameDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGroupSIDDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDDelete', Mandatory)]
        [switch]$Delete,
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDDelete', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameDelete', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDDelete', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameDelete')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDDelete')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameDelete')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDDelete')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext,
        [Parameter(ParameterSetName = 'ByGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate')]
        [string]$NewName,
        [Parameter(ParameterSetName = 'ByGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate')]
        [string]$Description,
        [Parameter(ParameterSetName = 'ByGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate')]
        [switch]$DeleteAllUsers,
        [Parameter(ParameterSetName = 'ByGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate')]
        [switch]$DeleteAllGroups,
        [Parameter(ParameterSetName = 'ByGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate')]
        [switch]$Disable,
        [Parameter(ParameterSetName = 'ByGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate')]
        [GPPItemGroupMember[]]$Members,
        [Parameter(ParameterSetName = 'ByGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate')]
        [switch]$PassThru
    )

    if ($SID) {
        $Name = [System.Security.Principal.SecurityIdentifier]::new($SID).Translate([System.Security.Principal.NTAccount]).Value
    }

    $Action = if ($Create) {
        [GPPItemAction]::C
    }
    elseif ($Replace) {
        [GPPItemAction]::R
    }
    elseif ($Update) {
        [GPPItemAction]::U
    }
    else {
        [GPPItemAction]::D
    }

    $Properties = [GPPItemPropertiesGroup]::new($Action, $Name, $SID, $NewName, $Description, $Members)
    $Group = [GPPItemGroup]::new($Properties, $Disable)

    if ($GPOName -or $GPOId) {
        $ParametersAddGPPGroup = @{
            InputObject = $Group
            Context     = $Context
        }

        if ($GPOId) {
            $ParametersAddGPPGroup.Add('GPOId', $GPOId)
        }
        else {
            $ParametersAddGPPGroup.Add('GPOName', $GPOName)
        }

        if ($PassThru) {
            $Group
        }
        Add-GPPGroup @ParametersAddGPPGroup
    }
    else {
        $Group
    }
}
