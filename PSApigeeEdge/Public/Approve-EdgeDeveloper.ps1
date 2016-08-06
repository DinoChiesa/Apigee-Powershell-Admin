Function Approve-EdgeDeveloper {
    <#
    .SYNOPSIS
        Approve a developer in Apigee Edge.

    .DESCRIPTION
        Set the status of the developer to 'Active', which means the credentials
        belonging to this developer will be treated as valid, at runtime. 

    .PARAMETER Name
        The email or id of the Developer to approve. 

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Approve-EdgeDeveloper -Name Elaine@example.org

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
       ContentType = 'application/octet-stream'
       QParams = $( ConvertFrom-Hashtable @{ action = 'active' } )
    }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }

    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    Send-EdgeRequest @Options
}
