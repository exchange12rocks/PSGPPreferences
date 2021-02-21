function Set-GPPGroupMember {
    [OutputType([System.Void])]
    Param (
        [Parameter(ParameterSetName = 'ByNameGPONameGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPONameGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPONameGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupUID', Mandatory)]
        [string]$Name,
        [Parameter(ParameterSetName = 'BySIDGPONameGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupUID', Mandatory)]
        [System.Security.Principal.SecurityIdentifier]$SID,
        [Parameter(ParameterSetName = 'ByNameGPONameGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPONameGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPONameGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupUID', Mandatory)]
        [GPPItemGroupMemberAction]$Action,
        [Parameter(ParameterSetName = 'ByNameGPONameGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupName', Mandatory)]
        [string]$GroupName,
        [Parameter(ParameterSetName = 'ByNameGPONameGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupSID', Mandatory)]
        [System.Security.Principal.SecurityIdentifier]$GroupSID,
        [Parameter(ParameterSetName = 'ByNameGPONameGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupUID', Mandatory)]
        [guid]$GroupUID,
        [Parameter(ParameterSetName = 'ByNameGPONameGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPONameGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPONameGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupUID', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupUID', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByNameGPONameGroupName')]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupName')]
        [Parameter(ParameterSetName = 'ByNameGPONameGroupSID')]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupSID')]
        [Parameter(ParameterSetName = 'ByNameGPONameGroupUID')]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupUID')]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupName')]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupName')]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupSID')]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupSID')]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupUID')]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupUID')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext
    )

    if (-not $GPOId) {
        $GPOId = Convert-GPONameToID -Name $GPOName
    }

    #$GroupsSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
    $GroupsSection = $GrpSection
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
            $WorkDone = $false
            foreach ($FilteredGroup in $FilteredGroups) {
                if ($FilteredGroup.Properties.Members) {
                    $FilterScript = if ($SID) {
                        {$_.sid -eq $SID}
                    }
                    else {
                        {$_.name -eq $Name}
                    }

                    $FilteredMembers = $FilteredGroup.Properties.Members | Where-Object -FilterScript $FilterScript
                    if ($FilteredMembers) {
                        $WorkDone = $true
                        foreach ($FilteredMember in $FilteredMembers) {
                            $FilteredMember.action = $Action
                        }
                    }
                }
            }

            if ($WorkDone) {
                Set-GPPSection -InputObject $GroupsSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
            }
        }
    }
}
