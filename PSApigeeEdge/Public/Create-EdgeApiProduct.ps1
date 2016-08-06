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
            
    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Create-EdgeApiProduct @{
             Name='Product-7'
             Enviroments=@('test')
             Proxies=@('oauth2-pwd-cc')
             Attributes=@{ CreatedBy = 'dino' }
        }

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

    $Payload = @{
      name = $Name
      environments = $Environments
      proxies = $Proxies
      approvalType = $Approval
      apiResources = @( '/**' )
    }

    if ($PSBoundParameters['Attributes']) {
      $a = ConvertFrom-HashtableToAttrList -Values $Attributes
      $Payload.Add('attributes', $a )
    }
    if ($PSBoundParameters['DisplayName']) {
      $Payload.Add('displayName', $DisplayName )
    }
    if ($PSBoundParameters['Description']) {
      $Payload.Add('description', $Description )
    }
    $Options.Add( 'Payload', $Payload )

    Send-EdgeRequest @Options
}
