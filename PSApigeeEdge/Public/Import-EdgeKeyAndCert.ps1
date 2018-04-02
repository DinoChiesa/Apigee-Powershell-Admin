# Copyright 2017-2018 Google Inc.
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

Function Import-EdgeKeyAndCert {
    <#
    .SYNOPSIS
        Import a key and cert into a keystore in Apigee Edge.

    .DESCRIPTION
        Import a key and cert into a keystore in Apigee Edge.

    .PARAMETER Environment
        Required. The environment in which the keystore is found.

    .PARAMETER Keystore
        Required. The keystore into which to import the key and cert.

    .PARAMETER Alias
        Required. The alias for the key/cert pair.

    .PARAMETER CertFile
        Required. A string, the pathname to the file containing the RSA certificate.

    .PARAMETER KeyFile
        Required. A string, the pathname to the file containing the RSA private key.

    .PARAMETER KeyPassword
        Optional. A string, the password to the key file. Required only if the key is encrypted.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Import-EdgeKeyAndCert -Environment test -Keystore ks1 -Alias alias1 -CertFile mycert.cert -KeyFile mykey.pem

    .LINK
        Get-EdgeKeystore

    .LINK
        Create-EdgeKeystore

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Environment,
        [Parameter(Mandatory=$True)][string]$Keystore,
        [Parameter(Mandatory=$True)][string]$Alias,
        [Parameter(Mandatory=$True)][string]$CertFile,
        [Parameter(Mandatory=$True)][string]$KeyFile,
        [Parameter(Mandatory=$False)][string]$KeyPassword,
        [string]$Org
    )

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['Keystore']) {
      throw [System.ArgumentNullException] "Keystore", "You must specify the -Keystore option."
    }
    if (!$PSBoundParameters['Environment']) {
      throw [System.ArgumentNullException] "Environment", "You must specify the -Environment option."
    }
    if (!$PSBoundParameters['Alias']) {
      throw [System.ArgumentNullException] "Alias", "You must specify the -Alias option."
    }
    if (!$PSBoundParameters['KeyFile']) {
      throw [System.ArgumentNullException] "KeyFile", "You must specify the -KeyFile option."
    }
    if (!$PSBoundParameters['CertFile']) {
      throw [System.ArgumentNullException] "CertFile", "You must specify the -CertFile option."
    }

    if( ! $PSBoundParameters.ContainsKey('Org')) {
      if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']) {
        throw [System.ArgumentNullException] 'Org', "use the -Org parameter to specify the organization."
      }
      $Org = $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']
    }

    if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']) {
      throw [System.ArgumentNullException] 'MgmtUri', "use Set-EdgeConnection to specify the Edge connection information."
    }
    $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']

    $BaseUri = Join-Parts -Separator "/" -Parts $MgmtUri, '/v1/o', $Org, 'e', $Environment, 'keystores', $Keystore, 'aliases'

    $boundary = [System.Guid]::NewGuid().ToString()

    $IRMParams = @{
        Method = 'POST'
        Uri = $BaseUri
        Params = @{
            alias = $Alias
            format= "keycertfile"
        }
        Headers = @{
            Accept = 'application/json'
        }
        ContentType = "multipart/form-data; boundary=`"$boundary`""
    }
    Apply-EdgeAuthorization -MgmtUri $MgmtUri -IRMParams $IRMParams

    Try {
        # PS v3.0 does not include "builtin" support for multipart-form
        $certFileContent = [System.IO.File]::ReadAllText($CertFile)
        $keyFileContent = [System.IO.File]::ReadAllText($KeyFile)
        $LF = "`r`n"
        $bodyLines = [System.Collections.ArrayList]@()
        $bodyLines.Add("--$boundary")
        $bodyLines.Add("Content-Disposition: form-data; name=`"certFile`"; filename=`"file.cert`"")
        $bodyLines.Add("Content-Type: application/octet-stream$LF")
        $bodyLines.Add( $certFileContent )
        $bodyLines.Add("--$boundary")
        $bodyLines.Add("Content-Disposition: form-data; name=`"keyFile`"; filename=`"file.key`"")
        $bodyLines.Add("Content-Type: application/octet-stream$LF")
        $bodyLines.Add( $keyFileContent )

        if (!$PSBoundParameters['KeyPassword']) {
            $bodyLines.Add("--$boundary")
            $bodyLines.Add("Content-Disposition: form-data; name=`"password`"")
            $bodyLines.Add( $KeyPassword )
        }
        $bodyLines.Add("--$boundary--$LF")
        $IRMParams.Add('Body', $( $bodyLines -join $LF ) )

        Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                      "Invoke-RestMethod parameters:`n$($IRMParams | Format-List | Out-String)" )

        $IRMResult = Invoke-RestMethod @IRMParams
        Write-Debug "Raw:`n$($IRMResult | Out-String)"
    }
    Catch {
        Throw $_
    }
    Finally {
        Remove-Variable IRMParams
    }

    $IRMResult
}
