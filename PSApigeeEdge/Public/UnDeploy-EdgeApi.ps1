Function UnDeploy-EdgeApi {
    <#
    .SYNOPSIS
        UnDeploy an apiproxy in Apigee Edge.

    .DESCRIPTION
        UnDeploy a revision of an API proxy that is deployed. 

    .PARAMETER Name
        The name of the apiproxy to deploy.

    .PARAMETER Env
        The name of the environment from which to undeploy the api proxy.

    .PARAMETER Revision
        The revision of the apiproxy. 

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        UnDeploy-EdgeApi -Name oauth2-pwd-cc -Env test 

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Env,
        [Parameter(Mandatory=$True)][string]$Revision,
        [string]$Org,
        [Hashtable]$Params
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Env']) {
      throw [System.ArgumentNullException] "You must specify the -Env option."
    }
    if (!$PSBoundParameters['Revision']) {
      throw [System.ArgumentNullException] "You must specify the -Revision option."
    }

    if( ! $PSBoundParameters.ContainsKey('Org')) {
      if( ! $MyInvocation.MyCommand.Module.PrivateData['Org']) {
        throw [System.ArgumentNullException] "use the -Org parameter to specify the organization."
      }
      $Org = $MyInvocation.MyCommand.Module.PrivateData['Org']
    }
    
    if( ! $MyInvocation.MyCommand.Module.PrivateData['MgmtUri']) {
      throw [System.ArgumentNullException] 'use Set-EdgeConnection to specify the Edge connection information.'
    }
    $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData['MgmtUri']

    if( ! $MyInvocation.MyCommand.Module.PrivateData['SecurePass']) {
      throw [System.ArgumentNullException] 'use Set-EdgeConnection to specify the Edge connection information.'
    }

    $BaseUri = Join-Parts -Separator '/' -Parts $MgmtUri, '/v1/o', $Org, 'apis', $Name, 'revisions', $Revision, 'deployments'

    $IRMParams = @{
        Uri = $BaseUri
        Method = 'POST'
        Headers = @{
            Accept = 'application/json'
            'content-type' = 'application/x-www-form-urlencoded'
            Authorization = 'Basic ' + $( Get-EdgeBasicAuth )
        }
        # these will transform into query params?  postbody? 
        Body = @{
          action = 'undeploy'
          env = $Env
          override = 'true'
          delay = 30
        }
    }

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
