Function Get-EdgeApi {
    <#
    .SYNOPSIS
        Get one or more apiproxies from Apigee Edge

    .DESCRIPTION
        Get one or more apiproxies from Apigee Edge

    .PARAMETER Name
        The name of the apiproxy to retrieve.
        The default is to list all apiproxies.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .PARAMETER Params
        Hash table with query options for the specific collection type

        Example for getting all details of developers:
            -Params @{
                expand  = 'true'
            }

    .EXAMPLE
        Get-EdgeApi -Org cap500

    .EXAMPLE
        Get-EdgeApi -Params @{ expand = 'true' }

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Org,
        [string]$Name,
        [string]$Revision,
        [Hashtable]$Params
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
    if ($PSBoundParameters['Params']) {
        $Options.Add( 'Params', $Params )
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
