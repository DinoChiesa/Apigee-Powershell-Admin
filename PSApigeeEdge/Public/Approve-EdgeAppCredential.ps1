Function Approve-EdgeAppCredential {
    <#
    .SYNOPSIS
        Approve an existing credential, or an apiproduct on a credential, for a developer app.

    .DESCRIPTION
        Approve an existing credential from a developer app. Or, approve a specific
        API Product on a credential for a developer app. Approving a credential that is pending
        or has been revoked allows the credential to be used at runtime.

    .PARAMETER AppName
        Required. The name of the developer app from which the credential will be approved.

    .PARAMETER Developer
        Required. The id or email of the developer that owns the app for which the credential will be approved.

    .PARAMETER Key
        Required. The consumer key for the credential to be approved.

    .PARAMETER ApiProduct
        Optional. The name of the API Product to be approved. It must be present on the credential.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Approve-EdgeAppCredential -AppName DPC6 -Developer dchiesa@example.org -Key pd0mg1FuedmfCpY9gWZonQmR2fGD3Osw

    .EXAMPLE
        Approve-EdgeAppCredential -AppName DPC6 -Developer dchiesa@example.org -Key pd0mg1FuedmfCpY9gWZonQmR2fGD3Osw -ApiProduct Product123

    .LINK
        Revoke-EdgeAppCredential

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
    $Options['Action'] = 'approve'
    Write-Debug $( [string]::Format("Approve-EdgeAppCredential Options {0}", $(ConvertTo-Json $Options )))
    Update-EdgeDevAppStatus @Options
}
