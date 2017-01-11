Function Get-EdgeApiRevision {
    <#
    .SYNOPSIS
        Get the list of revisions for an apiproxy from Apigee Edge.

    .DESCRIPTION
        Get the list of revisions for an apiproxy from Apigee Edge.

    .PARAMETER Name
        Required. The name of the apiproxy to retrieve. Required. 

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeApiRevision -Name myapiproxy

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Org
    )
    
    $Options = @{ Collection = 'apis' }
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    
    if (!$PSBoundParameters['Name']) {
        throw [System.ArgumentNullException] "Name", 'the -Name parameter is required.'
    }
    $Options.Add( 'Name', $( Join-Parts -Separator "/" -Parts $Name, 'revisions' ) )
    
    Write-Debug ( "Options @Options`n" )

    @( Get-EdgeObject @Options )
}
