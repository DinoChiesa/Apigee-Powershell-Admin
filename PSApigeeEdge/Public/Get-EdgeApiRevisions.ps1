Function Get-EdgeApiRevision {
    <#
    .SYNOPSIS
        Get the list of revisions for an apiproxy from Apigee Edge.

    .DESCRIPTION
        Get the list of revisions for an apiproxy from Apigee Edge.

    .PARAMETER Name
        The name of the apiproxy to retrieve. Required. 

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeApi -Org cap500

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Org,
        [Parameter(Mandatory=$True)][string]$Name
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
        $Path = Join-Parts -Separator "/" -Parts $Name
        $Options.Add( 'Name', 'revisions' )
    }
    else {
      throw [System.ArgumentNullException] 'the -Name parameter is required.'
    
    }
    
    Write-Debug ( "Options @Options`n" )

    Get-EdgeObject @Options
}
