#region Common

enum GPPItemAction {
    C
    R
    U
    D
}

enum GPPItemActionDisplay {
    Create
    Replace
    Update
    Delete
}

enum GPPType {
    Groups
}

enum GPPContext {
    Machine
#    User  I'll enable it later
}

class PSGPPreferencesItem {
    # This class is needed to gather all unique module's classes under a single umbrella.
    # It allows to strongly type input for the Serialize-GPPItem function - the purpose of that function is
    # to be able to serialize any GPP object we throw at it, but not other objects.
    # Therefore a single parent is required.
}

class GPPSection : PSGPPreferencesItem {
    # GPPSection is  what you see on the second level in the GPP folder in the GUI.
    # For example, "Local Users and Groups" is the "Groups" section. Yes, "User" objects are a part of the "Groups" section.
    [guid]$clsid
    [bool]$disabled
}

class GPPItemProperties : PSGPPreferencesItem {
    [GPPItemAction]$action
}

class GPPItemFilter : PSGPPreferencesItem {
    [GPPItemFilterBool]$bool
    [bool]$not
    [string]$filterName
    [string]$filterInfo
}

class GPPItem : PSGPPreferencesItem {
    [guid]$clsid
    [string]$name
    hidden [string]$status
    hidden [int]$image = $Properties.action.value__
    [datetime]$changed = (Get-Date)
    [guid]$uid = [guid]::NewGuid()
    [bool]$removePolicy
    [bool]$bypassErrors = $true
    [bool]$disabled
    [GPPItemProperties]$Properties
    [GPPItemFilter[]]$Filters
}
#endregion

#region Filters

enum GPPItemFilterBool {
    AND
    OR
}

enum GPPItemFilterComputerType {
    NETBIOS
    DNS
}

enum GPPItemFilterDatePeriod {
    WEEKLY
    MONTHLY
    YEARLY
}

enum GPPItemFilterDateDoW {
    SUN
    MON
    TUE
    WED
    THU
    FRI
    SAT
}

enum GPPItemFilterFileType {
    EXISTS
    VERSION
}

enum GPPItemFilterOSType {
    NE
    SV # Member Server
    DC # Domain Controller
}

enum GPPItemFilterTerminalType {
    NE
    TS
}

enum GPPItemFilterTerminalOption {
    NE
    APPLICATION
    CLIENT
    PROGRAM
    SESSION
    DIRECTORY
    IP
}


class GPPItemFilterBattery : GPPItemFilter {

}

class GPPItemFilterComputer : GPPItemFilter {
    [GPPItemFilterComputerType]$type
    [string]$name
}

class GPPItemFilterCPU : GPPItemFilter {
    [int]$speedMHz
}

class GPPItemFilterDate : GPPItemFilter {
    [GPPItemFilterDatePeriod]$period
    [GPPItemFilterDateDoW]$dow
    [int]$day
    [int]$month
    [int]$year


    GPPItemFilterDate ([GPPItemFilterBool]$bool, [bool]$not, [GPPItemFilterDatePeriod] $period, [GPPItemFilterDateDoW] $dow) {
        $this.period = $period
        $this.dow = $dow
    }

    GPPItemFilterDate([GPPItemFilterBool]$bool, [bool]$not, [GPPItemFilterDatePeriod] $period, [int] $day) {
        $this.period = $period
        $this.day = $day
    }

    GPPItemFilterDate([GPPItemFilterBool]$bool, [bool]$not, [GPPItemFilterDatePeriod] $period, [datetime]$Date) {
        $this.period = $period
        $this.day = $Date.Day
        $this.month = $Date.Month
        $this.year = $Date.Year
    }
}

class GPPItemFilterDisk : GPPItemFilter {
    [int]$freeSpace
    [string]$drive
}

class GPPItemFilterDomain : GPPItemFilter {
    [string]$name
    [bool]$userContext
}

class GPPItemFilterVariable : GPPItemFilter {
    [string]$variableName
    [string]$value
}

class GPPItemFilterFile : GPPItemFilter {
    [string]$path
    [GPPItemFilterFileType]$type
    [bool]$folder
    [version]$min
    [version]$max
    [bool]$gte
    [bool]$lte
}

class GPPItemFilterIpRange : GPPItemFilter {
    [bool]$useIPv6
    [string]$min
    [string]$max
}

class GPPItemFilterLanguage : GPPItemFilter {
    [bool]$default
    [bool]$system
    [bool]$native
    [string]$displayName
    [int]$language
    [int]$locale
}

