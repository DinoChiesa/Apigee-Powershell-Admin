# Edge Powershell Admin module

This is a module that can be used Windows Powershell module for managing Apigee Edge.

The goal is to allow Powershell scripts to do these things:

| entity type   | actions             |
| :------------ | :------------------ |
| apis          | list, query, import or export, create, delete, delete revision, deploy or undeploy
| apiproducts   | list, query, create, delete, change quota, add or remove proxy, add or remove custom attrs
| developers    | list, query, create, delete, make active or inactive, add or remove custom attrs
| developer app | list, query, create, delete, revoke, add or remove credential, add or remove custom attrs
| credential    | list, query, create, delete, revoke
| kvm           | list, add entry, remove entry
| cache         | list, query, create, clear, remove
| environment   | list, query


Not in scope:

- TargetServers: list, create, edit, etc
- keystores, truststores: adding certs, listing certs
- DebugSessions (trace)
- anything in BaaS
- OPDK-specific things.  Like starting, stopping services, manipulating pods, etc.

## Pre-Requisites

You need Windows, and Powershell v3.0 or later. If you're running Windows 10,
then you have Powershell 5.0. 

## Status

This project is a work-in-progress.

| entity type   | implemented              | Not implemented yet
| :------------ | :----------------------- | :-------------
| apis          | list, query, import or export, create, delete, delete revision, deploy or undeploy
| apiproducts   | list/query | create, delete, change quota, add or remove proxy, add or remove custom attrs
| developers    | list/query | create, delete, make active or inactive, add or remove custom attrs
| developer app | list, query | create, delete, revoke, add or remove credential, add or remove custom attrs
| credential    |  | list/query, create, delete, revoke
| kvm           |  | list, add entry, remove entry
| cache         | list, query | create, clear, remove
| environment   | list, query |

Pull requests are welcomed.


## Examples

### Import the Module

Do this first, before trying anything else.

```
C:\Users\Dino> powershell
PS C:\Users\Dino> Import-Module c:/random-path/PSApigeeEdge
```

### List Developers

```
C:\dev\ps>powershell
PS C:\dev\ps> Import-Module ./PSApigeeEdge
PS C:\dev\ps> Set-EdgeConnection -Org cap500 -User dino@apigee.com -Pass 'Secret1XYZ'
PS C:\dev\ps> Get-EdgeDeveloper
mpalmgre@seattlecca.org
dchiesa@example.org
dchiesa+workshop1@apigee.com
mmcsweyn@seattlecca.org
Lois@example.com
akshays@slalom.com
ecerruti@gmail.com
justinmadalone@gmail.com
PS C:\dev\ps>
```


### Get Details of API Proxy Revision

```
PS C:\dev\ps> Get-EdgeApi -Name oauth2-pwd-cc -Revision 2

configurationVersion : @{majorVersion=4; minorVersion=0}
contextInfo          : Revision 2 of application oauth2-pwd-cc, in organization cap500
createdAt            : 1470082739958
createdBy            : DChiesa@apigee.com
description          : Dispense OAuth v2.0 Bearer tokens for password and client_credentials grant_types. In this proxy, the user authentication is
                       handled by a mock service.
displayName          : oauth2-pwd-cc
lastModifiedAt       : 1470082739958
lastModifiedBy       : DChiesa@apigee.com
name                 : oauth2-pwd-cc
policies             : {AE-ConsumerKey, AM-CleanResponseHeaders, AM-NoContent, BasicAuth-1...}
proxyEndpoints       : {oauth-dispensary, resource}
resourceFiles        : @{resourceFile=System.Object[]}
resources            : {jsc://dateFormat.js, jsc://groomTokenResponse.js, jsc://mapRolesToScopes.js, jsc://maybeFormatFault.js...}
revision             : 2
targetEndpoints      : {}
targetServers        : {}
type                 : Application
```


### List Developers Verbosely

```
PS C:\dev\ps> (Get-EdgeDeveloper -Params @{ expand = 'true' }).developer | Format-List

apps             : {my-hospitality-app-oauth, my-hospitality-app}
companies        : {}
email            : mpalmgre@seattlecca.org
developerId      : 0wYm1ALhbLl3er5G
firstName        : Matt
lastName         : Palmgren
userName         : mpalmgre
organizationName : cap500
status           : active
attributes       : {}
createdAt        : 1470173119147
createdBy        : dchiesa+devportal@apigee.com
lastModifiedAt   : 1470174224727
lastModifiedBy   : dchiesa+devportal@apigee.com

apps             : {dpc1, dpc2, dpc3, DPC4...}
companies        : {}
email            : dchiesa@example.org
developerId      : IiwTHAerQeO1OAqG
firstName        : Dino
lastName         : Chiesa
userName         : DC
organizationName : cap500
status           : active
attributes       : {}
createdAt        : 1469831492534
createdBy        : dchiesa+devportal@apigee.com
lastModifiedAt   : 1469831492534
lastModifiedBy   : dchiesa+devportal@apigee.com

 ...

```


### List API Products Verbosely

```
PS C:\dev\ps> (Get-EdgeApiProduct -Params @{ expand = 'true' }).apiProduct | Format-List

apiResources   : {}
approvalType   : auto
attributes     : {@{name=access; value=public}}
createdAt      : 1469813885881
createdBy      : DChiesa@apigee.com
description    : API Bundle for a basic Hospitality App.
displayName    : DPC Hospitality Basic Product
environments   : {test}
lastModifiedAt : 1470151304300
lastModifiedBy : DChiesa@apigee.com
name           : DPC Hospitality Basic Product
proxies        : {dpc_hotels, dpc_hotels_oauth, oauth2-pwd-cc}
scopes         : {read, write, delete}

  ...

```

