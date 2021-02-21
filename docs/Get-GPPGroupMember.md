---
external help file: PSGPPreferences-help.xml
Module Name: PSGPPreferences
online version:
schema: 2.0.0
---

# Get-GPPGroupMember

## SYNOPSIS
Retrieves a member from a group defined in a Group Policy objects.

## SYNTAX

### ByNameGroupUIDGPOId
```
Get-GPPGroupMember [-Name <String>] -GroupUID <Guid> -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### ByNameGroupSIDGPOId
```
Get-GPPGroupMember [-Name <String>] -GroupSID <SecurityIdentifier> -GPOId <Guid> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByNameGroupNameGPOId
```
Get-GPPGroupMember [-Name <String>] -GroupName <String> -GPOId <Guid> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByNameGroupUIDGPOName
```
Get-GPPGroupMember [-Name <String>] -GroupUID <Guid> -GPOName <String> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByNameGroupSIDGPOName
```
Get-GPPGroupMember [-Name <String>] -GroupSID <SecurityIdentifier> -GPOName <String> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByNameGroupNameGPOName
```
Get-GPPGroupMember [-Name <String>] -GroupName <String> -GPOName <String> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByLiteralNameGroupUIDGPOId
```
Get-GPPGroupMember -LiteralName <String> -GroupUID <Guid> -GPOId <Guid> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByLiteralNameGroupSIDGPOId
```
Get-GPPGroupMember -LiteralName <String> -GroupSID <SecurityIdentifier> -GPOId <Guid> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByLiteralNameGroupNameGPOId
```
Get-GPPGroupMember -LiteralName <String> -GroupName <String> -GPOId <Guid> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByLiteralNameGroupUIDGPOName
```
Get-GPPGroupMember -LiteralName <String> -GroupUID <Guid> -GPOName <String> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByLiteralNameGroupSIDGPOName
```
Get-GPPGroupMember -LiteralName <String> -GroupSID <SecurityIdentifier> -GPOName <String>
 [-Context <GPPContext>] [<CommonParameters>]
```

### ByLiteralNameGroupNameGPOName
```
Get-GPPGroupMember -LiteralName <String> -GroupName <String> -GPOName <String> [-Context <GPPContext>]
 [<CommonParameters>]
```

### BySIDGroupUIDGPOId
```
Get-GPPGroupMember -SID <SecurityIdentifier> -GroupUID <Guid> -GPOId <Guid> [-Context <GPPContext>]
 [<CommonParameters>]
```

### BySIDGroupSIDGPOId
```
Get-GPPGroupMember -SID <SecurityIdentifier> -GroupSID <SecurityIdentifier> -GPOId <Guid>
 [-Context <GPPContext>] [<CommonParameters>]
```

### BySIDGroupNameGPOId
```
Get-GPPGroupMember -SID <SecurityIdentifier> -GroupName <String> -GPOId <Guid> [-Context <GPPContext>]
 [<CommonParameters>]
```

### BySIDGroupUIDGPOName
```
Get-GPPGroupMember -SID <SecurityIdentifier> -GroupUID <Guid> -GPOName <String> [-Context <GPPContext>]
 [<CommonParameters>]
```

### BySIDGroupSIDGPOName
```
Get-GPPGroupMember -SID <SecurityIdentifier> -GroupSID <SecurityIdentifier> -GPOName <String>
 [-Context <GPPContext>] [<CommonParameters>]
```

### BySIDGroupNameGPOName
```
Get-GPPGroupMember -SID <SecurityIdentifier> -GroupName <String> -GPOName <String> [-Context <GPPContext>]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-GPPGroupMember -Name 'TEST-*' -GroupName '*Admin*' -GPOName 'Custom Group Policy'
```

Returns all members, which names start with "TEST-", of groups which name contains "Admin" defined in a GPO called "Custom Group Policy".

### Example 2
```powershell
PS C:\> Get-GPPGroupMember -LiteralName 'TEST-*' -GroupSID 'S-1-5-2' -GPOId '70f86590-588a-4659-8880-3d2374604811'
```

