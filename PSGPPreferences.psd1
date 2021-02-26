@{
    RootModule        = 'PSGPPreferences.psm1'
    ModuleVersion     = '0.1.1'
    GUID              = '840171e9-2b12-448d-9fe3-9365af87081e'
    Author            = 'Kirill Nikolaev'
    PowerShellVersion = '5.1'
    Description       = ''
    RequiredModules   = @(
    )
    FunctionsToExport = @(
        'Add-GPPGroup'
        'Add-GPPGroupMember'
        'Get-GPPGroup'
        'Get-GPPGroupMember'
        'New-GPPGroup'
        'New-GPPGroupMember'
        'Remove-GPPGroup'
        'Remove-GPPGroupMember'
        'Set-GPPGroup'
        'Set-GPPGroupMember'
    )
    CmdletsToExport   = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @()
            LicenseUri   = 'https://github.com/exchange12rocks/PSGPPreferences/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/exchange12rocks/PSGPPreferences/'
            ReleaseNotes = ''
        }
    }
}