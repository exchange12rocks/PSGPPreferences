function Deserialize-GPPSection {
    Param (
        [Parameter(Mandatory)]
        [xml]$InputObject
    )

    $RootElement = $InputObject.DocumentElement

    switch ($RootElement.Name) {
        'Groups' {
            Deserialize-GPPSectionGroups -InputObject $RootElement
        }
        'Files' {
            # TODO
        }
        'IniFiles' {
            # TODO
        }
    }
}
