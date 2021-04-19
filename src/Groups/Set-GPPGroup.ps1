function Set-GPPGroup {
    [OutputType('GPPItemGroup')]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameObject', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObject', Mandatory)]
        [GPPItemGroup]$InputObject,
        [Parameter(ParameterSetName = 'ByGPONameItemName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemName', Mandatory)]
        [string]$Name,
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName', Mandatory)]
        [string]$LiteralName,
        [Parameter(ParameterSetName = 'ByGPONameItemSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemSID', Mandatory)]
        [System.Security.Principal.SecurityIdentifier]$SID,
        [Parameter(ParameterSetName = 'ByGPONameObject', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameItemSID', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ByGPOIdObject', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdItemSID', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemSID')]
        [Parameter(ParameterSetName = 'ByGPOIdItemSID')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemSID')]
        [Parameter(ParameterSetName = 'ByGPOIdItemSID')]
        [GPPItemActionDisplay]$Action,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemSID')]
        [Parameter(ParameterSetName = 'ByGPOIdItemSID')]
        [string]$NewName,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemSID')]
        [Parameter(ParameterSetName = 'ByGPOIdItemSID')]
        [string]$Description,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemSID')]
        [Parameter(ParameterSetName = 'ByGPOIdItemSID')]
        [switch]$DeleteAllUsers,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemSID')]
        [Parameter(ParameterSetName = 'ByGPOIdItemSID')]
        [switch]$DeleteAllItems,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemSID')]
        [Parameter(ParameterSetName = 'ByGPOIdItemSID')]
        [switch]$Disable,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemSID')]
        [Parameter(ParameterSetName = 'ByGPOIdItemSID')]
        [GPPItemItemMember[]]$Members,
        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemSID')]
        [Parameter(ParameterSetName = 'ByGPOIdItemSID')]
        [switch]$PassThru
    )

    if (-not $GPOId) {
        $GPOId = Convert-GPONameToID -Name $GPOName
    }
    $GPPSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)

    if ($GPPSection) {
        if (-not $InputObject) {
            $GetFunctionParameters = @{}

            if ($SID) {
                $GetFunctionParameters.Add('SID', $SID)
            }
            elseif ($LiteralName) {
                $GetFunctionParameters.Add('LiteralName', $LiteralName)
            }
            else {
                $GetFunctionParameters.Add('Name', $Name)
            }

            $InputObject = Get-GPPGroup @GetFunctionParameters -GPPSection $GPPSection
        }

        if ($PSBoundParameters.ContainsKey('Action')) {
            $InputObject.Properties.Action = if ($PSBoundParameters.ContainsKey('Action')) {
                [GPPItemAction]$Action.value__
            }
            else {
                [GPPItemAction]::U
            }
        }

        if ($InputObject.Properties.Action -ne [GPPItemAction]::D) {
            if ($PSBoundParameters.ContainsKey('NewName')) {
                if ($InputObject.Properties.Action -eq [GPPItemAction]::U) {
                    $InputObject.Properties.NewName = $NewName
                }
            }
            if ($PSBoundParameters.ContainsKey('Description')) {
                $InputObject.Properties.Description = $Description
            }
            if ($PSBoundParameters.ContainsKey('DeleteAllUsers')) {
                $InputObject.Properties.DeleteAllUsers = $DeleteAllUsers
            }
            if ($PSBoundParameters.ContainsKey('DeleteAllGroups')) {
                $InputObject.Properties.DeleteAllGroups = $DeleteAllGroups
            }
            if ($PSBoundParameters.ContainsKey('Members')) {
                $InputObject.Properties.Members = $Members
            }
            if ($PSBoundParameters.ContainsKey('Description')) {
            }

            # The NewName property applicable to the Update action only
            if ($InputObject.Properties.Action -eq [GPPItemAction]::C -and $InputObject.Properties.NewName) {
                $InputObject.Properties.NewName = $null
            }
        }
        else {
            # Items with the Delete action, should not have all these properties (GUI sets it this way)

            $InputObject.Properties.NewName = $null
            $InputObject.Properties.Description = $null
            $InputObject.Properties.DeleteAllUsers = $null
            $InputObject.Properties.DeleteAllGroups = $null
            $InputObject.Properties.Members = $null
        }

        if ($PSBoundParameters.ContainsKey('Disable')) {
            $InputObject.disabled = $Disable
        }

        $InputObject.image = $InputObject.Properties.action.value__ # Fixes up the item's icon in case we changed its action

        $NewGPPSection = Remove-GPPGroup -GPPSection $GPPSection -UID $InputObject.uid

        if ($NewGPPSection) {
            $NewGPPSection.Members.Add($InputObject)
        }
        else {
            $NewGPPSection = [GPPSectionGroups]::new($InputObject, $false)
        }

        if ($PassThru) {
            $InputObject
        }
        Set-GPPSection -InputObject $NewGPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
    }
}