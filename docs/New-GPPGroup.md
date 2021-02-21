---
external help file: PSGPPreferences-help.xml
Module Name: PSGPPreferences
online version:
schema: 2.0.0
---

# New-GPPGroup

## SYNOPSIS
Creates a new Group Policy Preferences group definition.

## SYNTAX

### ByGPOIdGroupNameDelete
```
New-GPPGroup -Name <String> [-Delete] -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPONameGroupNameDelete
```
New-GPPGroup -Name <String> [-Delete] -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGroupNameDelete
```
New-GPPGroup -Name <String> [-Delete] [<CommonParameters>]
```

### ByGPOIdGroupNameUpdate
```
New-GPPGroup -Name <String> [-Update] -GPOId <Guid> [-Context <GPPContext>] [-NewName <String>]
 [-Description <String>] [-DeleteAllUsers] [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>]
 [-PassThru] [<CommonParameters>]
```

### ByGPONameGroupNameUpdate
```
New-GPPGroup -Name <String> [-Update] -GPOName <String> [-Context <GPPContext>] [-NewName <String>]
 [-Description <String>] [-DeleteAllUsers] [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>]
 [-PassThru] [<CommonParameters>]
```

### ByGroupNameUpdate
```
New-GPPGroup -Name <String> [-Update] [-NewName <String>] [-Description <String>] [-DeleteAllUsers]
 [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>] [-PassThru] [<CommonParameters>]
```

### ByGPOIdGroupNameReplace
```
New-GPPGroup -Name <String> [-Replace] -GPOId <Guid> [-Context <GPPContext>] [-Description <String>]
 [-DeleteAllUsers] [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>] [-PassThru]
 [<CommonParameters>]
```

### ByGPONameGroupNameReplace
```
New-GPPGroup -Name <String> [-Replace] -GPOName <String> [-Context <GPPContext>] [-Description <String>]
 [-DeleteAllUsers] [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>] [-PassThru]
 [<CommonParameters>]
```

### ByGroupNameReplace
```
New-GPPGroup -Name <String> [-Replace] [-Description <String>] [-DeleteAllUsers] [-DeleteAllGroups] [-Disable]
 [-Members <GPPItemGroupMember[]>] [-PassThru] [<CommonParameters>]
```

### ByGPOIdGroupNameCreate
```
New-GPPGroup -Name <String> [-Create] -GPOId <Guid> [-Context <GPPContext>] [-Description <String>]
 [-DeleteAllUsers] [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>] [-PassThru]
 [<CommonParameters>]
```

### ByGPONameGroupNameCreate
```
New-GPPGroup -Name <String> [-Create] -GPOName <String> [-Context <GPPContext>] [-Description <String>]
 [-DeleteAllUsers] [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>] [-PassThru]
 [<CommonParameters>]
```

### ByGroupNameCreate
```
New-GPPGroup -Name <String> [-Create] [-Description <String>] [-DeleteAllUsers] [-DeleteAllGroups] [-Disable]
 [-Members <GPPItemGroupMember[]>] [-PassThru] [<CommonParameters>]
```

### ByGPOIdGroupSIDDelete
```
New-GPPGroup -SID <SecurityIdentifier> [-Delete] -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPONameGroupSIDDelete
```
New-GPPGroup -SID <SecurityIdentifier> [-Delete] -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGroupSIDDelete
```
New-GPPGroup -SID <SecurityIdentifier> [-Delete] [<CommonParameters>]
```

### ByGPOIdGroupSIDUpdate
```
New-GPPGroup -SID <SecurityIdentifier> [-Update] -GPOId <Guid> [-Context <GPPContext>] [-NewName <String>]
 [-Description <String>] [-DeleteAllUsers] [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>]
 [-PassThru] [<CommonParameters>]
```

### ByGPONameGroupSIDUpdate
```
New-GPPGroup -SID <SecurityIdentifier> [-Update] -GPOName <String> [-Context <GPPContext>] [-NewName <String>]
 [-Description <String>] [-DeleteAllUsers] [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>]
 [-PassThru] [<CommonParameters>]
```

### ByGroupSIDUpdate
```
New-GPPGroup -SID <SecurityIdentifier> [-Update] [-NewName <String>] [-Description <String>] [-DeleteAllUsers]
 [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>] [-PassThru] [<CommonParameters>]
```

