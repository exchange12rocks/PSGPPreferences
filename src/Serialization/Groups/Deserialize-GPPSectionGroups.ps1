function Deserialize-GPPSectionGroups {
    Param (
        [Parameter(Mandatory)]
        [System.Xml.XmlElement]$InputObject
    )

    $SectionMembers = [System.Collections.Generic.List[GPPItemGroupsSection]]::new()

    $SectionMembers = foreach ($ChildNode in $InputObject.ChildNodes) {
        $GPPItemPropertiesElement = Clean-GPPItemProperties -XMLNode $ChildNode

        $Disabled = Test-IsNodeDisabled -XMLNode $ChildNode

        switch ($ChildNode.LocalName) {
            'Group' {
                $GPPItemPropertiesGroup = Deserialize-GPPItemPropertiesGroup -XMLNode $GPPItemPropertiesElement

                [GPPItemGroup]::new($GPPItemPropertiesGroup, [guid]$ChildNode.uid, $Disabled, $ChildNode.name)
            }
            'User' {
                $GPPItemPropertiesUser = Deserialize-GPPItemPropertiesUser -XMLNode $GPPItemPropertiesElement

                [GPPItemUser]::new($GPPItemPropertiesUser, [guid]$ChildNode.uid, $Disabled, $ChildNode.name)
            }
        }
    }

    $SectionDisabled = Test-IsNodeDisabled -XMLNode $InputObject

    [GPPSectionGroups]::new($SectionMembers, $SectionDisabled)
}