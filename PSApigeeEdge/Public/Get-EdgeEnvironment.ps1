Function Get-EdgeEnvironment {
    <#
    .SYNOPSIS
        Get one or more environments from Apigee Edge

    .DESCRIPTION
        Get one or more environments from Apigee Edge

    .PARAMETER Name
        The name of the environment to retrieve.
        The default is to list all environments.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeEnvironment -Org cap500

    .EXAMPLE
        Get-EdgeEnvironment -Org cap500 -Name test

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$Org,
        [Hashtable]$Params
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    
    $Options = @{
        Collection = 'environments'
    }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    
    if ($PSBoundParameters['Name']) {
        $Options.Add( 'Name', $Name )
    }

    Write-Debug ( "Options @Options`n" )

    Get-EdgeObject @Options
}
