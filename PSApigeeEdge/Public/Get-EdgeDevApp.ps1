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

Function Get-EdgeDevApp {
    <#
    .SYNOPSIS
        Get one or more developer apps from Apigee Edge.

    .DESCRIPTION
        Get one or more developer apps from Apigee Edge.

    .PARAMETER AppId
        The id of the developer app to retrieve.
        The default is to list all developer app IDs.
        Do not specify this if specifying -AppName.

    .PARAMETER AppName
        The name of the particular developer app to retrieve. You must specify -Developer when
        using this option. 

    .PARAMETER Developer
        The id or email of the developer for which to retrieve apps.
        The default is to list apps for all developers.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        $appset = @( Get-EdgeDevApp -Params @{ expand = $True } )

    .EXAMPLE
        Get-EdgeDevApp -Org cap500

    .EXAMPLE
        Get-EdgeDevApp -Id 32ae4dbe-2e39-4225-b994-242042089723

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    PARAM(
        [string]$AppId,
        [string]$AppName,
        [string]$Developer,
        [string]$Org,
        [Hashtable]$Params
    )
    
    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Params']) {
        $Options.Add( 'Params', $Params )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    if ($PSBoundParameters['Developer']) {
        $Options.Add( 'Collection', $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps' ) )
        if ($PSBoundParameters['AppName']) {
            $Options.Add( 'Name', $AppName )
        }
    }
    else {
        $Options.Add( 'Collection', 'apps')
        if ($PSBoundParameters['AppId']) {
            $Options.Add( 'Name', $AppId )
        }
    }

    Get-EdgeObject @Options
}
