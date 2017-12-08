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

Function Create-EdgeKvm {
    <#
    .SYNOPSIS
        Create a named key-value map in Apigee Edge.

    .DESCRIPTION
        Create a named key-value map in Apigee Edge.

    .PARAMETER Name
        The name of the key-value map to create. It must be unique for the scope
        (organization or environment).

    .PARAMETER Values
        Optional. A hashtable specifying key/value pairs. Use in lieu of the -Source option.
        Example:
          @{
            key1 = 'value1'
            key2 = 'value2'
          }

    .PARAMETER Source
        Optional. A file containing JSON that specifis key/value pairs.  Use in
        lieu of the -Values option. Example contents:
          {
            "key1" : "value1",
            "key2" : "value2"
          }

    .PARAMETER Environment
        Optional. A string, the name of the environment within Apigee Edge with which to associate
        this keyvaluemap. KVMs can be associated to an organization, an environment, or an API
        Proxy. If you specify neither Environment nor Proxy, the default is to associate the KVM with
        the organization.

    .PARAMETER Proxy
        Optional. A string, the name of the API Proxy within Apigee Edge with which to associate
        this keyvaluemap. KVMs can be associated to an organization, an environment, or an API
        Proxy. If you specify neither Environment nor Proxy, the default is to associate the KVM with
        the organization.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .PARAMETER Encrypted
        Optional. Whether to create an encrypted KVM or not. Defaults to false.

    .EXAMPLE
        Create-EdgeKvm -Name kvm101 -Environment test -Values @{ key1 = 'value1'; key2 = 'value2' }

    .EXAMPLE
        Create-EdgeKvm -Name kvm102 -Environment test -Encrypted

    .EXAMPLE
        Create-EdgeKvm -Name proxy-specific-kvm -Proxy api101 -Encrypted

    .EXAMPLE
        Create-EdgeKvm -Name kvm104 -Environment test -Source .\myfile.json

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [hashtable]$Values,
        [string]$Source,
        [string]$Environment,
        [string]$Proxy,
        [string]$Org,
        [switch]$Encrypted
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

    $Payload = @{ name = $Name; encrypted = if ($Encrypted) {'true'} else {'false'} } ;

    if ($PSBoundParameters['Values']) {
      $Payload['entry'] = @( $Values.keys |% { @{ name = $_ ; value = $Values[$_] } } )
    }
    elseif ($PSBoundParameters['Source']) {
      # Read data from the JSON file
      $json = Get-Content $Source -Raw | ConvertFrom-JSON
      $Payload['entry'] = @( $json.psobject.properties.name |% {
          $value = ''
          # convert non-primitives to strings containing json
          if (($json.$_).GetType().Name -eq 'PSCustomObject') {
            $value = $($json.$_ | ConvertTo-json  -Compress ).ToString()
          }
          else {
            $value = $json.$_
          }
          @{ name =  $_ ; value = $value }
      } )
    }

    if ($PSBoundParameters['Environment']) {
      $Options['Collection'] = $( Join-Parts -Separator '/' -Parts 'e', $Environment, 'keyvaluemaps' )
    }
    elseif ($PSBoundParameters['Proxy']) {
        $Options['Collection'] = $(Join-Parts -Separator "/" -Parts 'apis', $Proxy, 'keyvaluemaps' )
    }
    else {
      $Options['Collection'] = 'keyvaluemaps'
    }

    $Options.Add( 'Payload', $Payload )

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )

    Send-EdgeRequest @Options
}
