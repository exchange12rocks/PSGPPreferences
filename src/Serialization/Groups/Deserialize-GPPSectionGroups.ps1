function Deserialize-GPPSectionGroups {
    Param (
        [Parameter(Mandatory)]
        [System.Xml.XmlElement]$InputObject
    )

    $GroupsMembers = [System.Collections.Generic.List[GPPItemGroupsSection]]::new()

    foreach ($ChildNode in $InputObject.ChildNodes) {
        $GPPItemPropertiesElement = $ChildNode.Properties
        $GPPItemPropertiesElementPropertyDefinitions = (Get-Member -InputObject $GPPItemPropertiesElement | Where-Object { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Name
        foreach ($PropertyDefinition in $GPPItemPropertiesElementPropertyDefinitions) {
            if ($GPPItemPropertiesElement.$PropertyDefinition -eq '') {
                $GPPItemPropertiesElement.RemoveAttribute($PropertyDefinition)
            }
        }

        $Disabled = if ($ChildNode.disabled -eq 1) {
            $true
        }
        else {
            $false
        }

        switch ($ChildNode.LocalName) {
            'Group' {
                $GPPItemGroupMembersElement = $GPPItemPropertiesElement.Members.Member

                $Members = $null
                if ($GPPItemGroupMembersElement) {
                    $Members = [System.Collections.Generic.List[GPPItemGroupMember]]::new()
                    foreach ($Item in $GPPItemGroupMembersElement) {
                        if ($Item.sid) {
                            $Members.Add([GPPItemGroupMember]::new($Item.action, $Item.name, $Item.sid))
                        }
                        else {
                            $Members.Add([GPPItemGroupMember]::new($Item.action, $Item.name))
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

                $GPPItemPropertiesGroup = [GPPItemPropertiesGroup]::new($GPPItemPropertiesElement.action, $GPPItemPropertiesElement.groupName, $GPPItemPropertiesElement.groupSid, $GPPItemPropertiesElement.newName, $GPPItemPropertiesElement.description, $Members, $DeleteAllUsers, $DeleteAllGroups)

                $GroupsMembers.Add([GPPItemGroup]::new($GPPItemPropertiesGroup, [guid]$ChildNode.uid, $Disabled))
            }
            'User' {
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
                    $BuiltInUser = $null
                }

                $GPPItemPropertiesUser = if ($UserMustChangePassword) {
                    [GPPItemPropertiesUser]::new($GPPItemPropertiesElement.action, $BuiltInUser, $GPPItemPropertiesElement.userName, $GPPItemPropertiesElement.newName, $GPPItemPropertiesElement.fullName, $GPPItemPropertiesElement.description, $UserMustChangePassword, $AccountDisabled, $GPPItemPropertiesElement.expires)
                }
                else {
                    [GPPItemPropertiesUser]::new($GPPItemPropertiesElement.action, $BuiltInUser, $GPPItemPropertiesElement.userName, $GPPItemPropertiesElement.newName, $GPPItemPropertiesElement.fullName, $GPPItemPropertiesElement.description, $UserMayNotChangePassword, $PasswordNeverExpires, $AccountDisabled, $GPPItemPropertiesElement.expires)
                }

                $GroupsMembers.Add([GPPItemUser]::new($GPPItemPropertiesUser, [guid]$ChildNode.uid, $Disabled))
            }
        }
    }

    # The following is as it is because:
    # > $InputObject.disabled.gettype().name
    # String
    # And $true / $false does not play well with string content.
    # But implicit type convertion works well with string -> int
    $SectionDisabled = if ($InputObject.disabled -eq 1) {
        $true
    }
    else {
        $false
    }
    [GPPSectionGroups]::new($GroupsMembers, $SectionDisabled)

}