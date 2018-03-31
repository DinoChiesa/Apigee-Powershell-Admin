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

Function Add-EdgeAppCredential {
    <#
    .SYNOPSIS
        Add a new credential to an existing developer app.

    .DESCRIPTION
        Add a new credential to an existing developer app.

    .PARAMETER AppName
        The name of the developer app to which the credential will be added.

    .PARAMETER Name
        Synonym for AppName.

    .PARAMETER Developer
        The id or email of the developer that owns the app to which the credential will be added.

    .PARAMETER ApiProducts
        An array of strings, the names of API Products that should be enabled for this credential.

    .PARAMETER Expiry
        Optional. The expiry for the credential. This can be a string like '90d' or '120m',
        or like '2016-12-10'.
        The default is no expiry.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Add-EdgeAppCredential -Name DPC6 -Developer dchiesa@example.org -Expiry '2016-12-10' -ApiProducts @( 'Product-7' )

    .LINK
        Get-EdgeAppCredential

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [string]$AppName,
        [string]$Name,
        [string]$Developer,

        [Parameter(Mandatory=$True)][string[]]$ApiProducts,

        [string]$Expiry,

        [string]$Org
    )


    $Options = @{ }

    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['Developer']) {
        throw [System.ArgumentNullException] "Developer", "You must specify the -Developer option."
    }

    if (!$PSBoundParameters['AppName'] -and !$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "AppName", "You must specify the -AppName option."
    }
    $RealAppName = if ($PSBoundParameters['AppName']) { $AppName } else { $Name }
    $Options.Add( 'Collection', $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps' ) )
    $Options.Add( 'Name', $RealAppName )

    $Payload = @{
      name = $RealAppName
      apiProducts = $ApiProducts
    }

    if ($PSBoundParameters['Expiry']) {
      $Payload.Add('keyExpiresIn', $(Resolve-Expiry $Expiry) )
    }

    $Options.Add( 'Payload', $Payload )

    Send-EdgeRequest @Options
}
