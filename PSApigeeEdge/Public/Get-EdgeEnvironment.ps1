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

Function Get-EdgeEnvironment {
    <#
    .SYNOPSIS
        Get one or more environments from Apigee Edge

    .DESCRIPTION
        Get one or more environments from Apigee Edge

    .PARAMETER Name
        The name of the environment to retrieve.
        The default is to list all environments.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeEnvironment -Org cap500

    .EXAMPLE
        Get-EdgeEnvironment -Org cap500 -Name test

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$Org,
        [Hashtable]$Params
    )

    $Options = @{
        Collection = 'environments'
    }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options['Debug'] = $Debug
    }
    if ($PSBoundParameters['Org']) {
        $Options['Org'] = $Org
    }

    if ($PSBoundParameters['Name']) {
        $Options['Name'] = $Name
    }

    Write-Debug $( [string]::Format("Get-EdgeEnvironment Options {0}", $(ConvertTo-Json $Options )))
    Get-EdgeObject @Options
}
