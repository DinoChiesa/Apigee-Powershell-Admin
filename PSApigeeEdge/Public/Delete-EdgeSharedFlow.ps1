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

Function Delete-EdgeSharedFlow {
    <#
    .SYNOPSIS
        Delete a sharedflow, or a revision of a sharedflow, from Apigee Edge.

    .DESCRIPTION
        Delete a sharedflow, or a revision of a sharedflow, from Apigee Edge.

    .PARAMETER Name
        Required. The name of the sharedflow to delete.
        
    .PARAMETER Revision
        Optional. The revision to delete. If not specified, all revisions will be deleted.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeSharedFlow common-error-handling

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Revision,
        [string]$Org
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    Delete-EdgeAsset -AssetType 'sharedflows' -Name $Name -Revision $Revision -Org $Org
}
