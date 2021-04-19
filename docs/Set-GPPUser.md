---
external help file: PSGPPreferences-help.xml
Module Name: PSGPPreferences
online version:
schema: 2.0.0
---

# Set-GPPUser

## SYNOPSIS
Sets properties of a user definition in a specified Group Policy object.

## SYNTAX

### ByGPOIdObject
```
Set-GPPUser -InputObject <GPPItemUser> -GPOId <Guid> [-Context <GPPContext>]
 [-Action <GPPItemUserActionDisplay>] [-NewName <String>] [-FullName <String>] [-Description <String>]
 [-AccountDisabled <Boolean>] [-AccountExpires <DateTime>] [-PasswordNeverExpires <Boolean>]
 [-UserMayNotChangePassword <Boolean>] [-UserMustChangePassword <Boolean>] [-Disable <Boolean>] [-PassThru]
 [<CommonParameters>]
```

### ByGPONameObject
```
Set-GPPUser -InputObject <GPPItemUser> -GPOName <String> [-Context <GPPContext>]
 [-Action <GPPItemUserActionDisplay>] [-NewName <String>] [-FullName <String>] [-Description <String>]
 [-AccountDisabled <Boolean>] [-AccountExpires <DateTime>] [-PasswordNeverExpires <Boolean>]
 [-UserMayNotChangePassword <Boolean>] [-UserMustChangePassword <Boolean>] [-Disable <Boolean>] [-PassThru]
 [<CommonParameters>]
```

### ByGPOIdItemName
```
Set-GPPUser -Name <String> -GPOId <Guid> [-Context <GPPContext>] [-Action <GPPItemUserActionDisplay>]
 [-NewName <String>] [-FullName <String>] [-Description <String>] [-AccountDisabled <Boolean>]
 [-AccountExpires <DateTime>] [-PasswordNeverExpires <Boolean>] [-UserMayNotChangePassword <Boolean>]
 [-UserMustChangePassword <Boolean>] [-Disable <Boolean>] [-PassThru] [<CommonParameters>]
```

### ByGPONameItemName
```
Set-GPPUser -Name <String> -GPOName <String> [-Context <GPPContext>] [-Action <GPPItemUserActionDisplay>]
 [-NewName <String>] [-FullName <String>] [-Description <String>] [-AccountDisabled <Boolean>]
 [-AccountExpires <DateTime>] [-PasswordNeverExpires <Boolean>] [-UserMayNotChangePassword <Boolean>]
 [-UserMustChangePassword <Boolean>] [-Disable <Boolean>] [-PassThru] [<CommonParameters>]
```

### ByGPOIdItemLiteralName
```
Set-GPPUser -LiteralName <String> -GPOId <Guid> [-Context <GPPContext>] [-Action <GPPItemUserActionDisplay>]
 [-NewName <String>] [-FullName <String>] [-Description <String>] [-AccountDisabled <Boolean>]
 [-AccountExpires <DateTime>] [-PasswordNeverExpires <Boolean>] [-UserMayNotChangePassword <Boolean>]
 [-UserMustChangePassword <Boolean>] [-Disable <Boolean>] [-PassThru] [<CommonParameters>]
```

### ByGPONameItemLiteralName
```
Set-GPPUser -LiteralName <String> -GPOName <String> [-Context <GPPContext>]
 [-Action <GPPItemUserActionDisplay>] [-NewName <String>] [-FullName <String>] [-Description <String>]
 [-AccountDisabled <Boolean>] [-AccountExpires <DateTime>] [-PasswordNeverExpires <Boolean>]
 [-UserMayNotChangePassword <Boolean>] [-UserMustChangePassword <Boolean>] [-Disable <Boolean>] [-PassThru]
 [<CommonParameters>]
```

### ByGPOIdItemBuiltInUser
```
Set-GPPUser -BuiltInUser <GPPItemUserSubAuthorityDisplay> -GPOId <Guid> [-Context <GPPContext>]
 [-Action <GPPItemUserActionDisplay>] [-NewName <String>] [-FullName <String>] [-Description <String>]
 [-AccountDisabled <Boolean>] [-AccountExpires <DateTime>] [-PasswordNeverExpires <Boolean>]
 [-UserMayNotChangePassword <Boolean>] [-UserMustChangePassword <Boolean>] [-Disable <Boolean>] [-PassThru]
 [<CommonParameters>]
```

