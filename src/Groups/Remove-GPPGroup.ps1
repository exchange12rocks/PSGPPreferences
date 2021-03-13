function Remove-GPPGroup {
    [OutputType([System.Void])]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupName', Mandatory)]
        [string]$Name,
        [Parameter(ParameterSetName = 'ByGPONameGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupSID', Mandatory)]
        [System.Security.Principal.SecurityIdentifier]$SID,
        [Parameter(ParameterSetName = 'ByGPONameGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupUID', Mandatory)]
        [guid]$UID,
        [Parameter(ParameterSetName = 'ByGPPSectionGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupUID', Mandatory)]
        [GPPSection]$GPPSection,
        [Parameter(ParameterSetName = 'ByGPONameGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupUID', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ByGPOIdGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupUID', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByGPONameGroupName')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID')]
        [Parameter(ParameterSetName = 'ByGPONameGroupUID')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupUID')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext
    )

    $GroupsSection = if (-not $GPPSection) {
        if (-not $GPOId) {
            $GPOId = Convert-GPONameToID -Name $GPOName
        }

        Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
    }
    else {
        $GPPSection
    }

    $Groups = $GroupsSection.Members
    if ($Groups) {
        $GetGPPGroupParameters = @{
            GPPSection = $GroupsSection
        }

        if ($UID) {
            $GetGPPGroupParameters.Add('UID', $UID)
        }
        elseif ($GroupSID) {
            $GetGPPGroupParameters.Add('SID', $GroupSID)
        }
        else {
            $GetGPPGroupParameters.Add('LiteralName', $GroupName)
        }

        $FilteredGroups = Get-GPPGroup @GetGPPGroupParameters

        if ($FilteredGroups) {
            foreach ($GroupToRemove in $FilteredGroups) {
                [void]$Groups.Remove($GroupToRemove)
            }
            if ($GPPSection) {
                $GroupsSection
            }
            else {
                Set-GPPSection -InputObject $GroupsSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
            }
        }
    }
}