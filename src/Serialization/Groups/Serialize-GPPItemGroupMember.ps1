function Serialize-GPPItemGroupMember {
    Param (
        [Parameter(Mandatory)]
        [GPPItemGroupMember]$InputObject
    )

    Serialize-GPPItem -InputObject $InputObject -RootElementName 'Member'
}
