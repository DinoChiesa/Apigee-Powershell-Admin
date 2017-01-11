Function Delete-EdgeCache {
    <#
    .SYNOPSIS
        Delete a named cache from Apigee Edge.

    .DESCRIPTION
        Delete a named cache from Apigee Edge.

    .PARAMETER Name
        Required. The name of the cache to delete.
        
    .PARAMETER Env
        Required. The Edge environment that contains the named cache. 
        
    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeCache -Env test  cache101

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Env,
        [string]$Org
    )
    
    $Options = @{ }
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    
    if (!$PSBoundParameters['Name']) {
        throw [System.ArgumentNullException] "Name", "The -Name parameter is required."
    }
    if (!$PSBoundParameters['Env']) {
        throw [System.ArgumentNullException] "Env", "The -Env parameter is required."
    }
    
    $Options.Add( 'Collection', $(Join-Parts -Separator "/" -Parts 'e', $Env, 'caches' ) )
    $Options.Add( 'Name', $Name )

    Write-Debug ( "Options @Options`n" )

    Delete-EdgeObject @Options
}
