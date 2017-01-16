Function Revoke-EdgeAppCredential {
    <#
    .SYNOPSIS
        Revoke an existing credential for a developer app, without removing it.     

    .DESCRIPTION
        Revoke an existing credential for a developer app, without removing it.     
        This is a reversible operation. 

    .PARAMETER AppName
        Required. The name of the developer app from which the credential will be revoked.

    .PARAMETER Developer
        Required. The id or email of the developer that owns the app for which the credential will be revoked.

    .PARAMETER Key
        Required. The consumer key for the credential to be revokd.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Revoke-EdgeAppCredential -AppName DPC6 -Developer dchiesa@example.org -Key pd0mg1FuedmfCpY9gWZonQmR2fGD3Osw

    .LINK
        Remove-EdgeAppCredential

    .LINK
        Approve-EdgeAppCredential

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [string]$AppName,
        [string]$Developer,
        [string]$Key,
        [string]$Org
    )
    
    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    if (!$PSBoundParameters['Developer']) {
        throw [System.ArgumentNullException] "Developer", "You must specify the -Developer option."
    }
    if (!$PSBoundParameters['AppName']) {
      throw [System.ArgumentNullException] "AppName", "You must specify the -AppName option."
    }

    if (!$PSBoundParameters['Key']) {
      throw [System.ArgumentNullException] "Key", "You must specify the -Key option."
    }
    
    $Options.Add( 'Collection', $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps', $AppName, 'keys' ) )
    $Options.Add( 'Name', $Key )
    $Options.Add( 'Params', { action  = 'revoke' } )
    
    Write-Debug ( "Options @Options`n" )
    Send-EdgeRequest @Options
}
