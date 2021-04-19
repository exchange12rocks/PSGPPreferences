function Get-GPPUser {
    [OutputType('GPPItemUser')]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameObjectName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName')]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectName')]
        [string]$Name,
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectLiteralName', Mandatory)]
        [string]$LiteralName,
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionBuiltInUser', Mandatory)]
        [GPPItemUserSubAuthorityDisplay]$BuiltInUser,
        [Parameter(ParameterSetName = 'ByGPONameObjectUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory)]
        [guid]$UID,
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
        [Parameter(ParameterSetName = 'ByGPPSectionObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory)]
        [GPPSection]$GPPSection,
        [Parameter(ParameterSetName = 'ByGPONameObjectName')]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext
    )

    if (-not $GPPSection) {
        if (-not $GPOId) {
            $GPOId = Convert-GPONameToID -Name $GPOName
        }

        $GPPSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
    }

    $Users = $GPPSection.Members | Where-Object -FilterScript { $_ -is [GPPItemUser] }
    if ($Users) {
        $FilterScript = if ($UID) {
            { $_.uid -eq $UID }
        }
        elseif ($PSBoundParameters.ContainsKey('BuiltInUser')) {
            $BuiltInUserInternal = [GPPItemUserSubAuthority]$BuiltInUser.value__
            { $_.Properties.subAuthority -eq $BuiltInUserInternal }
        }
        else {
            if ($LiteralName) {
                { $_.Properties.userName -eq $LiteralName }
            }
            else {
                $FilterName = if ($Name) {
                    $Name
                }
                else {
                    '*'
                }
                { $_.Properties.userName -like $FilterName }
            }
        }

        $Users | Where-Object -FilterScript $FilterScript
    }
}