function Serialize-GPPItemPropertiesGroup {
    Param (
        [Parameter(Mandatory)]
        [GPPItemPropertiesGroup]$InputObject
    )

    $RootElementName = 'Properties'

    $XmlDocument = Serialize-GPPItem -InputObject $InputObject -RootElementName $RootElementName -SpecialSerializationTypeNames 'GPPItemGroupMember'

    if ($InputObject.Members) {
        $RootElement = $XmlDocument.$RootElementName

        $ChildrenElement = $XmlDocument.CreateElement('Members')
        [void]$RootElement.AppendChild($ChildrenElement)
        foreach ($Item in $InputObject.Members) {
            $ChildElement = Serialize-GPPItemGroupMember -InputObject $Item
            $ImportedChildElement = $XmlDocument.ImportNode($ChildElement.Member, $false)
            [void]$ChildrenElement.AppendChild($ImportedChildElement)
        }
    }

    $XmlDocument
}