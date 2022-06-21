class GpoCseSet {
    [guid[]]$Tool
    [guid]$CSE

    <#
    GpoCseSet([guid] $CseId) {
        $this.CSE = $CseId
        $this.Tool = Get-GpoToolIdByCseId -Id $CseId # Does not work r/n - do we need it?
    }
    #>

    GpoCseSet([guid] $CseId, [guid[]] $ToolId) {
        $this.CSE = $CseId
        $this.Tool = $ToolId
    }
}

class GPOExtensionNamesAttribute {
    [System.Collections.Generic.List[GpoCseSet]]$Members

    GPOExtensionNamesAttribute([guid[]] $CseId) {
        $this.Members = foreach ($Id in $CseId) {
            [GpoCseSet]::new($Id)
        }
    }

    GPOExtensionNamesAttribute([GpoCseSet[]] $Members) {
        $this.Members = $Members
    }

    GPOExtensionNamesAttribute([GpoCseSet] $Members) {
        $this.Members = $Members
    }

    [string] ToString () {
        $SortedTools = $this.Members.Tool | Sort-Object

        $sb = [System.Text.StringBuilder]::new()
        foreach ($Tool in $SortedTools) {
            [void]$sb.Append($Tool.ToString('B'))
        }
        $SortedToolsString = $sb.ToString()

        $SortedCSE = $this.Members.CSE | Sort-Object

        $sb = [System.Text.StringBuilder]::new()
        foreach ($CSE in $SortedCSE) {
            $CurrentCSESet = $this.Members | Where-Object -FilterScript { $_.CSE -eq $CSE }
            $CurrentCSEString = $CSE.ToString('B')
            $SortedCSETools = $CurrentCSESet.Tool | Sort-Object
            $sb2 = [System.Text.StringBuilder]::new()
            foreach ($Tool in $SortedCSETools) {
                [void]$sb2.Append($Tool.ToString('B'))
            }
            $SortedCSEToolsString = $sb2.ToString()
            [void]$sb.Append(('[{0}{1}]' -f $CurrentCSEString, $SortedCSEToolsString))
        }
        $SortedCSEString = $sb.ToString()

        return '[{{00000000-0000-0000-0000-000000000000}}{0}]{1}' -f $SortedToolsString, $SortedCSEString
    }
}