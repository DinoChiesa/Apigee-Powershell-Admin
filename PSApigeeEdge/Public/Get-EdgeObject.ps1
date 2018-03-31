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

Function Get-EdgeObject {
    <#
.SYNOPSIS
Get one or more objects from Apigee Edge.

.DESCRIPTION
Get one or more objects from Apigee Edge, such as developers, apis, apiproducts.
This is a lower-level cmdlet. You may want to try the higher-level cmdlets like
Get-EdgeApi or Get-EdgeDeveloper, etc.

.PARAMETER Collection
Type of object to query for.

Example: 'developers', 'apis', 'caches', or 'apiproducts'

.PARAMETER Name
Name of the object to retrieve.

.PARAMETER Org
Optional. The Apigee Edge organization.

.PARAMETER Environment
The Apigee Edge environment. This parameter does not apply to all object types.
It applies to 'caches' and 'kvms' but not developers or apis.

.PARAMETER Params
Hash table with query options for the specific collection type.

.EXAMPLE
Get-EdgeObject -Collection developers -Org cap500

# List developers on Edge organization 'cap500'

.EXAMPLE
Get-EdgeObject -Collection developers -Org cap500 -Params @{ expand='true' }

.FUNCTIONALITY
ApigeeEdge

#>

    [cmdletbinding()]
    PARAM(
        [string]$Collection,
        [string]$Name,
        [string]$Environment,
        [string]$Org,
        [Hashtable]$Params
    )
    PROCESS {
        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }

        if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']) {
            throw [System.ArgumentNullException] 'MgmtUri', "use Set-EdgeConnection to specify the Edge connection information."
        }
        $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']

        if( ! $PSBoundParameters.ContainsKey('Org')) {
            if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']) {
                throw [System.ArgumentNullException] 'Org', "use the -Org parameter to specify the organization."
            }
            $Org = $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']
        }

        if($PSBoundParameters['Environment']) {
            $PartialPath = Join-Parts -Separator '/' -Parts '/v1/o', $Org, 'e', $Environment
        }
        else {
            $PartialPath = Join-Parts -Separator '/' -Parts '/v1/o', $Org
        }

        if($PSBoundParameters['Name']) {
            $BaseUri = Join-Parts -Separator '/' -Parts $MgmtUri, $PartialPath, $Collection, $Name
        }
        else {
            $BaseUri = Join-Parts -Separator '/' -Parts $MgmtUri, $PartialPath, $Collection
        }

        Write-Debug ( "Get-EdgeObject Uri $BaseUri`n" )

        $IRMParams = @{
            Uri = $BaseUri
            Method = 'Get'
            Headers = @{
                Accept = 'application/json'
            }
        }

        Apply-EdgeAuthorization -MgmtUri $MgmtUri -IRMParams $IRMParams

        if($PSBoundParameters.ContainsKey('Params')) {
            # Invoke-RestMethod with GET applies Body as query params
            $IRMParams.Add( 'Body', $Params )
        }

        Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                      "Invoke-RestMethod parameters:$($IRMParams | Format-List | Out-String -Width 4096)" )
        Write-Debug  $( [String]::Format("Headers:{0}", $($IRMParams["Headers"] | Format-List | Out-String -Width 4096) ) )
        Try {
            $TempResult = Invoke-RestMethod @IRMParams
            Write-Debug "Raw:`n$($TempResult | Out-String)"
        }
        Catch {
            $TempResult = $_
            # $Exception = @{
            #        status = $_.Exception.Response.StatusCode.value__
            #        description = $_.Exception.Response.StatusDescription
            # }
        }
        Finally {
            Remove-Variable IRMParams
        }

        $TempResult
    }
}
