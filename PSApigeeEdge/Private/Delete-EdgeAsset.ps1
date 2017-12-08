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

Function Delete-EdgeAsset {
    <#
    .SYNOPSIS
        Delete an apiproxy or sharedflow, or a revision of same, from Apigee Edge.
    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$AssetType,
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Revision,
        [string]$Org
    )
    
    if (!$PSBoundParameters['AssetType']) {
        throw [System.ArgumentNullException] "AssetType", "You must specify the -AssetType option."
    }

    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    
    if (!$PSBoundParameters['Name']) {
        throw [System.ArgumentNullException] "Name", "The -Name parameter is required."
    }
    
    if ($PSBoundParameters['Revision']) {
        $Options.Add( 'Collection', $(Join-Parts -Separator "/" -Parts $AssetType, $Name, 'revisions' ) )
        $Options.Add( 'Name', $Revision )
    }
    else {
        $Options.Add( 'Collection', $AssetType )
        $Options.Add( 'Name', $Name )
    }

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )
    Delete-EdgeObject @Options
}
