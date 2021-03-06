---
external help file: PSGPPreferences-help.xml
Module Name: PSGPPreferences
online version:
schema: 2.0.0
---

# Get-GPPGroup

## SYNOPSIS
Retrieves a group from a given Group Policy Preferences instance.

## SYNTAX

### ByGPPSectionObjectName
```
Get-GPPGroup [-Name <String>] -GPPSection <GPPSection> [<CommonParameters>]
```

### ByGPOIdObjectName
```
Get-GPPGroup [-Name <String>] -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPONameObjectName
```
Get-GPPGroup [-Name <String>] -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPPSectionObjectLiteralName
```
Get-GPPGroup -LiteralName <String> -GPPSection <GPPSection> [<CommonParameters>]
```

### ByGPOIdObjectLiteralName
```
Get-GPPGroup -LiteralName <String> -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPONameObjectLiteralName
```
Get-GPPGroup -LiteralName <String> -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPPSectionObjectSID
```
Get-GPPGroup -SID <SecurityIdentifier> -GPPSection <GPPSection> [<CommonParameters>]
```

### ByGPOIdObjectSID
```
Get-GPPGroup -SID <SecurityIdentifier> -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPONameObjectSID
```
Get-GPPGroup -SID <SecurityIdentifier> -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPPSectionObjectUID
```
Get-GPPGroup -UID <Guid> -GPPSection <GPPSection> [<CommonParameters>]
```

### ByGPOIdObjectUID
```
Get-GPPGroup -UID <Guid> -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPONameObjectUID
```
Get-GPPGroup -UID <Guid> -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves a group from a given Group Policy Preferences instance. You can get that GPP object either from a GPO or you can pass one to the -GPPSection parameter (but that's mostly for module's internal stuff).

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-GPPGroup -Name 'TEST-*' -GPOName 'Custom Group Policy'
```

Returns all group definitions where group name starts with "TEST-" from a GPO called "Custom Group Policy".

### Example 2
```powershell
PS C:\> Get-GPPGroup -LiteralName 'TEST-*' -GPOId '70f86590-588a-4659-8880-3d2374604811'
```

Returns all group definitions where group name is "TEST-*" from a GPO with an ID "70f86590-588a-4659-8880-3d2374604811".

### Example 3
```powershell
PS C:\> Get-GPPGroup -UID '3B1BF433-38BF-47A5-925C-3DC32B6555B3' -GPOName 'Custom Group Policy'
```

Returns a group definition with a UID "3B1BF433-38BF-47A5-925C-3DC32B6555B3" from a GPO called "Custom Group Policy".

## PARAMETERS

### -Context
Specifies which Group Policy context to use: Machine or User. Doesn't do anything right now, since the User one has not yet been implemented.

```yaml
Type: GPPContext
Parameter Sets: ByGPOIdObjectName, ByGPONameObjectName, ByGPOIdObjectLiteralName, ByGPONameObjectLiteralName, ByGPOIdObjectSID, ByGPONameObjectSID, ByGPOIdObjectUID, ByGPONameObjectUID
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
Parameter Sets: ByGPOIdObjectName, ByGPOIdObjectLiteralName, ByGPOIdObjectSID, ByGPOIdObjectUID
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
Parameter Sets: ByGPONameObjectName, ByGPONameObjectLiteralName, ByGPONameObjectSID, ByGPONameObjectUID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPPSection
You can use this parameter to easily extract group definition objects from a GPPSection object which you already have in memory, but that parameter is here mostly for intra-module calls.

```yaml
Type: GPPSection
Parameter Sets: ByGPPSectionObjectName, ByGPPSectionObjectLiteralName, ByGPPSectionObjectSID, ByGPPSectionObjectUID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiteralName
Name of a group you want to retrieve. Does NOT support wildcards.

```yaml
Type: String
Parameter Sets: ByGPPSectionObjectLiteralName, ByGPOIdObjectLiteralName, ByGPONameObjectLiteralName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of a group you want to retrieve. Supports wildcards.

```yaml
Type: String
Parameter Sets: ByGPPSectionObjectName, ByGPOIdObjectName, ByGPONameObjectName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -SID
Specifies the SID of a group you want to retrieve.

```yaml
Type: SecurityIdentifier
Parameter Sets: ByGPPSectionObjectSID, ByGPOIdObjectSID, ByGPONameObjectSID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UID
Specifies the UID of a group definition you want to retrieve. A UID is a unique identifier of an object in GPP. You can have several groups with the same Name/SID combination in the same Group Policy object - those group definitions will have different UIDs. You may get a UID of a group by looking at its "uid" property.

```yaml
Type: Guid
Parameter Sets: ByGPPSectionObjectUID, ByGPOIdObjectUID, ByGPONameObjectUID
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
