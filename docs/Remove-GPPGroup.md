---
external help file: PSGPPreferences-help.xml
Module Name: PSGPPreferences
online version:
schema: 2.0.0
---

# Remove-GPPGroup

## SYNOPSIS
Removes a group definition from a GPO object.

## SYNTAX

### ByGPPSectionGroupName
```
Remove-GPPGroup -Name <String> -GPPSection <GPPSection> [<CommonParameters>]
```

### ByGPOIdGroupName
```
Remove-GPPGroup -Name <String> -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPONameGroupName
```
Remove-GPPGroup -Name <String> -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPPSectionGroupSID
```
Remove-GPPGroup -SID <SecurityIdentifier> -GPPSection <GPPSection> [<CommonParameters>]
```

### ByGPOIdGroupSID
```
Remove-GPPGroup -SID <SecurityIdentifier> -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPONameGroupSID
```
Remove-GPPGroup -SID <SecurityIdentifier> -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPPSectionGroupUID
```
Remove-GPPGroup -UID <Guid> -GPPSection <GPPSection> [<CommonParameters>]
```

### ByGPOIdGroupUID
```
Remove-GPPGroup -UID <Guid> -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPONameGroupUID
```
Remove-GPPGroup -UID <Guid> -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

## DESCRIPTION
Removes a group definition from a GPO object.

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-GPPGroup -Name 'TEST-*' -GPOName 'Custom Group Policy'
```

Removes all groups named "TEST-*" from the "Custom Group Policy" GPO. The -Name parameter does not support wildcards.

### Example 2
```powershell
PS C:\> $Groups = Get-GPPGroup -Name 'TEST-*' -GPOName 'Custom Group Policy'
PS C:\> $Groups | % { Remove-GPPGroup -UID $_.uid -GPOName 'Custom Group Policy' }
```

Removes all groups which name starts with "TEST-" from the "Custom Group Policy" GPO.

## PARAMETERS

### -Context
Specifies which Group Policy context to use: Machine or User. Doesn't do anything right now, since the User one has not yet been implemented.

```yaml
Type: GPPContext
Parameter Sets: ByGPOIdGroupName, ByGPONameGroupName, ByGPOIdGroupSID, ByGPONameGroupSID, ByGPOIdGroupUID, ByGPONameGroupUID
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
Parameter Sets: ByGPOIdGroupName, ByGPOIdGroupSID, ByGPOIdGroupUID
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
Parameter Sets: ByGPONameGroupName, ByGPONameGroupSID, ByGPONameGroupUID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPPSection
You can use this parameter to easily remove group objects from a GPPSection object which you already have in memory, but that parameter is here mostly for intra-module calls.

```yaml
Type: GPPSection
Parameter Sets: ByGPPSectionGroupName, ByGPPSectionGroupSID, ByGPPSectionGroupUID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of a group you want to remove from a GPO.

```yaml
Type: String
Parameter Sets: ByGPPSectionGroupName, ByGPOIdGroupName, ByGPONameGroupName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SID
Specifies the SID of a group you want to remove from a GPO.

```yaml
Type: SecurityIdentifier
Parameter Sets: ByGPPSectionGroupSID, ByGPOIdGroupSID, ByGPONameGroupSID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UID
Specifies the UID of a group you want to remove from a GPO. A UID is a unique identifier of an object in GPP. You can have several groups with the same Name/SID combination in the same Group Policy object - those groups will have different UIDs. You may get a UID of a group by looking at its "uid" property.

```yaml
Type: Guid
Parameter Sets: ByGPPSectionGroupUID, ByGPOIdGroupUID, ByGPONameGroupUID
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
