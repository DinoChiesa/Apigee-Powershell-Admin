Function Deploy-EdgeAsset {
    <#
    .SYNOPSIS
        Deploy an apiproxy or sharedflow in Apigee Edge.

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$AssetType,
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Environment,
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
    if (!$PSBoundParameters['Environment']) {
      throw [System.ArgumentNullException] "Environment", "You must specify the -Environment option."
    }
    if (!$PSBoundParameters['Revision']) {
      throw [System.ArgumentNullException] "Revision", "You must specify the -Revision option."
    }

    if( ! $PSBoundParameters['Org']) {
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

    $BaseUri = Join-Parts -Separator '/' -Parts $MgmtUri, '/v1/o', $Org, 'e', $Environment, $AssetType, $Name, 'revisions', $Revision, 'deployments'

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
        Write-Debug ( "Deploy-EdgeAsset Uri $BaseUri`n" )
        $TempResult = Invoke-RestMethod @IRMParams
        Write-Debug "Raw:`n$($TempResult | Out-String)"
    }
    Catch {
        $TempResult = $_
    }
    Finally {
        Remove-Variable IRMParams
    }

    $TempResult
}
