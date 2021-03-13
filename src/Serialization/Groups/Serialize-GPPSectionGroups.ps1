function Serialize-GPPSectionGroups {
    Param (
        [Parameter(Mandatory)]
        [GPPSectionGroups]$InputObject
    )

    $RootElementName = 'Groups'

    $XmlDocument = Initialize-GPPSection

    $RootElement = Serialize-GPPItem -InputObject $InputObject -RootElementName $RootElementName -SpecialSerializationTypeNames ('GPPItemGroup', 'GPPItemUser')
    $ImportedRootElement = $XmlDocument.ImportNode($RootElement.$RootElementName, $true)
    [void]$XmlDocument.AppendChild($ImportedRootElement)


    if ($InputObject.Members) {
        $RootElement = $XmlDocument.$RootElementName

        foreach ($Item in $InputObject.Members) {
            $ImportedChildElement = switch ($Item.GetType().FullName) {
                'GPPItemGroup' {
                    $ChildElement = Serialize-GPPItemGroup -InputObject $Item
                    $XmlDocument.ImportNode($ChildElement.Group, $true)
                }
                'GPPItemUser' {
                    $ChildElement = Serialize-GPPItemUser -InputObject $Item
                    $XmlDocument.ImportNode($ChildElement.User, $true)
                }
            }

            [void]$RootElement.AppendChild($ImportedChildElement)
        }
    }

    $XmlDocument
}