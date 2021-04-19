function Serialize-GPPItemUser {
    Param (
        [Parameter(Mandatory)]
        [GPPItemUser]$InputObject
    )

    $RootElementName = 'User'

    $XmlDocument = Serialize-GPPItem -InputObject $InputObject -RootElementName $RootElementName -SpecialSerializationTypeNames 'GPPItemPropertiesUser'

    if ($InputObject.Properties) {
        $RootElement = $XmlDocument.$RootElementName

        $ChildElement = Serialize-GPPItemPropertiesUser -InputObject $InputObject.Properties
        $ImportedChildElement = $XmlDocument.ImportNode($ChildElement.Properties, $true)
        [void]$RootElement.AppendChild($ImportedChildElement)

        $XmlDocument
    }
}