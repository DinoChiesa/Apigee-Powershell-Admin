Function Export-EdgeApi {
    <#
    .SYNOPSIS
        Export an apiproxy from Apigee Edge, into a zip file.

    .DESCRIPTION
        Export an apiproxy from Apigee Edge, into a zip file.

    .PARAMETER Name
        The name of the api proxy to export. 

    .PARAMETER Revision
        The revision of the api proxy to export. 

    .PARAMETER Dest
        The name of the destination file, which will be a ZIP bundle.
        By default the zip file gets a name derived from the proxy name, the
        revision, and the time of export. 

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Import-EdgeApi -Name oauth2-pwd-cc -Revision 4 -Dest bundle.zip

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Revision,
        [string]$Dest,
        [string]$Org
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Revision']) {
      throw [System.ArgumentNullException] "You must specify the -Revision option."
    }
    if (!$PSBoundParameters['Dest']) {
        $tstmp = [System.DateTime]::Now.ToString('yyyyMMdd-HHmmss')
        $Dest = "${Name}-r${Revision}-${tstmp}.zip"
    }
    
    if( ! $PSBoundParameters.ContainsKey('Org')) {
      if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']) {
        throw [System.ArgumentNullException] "use the -Org parameter to specify the organization."
      }
      else {
        $Org = $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']
      }
    }
    if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']) {
      throw [System.ArgumentNullException] 'use Set-EdgeConnection to specify the Edge connection information.'
    }
    $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']

    if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['SecurePass']) {
      throw [System.ArgumentNullException] 'use Set-EdgeConnection to specify the Edge connection information.'
    }

    $BaseUri = Join-Parts -Separator '/' -Parts $MgmtUri, '/v1/o', $Org, 'apis', $Name, 'revisions', $Revision
    Write-Debug "BaseUri: $BaseUri"

    $IRMParams = @{
        Uri = "${BaseUri}?format=bundle"
        Method = 'GET'
        Headers = @{
            Authorization = 'Basic ' + $( Get-EdgeBasicAuth )
        }
        OutFile = $Dest
    }

    Try {
        $TempResult = Invoke-WebRequest @IRMParams -UseBasicParsing 

        Write-Debug "Raw:`n$($TempResult | Out-String)"
    }
    Catch {
        Throw $_
    }
    Finally {
        Remove-Variable IRMParams
    }

    $Dest
}
