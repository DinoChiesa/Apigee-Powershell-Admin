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

Function Create-EdgeApiProduct {
    <#
    .SYNOPSIS
        Create a API Product in Apigee Edge.

    .DESCRIPTION
        Create a API Product in Apigee Edge.

    .PARAMETER Name
        The name of the product. It must be unique for the organization.

    .PARAMETER Environments
        An array of strings, the names of environments this Product should be valid for.
        Each environment must be valid. 

    .PARAMETER Proxies
        An array of strings, the names of API Proxies that should be enabled for this Product.

    .PARAMETER Approval
        Optional. The approval type for this product - either 'manual' or 'auto'.

    .PARAMETER Attributes
        Optional. Hashtable specifying custom attributes for the product. 

    .PARAMETER DisplayName
        Optional. The display name for the product. Defaults to the name. 
            
    .PARAMETER Description
        Optional. The description.
            
    .PARAMETER Scopes
        Optional. An array of strings, each one a valid scope for this product.
            
    .PARAMETER Quota
        Optional. Aa string of the form "1000pm" implying 1000 per minute, which represents the quota.
        The suffix can be 'pm', 'ph', 'pd', 'pM', for minute, hour, day, month. If not
        specified, no Quota applies. 
            
    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Create-EdgeApiProduct -Name 'Product-7' -Environments @('test') -Proxies @('oauth2-pwd-cc') -Attributes @{ CreatedBy = 'dino'; access = 'public' } -Quota 30pm


    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string[]]$Environments,
        [Parameter(Mandatory=$True)][string[]]$Proxies,
        [string]$Approval = 'auto',
        [hashtable]$Attributes,
        [string]$DisplayName,
        [string]$Description,
        [string[]]$Scopes,
        [string]$Quota,
        [string]$Org
    )
    
    $Options = @{ Collection = 'apiproducts' }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Environments']) {
      throw [System.ArgumentNullException] "Environments", "You must specify the -Environments option."
    }
    if (!$PSBoundParameters['Proxies']) {
      throw [System.ArgumentNullException] "Proxies", "You must specify the -Proxies option."
    }

    $Payload = @{
      name = $Name
      environments = $Environments
      proxies = $Proxies
      approvalType = $Approval
      apiResources = @( '/**' )
    }

    if ($PSBoundParameters['Attributes']) {
      $a = @(ConvertFrom-HashtableToAttrList -Values $Attributes)
      $Payload.Add('attributes', $a )
    }
    if ($PSBoundParameters['DisplayName']) {
      $Payload.Add('displayName', $DisplayName )
    }
    else {
      $Payload.Add('displayName', $Name )
    }
    if ($PSBoundParameters['Description']) {
      $Payload.Add('description', $Description )
    }
    if ($PSBoundParameters['Scopes']) {
      $Payload.Add('scopes', $Scopes )
    }
    if ($PSBoundParameters['Quota']) {
      $quotaInfo = ConvertFrom-StringToQuota $Quota
      $quotaInfo.getEnumerator() | Foreach-Object { $Payload[$_.Key] = $_.Value  }
    }

    $Options.Add( 'Payload', $Payload )

    Send-EdgeRequest @Options
}
