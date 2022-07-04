function Deserialize-GPPSectionGroups {
    Param (
        [Parameter(Mandatory)]
        [System.Xml.XmlElement]$InputObject
    )

    $SectionMembers = [System.Collections.Generic.List[GPPItemGroupsSection]]::new()

    $SectionMembers = foreach ($ChildNode in $InputObject.ChildNodes) {
        Deserialize-GPPItem -XMLNode $ChildNode
    }

    $SectionDisabled = Test-IsNodeDisabled -XMLNode $InputObject

    [GPPSectionGroups]::new($SectionMembers, $SectionDisabled)
}