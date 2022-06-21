function Update-GPOMetadata {
    Param (
        [Parameter(Mandatory)]
        [guid]$Id
    )

    Update-GPOVersion -Id $Id
    Update-GPOCSE -Id $Id
}