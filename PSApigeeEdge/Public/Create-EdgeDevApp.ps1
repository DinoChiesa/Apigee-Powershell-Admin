Function Create-EdgeDevApp {
    <#
    .SYNOPSIS
        Create a developer app in Apigee Edge.

    .DESCRIPTION
        Create a developer app in Apigee Edge. This will generate a single
        credential for the app, with a list of api Products and optionally an expiry. 

    .PARAMETER Name
        The name of the app. It must be unique for this developer. 

    .PARAMETER Developer
        The id or email of the developer for which to create the app.

    .PARAMETER ApiProducts
        An array of strings, the names of API Products that should be enabled for the
        first credential created for this app.

    .PARAMETER Expiry
        Optional. The expiry for the first credential that will be created for this app.
        This is a string representing the number of seconds. Or, it can be a string like '48h',
        '120m', '30d', or '2016-12-10'; these would represent 48 hours, 120 minutes, 30 days,
        or a specific date. The date should be in the future.
        The default is no expiry.

    .PARAMETER CallbackUrl
        Optional. The callback URL for this app.  Used for 3-legged OAuth. 

    .PARAMETER Attributes
        Optional. Hashtable specifying custom attributes for the app. 

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
        [string]$CallbackUrl,
        [hashtable]$Attributes,
        [string]$Org
    )
    
    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    
    if (!$PSBoundParameters['Developer']) {
      throw [System.ArgumentNullException] "Developer", "You must specify the -Developer option."
    }
    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
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
        $actualExpiry = $(Resolve-Expiry $Expiry)
        if ( $actualExpiry -lt 0 ) {
            throw [System.ArgumentOutOfRangeException] "Expiry", "Specify an expiry in the future."
        }
        $Payload.Add('keyExpiresIn', $actualExpiry )
    }
    if ($PSBoundParameters['CallbackUrl']) {
      $Payload.Add('callbackUrl', $CallbackUrl )
    }
    if ($PSBoundParameters['Attributes']) {
      $a = @(ConvertFrom-HashtableToAttrList -Values $Attributes)
      $Payload.Add('attributes', $a )
    }
    $Options.Add( 'Payload', $Payload )

    Send-EdgeRequest @Options
}
