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

Function Get-EdgeAsset {
    [cmdletbinding()]
    param(
        [string]$AssetType,
        [string]$Name,
        [string]$Revision,
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

    if ($PSBoundParameters['Name']) {
      if ($PSBoundParameters['Revision']) {
        $Path = Join-Parts -Separator "/" -Parts $Name, 'revisions', $Revision
        $Options['Name'] = $Path
      }
      else {
        $Options['Name'] = $Name
      }
    }

    Write-Debug $( [string]::Format("Get-Edge{0} Options {1}", (Get-Culture).TextInfo.ToTitleCase($Collection), $(ConvertTo-Json $Options )))
    Get-EdgeObject @Options
}

