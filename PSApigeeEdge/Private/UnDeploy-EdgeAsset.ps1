Function UnDeploy-EdgeAsset {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$AssetType,
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Env,
        [Parameter(Mandatory=$True)][string]$Revision,
        [string]$Org
    )

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['AssetType']) {
      throw [System.ArgumentNullException] "AssetType", "You must specify the -AssetType option."
    }
    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Env']) {
      throw [System.ArgumentNullException] "Env", "You must specify the -Env option."
    }
    if (!$PSBoundParameters['Revision']) {
      throw [System.ArgumentNullException] "Revision", "You must specify the -Revision option."
    }

    if( ! $PSBoundParameters.ContainsKey('Org')) {
      if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']) {
        throw [System.ArgumentNullException] 'Org', "use the -Org parameter to specify the organization."
      }
      $Org = $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']
    }

    if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']) {
      throw [System.ArgumentNullException] 'MgmtUri', 'use Set-EdgeConnection to specify the Edge connection information.'
    }
    $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']

    $BaseUri = Join-Parts -Separator '/' -Parts $MgmtUri, '/v1/o', $Org, 'e', $Env, $AssetType, $Name, 'revisions', $Revision, 'deployments'

    $IRMParams = @{
        Uri = $BaseUri
        Method = 'DELETE'
        Headers = @{
            Accept = 'application/json'
        }
    }

    Apply-EdgeAuthorization -MgmtUri $MgmtUri -IRMParams $IRMParams

    Try {
        Write-Debug ( "UnDeploy-EdgeAsset Uri $BaseUri`n" )
        $TempResult = Invoke-RestMethod @IRMParams
        Write-Debug "Raw:`n$($TempResult | Out-String)"
    }
    Catch {
        Throw $_
    }
    Finally {
        Remove-Variable IRMParams
    }

    $TempResult
}
