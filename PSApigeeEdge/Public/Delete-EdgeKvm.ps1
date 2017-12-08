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

Function Delete-EdgeKvm {
    <#
    .SYNOPSIS
        Delete a key-value map from Apigee Edge.

    .DESCRIPTION
        Delete a key-value map from Apigee Edge.

    .PARAMETER Name
        Required. The name of the kvm to delete.

    .PARAMETER Environment
        Optional. The environment within Apigee Edge with which the keyvaluemap is
        associated. KVMs can be associated to an organization, an environment, or an API
        Proxy. If you specify neither Environment nor Proxy, the default is to find the named KVM in
        the list of organization-wide Key-Value Maps.

    .PARAMETER Proxy
        Optional. The API Proxy within Apigee Edge with which the keyvaluemap is
        associated. KVMs can be associated to an organization, an environment, or an API
        Proxy. If you specify neither Environment nor Proxy, the default is to find the named KVM in
        the list of organization-wide Key-Value Maps.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeKvm dino-test-2

    .EXAMPLE
        Delete-EdgeKvm -Proxy apiproxy1 -Name dino-test-3

    .LINK
        Create-EdgeKvm

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
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

    if (!$PSBoundParameters['Name']) {
        throw [System.ArgumentNullException] "Name", "The -Name parameter is required."
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
    $Options.Add( 'Name', $Name )

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )

    Delete-EdgeObject @Options
}
