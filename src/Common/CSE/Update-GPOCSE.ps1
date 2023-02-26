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
    $CurrentCSESet = [GPPCSE]::GetCseSetByType($Type)
    if ($EnabledCSEs) {
        if ($EnabledCSEs.CSE -notcontains $CurrentCSESet.CSE) {
            $NotContains = $true
        }
    }
    else {
        $NotContains = $true
    }

    $CSEAttribute = $null
    if ($NotContains -and -not $Remove) {
        $CSEAttribute = [GPOExtensionNamesAttribute]::new($CurrentCSESet)
        [void]$CSEAttribute.Members.Add($EnabledCSEs)
    }
    elseif (-not $NotContains -and $Remove) {
        $CSEAttribute = [GPOExtensionNamesAttribute]::new($EnabledCSEs)
        $MemberToRemove = $CSEAttribute.Members | Where-Object -FilterScript {$_.CSE -eq $CurrentCSESet.CSE}
        [void]$CSEAttribute.Members.Remove($MemberToRemove)
    }

    if ($CSEAttribute) {
        $CSEAttributeString = $CSEAttribute.ToString()
        Set-GPOCSE -Id $Id -Value $CSEAttributeString
    }
}