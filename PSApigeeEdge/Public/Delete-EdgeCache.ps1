Function Delete-EdgeCache {
    <#
    .SYNOPSIS
        Delete a named cache from Apigee Edge.

    .DESCRIPTION
        Delete a named cache from Apigee Edge.

    .PARAMETER Name
        The name of the cache to delete.
        
    .PARAMETER Environment
        The name of the cache to delete.
        
    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeApi dino-test-2

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Environment,
        [string]$Org
    )
    
    $Options = @{ }
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }
    
    if (!$PSBoundParameters['Name']) {
        throw [System.ArgumentNullException] "The -Name parameter is required."
    }
    if (!$PSBoundParameters['Environment']) {
        throw [System.ArgumentNullException] "The -Environment parameter is required."
    }
    
    $Options['Collection'] = $(Join-Parts -Separator "/" -Parts 'e', $Environment, 'caches' )
    $Options.Add( 'Name', $Name )

    Write-Debug ( "Options @Options`n" )

    Delete-EdgeObject @Options
}