### Get Deployment status of an API

```
PS C:\dev\ps> Get-EdgeApiDeployment -Name oauth2-pwd-cc

name revision
---- --------
test {@{configuration=; name=8; server=System.Object[]; state=deployed}}

PS C:\dev\ps> Get-EdgeApiDeployment -Name oauth2-pwd-cc | Format-List

name     : test
revision : {@{configuration=; name=8; server=System.Object[]; state=deployed}}

```

### Deploy an API Proxy

```
PS C:\dev\ps> Deploy-EdgeApi -Name oauth2-pwd-cc -Env test -Revision 8

aPIProxy      : oauth2-pwd-cc
configuration : @{basePath=/; steps=System.Object[]}
environment   : test
name          : 8
organization  : cap500
revision      : 8
server        : {@{status=deployed; type=System.Object[]; uUID=a4850e3b-6ce9-482a-9521-d9869be8482e}, @{status=deployed; type=System.Object[];
                uUID=647de67b-1142-4c07-8b22-c5d6f85616a4}, @{status=deployed; type=System.Object[]; uUID=6b4a729b-16e2-45c0-8560-51eb37f50ece},
                @{status=deployed; type=System.Object[]; uUID=589aa4f0-0a1b-492c-be1a-da3e295cf44d}...}
state         : deployed
```

### Undeploy an API Proxy

```
PS C:\dev\ps> UnDeploy-EdgeApi -Name oauth2-pwd-cc -Env test -Revision 8


aPIProxy      : oauth2-pwd-cc
configuration : @{basePath=/; steps=System.Object[]}
environment   : test
name          : 8
organization  : cap500
revision      : 8
server        : {@{status=undeployed; type=System.Object[]; uUID=a4850e3b-6ce9-482a-9521-d9869be8482e}, @{status=undeployed; type=System.Object[];
                uUID=647de67b-1142-4c07-8b22-c5d6f85616a4}, @{status=undeployed; type=System.Object[]; uUID=6b4a729b-16e2-45c0-8560-51eb37f50ece},
                @{status=undeployed; type=System.Object[]; uUID=589aa4f0-0a1b-492c-be1a-da3e295cf44d}...}
state         : undeployed

```


### Export an API Proxy

```
PS C:\dev\ps> Export-EdgeApi -Name oauth2-pwd-cc -Revision 8
oauth2-pwd-cc-r8-20160805-175438.zip
```


### Import an API Proxy

```
PS C:\dev\ps> Import-EdgeApi -Name dino-test-6 -Source oauth2-pwd-cc-r8-20160805-175438.zip


configurationVersion : @{majorVersion=4; minorVersion=0}
contextInfo          : Revision 1 of application dino-test-6, in organization cap500
createdAt            : 1470444956300
createdBy            : dino@apigee.com
description          : Dispense OAuth v2.0 Bearer tokens for password and client_credentials grant_types. In this proxy, the user authentication is
                       handled by a mock service.
displayName          : oauth2-pwd-cc
lastModifiedAt       : 1470444956300
lastModifiedBy       : dino@apigee.com
name                 : dino-test-6
policies             : {AE-ConsumerKey, AM-CleanResponseHeaders, AM-NoContent, AM-Response...}
proxyEndpoints       : {oauth-dispensary, resource}
resourceFiles        : @{resourceFile=System.Object[]}
resources            : {jsc://dateFormat.js, jsc://groomTokenResponse.js, jsc://mapRolesToScopes.js, jsc://maybeFormatFault.js...}
revision             : 1
targetEndpoints      : {}
targetServers        : {}
type                 : Application

```


### Delete an API Proxy

```
PS C:\dev\ps> Delete-EdgeApi dino-test-4


configurationVersion : @{majorVersion=4; minorVersion=0}
contextInfo          : Revision null of application -NA-, in organization -NA-
name                 : dino-test-4
policies             : {}
proxyEndpoints       : {}
resourceFiles        : @{resourceFile=System.Object[]}
resources            : {}
targetEndpoints      : {}
targetServers        : {}
type                 : Application

```

### Delete a revision of an API Proxy

```
PS C:\dev\ps> Delete-EdgeApi -Name oauth2-pwd-cc -Revision 3


configurationVersion : @{majorVersion=4; minorVersion=0}
contextInfo          : Revision 3 of application oauth2-pwd-cc, in organization cap500
createdAt            : 1470082789542
createdBy            : DChiesa@apigee.com
description          : Dispense OAuth v2.0 Bearer tokens for password and client_credentials grant_types. In this proxy, the user authentication is
                       handled by a mock service.
displayName          : oauth2-pwd-cc
lastModifiedAt       : 1470082789542
lastModifiedBy       : DChiesa@apigee.com
name                 : oauth2-pwd-cc
policies             : {}
proxyEndpoints       : {}
resourceFiles        : @{resourceFile=System.Object[]}
resources            : {}
revision             : 3
targetEndpoints      : {}
targetServers        : {}
type                 : Application

```

### List Environments

```
PS C:\dev\ps> get-EdgeEnvironment
test
prod
```

### Query a particular Environment by Name

```
PS C:\dev\ps> get-EdgeEnvironment -name test


createdAt      : 1408425529572
createdBy      : lyeo@apigee.com
lastModifiedAt : 1464341439395
lastModifiedBy : sanjoy@apigee.com
name           : test
properties     : @{property=System.Object[]}

```

## License

This is licensed under [the Apache 2.0 source license](LICENSE).

