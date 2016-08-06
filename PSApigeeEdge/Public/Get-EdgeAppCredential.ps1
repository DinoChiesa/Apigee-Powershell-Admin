Function Get-EdgeAppCredential {
    <#
    .SYNOPSIS
        Get the list of credentials for a developer app.

    .DESCRIPTION
        Get the list of credentials for a developer app.

    .PARAMETER Id
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
        [string]$Id,
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
    if (! $PSBoundParameters['Id']) {
      throw [System.ArgumentNullException] 'missing required parameter -Id'
    }

    $Options.Add( 'Collection', 'apps')
    $Options.Add( 'Name', $Id )

    $TempResult = Get-EdgeObject @Options
    if ($TempResult.credentials) {
        $TempResult.credentials
    }
    else {
        $TempResult
    }
}
