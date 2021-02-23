# PSGPPreferences - a native PowerShell way to manage Group Policy Preferences (formerly PolicyMaker)

The goal of this rather ambitious project is to provide full Group Policy Preferences experience in a command-line interface. Currentlly, Microsoft gives us only cmdlets for the Registry section of GPP, which is clearly not enough.

For more information see:
* https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/dn789194(v=ws.11)
* https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/dn581922(v=ws.11)
* https://web.archive.org/web/20060323144551/http://www.desktopstandard.com/pdf/pmsemanual.pdf

(Yep, all publicly available official documentation for this functionality is retired)

The most important part of GPP for me is "Local Users and Groups", that's why I started with it.

This module is a very much work in progress — expect breaking changes ahead.
Your help is welcome and appreciated.

## Installation

`Install-Module PSGPPreferences`

## What does already work

* The "Local Users and Groups" section, partially - Groups only:
  * You can create new groups and members (`New-GPPGroup`, `New-GPPGroupMember`),
  * retrieve groups and their members (`Get-GPPGroup`, `Get-GPPGroupMember`),
  * remove existing groups (`Remove-GPPGroup`),
  * add/remove members to/from groups (`Add-GPPGroupMember`, `Remove-GPPGroupMember`),
  * set group and member properties (`Set-GPPGroup`, `Set-GPPGroupMember`).

## What does not work, yet

* Other GPP sections
* Filters
* User context. Only the Machine context is supported right now

  * I expect implementing this feature to be a breaking change.
* Ordering
* Cross-domain editing

  * Currently you can work with group policies from your workstation's domain only

## Roadmap

1. Add Users support (section "Local Users and Groups") and add some tests
1. More tests
1. Support for changing the following properties:
    * [bool]$removePolicy
    * [bool]$bypassErrors
1. Support for disabling whole sections
1. Devices (v.0.3)
1. User context (v.1.0)
1. Services (v.1.0)
1. Filters (v.1.1)
    * At least some
1. Files (v.1.2)
1. Folders
1. Ordering
1. Environment
1. Ini Files
1. Data Sources
1. Shortcuts
1. Network Shares
1. Everything else

## What will NOT be implemented in the foreseeable future

* Filters: MSI, Registry (They are too complicated)
* Sections: Registry (Windows already has built-in cmdlets for that)
