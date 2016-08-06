Function Get-EdgeApiProduct {
    <#
    .SYNOPSIS
        Get one or more api products from Apigee Edge

    .DESCRIPTION
        Get one or more api products from Apigee Edge

    .PARAMETER Name
        The name of the apiproduct to retrieve.
        The default is to list all apiproducts.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .PARAMETER Params
        Hash table with query options for the specific collection type

        Example for getting all details of apiproducts:
            -Params @{
                expand  = 'true'
            }

    .EXAMPLE
        Get-EdgeApiProduct -Org cap500

    .EXAMPLE
        Get-EdgeApiProduct -Params @{ expand = 'true' }

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Org,
        [string]$Name,
        [Hashtable]$Params
    )
    
    $Options = @{
        Collection = 'apiproducts'
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
