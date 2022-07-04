function Deserialize-GPPItem {
    Param (
        [Parameter(Mandatory)]
        $XMLNode
    )

    $GPPItemPropertiesNode = Clean-GPPItemProperties -XMLNode $XMLNode

    $Disabled = Test-IsNodeDisabled -XMLNode $XMLNode

    switch ($XMLNode.LocalName) {
        'Group' {
            $GPPItemProperties = Deserialize-GPPItemPropertiesGroup -XMLNode $GPPItemPropertiesNode

            [GPPItemGroup]::new($GPPItemProperties, [guid]$XMLNode.uid, $Disabled, $XMLNode.name)
        }
        'User' {
            $GPPItemProperties = Deserialize-GPPItemPropertiesUser -XMLNode $GPPItemPropertiesNode

            [GPPItemUser]::new($GPPItemProperties, [guid]$XMLNode.uid, $Disabled, $XMLNode.name)
        }
        'PortPrinter' {
            $GPPItemProperties = Deserialize-GPPItemPropertiesPortPrinter -XMLNode $GPPItemPropertiesNode

            [GPPItemPortPrinter]::new($GPPItemProperties, [guid]$XMLNode.uid, $Disabled, $XMLNode.name)
        }
        'LocalPrinter' {
            $GPPItemProperties = Deserialize-GPPItemPropertiesLocalPrinter -XMLNode $GPPItemPropertiesNode

            [GPPItemLocalPrinter]::new($GPPItemProperties, [guid]$XMLNode.uid, $Disabled, $XMLNode.name)
        }
    }
}