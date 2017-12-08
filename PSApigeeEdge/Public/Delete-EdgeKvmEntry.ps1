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

Function Delete-EdgeKvmEntry {
    <#
    .SYNOPSIS
        Delete an entry from a Key-Value map in Apigee Edge.

    .DESCRIPTION
        Delete an entry from a Key-Value map in Apigee Edge.
        This works only in CPS-enabled Edge organizations.

    .PARAMETER Name
        Required. The name of the KVM from which to delete an entry.

    .PARAMETER Entry
        Required. The name of the KVM entry to delete.

    .PARAMETER Environment
        Optional. The environment with which the keyvalue map is associated. KVMs can be
        associated to an organization, an environment, or an API Proxy. If you specify
        neither Environment nor Proxy, the default is to resolve the KVM name in the list of
        organization-wide Key-Value Maps.

    .PARAMETER Proxy
        Optional. The API Proxy within Apigee Edge with which the keyvalue map is
        associated. KVMs can be associated to an organization, an environment, or an API
        Proxy. If you specify neither Environment nor Proxy, the default is to resolve the KVM name
        in the list of organization-wide Key-Value Maps.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeKvmEntry -Name kvm-2 -Environment test -Entry key1

    .LINK
        Create-EdgeKvmEntry

    .LINK
        Update-EdgeKvmEntry

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Entry,
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

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Entry']) {
      throw [System.ArgumentNullException] "Entry", "You must specify the -Entry option."
    }

    $basepath = if ($PSBoundParameters['Environment']) {
        $(Join-Parts -Separator "/" -Parts 'e', $Environment, 'keyvaluemaps' )
    }
    elseif ($PSBoundParameters['Proxy']) {
        $(Join-Parts -Separator "/" -Parts 'apis', $Proxy, 'keyvaluemaps' )
    }
    else {
        'keyvaluemaps'
    }
    $Options.Add( 'Collection', $( Join-Parts -Separator '/' -Parts $basepath, $Name, 'entries' ) )
    $Options.Add( 'Name', $Entry )

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )

    Delete-EdgeObject @Options
}