### ByGPOIdGroupSIDReplace
```
New-GPPGroup -SID <SecurityIdentifier> [-Replace] -GPOId <Guid> [-Context <GPPContext>] [-Description <String>]
 [-DeleteAllUsers] [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>] [-PassThru]
 [<CommonParameters>]
```

### ByGPONameGroupSIDReplace
```
New-GPPGroup -SID <SecurityIdentifier> [-Replace] -GPOName <String> [-Context <GPPContext>]
 [-Description <String>] [-DeleteAllUsers] [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>]
 [-PassThru] [<CommonParameters>]
```

### ByGroupSIDReplace
```
New-GPPGroup -SID <SecurityIdentifier> [-Replace] [-Description <String>] [-DeleteAllUsers] [-DeleteAllGroups]
 [-Disable] [-Members <GPPItemGroupMember[]>] [-PassThru] [<CommonParameters>]
```

### ByGPOIdGroupSIDCreate
```
New-GPPGroup -SID <SecurityIdentifier> [-Create] -GPOId <Guid> [-Context <GPPContext>] [-Description <String>]
 [-DeleteAllUsers] [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>] [-PassThru]
 [<CommonParameters>]
```

### ByGPONameGroupSIDCreate
```
New-GPPGroup -SID <SecurityIdentifier> [-Create] -GPOName <String> [-Context <GPPContext>]
 [-Description <String>] [-DeleteAllUsers] [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>]
 [-PassThru] [<CommonParameters>]
```

### ByGroupSIDCreate
```
New-GPPGroup -SID <SecurityIdentifier> [-Create] [-Description <String>] [-DeleteAllUsers] [-DeleteAllGroups]
 [-Disable] [-Members <GPPItemGroupMember[]>] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION
Creates a new Group Policy Preferences group definition. You can either save it in the memory for additional processing or immediately put into a GPO by using the -GPOName or -GPOId parameters.

Note that available parameters depend on the action you choose: -Create, -Replace, -Update, or -Delete.
This mimics the GUI behavior.

## EXAMPLES

### Example 1
```powershell
PS C:\> $Members = New-GPPGroupMember -SID 'S-1-5-21-2571216883-1601522099-2002488368-500' -Action REMOVE
PS C:\> New-GPPGroup -Name 'TEST-1' -GPOName 'Custom Group Policy' -Create -Members $Members
```

Creates a new group definition for a group called "TEST-1" with its action set to "Create" and using $Members as members for this group. The definition is saved in a GPO called "Custom Group Policy".

### Example 2
```powershell
PS C:\> New-GPPGroup -Name 'TEST-1' -GPOId '70f86590-588a-4659-8880-3d2374604811' -Delete
```

Creates a new group definition for a group called "TEST-1" with its action set to "Delete", and saved it in a GPO with ID 70f86590-588a-4659-8880-3d2374604811.

### Example 3
```powershell
PS C:\> $GroupDef = New-GPPGroup -SID 'S-1-5-32-547' -Update -Members (New-GPPGroupMember -Name 'EXAMPLE\SupportGroup' -Action ADD)
```

Creates a new group definition with "EXAMPLE\SupportGroup" as group member and "Update" as its action. The definition specifies the group by SID rather its name. S-1-5-32-547 means "Power Users".
Note that this group definition is not saved in any group policy object - it exists only in memory. You can modify it and later save in a GPO using Add-GPPGroup.

### Example 4
```powershell
PS C:\> New-GPPGroup -Name 'TEST-1' -Replace -GPOName 'Custom Group Policy' -Members @((New-GPPGroupMember -Name 'EXAMPLE\Administrator' -Action ADD),(New-GPPGroupMember -Name 'EXAMPLE\SupportGroup' -Action ADD)) -Disable
```

Creates a new group definition in a GPO named "Custom Group Policy", with "EXAMPLE\Administrator" and "EXAMPLE\SupportGroup" as group members. The group definition will be in a disabled state and its action is "Replace".

## PARAMETERS

### -Context
Specifies which Group Policy context to use: Machine or User. Doesn't do anything right now, since the User one has not yet been implemented.

```yaml
Type: GPPContext
Parameter Sets: ByGPOIdGroupNameDelete, ByGPONameGroupNameDelete, ByGPOIdGroupNameUpdate, ByGPONameGroupNameUpdate, ByGPOIdGroupNameReplace, ByGPONameGroupNameReplace, ByGPOIdGroupNameCreate, ByGPONameGroupNameCreate, ByGPOIdGroupSIDDelete, ByGPONameGroupSIDDelete, ByGPOIdGroupSIDUpdate, ByGPONameGroupSIDUpdate, ByGPOIdGroupSIDReplace, ByGPONameGroupSIDReplace, ByGPOIdGroupSIDCreate, ByGPONameGroupSIDCreate
Aliases:
Accepted values: Machine

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Create
Sets the action property of the group definition to "Create".

