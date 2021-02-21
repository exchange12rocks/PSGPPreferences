function Get-GPPSection {
    Param (
        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [string]$GPOName,
        [Parameter(ParameterSetName = 'ById', Mandatory)]
        [guid]$GPOId,
        [Parameter(ParameterSetName = 'ByName')]
        [Parameter(ParameterSetName = 'ById')]
        [GPPContext]$Context = $ModuleWideDefaultGPPContext,
        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [Parameter(ParameterSetName = 'ById', Mandatory)]
        [GPPType]$Type
    )

    if (-not $GPOId) {
        $GPOId = Convert-GPONameToID -Name $GPOName
    }

    $FilePath = Get-GPPSectionFilePath -GPOId $GPOId -Context $Context -Type $Type

    $FilePathExistence = Test-Path -Path $FilePath
    if ($FilePathExistence) {
        [xml]$XmlDocument = Get-Content -Path $FilePath

        Deserialize-GPPSection -InputObject $XmlDocument
    }
}