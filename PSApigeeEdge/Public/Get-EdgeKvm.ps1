Function Get-EdgeKvm {
    <#
    .SYNOPSIS
        Get one or more Key-Value Maps (KVMs) from Apigee Edge.

    .DESCRIPTION
        Get one or more Key-Value Maps (KVMs) from Apigee Edge.

    .PARAMETER Name
        Optional. The name of the KVM to retrieve.
        The default is to list all apiproxies.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .PARAMETER Env
        Optional. The Apigee Edge environment. The default is to use the organization-wide
        Key-Value Map.

    .EXAMPLE
        Get-EdgeKvm -Env test

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$Org,
        [string]$Env
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    
    $Options = @{ Collection = 'keyvaluemaps' }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    
    if ($PSBoundParameters['Env']) {
        $Path = Join-Parts -Separator "/" -Parts 'e', $Env
    }
    if ($PSBoundParameters['Name']) {
        $Options.Add( 'Name', $Name )
    }

    Write-Debug ( "Options @Options`n" )

    Get-EdgeObject @Options
}
