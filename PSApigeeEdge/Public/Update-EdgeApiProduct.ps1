Function Update-EdgeApiProduct {
    <#
    .SYNOPSIS
        Update a API Product in Apigee Edge.

    .DESCRIPTION
        Update a API Product in Apigee Edge. When invoking this cmdlet you need
        to specify all the data that you would like to retain the API Product. For example,
        not specifying a Description means you will remove any previous Description
        attached to the product. Only the custom attributes you specify here will
        be retained. Not specifying an attribute of 'access' will result in the
        API Product having no access setting. SImilarly, with Scopes.

    .PARAMETER Name
        The name of the product. It must exist.

    .PARAMETER Environments
        An array of strings, the names of environments this Product should be valid for.
        Each environment must be valid. 

    .PARAMETER Proxies
        An array of strings, the names of API Proxies that should be enabled for this Product.

    .PARAMETER Approval
        Optional. The approval type for this product - either 'manual' or 'auto'.
        Defaults to 'auto'.

    .PARAMETER Attributes
        Optional. Hashtable specifying custom attributes for the product. 

    .PARAMETER DisplayName
        Optional. The display name for the product. Defaults to the name. 
            
    .PARAMETER Description
        Optional. The description. Defaults to empty.
            
    .PARAMETER Scopes
        Optional. An array of strings, each one a valid scope for this product.
        Defaults to empty. 
            
    .PARAMETER Quota
        Optional. Aa string of the form "1000pm" implying 1000 per minute, which represents the quota.
        The suffix can be 'pm', 'ph', 'pd', 'pM', for minute, hour, day, month. If not
        specified, no Quota applies. 

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Update-EdgeApiProduct -Name 'Product-7' -DisplayName 'Product-7' -Environments @('test') -Proxies @('oauth2-pwd-cc') -Attributes @{ CreatedBy = 'dino'; access = 'public' } -Description 'This is a test product'

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
        [Parameter(Mandatory=$False)][string]$DisplayName,
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
      throw [System.ArgumentNullException] "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Environments']) {
      throw [System.ArgumentNullException] "You must specify the -Environments option."
    }
    if (!$PSBoundParameters['Proxies']) {
      throw [System.ArgumentNullException] "You must specify the -Proxies option."
    }
    $Options.Add( 'Name', $Name )

    $Payload = @{
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
