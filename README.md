# Edge Powershell Admin module

This is a module that can be used Windows Powershell module for managing Apigee Edge.

It allows Powershell scripts to do these things:

| entity type   | actions             |
| :------------ | :------------------ |
| apis          | list, query, import or export, create, deploy or undeploy
| apiproducts   | list/query, create, delete, modify (change quota, or add/remove proxy)
| developers    | list/query, create, delete
| developer app | list/query, create, delete, edit (add credential, add product to credential)
| kvm           | list, add entry, remove entry
| cache         | create, clear, remove
| environment   | list, query


Not in scope:

- TargetServers: list, create, edit
- keystores, truststores: adding certs, listing certs
- DebugSessions (trace)
- anything in BaaS
- OPDK-specific things.  Like starting, stopping services, etc.

## Pre-Requisites

You need Windows, and Powershell v3.0 or later. If you're running Windows 10,
then you have Powershell 5.0. 

## Status

This project is still in the "dream" stage.
Only one method has been created, as yet. 

## Examples

### Importing the Module

```
C:\Users\Dino> powershell
PS C:\Users\Dino> Import-Module c:/random-path/PSApigeeEdge
```

### List Developers

```
C:\dev\ps>powershell
Windows PowerShell
Copyright (C) 2015 Microsoft Corporation. All rights reserved.

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

This example uses the lower-level Get-EdgeObject function. 

```
PS C:\dev\ps> (Get-EdgeObject -Collection developers -Params @{ expand = 'true' }).developer | Format-List

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

PS C:\dev\ps>
```


### List API Products Verbosely

```
PS C:\dev\ps> (Get-EdgeObject -Collection apiproducts -Params @{ expand = 'true' }).apiProduct | Format-List

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


## License

This is licensed under [the Apache 2.0 source license](LICENSE).

