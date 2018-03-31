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

Function Get-EdgeApiDeployment {
    <#
    .SYNOPSIS
        Get the deployment status for an apiproxy in Apigee Edge

    .DESCRIPTION
        Get the deployment status for an apiproxy in Apigee Edge

    .PARAMETER Name
        Required. The name of the apiproxy to inquire.

    .PARAMETER Revision
        Optional. The revision of the named apiproxy to inquire.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeApiDeployment -Name oauth2-pwd-cc

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Org,
        [string]$Revision,
        [Hashtable]$Params
    )

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    Get-EdgeAssetDeployment -AssetType 'apis' -Name $Name -Org $Org -Revision $Revision -Params $Params     
}
