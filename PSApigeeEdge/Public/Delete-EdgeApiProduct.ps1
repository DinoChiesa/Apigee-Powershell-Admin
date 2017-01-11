Function Delete-EdgeApiProduct {
    <#
    .SYNOPSIS
        Delete an API Product from Apigee Edge.

    .DESCRIPTION
        Delete an API Product from Apigee Edge.

    .PARAMETER Name
        The name of the API Product to delete. 
        
    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeApiProduct -Name Product-7

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
      throw [System.ArgumentNullException] "Name", 'The -Name parameter is required.'
    }
    
    $Options = @{ Collection = 'apiproducts'; Name = $Name; }
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    
    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )
    
    Delete-EdgeObject @Options
}
