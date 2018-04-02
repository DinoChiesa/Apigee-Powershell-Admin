# Copyright 2017-2018 Google Inc.
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

Function Get-EdgeAlias {
    <#
    .SYNOPSIS
        Get one or more aliases from a keystore or truststore in Apigee Edge.

    .DESCRIPTION
        Get one or more aliases from a keystore or truststore in Apigee Edge.

    .PARAMETER Environment
        Required. The Apigee Edge environment. Keystores or Truststores in Edge are associated to
        an environment.

    .PARAMETER Keystore
        Optional. The Keystore to inquire. You should pass one of -Keystore or -Truststore.

    .PARAMETER Truststore
        Optional. The truststore to inquire. You should pass one of -Keystore or -Truststore.

    .PARAMETER Alias
        Optional. The specific Alias. If you do not specify an Alias, the default behavior
        is to list all the aliases.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeAlias -Environment test -Keystore ks1

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Environment,
        [Parameter(Mandatory=$False)][string]$Keystore,
        [Parameter(Mandatory=$False)][string]$Truststore,
        [Parameter(Mandatory=$False)][string]$Alias,
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

    if (!$PSBoundParameters['Environment']) {
      throw [System.ArgumentNullException] "Environment", "You must specify the -Environment option."
    }
    if ($PSBoundParameters.ContainsKey('Keystore') -and $PSBoundParameters.ContainsKey('Truststore')) {
        throw [System.ArgumentException] "You may specify only one of -Keystore and -Truststore."
    }
    if (!$PSBoundParameters['Truststore']) {
        if (!$PSBoundParameters['Keystore']) {
            throw [System.ArgumentNullException] "Truststore", "You must specify either the -Truststore or the -Keystore option."
        }
    }

    $store = if ($PSBoundParameters['Truststore']) { $Truststore } else { $Keystore }

    $Options['Collection'] = $(Join-Parts -Separator "/" -Parts 'e', $Environment, 'keystores', $store, 'aliases' )

    if ($PSBoundParameters['Alias']) {
        $Options.Add( 'Name', $Alias )
    }

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )

    Get-EdgeObject @Options
}