### ByGPONameItemBuiltInUser
```
Set-GPPUser -BuiltInUser <GPPItemUserSubAuthorityDisplay> -GPOName <String> [-Context <GPPContext>]
 [-Action <GPPItemUserActionDisplay>] [-NewName <String>] [-FullName <String>] [-Description <String>]
 [-AccountDisabled <Boolean>] [-AccountExpires <DateTime>] [-PasswordNeverExpires <Boolean>]
 [-UserMayNotChangePassword <Boolean>] [-UserMustChangePassword <Boolean>] [-Disable <Boolean>] [-PassThru]
 [<CommonParameters>]
```

## DESCRIPTION
Sets properties of a user definition in a specified Group Policy object. You may also use it to write a user definition object from memory into a GPO and changing some of its properties in the process.
If you want just to add a user definition into a GPO, w/o any modifications, I suggest you to use Add-GPPUser.

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-GPPUser -Name 'TEST-1' -GPOName 'Custom Group Policy' -NewName 'TEST2'
```

For a user called "TEST-1" in the "Custom Group Policy" GPO sets that on target computers this user must be renamed to "TEST2"

### Example 2
```powershell
PS C:\> Set-GPPUser -Name 'TEST-1' -GPOId '70f86590-588a-4659-8880-3d2374604811' -Delete
```

Specifies that a user called "TEST-1" must be deleted from all target computers, and saves these instructions in a GPO with ID 70f86590-588a-4659-8880-3d2374604811.

### Example 3
```powershell
PS C:\> $User = Get-GPPUser -Name 'TEST-1' -GPOName 'Custom Group Policy'
PS C:\> Set-GPPUser -InputObject $User -GPOName 'Custom Group Policy' -PasswordNeverExpires $true
```

Retrieves a user definition from a GPO called "Custom Group Policy" and then saves it back, but with an option to never-ever change their password.

## PARAMETERS

### -AccountDisabled
Specifies that the target user account must be disabled.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccountExpires
Specifies that this user account should expire at a given date in the future. Despite that you pass a full DateTime object to this parameter, only date will be used.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Action
Sets one of two actions which you can instruct the GPP engine to do with a user: Update or Delete. Different actions have different sets of allowed parameters.
The function initially does not restrict you from pass parameters incompatible with Action, but will correct them to be in accordance with the action. i.e. if you set -Action to "Delete" and -NewName to something, -NewName will be ignored.
Also, if you have a user object with some properties defined and change its action to "Delete", the object will be stripped off its properties.

For properties compatibility see help for New-GPPUser.

```yaml
Type: GPPItemUserActionDisplay
Parameter Sets: (All)
Aliases:
Accepted values: Update, Delete

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BuiltInUser
Allows you to target your user definition to a system built-in user, instead of a regular account.

```yaml
Type: GPPItemUserSubAuthorityDisplay
Parameter Sets: ByGPOIdItemBuiltInUser, ByGPONameItemBuiltInUser
Aliases:
Accepted values: Administrator, Guest

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

### -Description
Sets the description of a user object.

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
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FullName
Specifies a full name for the target account.

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

### -GPOId
Specifies the ID of a GPO in which you want to search for users. It is a name of a Group Policy's object in Active Directory. Look into a CN=Policies,CN=System container in your AD DS domain.

```yaml
Type: Guid
Parameter Sets: ByGPOIdObject, ByGPOIdItemName, ByGPOIdItemLiteralName, ByGPOIdItemBuiltInUser
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
Parameter Sets: ByGPONameObject, ByGPONameItemName, ByGPONameItemLiteralName, ByGPONameItemBuiltInUser
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
If you already have a user definition object in memory, which you want to write into a Group Policy, you can pass in into this parameter.

```yaml
Type: GPPItemUser
Parameter Sets: ByGPOIdObject, ByGPONameObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiteralName
Specifies the name of a user which you want to change. Does not support wildcards.

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

### -Name
Specifies the name of a user which you want to change. Supports wildcards.

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
Specifies a new name for a user if you want to rename it on target hosts.

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
Returns a new user definition object to the pipeline.

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

### -PasswordNeverExpires
Speficies that the password of the target account should not expire.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserMayNotChangePassword
Specifies that the target account should not be able to change its password by itself.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserMustChangePassword
Specifies that the target account must change its password at the next logon.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
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

### GPPItemUser

## NOTES

## RELATED LINKS
