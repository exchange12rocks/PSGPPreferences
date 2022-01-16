#Requires -Version 3.0

$ModulePath = $PSScriptRoot

foreach ($FolderName in @('Definitions')) {
    $Path = Join-Path -Path $ModulePath -ChildPath ('{0}\*.ps1' -f $FolderName)
    if (Test-Path -Path $Path) {
        Get-ChildItem -Path $Path -Recurse | ForEach-Object -Process {. $_.FullName}
    }
}

[GPPContext]$ModuleWideDefaultGPPContext = [GPPContext]::Machine

foreach ($FolderName in @('Common', 'Groups', 'Serialization')) {
    $Path = Join-Path -Path $ModulePath -ChildPath ('{0}\*.ps1' -f $FolderName)
    if (Test-Path -Path $Path) {
        Get-ChildItem -Path $Path -Recurse | ForEach-Object -Process {. $_.FullName}
    }
}