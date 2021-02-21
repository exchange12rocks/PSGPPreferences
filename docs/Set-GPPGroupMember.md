---
external help file: PSGPPreferences-help.xml
Module Name: PSGPPreferences
online version:
schema: 2.0.0
---

# Set-GPPGroupMember

## SYNOPSIS
Sets properties of a group member defined in a Group Policy object.

## SYNTAX

### ByNameGPOIdGroupUID
```
Set-GPPGroupMember -Name <String> -Action <GPPItemGroupMemberAction> -GroupUID <Guid> -GPOId <Guid>
 [-Context <GPPContext>] [<CommonParameters>]
```

### ByNameGPONameGroupUID
```
Set-GPPGroupMember -Name <String> -Action <GPPItemGroupMemberAction> -GroupUID <Guid> -GPOName <String>
 [-Context <GPPContext>] [<CommonParameters>]
```

### ByNameGPOIdGroupSID
```
Set-GPPGroupMember -Name <String> -Action <GPPItemGroupMemberAction> -GroupSID <SecurityIdentifier>
 -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### ByNameGPONameGroupSID
```
Set-GPPGroupMember -Name <String> -Action <GPPItemGroupMemberAction> -GroupSID <SecurityIdentifier>
 -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

### ByNameGPOIdGroupName
```
Set-GPPGroupMember -Name <String> -Action <GPPItemGroupMemberAction> -GroupName <String> -GPOId <Guid>
 [-Context <GPPContext>] [<CommonParameters>]
```

### ByNameGPONameGroupName
```
Set-GPPGroupMember -Name <String> -Action <GPPItemGroupMemberAction> -GroupName <String> -GPOName <String>
 [-Context <GPPContext>] [<CommonParameters>]
```

### BySIDGPOIdGroupUID
```
Set-GPPGroupMember -SID <SecurityIdentifier> -Action <GPPItemGroupMemberAction> -GroupUID <Guid> -GPOId <Guid>
 [-Context <GPPContext>] [<CommonParameters>]
```

### BySIDGPONameGroupUID
```
Set-GPPGroupMember -SID <SecurityIdentifier> -Action <GPPItemGroupMemberAction> -GroupUID <Guid>
 -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

### BySIDGPOIdGroupSID
```
Set-GPPGroupMember -SID <SecurityIdentifier> -Action <GPPItemGroupMemberAction> -GroupSID <SecurityIdentifier>
 -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### BySIDGPONameGroupSID
```
Set-GPPGroupMember -SID <SecurityIdentifier> -Action <GPPItemGroupMemberAction> -GroupSID <SecurityIdentifier>
 -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

### BySIDGPOIdGroupName
```
Set-GPPGroupMember -SID <SecurityIdentifier> -Action <GPPItemGroupMemberAction> -GroupName <String>
 -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### BySIDGPONameGroupName
```
Set-GPPGroupMember -SID <SecurityIdentifier> -Action <GPPItemGroupMemberAction> -GroupName <String>
 -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

## DESCRIPTION
Sets properties of a group member defined in a Group Policy object. Well, actually the only property you can change is "Action" - there's just not much to set.

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-GPPGroupMember -Name 'EXAMPLE\Administrator' -Action ADD -GroupName 'Administrators (built-in)' -GPOName 'Custom Group Policy'
```

Sets the action to ADD for the "EXAMPLE\Administrator" user in the "Administrators (built-in)" group in a group policy named "Custom Group Policy".

### Example 2
```powershell
PS C:\> Set-GPPGroupMember -Name 'EXAMPLE\Administrator' -Action REMOVE -GroupSID 'S-1-5-32-544' -GPOName 'Custom Group Policy'
```

Sets the action to REMOVE for the "EXAMPLE\Administrator" user in a group with the SID S-1-5-32-544 a group policy named "Custom Group Policy".

## PARAMETERS

### -Action
Specifies which action should GPP engine to execute regarding this security principal: either to ADD or to REMOVE it from a group.

```yaml
Type: GPPItemGroupMemberAction
Parameter Sets: (All)
Aliases:
Accepted values: ADD, REMOVE

Required: True
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
Specifies the name of a group in which you want to change a member.

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
Specifies the SID of a group in which you want to change a member.

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
Specifies the UID of a group in which you want to change a member. A UID is a unique identifier of an object in GPP. You can have several groups with the same Name/SID combination in the same Group Policy object - those groups will have different UIDs. You may get a UID of a group by looking at its "uid" property.

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
Specifies the name of a member which you want to change.

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
Specifies the SID of a member which you want to change.

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
