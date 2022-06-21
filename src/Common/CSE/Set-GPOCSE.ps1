function Set-GPOCSE {
    Param (
        [Parameter(Mandatory)]
        [guid]$Id,
        [Parameter(Mandatory)]
        [string]$Value
    )

    $GPO = Get-GPOObject -Id $Id
    $GPO.gPCMachineExtensionNames[0] = $Value
    $GPO.CommitChanges()
}