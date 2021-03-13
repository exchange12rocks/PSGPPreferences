function Get-GPPGroup {
    [OutputType('GPPItemGroup')]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameGroupName')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName')]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupName')]
        [string]$Name,
        [Parameter(ParameterSetName = 'ByGPONameGroupLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupLiteralName', Mandatory)]
        [string]$LiteralName,
        [Parameter(ParameterSetName = 'ByGPONameGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupSID', Mandatory)]
        [System.Security.Principal.SecurityIdentifier]$SID,
        [Parameter(ParameterSetName = 'ByGPONameGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupUID', Mandatory)]
        [guid]$UID,
        [Parameter(ParameterSetName = 'ByGPONameGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupUID', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ByGPOIdGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupUID', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByGPPSectionGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupUID', Mandatory)]
        [GPPSection]$GPPSection,
        [Parameter(ParameterSetName = 'ByGPONameGroupName')]
        [Parameter(ParameterSetName = 'ByGPONameGroupLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID')]
        [Parameter(ParameterSetName = 'ByGPONameGroupUID')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupUID')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext
    )

    if (-not $GPPSection) {
        if (-not $GPOId) {
            $GPOId = Convert-GPONameToID -Name $GPOName
        }

        $GroupsSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
    }
    $Groups = $GroupsSection.Members
    if ($Groups) {
        $FilterScript = if ($UID) {
            {$_.uid -eq $UID}
        }
        elseif ($SID) {
            {$_.Properties.groupSid -eq $SID}
        }
        else {
            if ($LiteralName) {
                {$_.Properties.groupName -eq $LiteralName}
            }
            else {
                $FilterName = if ($Name) {
                    $Name
                }
                else {
                    '*'
                }
                {$_.Properties.groupName -like $FilterName}
            }
        }
    }
    $Groups | Where-Object -FilterScript $FilterScript
}