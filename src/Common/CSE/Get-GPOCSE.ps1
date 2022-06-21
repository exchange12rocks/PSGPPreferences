function Get-GPOCSE {
    Param (
        [Parameter(Mandatory)]
        [guid]$Id
    )

    $GPO = Get-GPOObject -Id $Id
    $AttributeString = $GPO.gPCMachineExtensionNames[0]

    $ListsRegExFilter = '\[\{00000000-0000-0000-0000-000000000000\}(?<Tools>(?:\{[0-9A-f]{8}-[0-9A-f]{4}-[0-9A-f]{4}-[0-9A-f]{4}-[0-9A-f]{12}\})*)\](?<CseSets>(?:\[(?:\{[0-9A-f]{8}-[0-9A-f]{4}-[0-9A-f]{4}-[0-9A-f]{4}-[0-9A-f]{12}\})(?:\{[0-9A-f]{8}-[0-9A-f]{4}-[0-9A-f]{4}-[0-9A-f]{4}-[0-9A-f]{12}\})*\])*)'
    $ListsRegEx = [regex]::new($ListsRegExFilter)
    $ListMatches = $ListsRegEx.Matches($AttributeString)

    # $ToolsList = ($ListMatches.Groups | Where-Object -FilterScript { $_.Name -eq 'Tools' }).Value
    # All tools are listed under respecstive

    $CseSetsList = ($ListMatches.Groups | Where-Object -FilterScript { $_.Name -eq 'CseSets' }).Value

    $CseSetsSplitRegExFilter = '(\[(?:\{[0-9A-f]{8}-[0-9A-f]{4}-[0-9A-f]{4}-[0-9A-f]{4}-[0-9A-f]{12}\})+\])'
    $CseSetsSplitRegEx = [regex]::new($CseSetsSplitRegExFilter)
    $CseSets = $CseSetsSplitRegEx.Matches($CseSetsList).Value

    foreach ($Set in $CseSets) {
        $CseSetSplitRegExFilter = '\[(?<CSE>\{[0-9A-f]{8}-[0-9A-f]{4}-[0-9A-f]{4}-[0-9A-f]{4}-[0-9A-f]{12}\})(?<Tools>(?:\{[0-9A-f]{8}-[0-9A-f]{4}-[0-9A-f]{4}-[0-9A-f]{4}-[0-9A-f]{12}\})*)\]'
        $CseSetSplitRegEx = [regex]::new($CseSetSplitRegExFilter)
        $CseSetSplitted = $CseSetSplitRegEx.Matches($Set)
        $CseId = ($CseSetSplitted.Groups | Where-Object -FilterScript { $_.Name -eq 'CSE' }).Value
        $CseToolsList = ($CseSetSplitted.Groups | Where-Object -FilterScript { $_.Name -eq 'Tools' }).Value

        $ToolsFilter = '\{[0-9A-f]{8}-[0-9A-f]{4}-[0-9A-f]{4}-[0-9A-f]{4}-[0-9A-f]{12}\}'
        $ToolsRegEx = [regex]::new($ToolsFilter)
        $ToolsId = $ToolsRegEx.Matches($CseToolsList).Value

        [GpoCseSet]::new($CseId, $ToolsId)
    }
}