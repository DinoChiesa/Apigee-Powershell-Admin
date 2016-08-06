Function Get-EdgeCache {
    <#
    .SYNOPSIS
        Get one or more cache objects from Apigee Edge

    .DESCRIPTION
        Get one or more caches from Apigee Edge

    .PARAMETER Name
        The name of the cache to retrieve.
        The default is to list all caches

    .PARAMETER Env
        The name of the environment to search for caches.
        The default is to list organization-scoped caches

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeCache -Org cap500 -Env test

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$Env,
        [string]$Org,
        [Hashtable]$Params
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    
    $Options = @{
        Collection = 'caches'
    }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    if ($PSBoundParameters['Env']) {
        $Options.Add( 'Env', $Env )
    }
    if ($PSBoundParameters['Name']) {
        $Options.Add( 'Name', $Name )
    }

    Write-Debug ( "Options @Options`n" )

    Get-EdgeObject @Options
}
