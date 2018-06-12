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

Function Get-EdgeKvm {
    <#
    .SYNOPSIS
        Get one or more Key-Value Maps (KVMs) from Apigee Edge.

    .DESCRIPTION
        Get one or more Key-Value Maps (KVMs) from Apigee Edge.

    .PARAMETER Name
        Optional. The name of the specific KVM to retrieve.
        The default is to list all KVMs in scope (org or environment).

    .PARAMETER Environment
        Optional. The Apigee Edge environment. KVMs can be associated to an organization,
        an environment, or an API Proxy.  If you specify neither Environment nor Proxy, the default
        is to list or query the organization-wide Key-Value Maps.

    .PARAMETER Proxy
        Optional. The API Proxy within Apigee Edge. KVMs can be associated to an organization,
        an environment, or an API Proxy.  If you specify neither Environment nor Proxy, the default
        is to list or query the organization-wide Key-Value Maps.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeKvm -Environment test

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$Environment,
        [string]$Proxy,
        [string]$Org
        )

    $Options = @{ }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    if ($PSBoundParameters.ContainsKey('Environment') -and $PSBoundParameters.ContainsKey('Proxy')) {
        throw [System.ArgumentException] "You may specify only one of -Environment and -Proxy."
    }

    if ($PSBoundParameters['Environment']) {
        $Options['Collection'] = $(Join-Parts -Separator "/" -Parts 'e', $Environment, 'keyvaluemaps' )
    }
    elseif ($PSBoundParameters['Proxy']) {
        $Options['Collection'] = $(Join-Parts -Separator "/" -Parts 'apis', $Proxy, 'keyvaluemaps' )
    }
    else {
         $Options['Collection'] = 'keyvaluemaps'
    }

    if ($PSBoundParameters['Name']) {
        $Options.Add( 'Name', $Name )
    }

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )

    Get-EdgeObject @Options
}
