---
external help file: PSGPPreferences-help.xml
Module Name: PSGPPreferences
online version:
schema: 2.0.0
---

# New-GPPUser

## SYNOPSIS
Creates a new Group Policy Preferences user definition.

## SYNTAX

### ByGPOIdObjectNameUpdateUserMustChangePassword
```
New-GPPUser -Name <String> [-Update] -GPOId <Guid> [-Context <GPPContext>] [-NewName <String>]
 [-FullName <String>] [-Description <String>] [-AccountDisabled] [-AccountExpires <DateTime>]
 [-UserMustChangePassword] [-Disable] [-PassThru] [<CommonParameters>]
```

### ByGPONameObjectNameUpdateUserMustChangePassword
```
New-GPPUser -Name <String> [-Update] -GPOName <String> [-Context <GPPContext>] [-NewName <String>]
 [-FullName <String>] [-Description <String>] [-AccountDisabled] [-AccountExpires <DateTime>]
 [-UserMustChangePassword] [-Disable] [-PassThru] [<CommonParameters>]
```

### ByObjectNameUpdateUserMustChangePassword
```
New-GPPUser -Name <String> [-Update] [-NewName <String>] [-FullName <String>] [-Description <String>]
 [-AccountDisabled] [-AccountExpires <DateTime>] [-UserMustChangePassword] [-Disable] [<CommonParameters>]
```

### ByGPOIdObjectNameDelete
```
New-GPPUser -Name <String> [-Delete] -GPOId <Guid> [-Context <GPPContext>] [-Disable] [-PassThru]
 [<CommonParameters>]
```

### ByGPONameObjectNameDelete
```
New-GPPUser -Name <String> [-Delete] -GPOName <String> [-Context <GPPContext>] [-Disable] [-PassThru]
 [<CommonParameters>]
```

### ByObjectNameDelete
```
New-GPPUser -Name <String> [-Delete] [-Disable] [<CommonParameters>]
```

### ByGPOIdObjectNameUpdate
```
New-GPPUser -Name <String> [-Update] -GPOId <Guid> [-Context <GPPContext>] [-NewName <String>]
 [-FullName <String>] [-Description <String>] [-AccountDisabled] [-AccountExpires <DateTime>]
 [-PasswordNeverExpires] [-UserMayNotChangePassword] [-Disable] [-PassThru] [<CommonParameters>]
```

### ByGPONameObjectNameUpdate
```
New-GPPUser -Name <String> [-Update] -GPOName <String> [-Context <GPPContext>] [-NewName <String>]
 [-FullName <String>] [-Description <String>] [-AccountDisabled] [-AccountExpires <DateTime>]
 [-PasswordNeverExpires] [-UserMayNotChangePassword] [-Disable] [-PassThru] [<CommonParameters>]
```

### ByObjectNameUpdate
```
New-GPPUser -Name <String> [-Update] [-NewName <String>] [-FullName <String>] [-Description <String>]
 [-AccountDisabled] [-AccountExpires <DateTime>] [-PasswordNeverExpires] [-UserMayNotChangePassword] [-Disable]
 [<CommonParameters>]
```

### ByGPOIdBuiltInUserUpdateUserMustChangePassword
```
New-GPPUser -BuiltInUser <GPPItemUserSubAuthorityDisplay> [-Update] -GPOId <Guid> [-Context <GPPContext>]
 [-NewName <String>] [-FullName <String>] [-Description <String>] [-AccountDisabled]
 [-AccountExpires <DateTime>] [-UserMustChangePassword] [-Disable] [-PassThru] [<CommonParameters>]
```

### ByGPONameBuiltInUserUpdateUserMustChangePassword
```
New-GPPUser -BuiltInUser <GPPItemUserSubAuthorityDisplay> [-Update] -GPOName <String> [-Context <GPPContext>]
 [-NewName <String>] [-FullName <String>] [-Description <String>] [-AccountDisabled]
 [-AccountExpires <DateTime>] [-UserMustChangePassword] [-Disable] [-PassThru] [<CommonParameters>]
```