class GPPItemFilterLdap : GPPItemFilter {
    [string]$searchFilter
    [string]$binding
    [string]$variableName
    [string]$attribute
}

class GPPItemFilterMacRange : GPPItemFilter {
    [string]$min
    [string]$max
}

class GPPItemFilterMsi : GPPItemFilter {
    # TODO
}

class GPPItemFilterOS : GPPItemFilter {
    static [string]$class = 'NT'
    [string]$version
    [GPPItemFilterOSType]$type
    [string]$edition
    [string]$sp
}

class GPPItemFilterOrgUnit : GPPItemFilter {
    [string]$name
    [bool]$userContext
    [bool]$directMember
}

class GPPItemFiltePcmcia : GPPItemFilter {

}

class GPPItemFilterPortable : GPPItemFilter {
    [bool]$unknown
    [bool]$docked
    [bool]$undocked
}

class GPPItemFilterProcMode : GPPItemFilter {
    [bool]$synchFore
    [bool]$asynchFore
    [bool]$backRefr
    [bool]$forceRefr
    [bool]$linkTrns
    [bool]$noChg
    [bool]$rsopTrns
    [bool]$safeBoot
    [bool]$slowLink
    [bool]$verbLog
    [bool]$rsopEnbl
}

class GPPItemFilterRam : GPPItemFilter {
    [int]$totalMB
}

class GPPItemFilterRegistry : GPPItemFilter {
    # TODO
}

class GPPItemFilterGroup : GPPItemFilter {
    [string]$name
    [System.Security.Principal.SecurityIdentifier]$sid
    [bool]$userContext
    [bool]$primaryGroup
    [bool]$localGroup
}

class GPPItemFilterSite : GPPItemFilter {
    [string]$name
}

class GPPItemFilterTerminal : GPPItemFilter {
    [GPPItemFilterTerminalType]$type
    [GPPItemFilterTerminalType]$option
    [string]$value
    [string]$min
    [string]$max
}

class GPPItemFilterTime : GPPItemFilter {
    [string]$begin
    [string]$end
}

class GPPItemFilterWmi : GPPItemFilter {
    [string]$query
    [string]$nameSpace
    [string]$property
    [string]$variableName
}

class GPPItemFilterRunOnce : GPPItemFilter {
    static [bool]$hidden = 1
    [guid]$id = [guid]::NewGuid()
}

class GPPItemFilterCollection : GPPItemFilter {
    [GPPItemFilter[]]$Members
}

#endregion

#region Groups

enum GPPItemGroupMemberAction {
    ADD
    REMOVE
}

enum GPPItemUserSubAuthority {
    RID_ADMIN
    RID_GUEST
}

class GPPItemGroupsSection : GPPItem {
    # This class is needed only because both GPPItemGroup and GPPItemUser can be members of GPPSectionGroups (the "Groups" section in an XML-file)
}

class GPPItemGroupMember : PSGPPreferencesItem {
    [string]$name
    [GPPItemGroupMemberAction]$action
    [System.Security.Principal.SecurityIdentifier]$sid

    GPPItemGroupMember([GPPItemGroupMemberAction] $Action, [string]$Name, [System.Security.Principal.SecurityIdentifier] $SID) {
        $this.action = $Action
        $this.name = $Name
        $this.sid = $SID
    }

    GPPItemGroupMember([GPPItemGroupMemberAction] $Action, [string]$Name) {
        $this.action = $Action
        $this.name = $Name
    }
}

class GPPItemPropertiesGroup : GPPItemProperties {
    [string]$newName
    [string]$description
    [bool]$deleteAllUsers
    [bool]$deleteAllGroups
    hidden [bool]$removeAccounts = 0 # Always zero - don't know why, don't know what it does
    [System.Security.Principal.SecurityIdentifier]$groupSid
    [string]$groupName
    [System.Collections.Generic.List[GPPItemGroupMember]]$Members

    GPPItemPropertiesGroup ([GPPItemAction] $Action, [string] $Name, [System.Security.Principal.SecurityIdentifier] $SID) {
        $this.action = $Action
        $this.groupName = $Name
        $this.groupSid = $SID
    }

    GPPItemPropertiesGroup ([GPPItemAction] $Action, [string] $Name, [System.Security.Principal.SecurityIdentifier] $SID, [GPPItemGroupMember[]]$Members) {
        $this.action = $Action
        $this.groupName = $Name
        $this.groupSid = $SID
        $this.Members = $Members
    }

