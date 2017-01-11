# 

# You can connect to a different Edge using different Connection files

# Invoke-Pester -Script @{
#     Path = '.\Tests\PSApigeeEdge.Tests.ps1'
#     Parameters = @{Connection = 'ConnectionData.json'}
# }

# Trying to run pester non-interactively so as to suppress the prompts for
# parameters that are marked Mandatory. 

powershell.exe -NonInteractive -Command "Invoke-Pester -Script @{ Path = '.\Tests\PSApigeeEdge.Tests.ps1'; Parameters = @{Connection = 'ConnectionData.json'} }"


# $MyPS = [Powershell]::Create()
# $MyPS.Commands.AddCommand("Invoke-Pester")
# $MyPS.Commands.AddParameter("Script", @{
#      Path = '.\Tests\PSApigeeEdge.Tests.ps1'
#      Parameters = @{Connection = 'ConnectionData.json'}
# } )
# $MyPS.Invoke()



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
