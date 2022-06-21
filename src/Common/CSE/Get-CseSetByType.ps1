function Get-CseSetByType {
    Param (
        [Parameter(Mandatory)]
        [GPPType]$Type,
        [PSCustomObject]$Definitions = $CSEDefinitions
    )

    $Definitions.$Type
}