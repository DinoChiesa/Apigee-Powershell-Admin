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

Function UnDeploy-EdgeSharedFlow {
    <#
    .SYNOPSIS
        UnDeploy an sharedflow in Apigee Edge.

    .DESCRIPTION
        UnDeploy a revision of a sharedflow that is deployed.

    .PARAMETER Name
        Required. The name of the sharedflow to undeploy.

    .PARAMETER Environment
        Required. The name of the environment from which to undeploy the sharedflow.

    .PARAMETER Revision
        Required. The revision of the sharedflow.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        UnDeploy-EdgeSharedFlow -Name sf1a -Environment test -Revision 2

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Environment,
        [Parameter(Mandatory=$True)][string]$Revision,
        [string]$Org
    )

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    UnDeploy-EdgeAsset -AssetType 'sharedflows' -Name $Name -Environment $Environment -Revision $Revision -Org $Org
}
