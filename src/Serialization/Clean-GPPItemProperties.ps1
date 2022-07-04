function Clean-GPPItemProperties {
    Param (
        [Parameter(Mandatory)]
        $XMLNode
    )

    $ChildNode = $XMLNode
    $GPPItemPropertiesElement = $ChildNode.Properties
    $GPPItemPropertiesElementPropertyDefinitions = (Get-Member -InputObject $GPPItemPropertiesElement | Where-Object { $_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property }).Name
    foreach ($PropertyDefinition in $GPPItemPropertiesElementPropertyDefinitions) {
        if ($GPPItemPropertiesElement.$PropertyDefinition -eq '') {
            [void]$GPPItemPropertiesElement.RemoveAttribute($PropertyDefinition)
        }
    }

    $GPPItemPropertiesElement
}