# Edge Powershell Admin module

This is a module that can be used Windows Powershell module for managing Apigee Edge.

It allows Powershell scripts to do these things:

| entity type | actions  |
| :---------- | :---------- |
| apis        | list, query, import or export, create, deploy or undeploy
| apiproducts | list/query, create, delete, modify (change quota, or add/remove proxy)
| developers  | list/query, create, delete
| developer app | list/query, create, delete, edit (add credential, add product to credential)
| kvm         | list, add entry, remove entry
| cache       | create, clear, remove
| environment | list, query

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
C:\Users\Dino> powershell
PS C:\Users\Dino> Import-Module c:/random-path/PSApigeeEdge
PS C:\Users\Dino> Get-EdgeObject -Collection developers -Org cap500 -User dino@apigee.com -Pass Secret123
mpalmgre@seattlecca.org
dchiesa@example.org
dchiesa+workshop1@apigee.com
mmcsweyn@seattlecca.org
Lois@example.com
akshays@slalom.com
ecerruti@gmail.com
justinmadalone@gmail.com
PS C:\Users\Dino>
```


## License

This is licensed under [the Apache 2.0 source license](LICENSE).

