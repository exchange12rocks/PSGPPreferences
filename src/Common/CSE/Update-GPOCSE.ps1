function Update-GPOCSE {
    Param (
        [Parameter(Mandatory)]
        [guid]$Id,
        [Parameter(Mandatory)]
        [GPPType]$Type
    )

    $NeedToUpdateCSEAttribute = $false

    $EnabledCSEs = Get-GPOCSE
    if ($EnabledCSEs) {
        $CurrentCSESetDefinition = Get-CseSetByType -Type $Type
        if ($EnabledCSE.CSE -notcontains $CurrentCSESetDefinition.CSE) {
            $NeedToUpdateCSEAttribute = $true
        }
    }
    else {
        $NeedToUpdateCSEAttribute = $true
    }

    if ($NeedToUpdateCSEAttribute) {
        $CurrentCSESet = [GpoCseSet]::new($CurrentCSESetDefinition.CSE, $CurrentCSESetDefinition.Tool)
        $CSEAttribute = [GPOExtensionNamesAttribute]::new($CurrentCSESet)
        [void]$CSEAttribute.Members.Add($EnabledCSEs)
        $CSEAttributeString = $CSEAttribute.ToString()
        Set-GPOCSE -Id $Id -Value $CSEAttributeString
    }
}