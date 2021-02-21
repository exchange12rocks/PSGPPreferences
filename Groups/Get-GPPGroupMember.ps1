function Get-GPPGroupMember {
    [OutputType('GPPItemGroupMember')]
    Param (
        [Parameter(ParameterSetName = 'ByNameGroupNameGPOName')]
        [Parameter(ParameterSetName = 'ByNameGroupSIDGPOName')]
        [Parameter(ParameterSetName = 'ByNameGroupUIDGPOName')]
        [Parameter(ParameterSetName = 'ByNameGroupNameGPOId')]
        [Parameter(ParameterSetName = 'ByNameGroupSIDGPOId')]
        [Parameter(ParameterSetName = 'ByNameGroupUIDGPOId')]
        [string]$Name,
        [Parameter(ParameterSetName = 'ByLiteralNameGroupNameGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupSIDGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupUIDGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupNameGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupSIDGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupUIDGPOId', Mandatory)]
        [string]$LiteralName,
        [Parameter(ParameterSetName = 'BySIDGroupNameGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupSIDGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupUIDGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupNameGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupSIDGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupUIDGPOId', Mandatory)]
        [System.Security.Principal.SecurityIdentifier]$SID,
        [Parameter(ParameterSetName = 'ByNameGroupNameGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGroupNameGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupNameGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupNameGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupNameGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupNameGPOId', Mandatory)]
        [string]$GroupName,
        [Parameter(ParameterSetName = 'ByNameGroupSIDGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGroupSIDGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupSIDGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupSIDGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupSIDGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupSIDGPOId', Mandatory)]
        [System.Security.Principal.SecurityIdentifier]$GroupSID,
        [Parameter(ParameterSetName = 'ByNameGroupUIDGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGroupUIDGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupUIDGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupUIDGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupUIDGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupUIDGPOId', Mandatory)]
        [guid]$GroupUID,
        [Parameter(ParameterSetName = 'ByNameGroupNameGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupNameGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupNameGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGroupSIDGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupSIDGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupSIDGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGroupUIDGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupUIDGPOName', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupUIDGPOName', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ByNameGroupNameGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupNameGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupNameGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGroupSIDGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupSIDGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupSIDGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'ByNameGroupUIDGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupUIDGPOId', Mandatory)]
        [Parameter(ParameterSetName = 'BySIDGroupUIDGPOId', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByNameGroupNameGPOName')]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupNameGPOName')]
        [Parameter(ParameterSetName = 'BySIDGroupNameGPOName')]
        [Parameter(ParameterSetName = 'ByNameGroupSIDGPOName')]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupSIDGPOName')]
        [Parameter(ParameterSetName = 'BySIDGroupSIDGPOName')]
        [Parameter(ParameterSetName = 'ByNameGroupUIDGPOName')]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupUIDGPOName')]
        [Parameter(ParameterSetName = 'BySIDGroupUIDGPOName')]
        [Parameter(ParameterSetName = 'ByNameGroupNameGPOId')]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupNameGPOId')]
        [Parameter(ParameterSetName = 'BySIDGroupNameGPOId')]
        [Parameter(ParameterSetName = 'ByNameGroupSIDGPOId')]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupSIDGPOId')]
        [Parameter(ParameterSetName = 'BySIDGroupSIDGPOId')]
        [Parameter(ParameterSetName = 'ByNameGroupUIDGPOId')]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupUIDGPOId')]
        [Parameter(ParameterSetName = 'BySIDGroupUIDGPOId')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext
    )

    $GetGPPGroupParameters = @{}

    if ($GroupUID) {
        $GetGPPGroupParameters.Add('UID', $GroupUID)
    }
    elseif ($GroupSID) {
        $GetGPPGroupParameters.Add('UID', $GroupUID)
    }
    else {
        $GetGPPGroupParameters.Add('LiteralName', $GroupName)
    }

    if ($GPOId) {
        $GetGPPGroupParameters.Add('GPOId', $GPOId)
    }
    else {
        $GetGPPGroupParameters.Add('GPOName', $GPOName)
    }

    $Groups = Get-GPPGroup @GetGPPGroupParameters

    $FilterScript = if ($SID) {
        {$_.sid -eq $SID}
    }
    elseif ($LiteralName) {
        {$_.name -eq $LiteralName}
    }
    else {
        $FilterName = if ($Name) {
            $Name
        }
        else {
            '*'
        }

        {$_.name -like $FilterName}
    }

    foreach ($Group in $Groups) {
        $Group.Properties.Members | Where-Object -FilterScript $FilterScript
    }
}