BeforeDiscovery {
    $ScriptDirectoryPath = $PSScriptRoot
    $DataSourcePath = Join-Path -Path $ScriptDirectoryPath -ChildPath 'Data\Groups'
    $Set1Path = Join-Path -Path $DataSourcePath -ChildPath 'Groups-UserOnly-Set-1.xml'
    [xml]$Set1Data = Get-Content -Path $Set1Path
    $Set2Path = Join-Path -Path $DataSourcePath -ChildPath 'Groups-UserOnly-Set-2.xml'
    [xml]$Set2Data = Get-Content -Path $Set2Path
    $ModuleRootPath = Join-Path -Path $ScriptDirectoryPath -ChildPath ..\src\
    Import-Module -Name (Join-Path -Path $ModuleRootPath -ChildPath 'PSGPPreferences.psd1') -Force
    . (Join-Path -Path $ModuleRootPath -ChildPath 'Definitions\Classes.ps1')
}

Describe 'Internal functions' {
    InModuleScope PSGPPreferences {
        BeforeAll {
            $GPPSectionSet1 = Deserialize-GPPSection -InputObject $Set1Data
            $GPPSectionSet2 = Deserialize-GPPSection -InputObject $Set2Data
        }

    }
}