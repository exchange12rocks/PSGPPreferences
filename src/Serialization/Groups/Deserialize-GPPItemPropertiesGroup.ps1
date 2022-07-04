function Deserialize-GPPItemPropertiesGroup {
    Param (
        [Parameter(Mandatory)]
        $XMLNode
    )

    $GPPItemPropertiesElement = $XMLNode

    $GPPItemGroupMembersElement = $GPPItemPropertiesElement.Members.Member

    $Members = $null
    if ($GPPItemGroupMembersElement) {
        $Members = [System.Collections.Generic.List[GPPItemGroupMember]]::new()
        foreach ($Item in $GPPItemGroupMembersElement) {
            if ($Item.sid) {
                [void]$Members.Add([GPPItemGroupMember]::new($Item.action, $Item.name, $Item.sid))
            }
            else {
                [void]$Members.Add([GPPItemGroupMember]::new($Item.action, $Item.name))
            }
        }
    }

    $DeleteAllUsers = if ($GPPItemPropertiesElement.deleteAllUsers -eq 1) {
        $true
    }
    else {
        $false
    }
    $DeleteAllGroups = if ($GPPItemPropertiesElement.deleteAllGroups -eq 1) {
        $true
    }
    else {
        $false
    }

    [GPPItemPropertiesGroup]::new($GPPItemPropertiesElement.action, $GPPItemPropertiesElement.groupName, $GPPItemPropertiesElement.groupSid, $GPPItemPropertiesElement.newName, $GPPItemPropertiesElement.description, $Members, $DeleteAllUsers, $DeleteAllGroups)
}