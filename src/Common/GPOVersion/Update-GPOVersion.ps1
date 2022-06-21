function Update-GPOVersion {
    Param (
        [Parameter(Mandatory)]
        [guid]$Id
    )

    $GPO = Get-GPOObject -Id $Id
    $GPOVersionNumber = $GPO.versionNumber[0] # System.DirectoryServices.PropertyValueCollection, that's why we have to access the first element
    $GPOVersionNumber++
    $GPO.versionNumber[0] = $GPOVersionNumber
    $GPO.CommitChanges()

    Update-GPOFileVersion -IdFormatted $IdFormatted -Version $GPOVersionNumber
}