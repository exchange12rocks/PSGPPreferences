#$TestString = '[{00000000-0000-0000-0000-000000000000}{79F92669-4224-476C-9C5C-6EFB4D87DF4A}{A8C42CEA-CDB8-4388-97F4-5831F933DA84}{94978070-4645-4441-944f-9d3109ee1621}][{17D89FEC-5C44-4972-B12D-241CAEF74509}{79F92669-4224-476C-9C5C-6EFB4D87DF4A}{94978070-4645-4441-944f-9d3109ee1621}][{BC75B1ED-5833-4858-9BB8-CBF0B166DF9D}{A8C42CEA-CDB8-4388-97F4-5831F933DA84}]'

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