### BuiltInUserUpdateUserMustChangePassword
```
New-GPPUser -BuiltInUser <GPPItemUserSubAuthorityDisplay> [-Update] [-NewName <String>] [-FullName <String>]
 [-Description <String>] [-AccountDisabled] [-AccountExpires <DateTime>] [-UserMustChangePassword] [-Disable]
 [<CommonParameters>]
```

### ByGPOIdBuiltInUserUpdate
```
New-GPPUser -BuiltInUser <GPPItemUserSubAuthorityDisplay> [-Update] -GPOId <Guid> [-Context <GPPContext>]
 [-NewName <String>] [-FullName <String>] [-Description <String>] [-AccountDisabled]
 [-AccountExpires <DateTime>] [-PasswordNeverExpires] [-UserMayNotChangePassword] [-Disable] [-PassThru]
 [<CommonParameters>]
```

### ByGPONameBuiltInUserUpdate
```
New-GPPUser -BuiltInUser <GPPItemUserSubAuthorityDisplay> [-Update] -GPOName <String> [-Context <GPPContext>]
 [-NewName <String>] [-FullName <String>] [-Description <String>] [-AccountDisabled]
 [-AccountExpires <DateTime>] [-PasswordNeverExpires] [-UserMayNotChangePassword] [-Disable] [-PassThru]
 [<CommonParameters>]
```

### BuiltInUserUpdate
```
New-GPPUser -BuiltInUser <GPPItemUserSubAuthorityDisplay> [-Update] [-NewName <String>] [-FullName <String>]
 [-Description <String>] [-AccountDisabled] [-AccountExpires <DateTime>] [-PasswordNeverExpires]
 [-UserMayNotChangePassword] [-Disable] [<CommonParameters>]
```

## DESCRIPTION
Creates a new Group Policy Preferences user definition. You can either save it in the memory for additional processing or immediately put into a GPO by using the -GPOName or -GPOId parameters.

Note that available parameters depend on the action you choose: -Update or -Delete. This mimics the GUI behavior.

## EXAMPLES

### Example 1
```powershell
PS C:\> New-GPPUser -Name 'TEST-1' -GPOName 'Custom Group Policy' -Update -NewName 'TEST2'
```

Creates a new user definition for a user called "TEST-1" in a GPO called "Custom Group Policy". The definition will rename this user on target computers to "TEST2"

### Example 2
```powershell
PS C:\> New-GPPUser -Name 'TEST-1' -GPOId '70f86590-588a-4659-8880-3d2374604811' -Delete
```

Creates a new group definition for a user called "TEST-1" with its action set to "Delete", and saves it in a GPO with ID 70f86590-588a-4659-8880-3d2374604811.

### Example 3
```powershell
PS C:\> $UserDef = New-GPPUser -BuiltInUser Administrator -Update -PasswordNeverExpires
```

Creates a new user definition in the current PowerShell session for a built-in user "Administrator". This object defines that "Administrator"'s will never expire.
Note that this group definition is not saved in any group policy object - it exists only in memory. You can modify it and later save in a GPO using Add-GPPUser.

### Example 4
```powershell
PS C:\> New-GPPUser -Name 'TEST-1' -Update -GPOName 'Custom Group Policy' -AccountExpires ((Get-Date).AddMonths(1)) -UserMustChangePassword
```

Creates a new user definition in a GPO named "Custom Group Policy". The definition specifies that all users named "TEST-1" on target computers should expire in a month.

## PARAMETERS

### -AccountDisabled
Specifies that the target user account must be disabled.

