Function Delete-EdgeApi {
    <#
    .SYNOPSIS
        Delete an apiproxy from Apigee Edge.

    .DESCRIPTION
        Delete an apiproxy from Apigee Edge.

    .PARAMETER Name
        The name of the apiproxy to delete.
        
    .PARAMETER Revision
        Optional. The revision to delete. If not specified, all revisions will be deleted.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeApi dino-test-2

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Revision,
        [string]$Org
    )
    
    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    
    if (!$PSBoundParameters['Name']) {
        throw [System.ArgumentNullException] "The -Name parameter is required."
    }
    
    if ($PSBoundParameters['Revision']) {
        $Options['Collection'] = $(Join-Parts -Separator "/" -Parts 'apis', $Name, 'revisions' )
        $Options.Add( 'Name', $Revision )
    }
    else {
        $Options['Collection'] = 'apis'
        $Options.Add( 'Name', $Name )
    }

    Write-Debug ( "Options @Options`n" )
    Delete-EdgeObject @Options
}
