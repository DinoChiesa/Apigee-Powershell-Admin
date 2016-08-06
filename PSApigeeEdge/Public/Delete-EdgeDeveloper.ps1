Function Delete-EdgeDeveloper {
    <#
    .SYNOPSIS
        Delete an developer app from Apigee Edge.

    .DESCRIPTION
        Delete an developer app from Apigee Edge.

    .PARAMETER Name
        The id or email address of the developer to delete. 
        
    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeDeveloper -Name dchiesa@example.org 

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Org
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    
    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] 'The -Name parameter is required.'
    }
    
    $Options = @{ Collection = 'developers'; Name = $Name; }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    
    Write-Debug ( "Options @Options`n" )

    Delete-EdgeObject @Options
}
