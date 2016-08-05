Function Deploy-EdgeApi {
    <#
    .SYNOPSIS
        Deploy an apiproxy in Apigee Edge.

    .DESCRIPTION
        Deploy a revision of an API proxy that is not yet deployed. 

    .PARAMETER Name
        The name of the apiproxy to deploy.

    .PARAMETER Env
        The name of the environment to which to deploy the api proxy.

    .PARAMETER Revision
        The revision of the apiproxy. 

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Deploy-EdgeApi -Name oauth2-pwd-cc -Env test -Revision 8

    .FUNCTIONALITY
        ApigeeEdge

    #>

# Undeploy:
# POST
#  -H content-type:application/x-www-form-urlencoded \
#   "${mgmtserver}/v1/o/$org/apis/$proxyname/revisions/${rev1}/deployments?action=undeploy&env=${env}"

# Deploy
# POST \
#  -H content-type:application/x-www-form-urlencoded \
#   "${mgmtserver}/v1/o/${org}/apis/${proxyname}/revisions/${rev}/deployments?action=undeploy&env=${env}" \
#   -d "override=true&delay=60"



    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$Env,
        [string]$Revision,
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
      else {
        $Org = $MyInvocation.MyCommand.Module.PrivateData['Org']
      }
    }
    if( ! $MyInvocation.MyCommand.Module.PrivateData['MgmtUri']) {
      throw [System.ArgumentNullException] 'use Set-EdgeConnection to specify the Edge connection information.'
    }
    else {
      $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData['MgmtUri']
    }

    if( ! $MyInvocation.MyCommand.Module.PrivateData['AuthToken']) {
      throw [System.ArgumentNullException] 'use Set-EdgeConnection to specify the Edge connection information.'
    }
    else {
      $AuthToken = $MyInvocation.MyCommand.Module.PrivateData['AuthToken']
    }

    $BaseUri = Join-Parts -Separator '/' -Parts $MgmtUri, '/v1/o', $Org, 'apis', $Name, 'revisions', $Revision, 'deployments'


    $decrypted = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($AuthToken))

    $IRMParams = @{
        Uri = $BaseUri
        Method = 'POST'
        Headers = @{
            Accept = 'application/json'
            'content-type' = 'application/x-www-form-urlencoded'
            Authorization = "Basic $decrypted"
        }
        # these will transform into query params?  postbody? 
        Body = @{
          action = 'deploy'
          env = $Environment
          override = 'true'
          delay = 30
        }
    }

    Remove-Variable decrypted

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
