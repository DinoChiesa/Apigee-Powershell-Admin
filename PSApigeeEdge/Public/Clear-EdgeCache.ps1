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

Function Clear-EdgeCache {
    <#
    .SYNOPSIS
        Clear the entries in a cache in Apigee Edge.

    .PARAMETER Name
        The name of the cache to clear.

    .PARAMETER Environment
        The Edge environment that contains the named cache.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Clear-EdgeCache -Name cache101 -Environment test

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Environment,
        [string]$Org
    )


    if (!$PSBoundParameters['Name']) {
        throw [System.ArgumentNullException] "Name", "The -Name parameter is required."
    }
    if (!$PSBoundParameters['Environment']) {
        throw [System.ArgumentNullException] "Environment", "The -Environment parameter is required."
    }

    $Options = @{
       Collection = $( Join-Parts -Separator "/" -Parts 'e', $Environment, 'caches', $Name )
       Name = 'entries'
       NoAccept = 'true'
       ContentType = 'application/octet-stream'
       QParams = $( ConvertFrom-HashtableToQueryString @{ action = 'clear' } )
    }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }

    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    Send-EdgeRequest @Options
}
