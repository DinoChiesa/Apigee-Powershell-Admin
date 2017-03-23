Write-Output "Find API Product for a given API Proxy"

$Org = Read-Host "Edge org?"
$User = Read-Host "Edge admin user?"  # eg, 'dchiesa@google.com'
$SecurePass = Read-Host -assecurestring "Password for $User"
$EncryptedPassword = ConvertFrom-SecureString $SecurePass

$connection = @{
   Org = $Org
   User = $User
   EncryptedPassword = $EncryptedPassword
}

Set-EdgeConnection @connection

$proxyToFind = Read-Host "Proxy to find"

$prods = @(Get-EdgeApiProduct -Params @{ expand = 'true' }).apiProduct
Write-Output ("Total Products: " + $prods.count)

$filteredProds = $prods |? { $_.proxies -contains $proxyToFind }

Write-Output ([string]::Format('Products: {0}', (ConvertTo-Json $filteredProds) ) )
