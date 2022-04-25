---
external help file: PSGPPreferences-help.xml
Module Name: PSGPPreferences
online version:
schema: 2.0.0
---

# Set-GPPGroup

## SYNOPSIS
Sets properties of a group definition in a specified Group Policy object.

## SYNTAX

### ByGPOIdObject
```
Set-GPPGroup -InputObject <GPPItemGroup[]> -GPOId <Guid> [-Context <GPPContext>]
 [-Action <GPPItemActionDisplay>] [-NewName <String>] [-Description <String>] [-DeleteAllUsers]
 [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>] [-PassThru] [<CommonParameters>]
```

### ByGPONameObject
```
Set-GPPGroup -InputObject <GPPItemGroup[]> -GPOName <String> [-Context <GPPContext>]
 [-Action <GPPItemActionDisplay>] [-NewName <String>] [-Description <String>] [-DeleteAllUsers]
 [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>] [-PassThru] [<CommonParameters>]
```

### ByGPOIdItemName
```
Set-GPPGroup -Name <String> -GPOId <Guid> [-Context <GPPContext>] [-Action <GPPItemActionDisplay>]
 [-NewName <String>] [-Description <String>] [-DeleteAllUsers] [-DeleteAllGroups] [-Disable]
 [-Members <GPPItemGroupMember[]>] [-PassThru] [<CommonParameters>]
```

### ByGPONameItemName
```
Set-GPPGroup -Name <String> -GPOName <String> [-Context <GPPContext>] [-Action <GPPItemActionDisplay>]
 [-NewName <String>] [-Description <String>] [-DeleteAllUsers] [-DeleteAllGroups] [-Disable]
 [-Members <GPPItemGroupMember[]>] [-PassThru] [<CommonParameters>]
```

### ByGPOIdItemLiteralName
```
Set-GPPGroup -LiteralName <String> -GPOId <Guid> [-Context <GPPContext>] [-Action <GPPItemActionDisplay>]
 [-NewName <String>] [-Description <String>] [-DeleteAllUsers] [-DeleteAllGroups] [-Disable]
 [-Members <GPPItemGroupMember[]>] [-PassThru] [<CommonParameters>]
```

### ByGPONameItemLiteralName
```
Set-GPPGroup -LiteralName <String> -GPOName <String> [-Context <GPPContext>] [-Action <GPPItemActionDisplay>]
 [-NewName <String>] [-Description <String>] [-DeleteAllUsers] [-DeleteAllGroups] [-Disable]
 [-Members <GPPItemGroupMember[]>] [-PassThru] [<CommonParameters>]
```

### ByGPOIdItemSID
```
Set-GPPGroup -SID <SecurityIdentifier> -GPOId <Guid> [-Context <GPPContext>] [-Action <GPPItemActionDisplay>]
 [-NewName <String>] [-Description <String>] [-DeleteAllUsers] [-DeleteAllGroups] [-Disable]
 [-Members <GPPItemGroupMember[]>] [-PassThru] [<CommonParameters>]
```

### ByGPONameItemSID
```
Set-GPPGroup -SID <SecurityIdentifier> -GPOName <String> [-Context <GPPContext>]
 [-Action <GPPItemActionDisplay>] [-NewName <String>] [-Description <String>] [-DeleteAllUsers]
 [-DeleteAllGroups] [-Disable] [-Members <GPPItemGroupMember[]>] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION
Sets properties of a group definition in a specified Group Policy object. You may also use it to write a group definition object from memory into a GPO and changing some of its properties in the process.
If you want just to add a group definition into a GPO, w/o any modifications, I suggest you to use Add-GPPGroup.

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-GPPGroup -SID 'S-1-5-32-544' -GPOName 'Custom Group Policy' -Action Update -Members $Members
```

Changes the action of the group definition of a group with SID "S-1-5-32-544" in the GPO "Custom Group Policy" to "Update" and sets it members to the value of the $Members variable.

### Example 2
```powershell
PS C:\> Set-GPPGroup -Name 'EXAMPLE\Test-Group' -GPOName 'Custom Group Policy' -Action Delete
```

Changes the action of the group definition of a group called "EXAMPLE\Test-Group" in the GPO "Custom Group Policy" to "Delete".

### Example 3
```powershell
PS C:\> $Group = Get-GPPGroup -Name 'EXAMPLE\Test-Group' -GPOName 'Custom Group Policy'
PS C:\> Set-GPPGroup -InputObject $Group -GPOName 'Custom Group Policy' -DeleteAllGroups -DeleteAllUsers
```

Updates the definition of the "EXAMPLE\Test-Group" group in the "Custom Group Policy" GPO to delete all group and users from that group except for those explicitly defined in the group definition.

### Example 4
```powershell
PS C:\> Set-GPPGroup -Name 'EXAMPLE\Test-Group' -GPOName 'Custom Group Policy' -Disable
```

Disables the group definition for a group called "EXAMPLE\Test-Group" in the "Custom Group Policy" GPO.

## PARAMETERS

### -Action
Sets one of four actions which you can instruct the GPP engine to do with a group: Create, Replace, Update, or Delete. Different actions have different sets of allowed parameters.
The function initially does not restrict you from pass parameters incompatible with Action, but will correct them to be in accordance with the action. i.e. if you set -Action to "Delete" and -NewName to something, -NewName will be ignored.
Also, if you have a group object with some properties defined and change its action to "Delete", the object will be stripped off its properties. Same concept applies to other actions as well.

For properties compatibility see help for New-GPPGroup.

```yaml
Type: GPPItemActionDisplay
Parameter Sets: (All)
Aliases:
Accepted values: Create, Replace, Update, Delete

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Context
Specifies which Group Policy context to use: Machine or User. Doesn't do anything right now, since the User one has not yet been implemented.

```yaml
Type: GPPContext
Parameter Sets: (All)
Aliases:
Accepted values: Machine

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeleteAllGroups
Sets the DeleteAllGroups attribute at the group object.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
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
Parameter Sets: (All)
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
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Disable
Disables processing of this group definition. In the GUI you'll see it greyed out.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOId
Specifies the ID of a GPO in which you want to search for groups. It is a name of a Group Policy's object in Active Directory. Look into a CN=Policies,CN=System container in your AD DS domain.

```yaml
Type: Guid
Parameter Sets: ByGPOIdObject, ByGPOIdItemName, ByGPOIdItemLiteralName, ByGPOIdItemSID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
Specifies the name of a GPO in which you want to search for groups.

```yaml
Type: String
Parameter Sets: ByGPONameObject, ByGPONameItemName, ByGPONameItemLiteralName, ByGPONameItemSID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
If you already have a group definition object in memory, which you want to write into a Group Policy, you can pass in into this parameter.

```yaml
Type: GPPItemGroup[]
Parameter Sets: ByGPOIdObject, ByGPONameObject
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
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of a group which you want to change. Supports wildcards.

```yaml
Type: String
Parameter Sets: ByGPOIdItemName, ByGPONameItemName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -NewName
Specifies a new name for a group if you want to rename it on target hosts.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Returns a new group definition object to the pipeline.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SID
Specifies the SID of a group which you want to change.

```yaml
Type: SecurityIdentifier
Parameter Sets: ByGPOIdItemSID, ByGPONameItemSID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiteralName
Specifies the name of a group which you want to change. Does not support wildcards.

```yaml
Type: String
Parameter Sets: ByGPOIdItemLiteralName, ByGPONameItemLiteralName
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
