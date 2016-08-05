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


## License

This is licensed under [the Apache 2.0 source license](LICENSE).

