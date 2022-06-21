function Get-GPPSectionFilePath {
    Param (
        [Parameter(Mandatory)]
        [guid]$GPOId,
        [Parameter(Mandatory)]
        [GPPContext]$Context,
        [Parameter(Mandatory)]
        [GPPType]$Type,
        [switch]$Extended
    )

    $PolicyPath = Get-GPOFilePath -Id $Id
    $ContextPath = Join-Path -Path $PolicyPath -ChildPath ('{0}\Preferences' -f $Context)
    $FolderPath = Join-Path -Path $ContextPath -ChildPath $Type
    $FilePath = Join-Path -Path $FolderPath -ChildPath ('{0}.xml' -f $Type)

    if ($Extended) {
        @{
            FolderPath = $FolderPath
            FilePath = $FilePath
        }
    }
    else {
        $FilePath
    }
}