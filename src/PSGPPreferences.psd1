@{
    RootModule        = 'PSGPPreferences.psm1'
    ModuleVersion     = '0.2.0'
    GUID              = '840171e9-2b12-448d-9fe3-9365af87081e'
    Author            = 'Kirill Nikolaev'
    PowerShellVersion = '5.1'
    Description       = 'A way to manage Group Policy Preferences through PowerShell'
    RequiredModules   = @(
        'PsIni'
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
        'Add-GPPUser'
        'Get-GPPUser'
        'New-GPPUser'
        'Set-GPPUser'
        'Remove-GPPUser'
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