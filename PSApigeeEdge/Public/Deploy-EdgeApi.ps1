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

Function Deploy-EdgeApi {
    <#
    .SYNOPSIS
        Deploy an apiproxy in Apigee Edge.

    .DESCRIPTION
        Deploy a revision of an API proxy that is not yet deployed.

    .PARAMETER Name
        Required. The name of the apiproxy to deploy.

    .PARAMETER Environment
        Required. The name of the environment to which to deploy the api proxy.

    .PARAMETER Revision
        Required. The revision of the apiproxy.

    .PARAMETER Basepath
        Optional. The basepath to prepend to the proxy endpoints in the API proxy bundle.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Deploy-EdgeApi -Name oauth2-pwd-cc -Environment test -Revision 8

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Environment,
        [Parameter(Mandatory=$True)][string]$Revision,
        [string]$Org,
        [string]$Basepath,
        [Hashtable]$Params
    )

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    Deploy-EdgeAsset -AssetType 'apis' -Name $Name -Environment $Environment -Revision $Revision -Org $Org -Basepath $Basepath -Params $Params
}
