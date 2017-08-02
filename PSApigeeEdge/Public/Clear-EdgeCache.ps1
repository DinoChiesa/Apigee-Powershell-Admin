Function Clear-EdgeCache {
    <#
    .SYNOPSIS
        Clear the entries in a cache in Apigee Edge.

    .PARAMETER Name
        The name of the cache to clear.

    .PARAMETER Environment
        The Edge environment that contains the named cache.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Clear-EdgeCache -Name cache101 -Environment test

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Environment,
        [string]$Org
    )


    if (!$PSBoundParameters['Name']) {
        throw [System.ArgumentNullException] "Name", "The -Name parameter is required."
    }
    if (!$PSBoundParameters['Environment']) {
        throw [System.ArgumentNullException] "Environment", "The -Environment parameter is required."
    }

    $Options = @{
       Collection = $( Join-Parts -Separator "/" -Parts 'e', $Environment, 'caches', $Name )
       Name = 'entries'
       NoAccept = 'true'
       ContentType = 'application/octet-stream'
       QParams = $( ConvertFrom-HashtableToQueryString @{ action = 'clear' } )
    }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }

    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    Send-EdgeRequest @Options
}
