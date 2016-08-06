Function Add-EdgeAppCredential {
    <#
    .SYNOPSIS
        Add a new credential to an existing developer app.

    .DESCRIPTION
        Add a new credential to an existing developer app.

    .PARAMETER Name
        The name of the developer app to which the credential will be added.
        You must also specify -Developer when using this option. 

    .PARAMETER Developer
        The id or email of the developer that owns the app to which the credential will be added.
        Use this when employing the -Name option. 

    .PARAMETER ApiProducts
        An array of strings, the names of API Products that should be enabled for this credential.

    .PARAMETER Expiry
        Optional. The expiry for the credential. This can be a string like '90d' or '120m',
        or like '2016-12-10'.
        The default is no expiry.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .PARAMETER Params
        The id of the developer app to retrieve.
        
    .EXAMPLE
        Add-EdgeAppCredential -Name DPC6 -Developer dchiesa@example.org -Expiry '2016-12-10' -ApiProducts @( 'Product-7' )

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Position=0,
         Mandatory=$True,
         ValueFromPipeline=$True)]
        [string]$Name,
        
        [Parameter(Position=1,
         Mandatory=$True,
         ValueFromPipeline=$True)]
        [string]$Developer,

        [Parameter(Mandatory=$True)][string[]]$ApiProducts,

        [string]$Expiry,

        [string]$Org
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
    
    $Options.Add( 'Collection', $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps' ) )
    $Options.Add( 'Name', $Name )

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
