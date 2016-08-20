# 

# You can connect to a different Edge using different Connection files

Invoke-Pester -Script @{
    Path = '.\Tests\PSApigeeEdge.Tests.ps1'
    Parameters = @{Connection = 'ConnectionData.json'}
 }

# The connection file ought to look like this:
# {
#   "Org" : "orgname",
#   "MgmtUri" : "https://api.enterprise.apigee.com",
#   "User" : "user@example.com",
#   "Password" : "Password123"
# }
#
# or, you can use an encrypted password that you obtained via ConvertFrom-SecureString,
# with this kind of file:
# {
#   "Org" : "orgname",
#   "MgmtUri" : "http://opdk-mgmt-endpoint:8080",
#   "User" : "user@example.com",
#   "EncryptedPassword" : "01109092982209209209AB....ADFBABABABBEB"
# }
#
