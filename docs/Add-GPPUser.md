---
external help file: PSGPPreferences-help.xml
Module Name: PSGPPreferences
online version:
schema: 2.0.0
---

# Add-GPPUser

## SYNOPSIS
Adds a user item into a Group Policy Object

## SYNTAX

### ById
```
Add-GPPUser -InputObject <GPPItemUser> -GPOId <Guid> [-Context <GPPContext>] [<CommonParameters>]
```

### ByName
```
Add-GPPUser -InputObject <GPPItemUser> -GPOName <String> [-Context <GPPContext>] [<CommonParameters>]
```

## DESCRIPTION
Use this function to add a user into a Group Policy Object. First you have to create a new user definition object using New-GPPUser.
This function is useful if you want to add the same user definition into several Group Policy objects. If you just want to create a single user and add it into a GPO immediately, you can just use the -GPOName/GPOId parameter of New-GPPGroup.

## EXAMPLES

### Example 1
```powershell
PS C:\> Add-GPPUser -InputObject $UserObject -GPOName 'TEST'
```

Adds a user definition object $Userbject into a Group Policy named TEST.

### Example 2
```powershell
PS C:\> Add-GPPUser -InputObject $UserObject -GPOId '31B2F340-016D-11D2-945F-00C04FB984F9'
```

Adds a user definition object $UserObject into a Group Policy by using its ID (see the description for the -GPOId parameter below).

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
Specifies a Group Policy object ID into which you want to add a user. It is a name of a Group Policy's object in Active Directory. Look into a CN=Policies,CN=System container in your AD DS domain.

```yaml
Type: Guid
Parameter Sets: ById
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
Specifies a Group Policy object name into which you want to add a user.

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

### -InputObject
Specifies an object of a user definition which you want to add into a GPO. You can create one with New-GPPUser.

```yaml
Type: GPPItemUser
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
