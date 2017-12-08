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

Write-Output "Copy KVM entries from one KVM to another"

Function Convert-ArrayOfNameValuePairsToHashtable {
    param($a)
    $table = @{}
    for ( $i = 0; $i -lt $a.Length; $i++ ) {
        $table.Add($a[$i].name,$a[$i].value);
    }
    $table
}

function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}

Function Validate-Environment ($Name) {
    $env = $(get-EdgeEnvironment -Name $Name)
    if ( $env.status -eq 404 ) {
        throw [System.ArgumentException] [string]::Format("The environment '{0}' does not exist.", $Name)
    }
}

$Org = Read-Host "Edge org?"
$User = Read-Host "Edge admin user?"  # eg, 'dchiesa@google.com'
$SecurePass = Read-Host -assecurestring "`nPassword for $User"
$EncryptedPassword = ConvertFrom-SecureString $SecurePass

$connection = @{
   Org = $Org
   User = $User
   EncryptedPassword = $EncryptedPassword
}

Set-EdgeConnection @connection

$sourceEnvironment = Read-Host "`nSource Environment"
Validate-Environment $sourceEnvironment

$availableKvms = $(get-edgekvm -Environment $sourceEnvironment)
$counter = 1
$availableKvms | foreach { write-output ([string]::Format('{0}. {1}', $counter++, $_)) }

$sourceMap = Read-Host "`nSource Map"

if ( Is-Numeric $sourceMap ) {
    $intval = [convert]::ToInt32($sourceMap, 10) - 1
    if ( $intval -ge 0 -and $intval -lt $availableKvms.Length) {
        $sourceMap = $availableKvms[$intval]
    }
    else {
        throw [System.ArgumentException] "You must enter a valid Source Map."
    }
}

if ( !( $availableKvms -contains $sourceMap ) ) {
    throw [System.ArgumentException] "You must enter a valid Source Map."
}

$kvmEntity = $(get-edgekvm -Environment $sourceEnvironment -Name $sourceMap)

if ( $kvmEntity.encrypted ) {
    throw [System.ArgumentException] "It is not possible to copy the contents of an encrypted Map."
}

$destEnvironment = Read-Host "`nDestination Environment"
Validate-Environment $destEnvironment

$destMap = Read-Host "`nDestination Map to Create"

$valuesHt = Convert-ArrayOfNameValuePairsToHashtable $kvmEntity.entry

#Write-Output ([string]::Format('KVM values HT: {0}', (ConvertTo-Json $ht) ) )

$Params = @{
    Name = $destMap
    Environment = $destEnvironment
    Values = $valuesHt
    # Debug = $true
}

$newKvm = Create-EdgeKvm @Params

Write-Output ([string]::Format('New KVM: {0}', (ConvertTo-Json $newKvm) ) )
