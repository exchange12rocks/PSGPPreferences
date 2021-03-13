#Requires -Version 3.0

$ModulePath = $PSScriptRoot
$FunctionsPath = Join-Path -Path $ModulePath -ChildPath 'src'

foreach ($FolderName in @('Definitions')) {
    $Path = Join-Path -Path $FunctionsPath -ChildPath ('{0}\*.ps1' -f $FolderName)
    if (Test-Path -Path $Path) {
        Get-ChildItem -Path $Path -Recurse | ForEach-Object -Process {. $_.FullName}
    }
}

[GPPContext]$ModuleWideDefaultGPPContext = [GPPContext]::Machine

foreach ($FolderName in @('Common', 'Groups', 'Serialization')) {
    $Path = Join-Path -Path $FunctionsPath -ChildPath ('{0}\*.ps1' -f $FolderName)
    if (Test-Path -Path $Path) {
        Get-ChildItem -Path $Path -Recurse | ForEach-Object -Process {. $_.FullName}
    }
}