Function Get-EdgeAppCredential {
    <#
    .SYNOPSIS
        Get the list of credentials for a developer app.

    .DESCRIPTION
        Get the list of credentials for a developer app.

    .PARAMETER AppId
        The id of the developer app to retrieve.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeAppCredential -Id cc631102-80cd-4491-a99a-121cec08e0bb

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$AppId,
        [string]$Org,
        [Hashtable]$Params
    )
    
    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Params']) {
        $Options.Add( 'Params', $Params )
    }
    if (! $PSBoundParameters['AppId']) {
      throw [System.ArgumentNullException] 'missing required parameter -AppId'
    }

    $Options.Add( 'Collection', 'apps')
    $Options.Add( 'Name', $AppId )

    $TempResult = Get-EdgeObject @Options
    if ($TempResult.credentials) {
        $TempResult.credentials
    }
    else {
        $TempResult
    }
}
