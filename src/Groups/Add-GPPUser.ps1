function Add-GPPUser {
    [OutputType([System.Void])]
    Param (
        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [Parameter(ParameterSetName = 'ById', Mandatory)]
        [GPPItemUser]$InputObject,
        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ById', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByName')]
        [Parameter(ParameterSetName = 'ById')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext
    )

    Add-GPPGroupsItem @PSBoundParameters
}