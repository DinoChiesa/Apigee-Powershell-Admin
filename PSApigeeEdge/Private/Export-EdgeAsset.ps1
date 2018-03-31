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

Function Export-EdgeAsset {

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Revision,
        [Parameter(Mandatory=$True)][string]$UriPathElement,
        [Parameter(Mandatory=$True)][string]$Dest,
        [Parameter(Mandatory=$True)][string]$Org
    )

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']) {
      throw [System.ArgumentNullException] 'MgmtUri', 'use Set-EdgeConnection to specify the Edge connection information.'
    }
    $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']

    $BaseUri = Join-Parts -Separator '/' -Parts $MgmtUri, '/v1/o', $Org, $UriPathElement, $Name, 'revisions', $Revision
    Write-Debug "BaseUri: $BaseUri"

    $IRMParams = @{
        Uri = "${BaseUri}?format=bundle"
        Method = 'GET'
        Headers = @{ }
        OutFile = $Dest
    }

    Apply-EdgeAuthorization -MgmtUri $MgmtUri -IRMParams $IRMParams

    Try {
        $TempResult = Invoke-WebRequest @IRMParams -UseBasicParsing
        Write-Debug "Raw:`n$($TempResult | Out-String)"
    }
    Catch {
        Throw $_
    }
    Finally {
        Remove-Variable IRMParams
    }

    $Dest
}
