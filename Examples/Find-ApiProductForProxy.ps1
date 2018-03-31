# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
