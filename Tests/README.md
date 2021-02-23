## Groups

### Groups-GroupsOnly-Set-1

#### Common

* GPO GUID - f0a0c308-2fb0-433b-8a00-cc48b9ad1eba
* Section State - Enabled

#### EXAMPLE\TestGroup1

* Action - Update

#### Administrators (built-in)

* Action - Update
* SID - S-1-5-32-544

#### EXAMPLE\TestGroup3

* Action - Delete

#### EXAMPLE\TestGroup4

* Action - Create

#### EXAMPLE\TestGroup5

* Action - Replace

#### LocalGroup1

* Action - Update
* newName - LocalGroup2
* description - My Awesome Description

#### LocalGroup3

* Action - Create

##### Members

* EXAMPLE\Administrator
  * Action - ADD
* EXAMPLE\TEST1
  * Action - ADD
  * SID - S-1-5-21-2571216883-1601522099-2002488368-1620
* EXAMPLE\TEST2
  * Action - REMOVE
* EXAMPLE\TEST3
  * Action - REMOVE
  * SID - S-1-5-21-2571216883-1601522099-2002488368-1622

#### Backup Operators (built-in)

* Action - Update
* SID - S-1-5-32-551
* deleteAllUsers - True
* deleteAllGroups - True

##### Members

* EXAMPLE\Administrator
  * Action - ADD
* EXAMPLE\TEST1
  * Action - ADD
  * SID - S-1-5-21-2571216883-1601522099-2002488368-1620
* EXAMPLE\TEST2
  * Action - REMOVE
* EXAMPLE\TEST3
  * Action - REMOVE
  * SID - S-1-5-21-2571216883-1601522099-2002488368-1622

### Groups-GroupsOnly-Set-2

#### Common

* GPO GUID - 4c6924d8-020a-4362-8a42-5977fcb3a06e
* Section State - Disabled

Everything else is as in Groups-GroupsOnly-Set-1.