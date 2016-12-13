Function Get-EdgeDeveloper {
    <#
    .SYNOPSIS
        Get one or more developers from Apigee Edge

    .DESCRIPTION
        Get one or more developers from Apigee Edge

    .PARAMETER Name
        Optional. The name of the developer to retrieve.
        The default is to list all developers.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .PARAMETER Params
        Hash table with query options for the specific collection type

        Example for getting all details of developers:
            -Params @{
                expand  = 'true'
            }

    .EXAMPLE
        Get-EdgeDeveloper -Org cap500

    .EXAMPLE
        Get-EdgeDeveloper -Params @{ expand = 'true' }

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$Org,
        [Hashtable]$Params
    )
    
    $Options = @{
        Collection = 'developers'
    }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Params']) {
        $Options.Add( 'Params', $Params )
    }
    if ($PSBoundParameters['Name']) {
        $Options.Add( 'Name', $Name )
    }

    Get-EdgeObject @Options
}
