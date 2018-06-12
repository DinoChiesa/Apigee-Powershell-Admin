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

Function Get-EdgeAssetDeployment {
    <#
    .SYNOPSIS
        Get the deployment status for an apiproxy or sharedflow in Apigee Edge
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$AssetType,
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Org,
        [string]$Revision,
        [Hashtable]$Params
    )
    
    if (!$PSBoundParameters['AssetType']) {
      throw [System.ArgumentNullException] "AssetType", "You must specify the -AssetType option."
    }
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
    }

    $Options = @{
        Collection = $AssetType
    }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Params']) {
        $Options.Add( 'Params', $Params )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    
    if ($PSBoundParameters['Revision']) {
        $Path = Join-Parts -Separator "/" -Parts $Name, 'revisions', $Revision, 'deployments'
    }
    else {
        $Path = Join-Parts -Separator "/" -Parts $Name, 'deployments'
    }
    $Options.Add( 'Name', $Path )

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )

    if ( ! $PSBoundParameters['Revision'] ) {
        # an array of environments. Map it appropriately
        (Get-EdgeObject @Options).environment | % {
          @{ 'Environment' = $_.name; 'Revision' = $_.revision }
        }
    }
    else {
        (Get-EdgeObject @Options).environment 
    }

}
