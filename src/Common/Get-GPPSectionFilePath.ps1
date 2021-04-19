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

    $DomainName = (Get-CimInstance -ClassName 'Win32_ComputerSystem').Domain # Computer's domain name, not user's
    $PoliciesFolderPath = '\\{0}\SYSVOL\{0}\Policies' -f $DomainName
    $PolicyPath = Join-Path -Path $PoliciesFolderPath -ChildPath $GPOId.ToString('B') # B - 32 digits separated by hyphens, enclosed in braces: {00000000 - 0000 - 0000 - 0000 - 000000000000}
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