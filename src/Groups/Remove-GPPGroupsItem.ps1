function Remove-GPPGroupsItem {
    [OutputType([System.Void])]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectName', Mandatory)]
        [string]$Name,
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectLiteralName', Mandatory)]
        [string]$LiteralName,
        [Parameter(ParameterSetName = 'ByGPONameObjectSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectSID', Mandatory)]
        [System.Security.Principal.SecurityIdentifier]$SID,
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionBuiltInUser', Mandatory)]
        [GPPItemUserSubAuthority]$BuiltInUser,
        [Parameter(ParameterSetName = 'ByGPONameObjectUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory)]
        [guid]$UID,
        [Parameter(ParameterSetName = 'ByGPPSectionObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory)]
        [GPPSection]$GPPSection,
        [Parameter(ParameterSetName = 'ByGPONameObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ByGPOIdObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByGPONameObjectName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName')]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameObjectSID')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectSID')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext,
        [Parameter(ParameterSetName = 'ByGPONameObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory)]
        $ItemType
    )

    $WorkGPPSection = if (-not $GPPSection) {
        if (-not $GPOId) {
            $GPOId = Convert-GPONameToID -Name $GPOName
        }

        Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
    }
    else {
        $GPPSection
    }

    $WorkObjects = $WorkGPPSection.Members | Where-Object -FilterScript { $_ -is $ItemType }
    if ($WorkObjects) {
        $GetFunctionParameters = @{
            GPPSection = $WorkGPPSection
        }

        if ($UID) {
            $GetFunctionParameters.Add('UID', $UID)
        }
        elseif ($ItemType -eq [GPPItemGroup] -and $SID) {
            $GetFunctionParameters.Add('SID', $SID)
        }
        elseif ($LiteralName) {
            $GetFunctionParameters.Add('LiteralName', $LiteralName)
        }
        elseif ($ItemType -eq [GPPItemUser] -and $BuiltInUser) {
            $GetFunctionParameters.Add('BuiltInUser', $BuiltInUser)
        }
        else {
            $GetFunctionParameters.Add('Name', $Name)
        }

        $GetFunctionName = switch ($ItemType) {
            ([GPPItemGroup]) {
                'Get-GPPGroup'
            }
            ([GPPItemUser]) {
                'Get-GPPUser'
            }
        }
        $FilteredObjects = &$GetFunctionName @GetFunctionParameters

        if ($FilteredObjects) {
            foreach ($ObjectToRemove in $FilteredObjects) {
                [void]$WorkGPPSection.Members.Remove($ObjectToRemove)
            }
            if ($GPPSection) {
                $WorkGPPSection
            }
            else {
                Set-GPPSection -InputObject $WorkGPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
            }
        }
    }
}