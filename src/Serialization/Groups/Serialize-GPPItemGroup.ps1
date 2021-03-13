function Serialize-GPPItemGroup {
    Param (
        [Parameter(Mandatory)]
        [GPPItemGroup]$InputObject
    )

    $RootElementName = 'Group'

    $XmlDocument = Serialize-GPPItem -InputObject $InputObject -RootElementName $RootElementName -SpecialSerializationTypeNames 'GPPItemPropertiesGroup'

    if ($InputObject.Properties) {
        $RootElement = $XmlDocument.$RootElementName

        $ChildElement = Serialize-GPPItemPropertiesGroup -InputObject $InputObject.Properties
        $ImportedChildElement = $XmlDocument.ImportNode($ChildElement.Properties, $true)
        [void]$RootElement.AppendChild($ImportedChildElement)

        $XmlDocument
    }
}