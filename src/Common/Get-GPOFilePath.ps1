function Get-GPOFilePath {
    Param (
        [guid]$Id
    )

    $DomainName = (Get-CimInstance -ClassName 'Win32_ComputerSystem').Domain # Computer's domain name, not user's
    $PoliciesFolderPath = '\\{0}\SYSVOL\{0}\Policies' -f $DomainName
    Join-Path -Path $PoliciesFolderPath -ChildPath $GPOId.ToString('B') # B - 32 digits separated by hyphens, enclosed in braces: {00000000 - 0000 - 0000 - 0000 - 000000000000}
}