Function Update-EdgeAppCredentialStatus {
    <#
    .SYNOPSIS
        Approve or Revoke an existing credential, or an apiproduct on a credential, for a developer app.

    .DESCRIPTION
        Approve or Revoke an existing credential from a developer app. Or, approve or revoke a specific
        API Product on a credential for a developer app. Approving a credential that is pending
        or has been revoked allows the credential to be used at runtime. Revoking a credential means that
        the key will be rejected at runtime.

    .PARAMETER AppName
        Required. The name of the developer app that contains the credential to be updated.

    .PARAMETER Developer
        Required. The id or email of the developer that owns the app that contains the credential.

    .PARAMETER Key
        Required. The consumer key for the credential to be approved or revoked.

    .PARAMETER Action
        Required. The action to apply. Either revoke or approve.

    .PARAMETER ApiProduct
        Optional. The name of the API Product to be approved or revoked. It must be present on the credential.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Update-EdgeAppCredentialStatus -AppName DPC6 -Developer dchiesa@example.org -Key pd0mg1FuedmfCpY9gWZonQmR2fGD3Osw -Action revoke

    .EXAMPLE
        Update-EdgeAppCredentialStatus -AppName DPC6 -Developer dchiesa@example.org -Key pd0mg1FuedmfCpY9gWZonQmR2fGD3Osw -ApiProduct Product123 -Action approve

    .LINK
        Revoke-EdgeAppCredential

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
        [string]$ApiProduct,
        [string]$Action,
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

    if (!$PSBoundParameters['Developer']) {
        throw [System.ArgumentNullException] "Developer", "You must specify the -Developer option."
    }
    if (!$PSBoundParameters['AppName']) {
      throw [System.ArgumentNullException] "AppName", "You must specify the -AppName option."
    }
    if (!$PSBoundParameters['Key']) {
      throw [System.ArgumentNullException] "Key", "You must specify the -Key option."
    }
    if (!$PSBoundParameters['Action']) {
      throw [System.ArgumentNullException] "Action", "You must specify the -Action option."
    }
    $Action = $Action.ToLower()
    if ($Action -ne "approve" -and $Action -ne "revoke") {
      throw [System.ArgumentException] "Action", "Action must be 'revoke' or 'approve'."
    }

    if ($PSBoundParameters['ApiProduct']) {
        $Options.Add( 'Collection', $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps', $AppName, 'keys', $Key, 'apiproducts' ) )
        $Options.Add( 'Name', $ApiProduct )
    }
    else {
        $Options.Add( 'Collection', $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps', $AppName, 'keys' ) )
        $Options.Add( 'Name', $Key )
    }
    $Options.Add( 'QParams', $( ConvertFrom-HashtableToQueryString @{ action = $Action } ))

    Write-Debug ( "Options @Options`n" )
    Send-EdgeRequest @Options
}
