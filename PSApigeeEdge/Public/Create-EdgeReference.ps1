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

Function Create-EdgeReference {
    <#
    .SYNOPSIS
        Create a reference in Apigee Edge.

    .DESCRIPTION
        Create a reference in Apigee Edge. A reference points to something else, usually a keystore.

    .PARAMETER Name
        Required. The name to give to this new reference. It must be unique among references in the environment.

    .PARAMETER Environment
        Required. The name of the environment in which to create the reference.

    .PARAMETER Refers
        Required. The name of the thing this reference refers to.  Usually the name of a keystore in the environment.

    .PARAMETER ResourceType
        Optional. Defaults to KeyStore. There's really only one valid value, at this time.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Create-EdgeReference -Name ks-ref1 -Environment test

    .LINK
        Get-EdgeKeystore

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Environment,
        [Parameter(Mandatory=$True)][string]$Refers,
        [Parameter(Mandatory=$False)][string]$ResourceType,
        [string]$Org
    )

    $Options = @{ }

    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }

    if (!$PSBoundParameters['Environment']) {
      throw [System.ArgumentNullException] "Environment", "You must specify the -Environment option."
    }
    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Refers']) {
      throw [System.ArgumentNullException] "Name", "You must specify the -Refers option."
    }

    $Options['Collection'] = $(Join-Parts -Separator "/" -Parts 'e', $Environment, 'references' )

    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    $Payload = @{
      name = $Name
      refers = $Refers
      resourceType = if ($PSBoundParameters['ResourceType']) { $ResourceType } else { "KeyStore" }
    }
    $Options.Add( 'Payload', $Payload )

    Send-EdgeRequest @Options
}
