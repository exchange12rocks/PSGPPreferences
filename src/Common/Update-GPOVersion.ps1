function Update-GPOVersion {
    Param (
        [Parameter(Mandatory)]
        [guid]$Id
    )

    $IdFormatted = $Id.ToString('B')
    $RootDSE = ([System.DirectoryServices.DirectoryEntry]::new('LDAP://RootDSE'))
    $Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    $DomainDN = $RootDSE.defaultNamingContext
    $DomainDnsName = $Domain.Name
    $GPOLDAPPath = 'LDAP://CN={0},CN=Policies,CN=System,{1}' -f $IdFormatted, $DomainDN[0] # $DomainDN is a collection of a System.DirectoryServices.ResultPropertyValueCollection type with a single element inside it
    $GPOFSPath = '\\{0}\SYSVOL\{0}\Policies\{1}' -f $DomainDnsName, $IdFormatted
    $GPTIniPath = Join-Path -Path $GPOFSPath -ChildPath 'GPT.INI'

    $GPO = ([System.DirectoryServices.DirectoryEntry]::new($GPOLDAPPath))
    $GPOVersionNumber = $GPO.versionNumber[0] # System.DirectoryServices.PropertyValueCollection, that's why we have to access the first element
    $GPOVersionNumber++
    $GPO.versionNumber[0] = $GPOVersionNumber
    $GPO.CommitChanges()

    $GPOIni = Get-IniContent -FilePath $GPTIniPath
    $GPOIni.General.Version = $GPOVersionNumber # GPO AD DS version is more important than the version in the file
    $GPOIni | Out-IniFile -FilePath $GPTIniPath -Force
}