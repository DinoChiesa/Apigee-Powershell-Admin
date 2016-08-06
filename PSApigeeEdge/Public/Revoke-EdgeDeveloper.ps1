Function Revoke-EdgeDeveloper {
    <#
    .SYNOPSIS
        Revoke a developer in Apigee Edge.

    .DESCRIPTION
        Set the status of the developer to 'Inactive', which means none of the credentials
        belonging to this developer will be treated as valid, at runtime. 

    .PARAMETER Name
        The email or id of the Developer to revoke. 

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Revoke-EdgeDeveloper -Name Elaine@example.org

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Org
    )
    
    if (!$PSBoundParameters['Name']) {
       throw [System.ArgumentNullException] 'the -Name parameter is required.'
    }
    
    $Options = @{
       Collection = 'developers' 
       Name = $Name
       NoAccept = 'true'
       QParams = $( ConvertFrom-Hashtable @{ action = 'inactive' } )
    }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }

    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    Send-EdgeRequest @Options
}
