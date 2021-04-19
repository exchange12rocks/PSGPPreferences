function Serialize-GPPItemPropertiesUser {
    Param (
        [Parameter(Mandatory)]
        [GPPItemPropertiesUser]$InputObject
    )

    $RootElementName = 'Properties'

    $XmlDocument = Serialize-GPPItem -InputObject $InputObject -RootElementName $RootElementName

    $XmlDocument
}