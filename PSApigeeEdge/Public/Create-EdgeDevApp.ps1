Function Create-EdgeDevApp {
    <#
    .SYNOPSIS
        Get one or more developer apps from Apigee Edge

    .DESCRIPTION
        Get one or more developer apps from Apigee Edge

    .PARAMETER Name
        The name of the app. It must be unique for this developer. 

    .PARAMETER Developer
        The id or email of the developer for which to create the app.

    .PARAMETER ApiProducts
        An array of strings, the names of API Products that should be enabled for this app.

    .PARAMETER Expiry
        The expiry for the key. This can be a string like '90d' or '120m', or a date like '2016-12-10'.
        The default is no expiry.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Create-EdgeDevApp -Name abcdefg-1 -Developer Elaine@example.org

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Developer,
        [Parameter(Mandatory=$True)][string[]]$ApiProducts,
        [string]$Expiry,
        [string]$Org,
        [Hashtable]$Params
    )
    
    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    
    if (!$PSBoundParameters['Developer']) {
      throw [System.ArgumentNullException] "You must specify the -Developer option."
    }
    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "You must specify the -Name option."
    }

    $coll = Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps'
    $Options.Add( 'Collection', $coll )
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    $Payload = @{
      name = $Name
      apiProducts = $ApiProducts
    }

    if ($PSBoundParameters['Expiry']) {
      $Payload.Add('keyExpiresIn', $(Resolve-Expiry $Expiry) )
    }
    $Options.Add( 'Payload', $Payload )

    Send-EdgeRequest @Options
}
