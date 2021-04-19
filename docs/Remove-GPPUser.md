---
external help file: PSGPPreferences-help.xml
Module Name: PSGPPreferences
online version:
schema: 2.0.0
---

# Remove-GPPUser

## SYNOPSIS
Removes a user definition from a GPO object.

## SYNTAX

### ByGPPSectionObjectName
```
Remove-GPPUser -Name <String> -GPPSection <GPPSection> [<CommonParameters>]
```

### ByGPOIdObjectName
```
Remove-GPPUser -Name <String> -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPONameObjectName
```
Remove-GPPUser -Name <String> -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPPSectionObjectLiteralName
```
Remove-GPPUser -LiteralName <String> -GPPSection <GPPSection> [<CommonParameters>]
```

### ByGPOIdObjectLiteralName
```
Remove-GPPUser -LiteralName <String> -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPONameObjectLiteralName
```
Remove-GPPUser -LiteralName <String> -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPPSectionBuiltInUser
```
Remove-GPPUser -BuiltInUser <GPPItemUserSubAuthority> -GPPSection <GPPSection> [<CommonParameters>]
```

### ByGPOIdBuiltInUser
```
Remove-GPPUser -BuiltInUser <GPPItemUserSubAuthority> -GPOId <Guid> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByGPONameBuiltInUser
```
Remove-GPPUser -BuiltInUser <GPPItemUserSubAuthority> -GPOName <String> [-Context <GPPContext>]
 [<CommonParameters>]
```

### ByGPPSectionObjectUID
```
Remove-GPPUser -UID <Guid> -GPPSection <GPPSection> [<CommonParameters>]
```

### ByGPOIdObjectUID
```
Remove-GPPUser -UID <Guid> -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### ByGPONameObjectUID
```
Remove-GPPUser -UID <Guid> -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

## DESCRIPTION
Removes a user definition from a GPO object.

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-GPPUser -Name 'TEST-*' -GPOName 'Custom Group Policy'
```

Removes all user definitions where user names start with "TEST-*" from the "Custom Group Policy" GPO.

## PARAMETERS

### -BuiltInUser
Allows you to search for user definitions of a system built-in user, instead of a regular account.

```yaml
Type: GPPItemUserSubAuthority
Parameter Sets: ByGPPSectionBuiltInUser, ByGPOIdBuiltInUser, ByGPONameBuiltInUser
Aliases:
Accepted values: RID_ADMIN, RID_GUEST

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
Parameter Sets: ByGPOIdObjectName, ByGPONameObjectName, ByGPOIdObjectLiteralName, ByGPONameObjectLiteralName, ByGPOIdBuiltInUser, ByGPONameBuiltInUser, ByGPOIdObjectUID, ByGPONameObjectUID
Aliases:
Accepted values: Machine

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOId
Specifies the ID of a GPO in which you want to search for users. It is a name of a Group Policy's object in Active Directory. Look into a CN=Policies,CN=System container in your AD DS domain.

```yaml
Type: Guid
Parameter Sets: ByGPOIdObjectName, ByGPOIdObjectLiteralName, ByGPOIdBuiltInUser, ByGPOIdObjectUID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
Specifies the name of a GPO in which you want to search for users.

```yaml
Type: String
Parameter Sets: ByGPONameObjectName, ByGPONameObjectLiteralName, ByGPONameBuiltInUser, ByGPONameObjectUID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPPSection
You can use this parameter to easily remove user definition objects from a GPPSection object which you already have in memory, but that parameter is here mostly for intra-module calls.

```yaml
Type: GPPSection
Parameter Sets: ByGPPSectionObjectName, ByGPPSectionObjectLiteralName, ByGPPSectionBuiltInUser, ByGPPSectionObjectUID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiteralName
Specifies the name of a user you want to remove from a GPO. Does NOT support wildcards.

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
Specifies the name of a user you want to remove from a GPO.

```yaml
Type: String
Parameter Sets: ByGPPSectionObjectName, ByGPOIdObjectName, ByGPONameObjectName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -UID
Specifies the UID of a user definition you want to remove from a GPO. A UID is a unique identifier of an object in GPP. You can have several users with the same Name defined in the same Group Policy object - those user definitions will have different UIDs. You may get a UID of a user by looking at its "uid" property.

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

### System.Void

## NOTES

## RELATED LINKS
