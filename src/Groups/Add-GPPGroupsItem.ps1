function Add-GPPGroupsItem {
    [OutputType([System.Void])]
    Param (
        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [Parameter(ParameterSetName = 'ById', Mandatory)]
        [GPPItemGroup]$InputObject,
        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ById', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByName')]
        [Parameter(ParameterSetName = 'ById')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext
    )

    if (-not $GPOId) {
        $GPOId = Convert-GPONameToID -Name $GPOName
    }

    $GPPSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
    if ($GPPSection) {
        $GPPSection.Members.Add($InputObject)
    }
    else {
        $GPPSection = [GPPSectionGroups]::new($InputObject, $false)
    }

    Set-GPPSection -InputObject $GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
}