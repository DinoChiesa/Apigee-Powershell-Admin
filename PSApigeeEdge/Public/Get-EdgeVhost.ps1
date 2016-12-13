Function Get-EdgeVhost {
    <#
    .SYNOPSIS
        Get one or more virtualhost objects from Apigee Edge

    .DESCRIPTION
        Get information about one or more virtualhosts from Apigee Edge

    .PARAMETER Name
        Optional. The name of the virtualhost to retrieve.
        The default is to list all virtualhosts.

    .PARAMETER Env
        Required. The name of the environment to search for virtualhosts.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeVhost -Org cap500 -Env test

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
        throw [System.ArgumentNullException] "The -Env parameter is required."
    }
    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    $Options['Collection'] = $( Join-Parts -Separator '/' -Parts 'e', $Env, 'virtualhosts' )

    if ($PSBoundParameters['Name']) {
        $Options.Add( 'Name', $Name )
    }

    Write-Debug ( "Options @Options`n" )

    Get-EdgeObject @Options
}