    GPPItemPropertiesGroup ([GPPItemAction] $Action, [string] $Name, [System.Security.Principal.SecurityIdentifier] $SID, [string] $NewName, [string] $Description) {
        $this.action = $Action
        $this.groupName = $Name
        $this.groupSid = $SID
        $this.newName = $NewName
        $this.description = $Description
    }

    GPPItemPropertiesGroup ([GPPItemAction] $Action, [string] $Name, [System.Security.Principal.SecurityIdentifier] $SID, [string] $NewName, [string] $Description, [GPPItemGroupMember[]] $Members) {
        $this.action = $Action
        $this.groupName = $Name
        $this.groupSid = $SID
        $this.newName = $NewName
        $this.description = $Description
        $this.Members = $Members
    }

    GPPItemPropertiesGroup ([GPPItemAction] $Action, [string] $Name, [System.Security.Principal.SecurityIdentifier] $SID, [string] $NewName, [string] $Description, [GPPItemGroupMember[]] $Members, [bool] $DeleteAllUsers, [bool] $DeleteAllGroups) {
        $this.action = $Action
        $this.groupName = $Name
        $this.groupSid = $SID
        $this.newName = $NewName
        $this.description = $Description
        $this.Members = $Members
        $this.deleteAllUsers = $DeleteAllUsers
        $this.deleteAllGroups = $DeleteAllGroups
    }

    [void]RemoveMember([GPPItemGroupMember] $Member) {
        $NewMembers = [System.Collections.Generic.List[GPPItemGroupMember]]::new()
        foreach ($ExistingMember in $this.Members) {
            if ($ExistingMember -ne $Member) {
                $NewMembers.Add($ExistingMember)
            }
        }
        $this.Members = $NewMembers
    }
}

class GPPItemGroup : GPPItemGroupsSection {
    static [guid]$clsid = '{6D4A79E4-529C-4481-ABD0-F5BD7EA93BA7}'
    [GPPItemPropertiesGroup]$Properties

    GPPItemGroup([GPPItemPropertiesGroup] $Properties, [bool] $Disabled) {
        $this.Properties = $Properties
        $this.name = $Properties.groupName
        $this.disabled = $Disabled
    }

    GPPItemGroup([GPPItemPropertiesGroup] $Properties, [guid] $UID, [bool] $Disabled) {
        $this.Properties = $Properties
        $this.name = $Properties.groupName
        $this.uid = $UID
        $this.disabled = $Disabled
    }
}

class GPPItemPropertiesUser : GPPItemProperties {
    [string]$newName
    [string]$fullName
    [string]$description
    # [string]$cpassword - EVIL, EVIL PROPERTY, ONE SHOULD NEVER USE IT
    [bool]$changeLogon
    [bool]$noChange
    [bool]$neverExpires
    [bool]$acctDisabled
    [GPPItemUserSubAuthority]$subAuthority
    [string]$userName
    [string]$expires
}

class GPPItemUser : GPPItemGroupsSection {
    static [guid]$clsid = '{DF5F1855-51E5-4d24-8B1A-D9BDE98BA1D1}'
    [GPPItemPropertiesUser]$Properties

    GPPItemUser([GPPItemPropertiesGroup] $Properties, [bool] $Disabled) {
        $this.Properties = $Properties
        $this.name = $Properties.groupName
        $this.disabled = $Disabled
    }

    GPPItemUser([GPPItemPropertiesGroup] $Properties, [guid] $UID, [bool] $Disabled) {
        $this.Properties = $Properties
        $this.name = $Properties.groupName
        $this.uid = $UID
        $this.disabled = $Disabled
    }
}

class GPPSectionGroups : GPPSection {
    static [guid]$clsid = '{3125E937-EB16-4b4c-9934-544FC6D24D26}'
    [System.Collections.Generic.List[GPPItemGroupsSection]]$Members = @()

    GPPSectionGroups([GPPItemGroupsSection[]] $Members, [bool] $Disabled) {
        $this.Members = $Members
        $this.disabled = $Disabled
    }
}
#endregion

#region IniFiles
class GPPItemPropertiesIni : GPPItemProperties {
    [string]$path
    [string]$section
    [string]$value
    [string]$property
}

class GPPItemIni : GPPItem {
    static [guid]$clsid = '{EEFACE84-D3D8-4680-8D4B-BF103E759448}'
    [GPPItemPropertiesIni]$Properties
}

class GPPSectionIniFiles : GPPSection {
    static [guid]$clsid = '{694C651A-08F2-47fa-A427-34C4F62BA207}'
    [GPPItemIni]$Members
}
#endregion