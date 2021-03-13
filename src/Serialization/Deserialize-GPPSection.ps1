function Deserialize-GPPSection {
    Param (
        [xml]$InputObject
    )

    $RootElement = $InputObject.DocumentElement

    switch ($RootElement.Name) {
        'Groups' {
            $GroupsMembers = [System.Collections.Generic.List[GPPItemGroupsSection]]::new()

            foreach ($ChildNode in $RootElement.ChildNodes) {
                switch ($ChildNode.LocalName) {
                    'Group' {
                        $GPPItemPropertiesGroupElement = $ChildNode.Properties
                        $GPPItemGroupMembersElement = $GPPItemPropertiesGroupElement.Members.Member

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

                        $GPPItemPropertiesGroupElementPropertyDefinitions = (Get-Member -InputObject $GPPItemPropertiesGroupElement | Where-Object { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Name
                        foreach ($PropertyDefinition in $GPPItemPropertiesGroupElementPropertyDefinitions) {
                            if ($GPPItemPropertiesGroupElement.$PropertyDefinition -eq '') {
                                $GPPItemPropertiesGroupElement.RemoveAttribute($PropertyDefinition)
                            }
                        }

                        $DeleteAllUsers = if ($GPPItemPropertiesGroupElement.deleteAllUsers -eq 1) {
                            $true
                        }
                        else {
                            $false
                        }
                        $DeleteAllGroups = if ($GPPItemPropertiesGroupElement.deleteAllGroups -eq 1) {
                            $true
                        }
                        else {
                            $false
                        }
                        $GPPItemPropertiesGroup = [GPPItemPropertiesGroup]::new($GPPItemPropertiesGroupElement.action, $GPPItemPropertiesGroupElement.groupName, $GPPItemPropertiesGroupElement.groupSid, $GPPItemPropertiesGroupElement.newName, $GPPItemPropertiesGroupElement.description, $Members, $DeleteAllUsers, $DeleteAllGroups)
                        $Disabled = if ($ChildNode.disabled -eq 1) {
                            $true
                        }
                        else {
                            $false
                        }
                        $GroupsMembers.Add([GPPItemGroup]::new($GPPItemPropertiesGroup, [guid]$ChildNode.uid, $Disabled))
                    }
                    'User' {
                        # TODO
                    }
                }
            }

            # The following is as it is because:
            # > $RootElement.disabled.gettype().name
            # String
            # And $true / $false does not play well with string content.
            # But implicit type convertion works well with string -> int 
            $SectionDisabled = if ($RootElement.disabled -eq 1) {
                $true
            }
            else {
                $false
            }
            [GPPSectionGroups]::new($GroupsMembers, $SectionDisabled)
        }
        'Files' {
            # TODO
        }
        'IniFiles' {
            # TODO
        }
    }
}
