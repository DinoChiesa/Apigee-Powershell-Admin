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

Function Delete-EdgeDevApp {
    <#
    .SYNOPSIS
        Delete an developer app from Apigee Edge.

    .DESCRIPTION
        Delete an developer app from Apigee Edge.

    .PARAMETER AppName
        Required. The name of the developer app to delete.

    .PARAMETER Name
        A synonym for AppName.
        
    .PARAMETER Developer
        Required. The developer that owns the app to delete.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeDevApp -Developer dchiesa@example.org -AppName abcdfege-1

    .LINK
        Create-EdgeDevApp
        
    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$AppName,
        [Parameter(Mandatory=$True)][string]$Developer,
        [string]$Org
    )

    $Options = @{ }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }
    if (!$PSBoundParameters['Developer']) {
        throw [System.ArgumentNullException] "Developer", 'use -AppName and -Developer.'
    }
    if (!$PSBoundParameters['Name'] -and !$PSBoundParameters['AppName']) {
        throw [System.ArgumentNullException] "AppName", 'use -AppName and -Developer.'
    }
    $RealAppName = if ($PSBoundParameters['AppName']) { $AppName } else { $Name }
    $Options.Add( 'Collection', $( Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps' ))
    $Options.Add( 'Name', $AppName )

    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    
    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )
    Delete-EdgeObject @Options
}
