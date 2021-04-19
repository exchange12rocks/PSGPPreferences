function Get-GPPGroup {
    [OutputType('GPPItemGroup')]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameObjectName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName')]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectName')]
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
        [Parameter(ParameterSetName = 'ByGPPSectionObjectName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectSID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory)]
        [GPPSection]$GPPSection,
        [Parameter(ParameterSetName = 'ByGPONameObjectName')]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameObjectSID')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectSID')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext
    )

    if (-not $GPPSection) {
        if (-not $GPOId) {
            $GPOId = Convert-GPONameToID -Name $GPOName
        }

        $GPPSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
    }

    $Groups = $GPPSection.Members | Where-Object -FilterScript { $_ -is [GPPItemGroup] }
    if ($Groups) {
        $FilterScript = if ($UID) {
            { $_.uid -eq $UID }
        }
        elseif ($SID) {
            { $_.Properties.groupSid -eq $SID }
        }
        else {
            if ($LiteralName) {
                { $_.Properties.groupName -eq $LiteralName }
            }
            else {
                $FilterName = if ($Name) {
                    $Name
                }
                else {
                    '*'
                }
                { $_.Properties.groupName -like $FilterName }
            }
        }

        $Groups | Where-Object -FilterScript $FilterScript
    }
}