```yaml
Type: SwitchParameter
Parameter Sets: ByGPOIdGroupNameCreate, ByGPONameGroupNameCreate, ByGroupNameCreate, ByGPOIdGroupSIDCreate, ByGPONameGroupSIDCreate, ByGroupSIDCreate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Delete
Sets the action property of the group definition to "Delete".

```yaml
Type: SwitchParameter
Parameter Sets: ByGPOIdGroupNameDelete, ByGPONameGroupNameDelete, ByGroupNameDelete, ByGPOIdGroupSIDDelete, ByGPONameGroupSIDDelete, ByGroupSIDDelete
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeleteAllGroups
Sets the DeleteAllGroups attribute at the group object.

```yaml
Type: SwitchParameter
Parameter Sets: ByGPOIdGroupNameUpdate, ByGPONameGroupNameUpdate, ByGroupNameUpdate, ByGPOIdGroupNameReplace, ByGPONameGroupNameReplace, ByGroupNameReplace, ByGPOIdGroupNameCreate, ByGPONameGroupNameCreate, ByGroupNameCreate, ByGPOIdGroupSIDUpdate, ByGPONameGroupSIDUpdate, ByGroupSIDUpdate, ByGPOIdGroupSIDReplace, ByGPONameGroupSIDReplace, ByGroupSIDReplace, ByGPOIdGroupSIDCreate, ByGPONameGroupSIDCreate, ByGroupSIDCreate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeleteAllUsers
Sets the DeleteAllUsers attribute at the group object.

```yaml
Type: SwitchParameter
Parameter Sets: ByGPOIdGroupNameUpdate, ByGPONameGroupNameUpdate, ByGroupNameUpdate, ByGPOIdGroupNameReplace, ByGPONameGroupNameReplace, ByGroupNameReplace, ByGPOIdGroupNameCreate, ByGPONameGroupNameCreate, ByGroupNameCreate, ByGPOIdGroupSIDUpdate, ByGPONameGroupSIDUpdate, ByGroupSIDUpdate, ByGPOIdGroupSIDReplace, ByGPONameGroupSIDReplace, ByGroupSIDReplace, ByGPOIdGroupSIDCreate, ByGPONameGroupSIDCreate, ByGroupSIDCreate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Sets the description of a group object.

```yaml
Type: String
Parameter Sets: ByGPOIdGroupNameUpdate, ByGPONameGroupNameUpdate, ByGroupNameUpdate, ByGPOIdGroupNameReplace, ByGPONameGroupNameReplace, ByGroupNameReplace, ByGPOIdGroupNameCreate, ByGPONameGroupNameCreate, ByGroupNameCreate, ByGPOIdGroupSIDUpdate, ByGPONameGroupSIDUpdate, ByGroupSIDUpdate, ByGPOIdGroupSIDReplace, ByGPONameGroupSIDReplace, ByGroupSIDReplace, ByGPOIdGroupSIDCreate, ByGPONameGroupSIDCreate, ByGroupSIDCreate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Disable
Disables processing of this group object. In the GUI you'll see it greyed out.

```yaml
Type: SwitchParameter
Parameter Sets: ByGPOIdGroupNameUpdate, ByGPONameGroupNameUpdate, ByGroupNameUpdate, ByGPOIdGroupNameReplace, ByGPONameGroupNameReplace, ByGroupNameReplace, ByGPOIdGroupNameCreate, ByGPONameGroupNameCreate, ByGroupNameCreate, ByGPOIdGroupSIDUpdate, ByGPONameGroupSIDUpdate, ByGroupSIDUpdate, ByGPOIdGroupSIDReplace, ByGPONameGroupSIDReplace, ByGroupSIDReplace, ByGPOIdGroupSIDCreate, ByGPONameGroupSIDCreate, ByGroupSIDCreate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOId
Specifies the ID of a GPO into which you want to add the newly created group item. It is a name of a Group Policy's object in Active Directory. Look into a CN=Policies,CN=System container in your AD DS domain.

