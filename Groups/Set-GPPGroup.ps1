function Set-GPPGroup {
    [OutputType('GPPItemGroup')]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameObject', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObject', Mandatory)]
        [GPPItemGroup]$InputObject,
        [Parameter(ParameterSetName = 'ByGPONameGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName', Mandatory)]
        [string]$Name,
        [Parameter(ParameterSetName = 'ByGPONameGroupSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID', Mandatory)]
        [System.Security.Principal.SecurityIdentifier]$SID,
        [Parameter(ParameterSetName = 'ByGPONameObject', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ByGPOIdObject', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameGroupName')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameGroupName')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID')]
        [GPPItemActionDisplay]$Action,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameGroupName')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID')]
        [string]$NewName,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameGroupName')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID')]
        [string]$Description,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameGroupName')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID')]
        [switch]$DeleteAllUsers,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameGroupName')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID')]
        [switch]$DeleteAllGroups,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameGroupName')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID')]
        [switch]$Disable,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameGroupName')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID')]
        [GPPItemGroupMember[]]$Members,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameGroupName')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID')]
        [switch]$PassThru
    )

    if (-not $GPOId) {
        $GPOId = Convert-GPONameToID -Name $GPOName
    }
    $GroupsSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)

    if ($GroupsSection) {
        $InternalAction = if ($PSBoundParameters.ContainsKey('Action')) {
            [GPPItemAction]$Action.value__
        }
        else {
            [GPPItemAction]::U
        }

        if (-not $InputObject) {
            $GetGroupFunctionParameters = @{}

            if ($SID) {
                $GetGroupFunctionParameters.Add('SID', $SID)
            }
            else {
                $GetGroupFunctionParameters.Add('Name', $Name)
            }

            if ($GroupsSection) {
                $InputObject = Get-GPPGroup @GetGroupFunctionParameters -GPPSection $GroupsSection
            }
            else {
                New-GPPGroup @GetGroupFunctionParameters -Create:$true
            }
        }

        if ($PSBoundParameters.ContainsKey('Action')) {
            $InputObject.Properties.Action = $InternalAction
        }
        if ($NewName) {
            if ($InternalAction -eq [GPPItemAction]::U) {
                $InputObject.Properties.NewName = $NewName
                if (-not $PSBoundParameters.ContainsKey('Action')) {
                    $InputObject.Properties.Action = $InternalAction
                }
            }
        }
        if ($Description -and $InternalAction -ne [GPPItemAction]::D) {
            $InputObject.Properties.Description = $Description
        }
        if ($DeleteAllUsers -and $InternalAction -ne [GPPItemAction]::D) {
            $InputObject.Properties.DeleteAllUsers = $DeleteAllUsers
        }
        if ($DeleteAllGroups -and $InternalAction -ne [GPPItemAction]::D) {
            $InputObject.Properties.DeleteAllGroups = $DeleteAllGroups
        }
        if ($Members -and $InternalAction -ne [GPPItemAction]::D) {
            $InputObject.Properties.Members = $Members
        }

        # The NewName property applicable to the Update action only
        if ($InputObject.Properties.Action -eq [GPPItemAction]::C -and $InputObject.Properties.NewName) {
            $InputObject.Properties.NewName = $null
        }

        # Items with the Delete action, should not have all these properties (GUI sets it this way)
        if ($InputObject.Properties.Action -eq [GPPItemAction]::D) {
            $InputObject.Properties.NewName = $null
            $InputObject.Properties.Description = $null
            $InputObject.Properties.DeleteAllUsers = $null
            $InputObject.Properties.DeleteAllGroups = $null
            $InputObject.Properties.Members = $null
        }

        $InputObject.disabled = $Disable

        $InputObject.image = $InputObject.Properties.action.value__ # Fixes up the item's icon in case we changed its action

        $NewGroupsSection = Remove-GPPGroup -GPPSection $GroupsSection -UID $InputObject.uid

        if ($NewGroupsSection) {
            $NewGroupsSection.Members.Add($InputObject)
        }
        else {
            $NewGroupsSection = [GPPSectionGroups]::new($InputObject, $false)
        }

        if ($PassThru) {
            $InputObject
        }
        Set-GPPSection -InputObject $NewGroupsSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
    }
}