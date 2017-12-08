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

Function Update-EdgeAppCredential {
    <#
    .SYNOPSIS
        Update a credential in Apigee Edge, by adding or removing API Products.

    .DESCRIPTION
        Update a credential in Apigee Edge, by adding or removing API Products.
        If you want to update the status of the credential see Revoke-EdgeAppCredential or
        Approve-EdgeAppCredential .

    .PARAMETER Remove
        A flag parameter to request the removal of API products from the credential.
        Use one of -Remove or -Add, not both.

    .PARAMETER Add
        A flag parameter to request the aditionof API products to the credential.
        Use one of -Remove or -Add, not both.

    .PARAMETER AppName
        The name of the developer app to update.

    .PARAMETER Name
        A synonym for AppName.

    .PARAMETER Developer
        Required. The id or email of the developer that owns the app to be updated.

    .PARAMETER Key
        The consumer key for the credential to be updated.

    .PARAMETER ApiProducts
        An array of strings, the names of API Products that should be added or removed from this credential.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Update-EdgeAppCredential -AppName DPC6 -Developer dchiesa@example.org -Key iQGvTYtUWcWAdJ6WAJebedgLSKaVQidZ -Add -ApiProducts @( 'Product-1971' )

    .LINK
       Revoke-EdgeDevApp

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$False)]
        [switch]$Remove,

        [Parameter(Mandatory=$False)]
        [switch]$Add,
        [string]$AppName,
        [string]$Name,
        [Parameter(Mandatory=$True)][string]$Developer,
        [Parameter(Mandatory=$True)][string]$Key,

        [Parameter(Mandatory=$True)][string[]]$ApiProducts,

        [string]$Org
    )

    $Options = @{ }

    if ($PSBoundParameters['Debug']) {
        $Options['Debug'] = $Debug
    }
    if ($PSBoundParameters['Org']) {
        $Options['Org'] = $Org
    }

    if (!$PSBoundParameters['Developer']) {
        throw [System.ArgumentNullException] "Developer", "You must specify the -Developer option."
    }
    if (!$PSBoundParameters['AppName'] -and !$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "AppName", "You must specify the -AppName option."
    }
    $RealAppName = if ($PSBoundParameters['AppName']) { $AppName } else { $Name }

    if ((!$Remove -and ! $Add) -or ($Remove -and $Add)) {
      throw [System.ArgumentException] "You must specify exactly one of -Remove or -Add."
    }
    if (!$PSBoundParameters['ApiProducts']) {
      throw [System.ArgumentNullException] "ApiProducts", "You must specify the -ApiProducts option."
    }

    if ($Add) {
        $Options['Collection'] = $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps', $RealAppName, keys )
        $Options['Name'] = $Key

        $Payload = @{
          apiProducts = $ApiProducts
        }

        $Options['Payload'] = $Payload

        Write-Debug $( [string]::Format("Update-EdgeAppCredential Options {0}", $(ConvertTo-Json $Options )))
        Send-EdgeRequest @Options
    }
    else {
        # Remove, each one in series
        $ApiProducts | Foreach-Object {
            $Options['Collection'] = $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps', $RealAppName, keys, $Key, 'apiproducts' )
            $Options['Name'] = $_

            Write-Debug $( [string]::Format("Update-EdgeAppCredential Options {0}", $(ConvertTo-Json $Options )))
            Delete-EdgeObject @Options
        }
    }

}
