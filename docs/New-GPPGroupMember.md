---
external help file: PSGPPreferences-help.xml
Module Name: PSGPPreferences
online version:
schema: 2.0.0
---

# New-GPPGroupMember

## SYNOPSIS
Creates a new group member object to use in other commands later.

## SYNTAX

### ByName
```
New-GPPGroupMember -Name <String> [-Action <GPPItemGroupMemberAction>] [<CommonParameters>]
```

### BySID
```
New-GPPGroupMember -SID <SecurityIdentifier> [-Action <GPPItemGroupMemberAction>] [<CommonParameters>]
```

## DESCRIPTION
Creates a new group member object in memory. Use the created object in Add-GPPGroupMember, New-GPPGroup, or Set-GPPGroup.
The result object MUST have both the name and SID filled, so the function resolves one through another and fails if it does not succeed.

## EXAMPLES

### Example 1
```powershell
PS C:\> New-GPPGroupMember -Name 'EXAMPLE\Administrator' -Action ADD
```

Uses the -Name parameter to resolve the SID of this security principal from Active Directory domain. The result object will have its action set to "ADD".

### Example 2
```powershell
PS C:\> New-GPPGroupMember -SID 'S-1-5-21-2571216883-1601522099-2002488368-500' -Action REMOVE
```

Uses the -SID parameter to resolve the name of this security principal from Active Directory domain. The result object will have its action set to "ADD".

## PARAMETERS

### -Action
Specifies which action should GPP engine to execute regarding this security principal: either to ADD or to REMOVE it from a group.

```yaml
Type: GPPItemGroupMemberAction
Parameter Sets: (All)
Aliases:
Accepted values: ADD, REMOVE

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of a security principal.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SID
Specifies the SID of a security principal.

```yaml
Type: SecurityIdentifier
Parameter Sets: BySID
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
