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

Function Update-EdgeDevAppStatus {
    <#
    .SYNOPSIS
        Approve or Revoke an existing credential, or an apiproduct on a credential, for a developer app. Or the entire app.

    .DESCRIPTION
        Approve or Revoke an existing credential from a developer app. Or, approve or revoke a specific
        API Product on a credential for a developer app. Approving an {app, credential, product} that is pending
        or has been revoked allows the {app, credential, product} to be used at runtime. Revoking same means that
        the key will be rejected at runtime. Note that the entire chain {app, credential, product } must have
        status=approved for the key to be accepted.

    .PARAMETER AppName
        Required. The name of the developer app that contains the credential to be updated.

    .PARAMETER Developer
        Required. The id or email of the developer that owns the app that contains the credential.

    .PARAMETER Action
        Required. The action to apply. Either revoke or approve.

    .PARAMETER Key
        Optional. The consumer key for the credential to be approved or revoked. If omitted, the Action
        applies to the app.

    .PARAMETER ApiProduct
        Optional. The name of the API Product to be approved or revoked. It must be present on the credential.
        This is ignored if the Key is not also passed.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Update-EdgeDevAppStatus -AppName DPC6 -Developer dchiesa@example.org -Key pd0mg1FuedmfCpY9gWZonQmR2fGD3Osw -Action revoke

    .EXAMPLE
        Update-EdgeDevAppStatus -AppName DPC6 -Developer dchiesa@example.org -Key pd0mg1FuedmfCpY9gWZonQmR2fGD3Osw -ApiProduct Product123 -Action approve

    .EXAMPLE
        Update-EdgeDevAppStatus -AppName DPC6 -Developer dchiesa@example.org -Action approve

    .LINK
        Revoke-EdgeAppCredential

    .LINK
        Approve-EdgeAppCredential

    .LINK
        Approve-EdgeDevApp

    .LINK
        Revoke-EdgeDevApp

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [string]$AppName,
        [string]$Developer,
        [string]$Key,
        [string]$ApiProduct,
        [string]$Action,
        [string]$Org
    )

    $Options = @{ }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options['Debug'] = $Debug
    }
    if ($PSBoundParameters['Org']) {
        $Options['Org'] = $Org
    }

    if (!$PSBoundParameters['Developer']) {
        throw [System.ArgumentNullException] "Developer", "You must specify the -Developer option."
    }
    if (!$PSBoundParameters['AppName']) {
      throw [System.ArgumentNullException] "AppName", "You must specify the -AppName option."
    }
    if (!$PSBoundParameters['Action']) {
      throw [System.ArgumentNullException] "Action", "You must specify the -Action option."
    }
    $Action = $Action.ToLower()
    if ($Action -ne "approve" -and $Action -ne "revoke") {
      throw [System.ArgumentException] "Action", "Action must be 'revoke' or 'approve'."
    }

    if ($PSBoundParameters['Key']) {
        if ($PSBoundParameters['ApiProduct']) {
            $Options['Collection'] = $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps', $AppName, 'keys', $Key, 'apiproducts' )
            $Options['Name'] = $ApiProduct
        }
        else {
            $Options['Collection'] = $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps', $AppName, 'keys' )
            $Options['Name'] = $Key
        }
    }
    else {
        # Just update the app status
        $Options['Collection'] = $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps' )
        $Options['Name'] = $AppName
    }
    $Options['QParams'] = $( ConvertFrom-HashtableToQueryString @{ action = $Action } )

    Write-Debug $( [string]::Format("Update-EdgeDevAppStatus Options {0}", $(ConvertTo-Json $Options )))
    Send-EdgeRequest @Options
}
