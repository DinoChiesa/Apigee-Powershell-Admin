Function Delete-EdgeApi {
    <#
    .SYNOPSIS
        Delete an apiproxy from Apigee Edge

    .DESCRIPTION
        Delete an apiproxy from Apigee Edge

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
    param(
        [string]$Name,
        [string]$Revision,
        [string]$Org
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

    Delete-EdgeObject @Options
}
