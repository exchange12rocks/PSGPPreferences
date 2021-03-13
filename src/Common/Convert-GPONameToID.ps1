function Convert-GPONameToID {
    Param (
        [Parameter(Mandatory)]
        [string]$Name
    )

    $Filter = '(&(objectClass=groupPolicyContainer)(displayName={0}))' -f $Name
    $DomainDN = ([System.DirectoryServices.DirectoryEntry]::new('LDAP://RootDSE')).defaultNamingContext
    $PoliciesCNLDAPPath = 'LDAP://CN=Policies,CN=System,{0}' -f $DomainDN[0] # $DomainDN is a collection of a System.DirectoryServices.ResultPropertyValueCollection type with a single element inside it
    $PoliciesDSE = [System.DirectoryServices.DirectoryEntry]::new($PoliciesCNLDAPPath)

    $Searcher = [System.DirectoryServices.DirectorySearcher]::new($PoliciesDSE, $Filter, 'cn', 'OneLevel')
    $Result = $Searcher.FindOne() # $Result is also a collection of a System.DirectoryServices.ResultPropertyValueCollection type
    [guid]$Result.Properties.cn[0]
}