Returns all members, which name is "TEST-*", of the "Network (built-in)" group defined in a GPO with an ID "70f86590-588a-4659-8880-3d2374604811".

### Example 3
```powershell
PS C:\> Get-GPPGroupMember -SID 'S-1-5-21-2571216883-1601522099-2002488368-1620' -GroupName 'Administrators (built-in)' -GPOName 'Custom Group Policy'
```

Returns all members with SID "S-1-5-21-2571216883-1601522099-2002488368-1620" from the "Administrators (built-in)" group defined in a GPO "Custom Group Policy".

## PARAMETERS

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

### -GPOId
Specifies the ID of a GPO in which you want to search for groups. It is a name of a Group Policy's object in Active Directory. Look into a CN=Policies,CN=System container in your AD DS domain.

```yaml
Type: Guid
Parameter Sets: ByNameGroupUIDGPOId, ByNameGroupSIDGPOId, ByNameGroupNameGPOId, ByLiteralNameGroupUIDGPOId, ByLiteralNameGroupSIDGPOId, ByLiteralNameGroupNameGPOId, BySIDGroupUIDGPOId, BySIDGroupSIDGPOId, BySIDGroupNameGPOId
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
Parameter Sets: ByNameGroupUIDGPOName, ByNameGroupSIDGPOName, ByNameGroupNameGPOName, ByLiteralNameGroupUIDGPOName, ByLiteralNameGroupSIDGPOName, ByLiteralNameGroupNameGPOName, BySIDGroupUIDGPOName, BySIDGroupSIDGPOName, BySIDGroupNameGPOName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupName
Specifies the name of a group from which you want to get a member.

```yaml
Type: String
Parameter Sets: ByNameGroupNameGPOId, ByNameGroupNameGPOName, ByLiteralNameGroupNameGPOId, ByLiteralNameGroupNameGPOName, BySIDGroupNameGPOId, BySIDGroupNameGPOName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -GroupSID
Specifies the SID of a group from which you want to get a member.

```yaml
Type: SecurityIdentifier
Parameter Sets: ByNameGroupSIDGPOId, ByNameGroupSIDGPOName, ByLiteralNameGroupSIDGPOId, ByLiteralNameGroupSIDGPOName, BySIDGroupSIDGPOId, BySIDGroupSIDGPOName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupUID
Specifies the UID of a group from which you want to get a member. A UID is a unique identifier of an object in GPP. You can have several groups with the same Name/SID combination in the same Group Policy object - those groups will have different UIDs. You may get a UID of a group by looking at its "uid" property.

```yaml
Type: Guid
Parameter Sets: ByNameGroupUIDGPOId, ByNameGroupUIDGPOName, ByLiteralNameGroupUIDGPOId, ByLiteralNameGroupUIDGPOName, BySIDGroupUIDGPOId, BySIDGroupUIDGPOName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiteralName
Specifies the name of a member which you want to retrieve. Does NOT support wildcards.

```yaml
Type: String
Parameter Sets: ByLiteralNameGroupUIDGPOId, ByLiteralNameGroupSIDGPOId, ByLiteralNameGroupNameGPOId, ByLiteralNameGroupUIDGPOName, ByLiteralNameGroupSIDGPOName, ByLiteralNameGroupNameGPOName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of a member which you want to retrieve. Supports wildcards.

```yaml
Type: String
Parameter Sets: ByNameGroupUIDGPOId, ByNameGroupSIDGPOId, ByNameGroupNameGPOId, ByNameGroupUIDGPOName, ByNameGroupSIDGPOName, ByNameGroupNameGPOName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -SID
Specifies the SID of a member which you want to retrieve.

```yaml
Type: SecurityIdentifier
Parameter Sets: BySIDGroupUIDGPOId, BySIDGroupSIDGPOId, BySIDGroupNameGPOId, BySIDGroupUIDGPOName, BySIDGroupSIDGPOName, BySIDGroupNameGPOName
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

### GPPItemGroupMember

## NOTES

## RELATED LINKS
