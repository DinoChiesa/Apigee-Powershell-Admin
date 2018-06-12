# Copyright 2017 Google LLC.
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

Function Delete-EdgeObject {
    <#
    .SYNOPSIS
        Delete one or more objects from Apigee Edge

    .DESCRIPTION
        Delete one or more objects from Apigee Edge, such as developers, apis, apiproducts

    .PARAMETER Collection
        Type of object to delete.

        Example: 'developers', 'apis', or 'apiproducts'

    .PARAMETER Name
        Name of the object to delete.

    .PARAMETER Org
        The Apigee Edge organization.

    .EXAMPLE
        Delete-EdgeObject -Collection apis -Name dino-test-2

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Collection,
        [string]$Name,
        [string]$Org,
        [Hashtable]$Params
    )

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
    }
    if( ! $PSBoundParameters.ContainsKey('Org')) {
      if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']) {
        throw [System.ArgumentNullException] "Org", "use the -Org parameter to specify the organization."
      }
      else {
        $Org = $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']
      }
    }

    if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']) {
      throw [System.ArgumentNullException] "MgmtUri", "use Set-EdgeConnection to specify the Edge connection information."
    }
    $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']

    $BaseUri = Join-Parts -Separator "/" -Parts $MgmtUri, '/v1/o', $Org, $Collection, $Name

    Write-Debug ( "Uri $BaseUri`n" )

    $IRMParams = @{
        Uri = $BaseUri
        Method = 'Delete'
        Headers = @{
            Accept = 'application/json'
        }
    }

    Apply-EdgeAuthorization -MgmtUri $MgmtUri -IRMParams $IRMParams

    Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                 "Invoke-RestMethod parameters:`n$($IRMParams | Format-List | Out-String)" )

    Try {
        $TempResult = Invoke-RestMethod @IRMParams
        Write-Debug "Raw:`n$($TempResult | Out-String)"
    }
    Catch {
        Throw $_
    }
    Finally {
        Remove-Variable IRMParams
    }

   $TempResult
}