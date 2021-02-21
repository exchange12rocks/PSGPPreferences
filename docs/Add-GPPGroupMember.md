---
external help file: PSGPPreferences-help.xml
Module Name: PSGPPreferences
online version:
schema: 2.0.0
---

# Add-GPPGroupMember

## SYNOPSIS
Adds a member into a group already existing in a GPO object.

## SYNTAX

### ByGPOIdGroupUID
```
Add-GPPGroupMember -InputObject <GPPItemGroupMember> -GroupUID <Guid> -GPOId <Guid> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByGPONameGroupUID
```
Add-GPPGroupMember -InputObject <GPPItemGroupMember> -GroupUID <Guid> -GPOName <String> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByGPOIdGroupSID
```
Add-GPPGroupMember -InputObject <GPPItemGroupMember> -GroupSID <SecurityIdentifier> -GPOId <Guid>
 [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPONameGroupSID
```
Add-GPPGroupMember -InputObject <GPPItemGroupMember> -GroupSID <SecurityIdentifier> -GPOName <String>
 [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPOIdGroupName
```
Add-GPPGroupMember -InputObject <GPPItemGroupMember> -GroupName <String> -GPOId <Guid> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByGPONameGroupName
```
Add-GPPGroupMember -InputObject <GPPItemGroupMember> -GroupName <String> -GPOName <String>
 [-Context <GPPContext>] [<CommonParameters>]
```

## DESCRIPTION
Adds a member into a group already existing in a GPO object. Use New-GPPGroupMember to create group members.

## EXAMPLES

### Example 1
```powershell
PS C:\> $Member = New-GPPGroupMember -Name 'EXAMPLE\Administrator' -Action REMOVE
PS C:\> Add-GPPGroupMember -InputObject $Member -GroupName 'EXAMPLE\TEST' -GPOName 'Custom Group Policy'
```

Adds a user "Administrator" into all groups named "EXAMPLE\TEST" defined in the "Custom Group Policy" GPO. The user will be REMOVED from this group on computers to which the GPO applies.

### Example 2
```powershell
PS C:\> $Member = New-GPPGroupMember -Name 'EXAMPLE\Administrator' -Action REMOVE
PS C:\> Add-GPPGroupMember -InputObject $Member -GroupUID '3B1BF433-38BF-47A5-925C-3DC32B6555B3' -GPOId '70f86590-588a-4659-8880-3d2374604811'
```

Adds a user "Administrator" into a group with the UID "3B1BF433-38BF-47A5-925C-3DC32B6555B3" defined in a GPO with the ID "70f86590-588a-4659-8880-3d2374604811". The user will be REMOVED from this group on computers to which the GPO applies.

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
Specifies the ID of a GPO where the target group is. It is a name of a Group Policy's object in Active Directory. Look into a CN=Policies,CN=System container in your AD DS domain.

```yaml
Type: Guid
Parameter Sets: ByGPOIdGroupUID, ByGPOIdGroupSID, ByGPOIdGroupName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
Specifies the name of a GPO where the target group is.

```yaml
Type: String
Parameter Sets: ByGPONameGroupUID, ByGPONameGroupSID, ByGPONameGroupName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupName
Specifies the name of a target group.

```yaml
Type: String
Parameter Sets: ByGPOIdGroupName, ByGPONameGroupName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupSID
Specifies the SID of a target group.

```yaml
Type: SecurityIdentifier
Parameter Sets: ByGPOIdGroupSID, ByGPONameGroupSID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupUID
Specifies the UID of a target group. UID is a unique identifier of an object in GPP. You can have several groups with the same Name/SID combination in the same Group Policy object - those groups will have different UIDs. You may get a UID of a group by looking at its "uid" property.

```yaml
Type: Guid
Parameter Sets: ByGPOIdGroupUID, ByGPONameGroupUID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
Specifies a member object to add. Use New-GPPGroupMember to create one.

```yaml
Type: GPPItemGroupMember
Parameter Sets: (All)
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

### System.Void

## NOTES

## RELATED LINKS
