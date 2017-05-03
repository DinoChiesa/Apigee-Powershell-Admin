Function Deploy-EdgeAsset {
    <#
    .SYNOPSIS
        Deploy an apiproxy or sharedflow in Apigee Edge.

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$AssetType,
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Env,
        [Parameter(Mandatory=$True)][string]$Revision,
        [string]$Org,
        [string]$Basepath,
        [Hashtable]$Params
    )

    if (!$PSBoundParameters['AssetType']) {
        throw [System.ArgumentNullException] "AssetType", "You must specify the -AssetType option."
    }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
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
        throw [System.ArgumentNullException] "Org", "use the -Org parameter to specify the organization."
      }
      else {
        $Org = $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']
      }
    }
    if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']) {
      throw [System.ArgumentNullException] 'MgmtUri', 'use Set-EdgeConnection to specify the Edge connection information.'
    }
    $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']

    $BaseUri = Join-Parts -Separator '/' -Parts $MgmtUri, '/v1/o', $Org, 'e', $Env, $AssetType, $Name, 'revisions', $Revision, 'deployments'

    $RequestBody = @{
          action = 'deploy'
          override = 'true'
          delay = 30 # currently not parameterized
    }

    if ($AssetType -eq "apis") {
        if ($PSBoundParameters['Basepath']) {
            $RequestBody['basepath'] = $Basepath
        }
    }

    $IRMParams = @{
        Uri = $BaseUri
        Method = 'POST'
        Headers = @{
            Accept = 'application/json'
            'content-type' = 'application/x-www-form-urlencoded'
        }
        # this hash will transform into postbody
        Body = $RequestBody
    }

    Apply-EdgeAuthorization -MgmtUri $MgmtUri -IRMParams $IRMParams

    Try {
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
