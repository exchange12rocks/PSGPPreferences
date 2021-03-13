function Add-GPPGroup {
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

    $GroupsSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
    if ($GroupsSection) {
        $GroupsSection.Members.Add($InputObject)
    }
    else {
        $GroupsSection = [GPPSectionGroups]::new($InputObject, $false)
    }

    Set-GPPSection -InputObject $GroupsSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
}