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

Function Get-EdgeAssetRevision {
    <#
    .SYNOPSIS
        Get the list of revisions for an apiproxy or sharedflow from Apigee Edge.
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$AssetType,
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Org
    )

    if (!$PSBoundParameters['AssetType']) {
      throw [System.ArgumentNullException] "AssetType", "You must specify the -AssetType option."
    }
    
    $Options = @{ Collection = $AssetType }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options['Debug'] = $Debug
    }
    if ($PSBoundParameters['Org']) {
        $Options['Org'] = $Org
    }

    if (!$PSBoundParameters['Name']) {
        throw [System.ArgumentNullException] "Name", 'the -Name parameter is required.'
    }
    $Options['Name'] = $( Join-Parts -Separator "/" -Parts $Name, 'revisions' )

    Write-Debug $( [string]::Format("Get-EdgeAssetRevision Options {0}", $(ConvertTo-Json $Options )))
    @( Get-EdgeObject @Options )
}