```yaml
Type: Guid
Parameter Sets: ByGPOIdGroupNameDelete, ByGPOIdGroupNameUpdate, ByGPOIdGroupNameReplace, ByGPOIdGroupNameCreate, ByGPOIdGroupSIDDelete, ByGPOIdGroupSIDUpdate, ByGPOIdGroupSIDReplace, ByGPOIdGroupSIDCreate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
Specifies the name of a GPO into which you want to add the newly created group item.

```yaml
Type: String
Parameter Sets: ByGPONameGroupNameDelete, ByGPONameGroupNameUpdate, ByGPONameGroupNameReplace, ByGPONameGroupNameCreate, ByGPONameGroupSIDDelete, ByGPONameGroupSIDUpdate, ByGPONameGroupSIDReplace, ByGPONameGroupSIDCreate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Members
Specifies which group members should be set for this group. Use New-GPPGroupMember to create them.

```yaml
Type: GPPItemGroupMember[]
Parameter Sets: ByGPOIdGroupNameUpdate, ByGPONameGroupNameUpdate, ByGroupNameUpdate, ByGPOIdGroupNameReplace, ByGPONameGroupNameReplace, ByGroupNameReplace, ByGPOIdGroupNameCreate, ByGPONameGroupNameCreate, ByGroupNameCreate, ByGPOIdGroupSIDUpdate, ByGPONameGroupSIDUpdate, ByGroupSIDUpdate, ByGPOIdGroupSIDReplace, ByGPONameGroupSIDReplace, ByGroupSIDReplace, ByGPOIdGroupSIDCreate, ByGPONameGroupSIDCreate, ByGroupSIDCreate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of the group.

```yaml
Type: String
Parameter Sets: ByGPOIdGroupNameDelete, ByGPONameGroupNameDelete, ByGroupNameDelete, ByGPOIdGroupNameUpdate, ByGPONameGroupNameUpdate, ByGroupNameUpdate, ByGPOIdGroupNameReplace, ByGPONameGroupNameReplace, ByGroupNameReplace, ByGPOIdGroupNameCreate, ByGPONameGroupNameCreate, ByGroupNameCreate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NewName
Specifies the new name of the group if you want to rename it on target hosts.

```yaml
Type: String
Parameter Sets: ByGPOIdGroupNameUpdate, ByGPONameGroupNameUpdate, ByGroupNameUpdate, ByGPOIdGroupSIDUpdate, ByGPONameGroupSIDUpdate, ByGroupSIDUpdate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Returns a new group object to the pipeline.

```yaml
Type: SwitchParameter
Parameter Sets: ByGPOIdGroupNameUpdate, ByGPONameGroupNameUpdate, ByGroupNameUpdate, ByGPOIdGroupNameReplace, ByGPONameGroupNameReplace, ByGroupNameReplace, ByGPOIdGroupNameCreate, ByGPONameGroupNameCreate, ByGroupNameCreate, ByGPOIdGroupSIDUpdate, ByGPONameGroupSIDUpdate, ByGroupSIDUpdate, ByGPOIdGroupSIDReplace, ByGPONameGroupSIDReplace, ByGroupSIDReplace, ByGPOIdGroupSIDCreate, ByGPONameGroupSIDCreate, ByGroupSIDCreate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Replace
Sets the action property of the group definition to "Replace".

```yaml
Type: SwitchParameter
Parameter Sets: ByGPOIdGroupNameReplace, ByGPONameGroupNameReplace, ByGroupNameReplace, ByGPOIdGroupSIDReplace, ByGPONameGroupSIDReplace, ByGroupSIDReplace
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SID
Specifies the SID of the group.

```yaml
Type: SecurityIdentifier
Parameter Sets: ByGPOIdGroupSIDDelete, ByGPONameGroupSIDDelete, ByGroupSIDDelete, ByGPOIdGroupSIDUpdate, ByGPONameGroupSIDUpdate, ByGroupSIDUpdate, ByGPOIdGroupSIDReplace, ByGPONameGroupSIDReplace, ByGroupSIDReplace, ByGPOIdGroupSIDCreate, ByGPONameGroupSIDCreate, ByGroupSIDCreate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Update
Sets the action property of the group definition to "Update".

```yaml
Type: SwitchParameter
Parameter Sets: ByGPOIdGroupNameUpdate, ByGPONameGroupNameUpdate, ByGroupNameUpdate, ByGPOIdGroupSIDUpdate, ByGPONameGroupSIDUpdate, ByGroupSIDUpdate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### GPPItemGroup

## NOTES

## RELATED LINKS
