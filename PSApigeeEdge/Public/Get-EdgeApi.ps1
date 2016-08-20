Function Get-EdgeApi {
    <#
    .SYNOPSIS
        Get one or more apiproxies from Apigee Edge.

    .DESCRIPTION
        Get one or more apiproxies from Apigee Edge.

    .PARAMETER Name
        Optional. The name of the apiproxy to retrieve.
        The default is to list all apiproxies.

    .PARAMETER Revision
        Optional. The revision of the apiproxy. Use only when also using the -Name option.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeApi -Org cap500

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Org,
        [string]$Name,
        [string]$Revision
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    
    $Options = @{
        Collection = 'apis'
    }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    
    if ($PSBoundParameters['Name']) {
      if ($PSBoundParameters['Revision']) {
        $Path = Join-Parts -Separator "/" -Parts $Name, 'revisions', $Revision
        $Options.Add( 'Name', $Path )
      }
      else {
        $Options.Add( 'Name', $Name )
      }
    }

    Write-Debug ( "Options @Options`n" )

    Get-EdgeObject @Options
}
