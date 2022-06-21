function Update-GPOMetadata {
    Param (
        [Parameter(Mandatory)]
        [guid]$Id,
        [Parameter(Mandatory)]
        [GPPType]$Type,
        [switch]$Remove
    )

    Update-GPOVersion -Id $Id
    Update-GPOCSE -Id $Id -Type $Type -Remove:$Remove
}