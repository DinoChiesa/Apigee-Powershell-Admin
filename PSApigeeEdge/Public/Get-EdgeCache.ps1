Function Get-EdgeCache {
    <#
    .SYNOPSIS
        Get one or more cache objects from Apigee Edge

    .DESCRIPTION
        Get one or more caches from Apigee Edge

    .PARAMETER Env
        Required. The name of the environment to search for caches.

    .PARAMETER Name
        Optional. The name of the cache to retrieve.
        The default is to list all caches

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeCache -Org cap500 -Env test

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Env,
        [string]$Name,
        [string]$Org,
        [Hashtable]$Params
    )

    if (!$PSBoundParameters['Env']) {
        throw [System.ArgumentNullException] "Env", "The -Env parameter is required."
    }
    $Options = @{ }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options['Debug'] = $Debug
    }
    if ($PSBoundParameters['Org']) {
        $Options['Org'] = $Org
    }

    $Options['Collection'] = $( Join-Parts -Separator '/' -Parts 'e', $Env, 'caches' )

    if ($PSBoundParameters['Name']) {
        $Options['Name'] = $Name
    }

    Write-Debug $( [string]::Format("Get-EdgeCache Options {0}", $(ConvertTo-Json $Options )))
    Get-EdgeObject @Options
}
