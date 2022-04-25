function Set-GPPGroup {
    [OutputType('GPPItemGroup')]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameObject', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObject', Mandatory)]
        [GPPItemGroup[]]$InputObject,
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
        [switch]$DeleteAllGroups,
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
        [GPPItemGroupMember[]]$Members,
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

        if ($InputObject) {
            foreach ($GroupObject in $InputObject) {
                if ($PSBoundParameters.ContainsKey('Action')) {
                    $GroupObject.Properties.Action = if ($PSBoundParameters.ContainsKey('Action')) {
                        [GPPItemAction]$Action.value__
                    }
                    else {
                        [GPPItemAction]::U
                    }
                }

                if ($GroupObject.Properties.Action -ne [GPPItemAction]::D) {
                    if ($PSBoundParameters.ContainsKey('NewName')) {
                        if ($GroupObject.Properties.Action -eq [GPPItemAction]::U) {
                            $GroupObject.Properties.NewName = $NewName
                        }
                    }
                    if ($PSBoundParameters.ContainsKey('Description')) {
                        $GroupObject.Properties.Description = $Description
                    }
                    if ($PSBoundParameters.ContainsKey('DeleteAllUsers')) {
                        $GroupObject.Properties.DeleteAllUsers = $DeleteAllUsers
                    }
                    if ($PSBoundParameters.ContainsKey('DeleteAllGroups')) {
                        $GroupObject.Properties.DeleteAllGroups = $DeleteAllGroups
                    }
                    if ($PSBoundParameters.ContainsKey('Members')) {
                        $GroupObject.Properties.Members = $Members
                    }
                    if ($PSBoundParameters.ContainsKey('Description')) {
                    }

                    # The NewName property applicable to the Update action only
                    if ($GroupObject.Properties.Action -eq [GPPItemAction]::C -and $GroupObject.Properties.NewName) {
                        $GroupObject.Properties.NewName = $null
                    }
                }
                else {
                    # Items with the Delete action, should not have all these properties (GUI sets it this way)

                    $GroupObject.Properties.NewName = $null
                    $GroupObject.Properties.Description = $null
                    $GroupObject.Properties.DeleteAllUsers = $null
                    $GroupObject.Properties.DeleteAllGroups = $null
                    $GroupObject.Properties.Members = $null
                }

                if ($PSBoundParameters.ContainsKey('Disable')) {
                    $GroupObject.disabled = $Disable
                }

                $GroupObject.image = $GroupObject.Properties.action.value__ # Fixes up the item's icon in case we changed its action

                $NewGPPSection = Remove-GPPGroup -GPPSection $GPPSection -UID $GroupObject.uid

                if ($NewGPPSection) {
                    $NewGPPSection.Members.Add($GroupObject)
                }
                else {
                    $NewGPPSection = [GPPSectionGroups]::new($GroupObject, $false)
                }

                if ($PassThru) {
                    $GroupObject
                }
                Set-GPPSection -InputObject $NewGPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
            }
        }
    }
}