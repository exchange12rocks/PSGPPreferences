function Test-IsNodeDisabled {
    Param (
        [Parameter(Mandatory)]
        $XMLNode
    )

    # The following is as it is because:
    # > $XMLNode.disabled.GetType().name
    # String
    # And $true / $false does not play well with string content.
    # But implicit type convertion works well with string -> int
    if ($XMLNode.disabled -eq 1) {
        $true
    }
    else {
        $false
    }
}