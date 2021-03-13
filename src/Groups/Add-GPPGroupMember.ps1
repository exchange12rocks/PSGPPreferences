function Add-GPPGroupMember {
    [OutputType([System.Void])]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupUID', Mandatory)]
        [GPPItemGroupMember]$InputObject,
        [Parameter(ParameterSetName = 'ByGPONameGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName', Mandatory)]
        [string]$GroupName,
        [Parameter(ParameterSetName = 'ByGPONameGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID', Mandatory)]
        [System.Security.Principal.SecurityIdentifier]$GroupSID,
        [Parameter(ParameterSetName = 'ByGPONameGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupUID', Mandatory)]
        [guid]$GroupUID,
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

    if (-not $GPOId) {
        $GPOId = Convert-GPONameToID -Name $GPOName
    }

    $GroupsSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
    if ($GroupsSection) {
        $GetGPPGroupParameters = @{
            GPPSection = $GroupsSection
        }

        if ($GroupUID) {
            $GetGPPGroupParameters.Add('UID', $GroupUID)
        }
        elseif ($GroupSID) {
            $GetGPPGroupParameters.Add('SID', $GroupSID)
        }
        else {
            $GetGPPGroupParameters.Add('LiteralName', $GroupName)
        }

        $FilteredGroups = Get-GPPGroup @GetGPPGroupParameters

        if ($FilteredGroups) {
            foreach ($FilteredGroup in $FilteredGroups) {
                if ($FilteredGroup.Properties.Members) {
                    $FilteredGroup.Properties.Members.Add($InputObject)
                }
                else {
                    $FilteredGroup.Properties.Members = $InputObject
                }
            }
        }
    }

    Set-GPPSection -InputObject $GroupsSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
}