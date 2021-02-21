---
external help file: PSGPPreferences-help.xml
Module Name: PSGPPreferences
online version:
schema: 2.0.0
---

# Remove-GPPGroupMember

## SYNOPSIS
Removes a member from a group defined in a Group Policy object.

## SYNTAX

### ByNameGPOIdGroupUID
```
Remove-GPPGroupMember -Name <String> -GroupUID <Guid> -GPOId <Guid> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByNameGPONameGroupUID
```
Remove-GPPGroupMember -Name <String> -GroupUID <Guid> -GPOName <String> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByNameGPOIdGroupSID
```
Remove-GPPGroupMember -Name <String> -GroupSID <SecurityIdentifier> -GPOId <Guid> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByNameGPONameGroupSID
```
Remove-GPPGroupMember -Name <String> -GroupSID <SecurityIdentifier> -GPOName <String> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByNameGPOIdGroupName
```
Remove-GPPGroupMember -Name <String> -GroupName <String> -GPOId <Guid> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByNameGPONameGroupName
```
Remove-GPPGroupMember -Name <String> -GroupName <String> -GPOName <String> [-Context <GPPContext>]
 [<CommonParameters>]
```

### BySIDGPOIdGroupUID
```
Remove-GPPGroupMember -SID <SecurityIdentifier> -GroupUID <Guid> -GPOId <Guid> [-Context <GPPContext>]
 [<CommonParameters>]
```

### BySIDGPONameGroupUID
```
Remove-GPPGroupMember -SID <SecurityIdentifier> -GroupUID <Guid> -GPOName <String> [-Context <GPPContext>]
 [<CommonParameters>]
```

### BySIDGPOIdGroupSID
```
Remove-GPPGroupMember -SID <SecurityIdentifier> -GroupSID <SecurityIdentifier> -GPOId <Guid>
 [-Context <GPPContext>] [<CommonParameters>]
```

### BySIDGPONameGroupSID
```
Remove-GPPGroupMember -SID <SecurityIdentifier> -GroupSID <SecurityIdentifier> -GPOName <String>
 [-Context <GPPContext>] [<CommonParameters>]
```

### BySIDGPOIdGroupName
```
Remove-GPPGroupMember -SID <SecurityIdentifier> -GroupName <String> -GPOId <Guid> [-Context <GPPContext>]
 [<CommonParameters>]
```

### BySIDGPONameGroupName
```
Remove-GPPGroupMember -SID <SecurityIdentifier> -GroupName <String> -GPOName <String> [-Context <GPPContext>]
 [<CommonParameters>]
```

## DESCRIPTION
Removes a member from a group defined in a Group Policy object. This doesn't necessary remove that member from computers to which the GPO applies - it depends on the group's and member's configuration.

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-GPPGroupMember -Name 'EXAMPLE\TEST-*' -GroupName 'TEST' -GPOName 'Custom Group Policy'
```

Removes all groups named "TEST-*" from group "TEST" defined in the "Custom Group Policy" GPO. The -Name parameter does not support wildcards.

### Example 2
```powershell
PS C:\> $Members = Get-GPPGroupMember -Name 'EXAMPLE\TEST-*' -GPOName 'Custom Group Policy'
PS C:\> $Members | % { Remove-GPPGroupMember -Name $_.Name -GroupSID 'S-1-5-2' -GPOName 'Custom Group Policy' }
```

Removes all groups which name starts with "EXAMPLE\TEST-" from a group with SID "S-1-5-2" defined in the "Custom Group Policy" GPO.

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
Parameter Sets: ByNameGPOIdGroupUID, ByNameGPOIdGroupSID, ByNameGPOIdGroupName, BySIDGPOIdGroupUID, BySIDGPOIdGroupSID, BySIDGPOIdGroupName
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
Parameter Sets: ByNameGPONameGroupUID, ByNameGPONameGroupSID, ByNameGPONameGroupName, BySIDGPONameGroupUID, BySIDGPONameGroupSID, BySIDGPONameGroupName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupName
Specifies the name of a group from which you want to remove a member.

```yaml
Type: String
Parameter Sets: ByNameGPOIdGroupName, ByNameGPONameGroupName, BySIDGPOIdGroupName, BySIDGPONameGroupName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupSID
Specifies the SID of a group from which you want to remove a member.

```yaml
Type: SecurityIdentifier
Parameter Sets: ByNameGPOIdGroupSID, ByNameGPONameGroupSID, BySIDGPOIdGroupSID, BySIDGPONameGroupSID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupUID
Specifies the UID of a group from which you want to remove a member. A UID is a unique identifier of an object in GPP. You can have several groups with the same Name/SID combination in the same Group Policy object - those groups will have different UIDs. You may get a UID of a group by looking at its "uid" property.

```yaml
Type: Guid
Parameter Sets: ByNameGPOIdGroupUID, ByNameGPONameGroupUID, BySIDGPOIdGroupUID, BySIDGPONameGroupUID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of a member which you want to remove.

```yaml
Type: String
Parameter Sets: ByNameGPOIdGroupUID, ByNameGPONameGroupUID, ByNameGPOIdGroupSID, ByNameGPONameGroupSID, ByNameGPOIdGroupName, ByNameGPONameGroupName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SID
Specifies the SID of a member which you want to remove.

```yaml
Type: SecurityIdentifier
Parameter Sets: BySIDGPOIdGroupUID, BySIDGPONameGroupUID, BySIDGPOIdGroupSID, BySIDGPONameGroupSID, BySIDGPOIdGroupName, BySIDGPONameGroupName
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
