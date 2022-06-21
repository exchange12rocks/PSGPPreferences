function Update-GPOFileVersion {
    Param (
        [Parameter(Mandatory)]
        [guid]$Id,
        [Parameter(Mandatory)]
        [int]$Version
    )

    $Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    $DomainDnsName = $Domain.Name

    $IdFormatted = $Id.ToString('B')
    $GPOFSPath = '\\{0}\SYSVOL\{0}\Policies\{1}' -f $DomainDnsName, $IdFormatted
    $GPTIniPath = Join-Path -Path $GPOFSPath -ChildPath 'GPT.INI'
    $Value = '[General]
Version={0}' -f $GPOVersionNumber # GPO AD DS version is more important than the version in the file

    Set-Content -Path $GPTIniPath -Value $Value
}