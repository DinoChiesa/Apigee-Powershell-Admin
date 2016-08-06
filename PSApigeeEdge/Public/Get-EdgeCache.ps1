Function Get-EdgeCache {
    <#
    .SYNOPSIS
        Get one or more cache objects from Apigee Edge

    .DESCRIPTION
        Get one or more caches from Apigee Edge

    .PARAMETER Name
        The name of the cache to retrieve.
        The default is to list all caches

    .PARAMETER Environment
        Required. The name of the environment to search for caches.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeCache -Org cap500 -Env test

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Environment,
        [string]$Name,
        [string]$Org,
        [Hashtable]$Params
    )
    
    if (!$PSBoundParameters['Environment']) {
        throw [System.ArgumentNullException] "The -Environment parameter is required."
    }
    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    $Options['Collection'] = $( Join-Parts -Separator '/' -Parts 'e', $Environment, 'caches' )

    if ($PSBoundParameters['Name']) {
        $Options.Add( 'Name', $Name )
    }

    Write-Debug ( "Options @Options`n" )

    Get-EdgeObject @Options
}
