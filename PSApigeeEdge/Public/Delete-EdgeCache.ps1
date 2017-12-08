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

Function Delete-EdgeCache {
    <#
    .SYNOPSIS
        Delete a named cache from Apigee Edge.

    .DESCRIPTION
        Delete a named cache from Apigee Edge.

    .PARAMETER Name
        Required. The name of the cache to delete.

    .PARAMETER Environment
        Required. The Edge environment that contains the named cache.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeCache -Environment test  cache101

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Environment,
        [string]$Org
    )

    $Options = @{ }
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options['Debug'] = $Debug
    }
    if ($PSBoundParameters['Org']) {
        $Options['Org'] = $Org
    }

    if (!$PSBoundParameters['Name']) {
        throw [System.ArgumentNullException] "Name", "The -Name parameter is required."
    }
    if (!$PSBoundParameters['Environment']) {
        throw [System.ArgumentNullException] "Environment", "The -Environment parameter is required."
    }

    $Options['Collection'] = $(Join-Parts -Separator "/" -Parts 'e', $Environment, 'caches' )
    $Options['Name'] = $Name

    Write-Debug $( [string]::Format("Delete-EdgeCache Options {0}", $(ConvertTo-Json $Options )))
    Delete-EdgeObject @Options
}
