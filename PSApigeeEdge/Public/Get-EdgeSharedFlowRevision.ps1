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

Function Get-EdgeSharedFlowRevision {
    <#
    .SYNOPSIS
        Get the list of revisions for a sharedflow from Apigee Edge.

    .DESCRIPTION
        Get the list of revisions for a sharedflow from Apigee Edge.

    .PARAMETER Name
        Required. The name of the sharedflow to retrieve.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeSharedFlowRevision -Name common-error-handling

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Org
    )
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    @( Get-EdgeAssetRevision -AssetType 'sharedflows' -Name $Name -Org $Org )
}
