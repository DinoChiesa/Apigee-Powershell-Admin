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

    if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['SecurePass']) {
      throw [System.ArgumentNullException] 'SecurePass', 'use Set-EdgeConnection to specify the Edge connection information.'
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
          action = 'deploy'
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
