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

Function Get-EdgeSharedFlow {
    <#
    .SYNOPSIS
        Get one or more sharedflows from Apigee Edge.

    .DESCRIPTION
        Get one or more sharedflows from Apigee Edge.

    .PARAMETER Name
        Optional. The name of the sharedflow to retrieve.
        The default is to list all of them.

    .PARAMETER Revision
        Optional. The revision of the sharedflow. Use only when also using the -Name option.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeSharedFlow -Org cap500

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$Revision,
        [string]$Org
    )

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    Get-EdgeAsset -AssetType 'sharedflows' -Name $Name -Revision $Revision -Org $Org
}