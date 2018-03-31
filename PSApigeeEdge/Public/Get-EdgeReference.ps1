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

Function Get-EdgeReference {
    <#
    .SYNOPSIS
        Get information about a reference from Apigee Edge.

    .DESCRIPTION
        Get information about a reference from Apigee Edge. Typically the reference points to a keystore.

    .PARAMETER Name
        Optional. The name of the specific reference to retrieve.
        The default is to list all references in the environment.

    .PARAMETER Environment
        Required. The Apigee Edge environment in which the reference is to be found.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeReference -Name ref1 -Environment test

    .EXAMPLE
        Get-EdgeReference -Environment test

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$False)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Environment,
        [string]$Org
        )

    $Options = @{ }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }

    if (!$PSBoundParameters['Environment']) {
      throw [System.ArgumentNullException] "Environment", "You must specify the -Environment option."
    }

    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    $Options.Add( 'Collection', $(Join-Parts -Separator "/" -Parts 'e', $Environment, 'references' ) )

    if ($PSBoundParameters['Name']) {
        $Options.Add( 'Name', $Name )
    }

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )

    Get-EdgeObject @Options
}
