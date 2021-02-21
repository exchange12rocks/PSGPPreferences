function Initialize-GPPSection {
    $XmlDocument = [System.Xml.XmlDocument]::new()
    $XmlDeclarationElement = $XmlDocument.CreateXmlDeclaration('1.0', 'utf-8', $null)
    [void]$XmlDocument.AppendChild($XmlDeclarationElement)

    $XmlDocument
}