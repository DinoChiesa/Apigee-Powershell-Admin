# Copyright 2017-2019 Google LLC.
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

Function Get-EdgeSharedFlowPolicy {
    <#
    .SYNOPSIS
        Get the list of policies for a sharedflow revision from Apigee Edge,
        or a specific policy.

    .DESCRIPTION
        Get the list of policies for a sharedflow revision from Apigee Edge,
        or a specific policy.

    .PARAMETER Name
        Required. The name of the sharedflow

    .PARAMETER Revision
        Required. The revision of the sharedflow.

    .PARAMETER Policy
        Optional. The name of the policy within the sharedflow.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeApiPolicy -Name myapiproxy -Revision 3

    .EXAMPLE
        Get-EdgeApiPolicy -Name myapiproxy -Revision 3 -Policy FC-1

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Revision,
        [string]$Policy,
        [string]$Org
    )
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    @(Get-EdgeAssetPolicy -AssetType 'apis' -Name $Name -Revision $Revision -Policy $Policy -Org $Org )
}