```yaml
Type: SwitchParameter
Parameter Sets: ByGPOIdObjectNameUpdateUserMustChangePassword, ByGPONameObjectNameUpdateUserMustChangePassword, ByObjectNameUpdateUserMustChangePassword, ByGPOIdObjectNameUpdate, ByGPONameObjectNameUpdate, ByObjectNameUpdate, ByGPOIdBuiltInUserUpdateUserMustChangePassword, ByGPONameBuiltInUserUpdateUserMustChangePassword, BuiltInUserUpdateUserMustChangePassword, ByGPOIdBuiltInUserUpdate, ByGPONameBuiltInUserUpdate, BuiltInUserUpdate
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
Parameter Sets: ByGPOIdObjectNameUpdateUserMustChangePassword, ByGPONameObjectNameUpdateUserMustChangePassword, ByObjectNameUpdateUserMustChangePassword, ByGPOIdObjectNameUpdate, ByGPONameObjectNameUpdate, ByObjectNameUpdate, ByGPOIdBuiltInUserUpdateUserMustChangePassword, ByGPONameBuiltInUserUpdateUserMustChangePassword, BuiltInUserUpdateUserMustChangePassword, ByGPOIdBuiltInUserUpdate, ByGPONameBuiltInUserUpdate, BuiltInUserUpdate
Aliases:

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
Parameter Sets: ByGPOIdBuiltInUserUpdateUserMustChangePassword, ByGPONameBuiltInUserUpdateUserMustChangePassword, BuiltInUserUpdateUserMustChangePassword, ByGPOIdBuiltInUserUpdate, ByGPONameBuiltInUserUpdate, BuiltInUserUpdate
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
Parameter Sets: ByGPOIdObjectNameUpdateUserMustChangePassword, ByGPONameObjectNameUpdateUserMustChangePassword, ByGPOIdObjectNameDelete, ByGPONameObjectNameDelete, ByGPOIdObjectNameUpdate, ByGPONameObjectNameUpdate, ByGPOIdBuiltInUserUpdateUserMustChangePassword, ByGPONameBuiltInUserUpdateUserMustChangePassword, ByGPOIdBuiltInUserUpdate, ByGPONameBuiltInUserUpdate
Aliases:
Accepted values: Machine

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Delete
Sets the action property of the user definition to "Delete".

```yaml
Type: SwitchParameter
Parameter Sets: ByGPOIdObjectNameDelete, ByGPONameObjectNameDelete, ByObjectNameDelete
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Sets the description of a user object.

```yaml
Type: String
Parameter Sets: ByGPOIdObjectNameUpdateUserMustChangePassword, ByGPONameObjectNameUpdateUserMustChangePassword, ByObjectNameUpdateUserMustChangePassword, ByGPOIdObjectNameUpdate, ByGPONameObjectNameUpdate, ByObjectNameUpdate, ByGPOIdBuiltInUserUpdateUserMustChangePassword, ByGPONameBuiltInUserUpdateUserMustChangePassword, BuiltInUserUpdateUserMustChangePassword, ByGPOIdBuiltInUserUpdate, ByGPONameBuiltInUserUpdate, BuiltInUserUpdate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Disable
Disables processing of this group object. In the GUI you'll see it greyed out.

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

### -FullName
Specifies a full name for the target account.

```yaml
Type: String
Parameter Sets: ByGPOIdObjectNameUpdateUserMustChangePassword, ByGPONameObjectNameUpdateUserMustChangePassword, ByObjectNameUpdateUserMustChangePassword, ByGPOIdObjectNameUpdate, ByGPONameObjectNameUpdate, ByObjectNameUpdate, ByGPOIdBuiltInUserUpdateUserMustChangePassword, ByGPONameBuiltInUserUpdateUserMustChangePassword, BuiltInUserUpdateUserMustChangePassword, ByGPOIdBuiltInUserUpdate, ByGPONameBuiltInUserUpdate, BuiltInUserUpdate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOId
Specifies the ID of a GPO into which you want to add the newly created user definition. It is a name of a Group Policy's object in Active Directory. Look into a CN=Policies,CN=System container in your AD DS domain.

