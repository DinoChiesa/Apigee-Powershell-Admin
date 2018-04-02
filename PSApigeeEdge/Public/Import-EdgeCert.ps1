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

Function Import-EdgeCert {
    <#
    .SYNOPSIS
        Import a cert into a truststore in Apigee Edge.

    .DESCRIPTION
        Import a cert into a truststore in Apigee Edge.

    .PARAMETER Environment
        Required. The environment in which the truststore is found.

    .PARAMETER Truststore
        Required. The truststore into which to import the cert.

    .PARAMETER Alias
        Required. The alias for the certificate.

    .PARAMETER CertFile
        Required. A string, the pathname to the file containing the RSA certificate.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Import-EdgeCert -Environment test -Truststore ts1 -Alias alias1 -CertFile mycert.cert

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
        [Parameter(Mandatory=$True)][string]$Truststore,
        [Parameter(Mandatory=$True)][string]$Alias,
        [Parameter(Mandatory=$True)][string]$CertFile,
        [string]$Org
    )

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['Environment']) {
      throw [System.ArgumentNullException] "Environment", "You must specify the -Environment option."
    }
    if (!$PSBoundParameters['Truststore']) {
      throw [System.ArgumentNullException] "Truststore", "You must specify the -Truststore option."
    }
    if (!$PSBoundParameters['Alias']) {
      throw [System.ArgumentNullException] "Alias", "You must specify the -Alias option."
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

    $BaseUri = Join-Parts -Separator "/" -Parts $MgmtUri, '/v1/o', $Org, 'e', $Environment, 'keystores', $Truststore, 'aliases'

    $boundary = [System.Guid]::NewGuid().ToString()
    $QParams = $( ConvertFrom-HashtableToQueryString @{ alias = $Alias ; format = "keycertfile" } )
    $BaseUri = "${BaseUri}?${QParams}"
    $IRMParams = @{
        Method = 'POST'
        Uri = $BaseUri
        Headers = @{
            Accept = 'application/json'
        }
        ContentType = "multipart/form-data; boundary=`"$boundary`""
    }
    Apply-EdgeAuthorization -MgmtUri $MgmtUri -IRMParams $IRMParams

    Try {
        # PS v3.0 does not include "builtin" support for multipart-form
        $certFileContent = [System.IO.File]::ReadAllText( $( Resolve-Path $CertFile ) )
        $keyFileContent = [System.IO.File]::ReadAllText( $( Resolve-Path $KeyFile ) )
        $LF = "`r`n"
        $bodyLines = [System.Collections.ArrayList]@()
        [void]$bodyLines.Add("--$boundary")
        [void]$bodyLines.Add("Content-Disposition: form-data; name=`"certFile`"; filename=`"file.cert`"")
        [void]$bodyLines.Add("Content-Type: application/octet-stream$LF")
        [void]$bodyLines.Add( $certFileContent )
        [void]$bodyLines.Add("--$boundary--$LF")

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
