function Remove-GPPUser {
    [OutputType([System.Void])]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectName', Mandatory)]
        [string]$Name,
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectLiteralName', Mandatory)]
        [string]$LiteralName,
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionBuiltInUser', Mandatory)]
        [GPPItemUserSubAuthority]$BuiltInUser,
        [Parameter(ParameterSetName = 'ByGPONameObjectUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory)]
        [guid]$UID,
        [Parameter(ParameterSetName = 'ByGPPSectionObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory)]
        [GPPSection]$GPPSection,
        [Parameter(ParameterSetName = 'ByGPONameObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ByGPOIdObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByGPONameObjectName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName')]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext
    )

    Remove-GPPGroupsItem @PSBoundParameters -Context $Context -ItemType ([GPPItemUser])
}