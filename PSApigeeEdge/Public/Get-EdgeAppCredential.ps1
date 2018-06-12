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

Function Get-EdgeAppCredential {
    <#
    .SYNOPSIS
        Get the list of credentials for a developer app.

    .DESCRIPTION
        Get the list of credentials for a developer app. You can also
        use the Get-EdgeDevApp cmdlet to inquire the entire app, and then
        examine the credentials property on the result. This is a shortcut command
        to retrieve only the credentials.

    .PARAMETER AppId
        Optional. The id of the developer app to retrieve. You need to specify either AppId
        or AppName and Developer to uniquely identify the app.

    .PARAMETER AppName
        Optional. The name of the developer app to retrieve.

    .PARAMETER Name
        Optional. Synonym for AppName.

    .PARAMETER Developer
        Optional. The id or email of the developer that owns the app to retrieve.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeAppCredential -AppId cc631102-80cd-4491-a99a-121cec08e0bb

    .EXAMPLE
        Get-EdgeAppCredential -AppName TestApp_2 -Developer dchiesa@apigee.com

    .LINK
        Get-EdgeDevApp

    .LINK
        Add-EdgeAppCredential

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    param(
        [string]$AppName,
        [string]$Name,
        [string]$AppId,
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

    if ((!$PSBoundParameters['AppName'] -and !$PSBoundParameters['Name'] -and ! $PSBoundParameters['AppId']) -or
      (($PSBoundParameters['AppName'] -or $PSBoundParameters['Name']) -and $PSBoundParameters['AppId'])) {
      throw [System.ArgumentNullException] "AppName", "You must specify exactly one of -AppName or -AppId."
    }

    if ($PSBoundParameters['AppId']) {
        $Options.Add( 'Collection', 'apps')
        $Options.Add( 'Name', $AppId )
    }
    else {
        if (!$PSBoundParameters['Developer']) {
            throw [System.ArgumentNullException] "Developer", "You must specify the -Developer option with -AppName."
        }
        $RealAppName = if ($PSBoundParameters['AppName']) { $AppName } else { $Name }
        $Options.Add( 'Collection', $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps' ) )
        $Options.Add( 'Name', $RealAppName )
    }

    $TempResult = Get-EdgeObject @Options
    if ($TempResult.credentials) {
        $TempResult.credentials
    }
    else {
        $TempResult
    }
}
