Function Export-EdgeAsset {

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Revision,
        [Parameter(Mandatory=$True)][string]$UriPathElement,
        [Parameter(Mandatory=$True)][string]$Dest,
        [Parameter(Mandatory=$True)][string]$Org
    )

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']) {
      throw [System.ArgumentNullException] 'MgmtUri', 'use Set-EdgeConnection to specify the Edge connection information.'
    }
    $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']

    $BaseUri = Join-Parts -Separator '/' -Parts $MgmtUri, '/v1/o', $Org, $UriPathElement, $Name, 'revisions', $Revision
    Write-Debug "BaseUri: $BaseUri"

    $IRMParams = @{
        Uri = "${BaseUri}?format=bundle"
        Method = 'GET'
        Headers = @{ }
        OutFile = $Dest
    }

    Apply-EdgeAuthorization -MgmtUri $MgmtUri -IRMParams $IRMParams

    Try {
        $TempResult = Invoke-WebRequest @IRMParams -UseBasicParsing
        Write-Debug "Raw:`n$($TempResult | Out-String)"
    }
    Catch {
        $Dest = $_
    }
    Finally {
        Remove-Variable IRMParams
    }

    $Dest
}
