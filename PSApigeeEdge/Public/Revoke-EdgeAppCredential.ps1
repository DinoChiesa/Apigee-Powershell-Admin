Function Revoke-EdgeAppCredential {
    <#
    .SYNOPSIS
        Revoke an existing credential or apiproduct on a credential for a developer app, without removing it.

    .DESCRIPTION
        Revoke an existing credential for a developer app, without removing it. Or, revoke a specific
        API Product on a credential for a developer app. Revoking a credential or an apiproduct on a
        credential means the key will be rejected at runtime.

    .PARAMETER AppName
        Required. The name of the developer app from which the credential will be revoked.

    .PARAMETER Developer
        Required. The id or email of the developer that owns the app for which the credential will be revoked.

    .PARAMETER Key
        Required. The consumer key for the credential to be revoked.

    .PARAMETER ApiProduct
        Optional. The name of the API Product to be revoked. It must be present on the credential.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Revoke-EdgeAppCredential -AppName DPC6 -Developer dchiesa@example.org -Key pd0mg1FuedmfCpY9gWZonQmR2fGD3Osw

    .EXAMPLE
        Revoke-EdgeAppCredential -AppName DPC6 -Developer dchiesa@example.org -Key pd0mg1FuedmfCpY9gWZonQmR2fGD3Osw -ApiProduct Product123

    .LINK
        Remove-EdgeAppCredential

    .LINK
        Approve-EdgeAppCredential

    .LINK
        Update-EdgeDevAppStatus


    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [string]$AppName,
        [string]$Developer,
        [string]$Key,
        [string]$ApiProduct,
        [string]$Org
    )

    $Options = @{ }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options['Debug'] = $Debug
    }
    foreach ($k in $MyInvocation.BoundParameters.keys) {
        $var = Get-Variable -Name $k -ErrorAction SilentlyContinue
        if ($var) {
            Write-Host $( [string]::Format("key[{0}] value[{1}]", $k, $var.value) )
            $Options[$k] = $var.value
        }
    }
    $Options['Action'] = 'revoke'
    Write-Debug $( [string]::Format("Revoke-EdgeAppCredential Options {0}", $(ConvertTo-Json $Options )))
    Update-EdgeDevAppStatus @Options
}
