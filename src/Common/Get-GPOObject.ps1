function Get-GPOObject {
    Param (
        [Parameter(Mandatory)]
        [guid]$Id
    )

    $IdFormatted = $Id.ToString('B')
    $RootDSE = ([System.DirectoryServices.DirectoryEntry]::new('LDAP://RootDSE'))
    $DomainDN = $RootDSE.defaultNamingContext
    $GPOLDAPPath = 'LDAP://CN={0},CN=Policies,CN=System,{1}' -f $IdFormatted, $DomainDN[0] # $DomainDN is a collection of a System.DirectoryServices.ResultPropertyValueCollection type with a single element inside it

    ([System.DirectoryServices.DirectoryEntry]::new($GPOLDAPPath))
}