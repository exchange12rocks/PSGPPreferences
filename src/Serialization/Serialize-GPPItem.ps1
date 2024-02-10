function Serialize-GPPItem {
    Param (
        [Parameter(Mandatory)]
        [PSGPPreferencesItem]$InputObject,
        [Parameter(Mandatory)]
        [string]$RootElementName,
        [string[]]$SpecialSerializationTypeNames
    )

    $PropertyDefinitions = Get-Member -InputObject $InputObject -Force | Where-Object -FilterScript {$_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property}
    $StaticPropertyDefinitions = Get-Member -InputObject $InputObject -Force -Static | Where-Object -FilterScript {$_.MemberType -eq [System.Management.Automation.PSMemberTypes]::Property}

    $CombinedPropertyDefinitions = [System.Collections.Generic.List[PSCustomObject]]::new()
    foreach ($PropertyDefinition in $StaticPropertyDefinitions) {
        $CombinedPropertyDefinitions.Add(
            [PSCustomObject]@{
                Name = $PropertyDefinition.Name
                Type = 'Static'
            }
        )
    }
    foreach ($PropertyDefinition in $PropertyDefinitions) {
        $CombinedPropertyDefinitions.Add(
            [PSCustomObject]@{
                Name = $PropertyDefinition.Name
                Type = 'Non-static'
            }
        )
    }

    $XmlDocument = [System.Xml.XmlDocument]::new()

    $RootElement = $XmlDocument.CreateElement($RootElementName)
    [void]$XmlDocument.AppendChild($RootElement)

    foreach ($PropertyDefinition in $CombinedPropertyDefinitions) {
        $PropertyName = $PropertyDefinition.Name
        $PropertyValue = switch ($PropertyDefinition.Type) {
            'Static' {
                $InputObject::$PropertyName
            }
            Default {
                $InputObject.$PropertyName
            }
        }

        $ProcessedPropertyValue = switch ($PropertyValue) {
            {$_ -is [bool]} {
                if ($_) {
                    1
                }
                else {
                    0
                }
            }
            {$_ -is [datetime]} {
                $_.ToString('yyyy-MM-dd HH:mm:ss')
            }
            {$_ -is [guid]} {
                $_.ToString('B') # https://docs.microsoft.com/en-us/dotnet/api/system.guid.tostring?view=net-5.0#System_Guid_ToString_System_String: B - 32 digits separated by hyphens, enclosed in braces
            }
            {$_ -is [System.Xml.XmlElement]} {
                $XmlElementToInsert = $XmlDocument.ImportNode($_, $true)
                [void]$RootElement.AppendChild($XmlElementToInsert)
            }
            Default {
                if ($null -ne $_ -and $_.GetType().FullName -notin $SpecialSerializationTypeNames) {
                    $_
                }
            }
        }

        if ($null -ne $ProcessedPropertyValue) {
            # This allows us to keep [int]0 values, but remove empty strings and specially serialized properties
            $RootElement.SetAttribute($PropertyName, $ProcessedPropertyValue)
        }
    }

    $XmlDocument
}