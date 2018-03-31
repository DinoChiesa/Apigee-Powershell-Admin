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

Function Get-EdgeCache {
    <#
    .SYNOPSIS
        Get one or more cache objects from Apigee Edge

    .DESCRIPTION
        Get one or more caches from Apigee Edge

    .PARAMETER Environment
        Required. The name of the environment to search for caches.

    .PARAMETER Name
        Optional. The name of the cache to retrieve.
        The default is to list all caches.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeCache -Org cap500 -Environment test

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Environment,
        [string]$Name,
        [string]$Org,
        [Hashtable]$Params
    )

    if (!$PSBoundParameters['Environment']) {
        throw [System.ArgumentNullException] "Environment", "The -Environment parameter is required."
    }
    $Options = @{ }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options['Debug'] = $Debug
    }
    if ($PSBoundParameters['Org']) {
        $Options['Org'] = $Org
    }

    $Options['Collection'] = $( Join-Parts -Separator '/' -Parts 'e', $Environment, 'caches' )

    if ($PSBoundParameters['Name']) {
        $Options['Name'] = $Name
    }

    Write-Debug $( [string]::Format("Get-EdgeCache Options {0}", $(ConvertTo-Json $Options )))
    Get-EdgeObject @Options
}
