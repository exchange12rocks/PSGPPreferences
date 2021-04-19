function Set-GPPSection {
    Param (
        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [Parameter(ParameterSetName = 'ById', Mandatory)]
        [GPPSection]$InputObject,
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

    $SectionDescription = Serialize-GPPSection -InputObject $InputObject -IncludeType

    $XMLDocument = $SectionDescription.XMLDocument
    $Type = $SectionDescription.Type

    $GPPSectionFilePathResult = Get-GPPSectionFilePath -GPOId $GPOId -Context $Context -Type $Type -Extended
    $FilePath = $GPPSectionFilePathResult.FilePath
    $FolderPath = $GPPSectionFilePathResult.FolderPath

    if (-not (Test-Path -Path $FolderPath)) {
        $null = New-Item -Path $FolderPath -ItemType Directory
    }

    Set-Content -Path $FilePath -Value $XMLDocument.OuterXml
}