```yaml
Type: Guid
Parameter Sets: ByGPOIdObjectNameUpdateUserMustChangePassword, ByGPOIdObjectNameDelete, ByGPOIdObjectNameUpdate, ByGPOIdBuiltInUserUpdateUserMustChangePassword, ByGPOIdBuiltInUserUpdate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
Specifies the name of a GPO into which you want to add the newly created group definition.

```yaml
Type: String
Parameter Sets: ByGPONameObjectNameUpdateUserMustChangePassword, ByGPONameObjectNameDelete, ByGPONameObjectNameUpdate, ByGPONameBuiltInUserUpdateUserMustChangePassword, ByGPONameBuiltInUserUpdate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of a user.

```yaml
Type: String
Parameter Sets: ByGPOIdObjectNameUpdateUserMustChangePassword, ByGPONameObjectNameUpdateUserMustChangePassword, ByObjectNameUpdateUserMustChangePassword, ByGPOIdObjectNameDelete, ByGPONameObjectNameDelete, ByObjectNameDelete, ByGPOIdObjectNameUpdate, ByGPONameObjectNameUpdate, ByObjectNameUpdate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NewName
Specifies the new name of a user if you want to rename it on target hosts.

```yaml
Type: String
Parameter Sets: ByGPOIdObjectNameUpdateUserMustChangePassword, ByGPONameObjectNameUpdateUserMustChangePassword, ByObjectNameUpdateUserMustChangePassword, ByGPOIdObjectNameUpdate, ByGPONameObjectNameUpdate, ByObjectNameUpdate, ByGPOIdBuiltInUserUpdateUserMustChangePassword, ByGPONameBuiltInUserUpdateUserMustChangePassword, BuiltInUserUpdateUserMustChangePassword, ByGPOIdBuiltInUserUpdate, ByGPONameBuiltInUserUpdate, BuiltInUserUpdate
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
Parameter Sets: ByGPOIdObjectNameUpdateUserMustChangePassword, ByGPONameObjectNameUpdateUserMustChangePassword, ByGPOIdObjectNameDelete, ByGPONameObjectNameDelete, ByGPOIdObjectNameUpdate, ByGPONameObjectNameUpdate, ByGPOIdBuiltInUserUpdateUserMustChangePassword, ByGPONameBuiltInUserUpdateUserMustChangePassword, ByGPOIdBuiltInUserUpdate, ByGPONameBuiltInUserUpdate
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
Type: SwitchParameter
Parameter Sets: ByGPOIdObjectNameUpdate, ByGPONameObjectNameUpdate, ByObjectNameUpdate, ByGPOIdBuiltInUserUpdate, ByGPONameBuiltInUserUpdate, BuiltInUserUpdate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Update
Sets the action property of the user definition to "Update".

```yaml
Type: SwitchParameter
Parameter Sets: ByGPOIdObjectNameUpdateUserMustChangePassword, ByGPONameObjectNameUpdateUserMustChangePassword, ByObjectNameUpdateUserMustChangePassword, ByGPOIdObjectNameUpdate, ByGPONameObjectNameUpdate, ByObjectNameUpdate, ByGPOIdBuiltInUserUpdateUserMustChangePassword, ByGPONameBuiltInUserUpdateUserMustChangePassword, BuiltInUserUpdateUserMustChangePassword, ByGPOIdBuiltInUserUpdate, ByGPONameBuiltInUserUpdate, BuiltInUserUpdate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserMayNotChangePassword
Specifies that the target account should not be able to change its password by itself.

```yaml
Type: SwitchParameter
Parameter Sets: ByGPOIdObjectNameUpdate, ByGPONameObjectNameUpdate, ByObjectNameUpdate, ByGPOIdBuiltInUserUpdate, ByGPONameBuiltInUserUpdate, BuiltInUserUpdate
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
Type: SwitchParameter
Parameter Sets: ByGPOIdObjectNameUpdateUserMustChangePassword, ByGPONameObjectNameUpdateUserMustChangePassword, ByObjectNameUpdateUserMustChangePassword, ByGPOIdBuiltInUserUpdateUserMustChangePassword, ByGPONameBuiltInUserUpdateUserMustChangePassword, BuiltInUserUpdateUserMustChangePassword
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

### GPPItemUser

## NOTES

## RELATED LINKS
