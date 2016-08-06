Function Remove-EdgeAppCredential {
    <#
    .SYNOPSIS
        Remove an existing credential from a developer app.

    .DESCRIPTION
        Remove an existing credential from a developer app.

    .PARAMETER Name
        The name of the developer app from which the credential will be removed.

    .PARAMETER Developer
        The id or email of the developer that owns the app from which the credential will be removed.

    .PARAMETER Key
        The consumer key for the credential to be removed.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Remove-EdgeAppCredential -Name DPC6 -Developer dchiesa@example.org -Key pd0mg1FuedmfCpY9gWZonQmR2fGD3Osw

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Position=0,
         Mandatory=$True,
         ValueFromPipeline=$True)]
        [string]$Name,
        
        [Parameter(Position=1,
         Mandatory=$True,
         ValueFromPipeline=$True)]
        [string]$Developer,

        [Parameter(Position=2,
         Mandatory=$True,
         ValueFromPipeline=$True)]
        [string]$Key,

        [string]$Org
    )
    
    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }

    if (!$PSBoundParameters['Developer']) {
        throw [System.ArgumentNullException] "You must specify the -Developer option."
    }
    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Key']) {
      throw [System.ArgumentNullException] "You must specify the -Key option."
    }
    
    $Options.Add( 'Collection', $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps', $Name, 'keys' ) )
    $Options.Add( 'Name', $Key )

    Write-Debug ( "Options @Options`n" )
    Delete-EdgeObject @Options
}
