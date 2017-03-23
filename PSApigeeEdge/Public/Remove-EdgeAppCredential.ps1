Function Remove-EdgeAppCredential {
    <#
    .SYNOPSIS
        Remove an existing credential from a developer app.

    .DESCRIPTION
        Remove an existing credential from a developer app.

    .PARAMETER AppName
        The name of the developer app from which the credential will be removed.

    .PARAMETER Name
        A synonym for AppName.

    .PARAMETER Developer
        The id or email of the developer that owns the app from which the credential will be removed.

    .PARAMETER Key
        The consumer key for the credential to be removed.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Remove-EdgeAppCredential -AppName DPC6 -Developer dchiesa@example.org -Key pd0mg1FuedmfCpY9gWZonQmR2fGD3Osw

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [string]$AppName,
        [string]$Name,
        [string]$Developer,
        [string]$Key,
        [string]$Org
    )

    $Options = @{ }

    if ($PSBoundParameters['Debug']) {
        $Options['Debug'] = $Debug
    }
    if ($PSBoundParameters['Org']) {
        $Options['Org'] = $Org
    }

    if (!$PSBoundParameters['Developer']) {
        throw [System.ArgumentNullException] "Developer", "You must specify the -Developer option."
    }
    if (!$PSBoundParameters['AppName'] -and !$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "AppName", "You must specify the -AppName option."
    }
    $RealAppName = if ($PSBoundParameters['AppName']) { $AppName } else { $Name }

    if (!$PSBoundParameters['Key']) {
      throw [System.ArgumentNullException] "Key", "You must specify the -Key option."
    }

    $Options['Collection'] = $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps', $RealAppName, 'keys' )
    $Options['Name'] = $Key

    Write-Debug $( [string]::Format("Remove-EdgeAppCredential Options {0}", $(ConvertTo-Json $Options )))
    Delete-EdgeObject @Options
}
