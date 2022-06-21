function Update-GPOCSE {
    Param (
        [Parameter(Mandatory)]
        [guid]$Id,
        [Parameter(Mandatory)]
        [GPPType]$Type,
        [switch]$Remove
    )

    $NotContains = $false

    $EnabledCSEs = Get-GPOCSE -Id $Id
    $CurrentCSESetDefinition = Get-CseSetByType -Type $Type
    if ($EnabledCSEs) {
        if ($EnabledCSEs.CSE -notcontains $CurrentCSESetDefinition.CSE) {
            $NotContains = $true
        }
    }
    else {
        $NotContains = $true
    }

    $CSEAttribute = $null
    if ($NotContains -and -not $Remove) {
        $CurrentCSESet = [GpoCseSet]::new($CurrentCSESetDefinition.CSE, $CurrentCSESetDefinition.Tool)
        $CSEAttribute = [GPOExtensionNamesAttribute]::new($CurrentCSESet)
        [void]$CSEAttribute.Members.Add($EnabledCSEs)
    }
    elseif (-not $NotContains -and $Remove) {
        $CSEAttribute = [GPOExtensionNamesAttribute]::new($EnabledCSEs)
        $MemberToRemove = $CSEAttribute.Members | Where-Object -FilterScript {$_.CSE -eq $CurrentCSESetDefinition.CSE}
        [void]$CSEAttribute.Members.Remove($MemberToRemove)
    }

    if ($CSEAttribute) {
        $CSEAttributeString = $CSEAttribute.ToString()
        Set-GPOCSE -Id $Id -Value $CSEAttributeString
    }
}