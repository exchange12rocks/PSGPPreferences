function Get-GPPUser {
    [OutputType('GPPItemUser')]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameGroupName')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName')]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupName')]
        [string]$Name,
        [Parameter(ParameterSetName = 'ByGPONameGroupLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupLiteralName', Mandatory)]
        [string]$LiteralName,
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionBuiltInUser', Mandatory)]
        [GPPItemUserSubAuthority]$BuiltInUser,
        [Parameter(ParameterSetName = 'ByGPONameGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupUID', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupUID', Mandatory)]
        [guid]$UID,
        [Parameter(ParameterSetName = 'ByGPONameGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPONameGroupUID', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ByGPOIdGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupUID', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByGPPSectionGroupName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupLiteralName', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionBuiltInUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByGPPSectionGroupUID', Mandatory)]
        [GPPSection]$GPPSection,
        [Parameter(ParameterSetName = 'ByGPONameGroupName')]
        [Parameter(ParameterSetName = 'ByGPONameGroupLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPONameGroupUID')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupUID')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext
    )

    if (-not $GPPSection) {
        if (-not $GPOId) {
            $GPOId = Convert-GPONameToID -Name $GPOName
        }

        $GroupsSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
    }

    $Users = $GroupsSection.Members | Where-Object -FilterScript { $_ -is [GPPItemUser] }
    if ($Users) {
        $FilterScript = if ($UID) {
            { $_.uid -eq $UID }
        }
        elseif ($BuiltInUser) {
            { $_.Properties.subAuthority -eq $BuiltInUser }
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
    }
    $Users | Where-Object -FilterScript $FilterScript
}