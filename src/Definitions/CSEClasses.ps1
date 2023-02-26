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

class GPPCSE {
    static [hashtable]$All = @{
        # https://web.archive.org/web/20230225180305/https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-gppref/a00e597a-cd21-4a97-9277-f53fae251acf
        # https://web.archive.org/web/20230225231706/https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-gppref/12512ed6-0632-4e90-a112-d3d2cd41df6c
        [GPPType]::Applications         = [GpoCseSet]::new([guid]'F9C77450-3A41-477E-9310-9ACD617BD9E3', [guid]'0DA274B5-EB93-47A7-AAFB-65BA532D3FE6')
        [GPPType]::DataSources          = [GpoCseSet]::new([guid]'728EE579-943C-4519-9EF7-AB56765798ED', [guid]'1612B55C-243C-48DD-A449-FFC097B19776')
        [GPPType]::Devices              = [GpoCseSet]::new([guid]'1A6364EB-776B-4120-ADE1-B63A406A76B5', [guid]'1B767E9A-7BE4-4D35-85C1-2E174A7BA951')
        [GPPType]::Drives               = [GpoCseSet]::new([guid]'5794DAFD-BE60-433F-88A2-1A31939AC01F', [guid]'2EA1A81B-48E5-45E9-8BB7-A6E3AC170006')
        [GPPType]::EnvironmentVariables = [GpoCseSet]::new([guid]'0E28E245-9368-4853-AD84-6DA3BA35BB75', [guid]'35141B6B-498A-4CC7-AD59-CEF93D89B2CE')
        [GPPType]::Files                = [GpoCseSet]::new([guid]'7150F9BF-48AD-4da4-A49C-29EF4A8369BA', [guid]'3BAE7E51-E3F4-41D0-853D-9BB9FD47605F')
        [GPPType]::FolderOptions        = [GpoCseSet]::new([guid]'A3F3E39B-5D83-4940-B954-28315B82F0A8', [guid]'3BFAE46A-7F3A-467B-8CEA-6AA34DC71F53')
        [GPPType]::Folders              = [GpoCseSet]::new([guid]'6232C319-91AC-4931-9385-E70C2B099F0E', [guid]'3EC4E9D3-714D-471F-88DC-4DD4471AAB47')
        [GPPType]::IniFiles             = [GpoCseSet]::new([guid]'74EE6C03-5363-4554-B161-627540339CAB', [guid]'516FC620-5D34-4B08-8165-6A06B623EDEB')
        [GPPType]::InternetSettings     = [GpoCseSet]::new([guid]'E47248BA-94CC-49C4-BBB5-9EB7F05183D0', [guid]'5C935941-A954-4F7C-B507-885941ECE5C4')
        [GPPType]::Groups               = [GpoCseSet]::new([guid]'17D89FEC-5C44-4972-B12D-241CAEF74509', [guid]'79F92669-4224-476c-9C5C-6EFB4D87DF4A')
        [GPPType]::NetworkOptions       = [GpoCseSet]::new([guid]'3A0DBA37-F8B2-4356-83DE-3E90BD5C261F', [guid]'949FB894-E883-42C6-88C1-29169720E8CA')
        [GPPType]::NetworkShareSettings = [GpoCseSet]::new([guid]'6A4C88C6-C502-4F74-8F60-2CB23EDC24E2', [guid]'BFCBBEB0-9DF4-4C0c-A728-434EA66A0373')
        [GPPType]::PowerOptions         = [GpoCseSet]::new([guid]'E62688F0-25FD-4C90-BFF5-F508B9D2E31F', [guid]'9AD2BAFE-63B4-4883-A08C-C3C6196BCAFD')
        [GPPType]::Printers             = [GpoCseSet]::new([guid]'BC75B1ED-5833-4858-9BB8-CBF0B166DF9D', [guid]'A8C42CEA-CDB8-4388-97F4-5831F933DA84')
        [GPPType]::Regional             = [GpoCseSet]::new([guid]'E5094040-C46C-4115-B030-04FB2E545B00', [guid]'B9CCA4DE-E2B9-4CBD-BF7D-11B6EBFBDDF7')
        [GPPType]::RegistrySettings     = [GpoCseSet]::new([guid]'B087BE9D-ED37-454F-AF9C-04291E351182', [guid]'BEE07A6A-EC9F-4659-B8C9-0B1937907C83')
        [GPPType]::ScheduledTasks       = [GpoCseSet]::new([guid]'AADCED64-746C-4633-A97C-D61349046527', [guid]'CAB54552-DEEA-4691-817E-ED4A4D1AFC72')
        [GPPType]::NTServices           = [GpoCseSet]::new([guid]'91FBB303-0CD5-4055-BF42-E512A681B325', [guid]'CC5746A9-9B74-4BE5-AE2E-64379C86E0E4')
        [GPPType]::Shortcuts            = [GpoCseSet]::new([guid]'C418DD9D-0D14-4EFB-8FBF-CFE535C8FAC7', [guid]'CEFFA6E2-E3BD-421B-852C-6F6A79A59BC1')
        [GPPType]::StartMenuTaskbar     = [GpoCseSet]::new([guid]'E4F48E54-F38D-4884-BFB9-D4D2E5729C18', [guid]'CF848D48-888D-4F45-B530-6A201E62A605')
    }

    static [GpoCseSet] GetCseSetByType ([GPPType] $Type) {
        $Definitions = [GPPCSE]::All
        return $Definitions.$Type
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

        $CSEDefinitions = [GPPCSE]::All
        $GPPToolExtensionGUIDs = foreach ($Key in $CSEDefinitions.Keys) {
            $CSEDefinitions.$Key.Tool.Guid
        }

        $SortedTools = $this.Members.Tool | Where-Object -FilterScript { $_ -in $GPPToolExtensionGUIDs } | Sort-Object

        $sb = [System.Text.StringBuilder]::new()
        foreach ($Tool in $SortedTools) {
            [void]$sb.Append($Tool.ToString('B').ToUpper())
        }
        $SortedToolsString = $sb.ToString()

        $SortedCSE = $this.Members.CSE | Sort-Object

        $sb = [System.Text.StringBuilder]::new()
        foreach ($CSE in $SortedCSE) {
            $CurrentCSESet = $this.Members | Where-Object -FilterScript { $_.CSE -eq $CSE }
            $CurrentCSEString = $CSE.ToString('B').ToUpper()
            $SortedCSETools = $CurrentCSESet.Tool | Sort-Object
            $sb2 = [System.Text.StringBuilder]::new()
            foreach ($Tool in $SortedCSETools) {
                [void]$sb2.Append($Tool.ToString('B').ToUpper())
            }
            $SortedCSEToolsString = $sb2.ToString()
            [void]$sb.Append(('[{0}{1}]' -f $CurrentCSEString, $SortedCSEToolsString))
        }
        $SortedCSEString = $sb.ToString()

        # GPP Tool Extensions are added into a special "null"-section in *ExtensionNames attributes
        # https://web.archive.org/web/20220731175940/https://sdmsoftware.com/tips-tricks/group-policy-preferences-in-the-local-gpo-yes/
        return '[{{00000000-0000-0000-0000-000000000000}}{0}]{1}' -f $SortedToolsString, $SortedCSEString
    }
}
