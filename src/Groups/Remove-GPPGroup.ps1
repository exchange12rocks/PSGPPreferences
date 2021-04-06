function Remove-GPPGroup {
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
        [Parameter(ParameterSetName = 'ByGPONameObjectSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectSID', Mandatory)]
        [System.Security.Principal.SecurityIdentifier]$SID,
        [Parameter(ParameterSetName = 'ByGPONameObjectUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory)]
        [guid]$UID,
        [Parameter(ParameterSetName = 'ByGPPSectionObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory)]
        [GPPSection]$GPPSection,
        [Parameter(ParameterSetName = 'ByGPONameObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ByGPOIdObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByGPONameObjectName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName')]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameObjectSID')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectSID')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext
    )

    Remove-GPPGroupsItem @PSBoundParameters -Context $Context -ItemType ([GPPItemGroup])
}