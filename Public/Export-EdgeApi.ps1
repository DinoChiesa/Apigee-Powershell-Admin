Function Export-EdgeApi {
    <#
    .SYNOPSIS
        Export an apiproxy from Apigee Edge, into a zip file.

    .DESCRIPTION
        Export an apiproxy from Apigee Edge, into a zip file.

    .PARAMETER Name
        The name to use for the apiproxy, once imported

    .PARAMETER Revision
        The name to use for the apiproxy, once imported

    .PARAMETER Dest
        The name of the destination file, which will be a ZIP bundle.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Import-EdgeApi -Name oauth2-pwd-cc -Source bundle.zip

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$Revision,
        [string]$Dest,
        [string]$Org
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Dest']) {
      throw [System.ArgumentNullException] "You must specify the -Dest option."
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

    $BaseUri = Join-Parts -Separator '/' -Parts $MgmtUri, '/v1/o', $Org, 'apis', $Name, 'revisions', $Revision

    $decrypted = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($AuthToken))

    $IRMParams = @{
        Uri = "$BaseUri?format=bundle"
        Method = 'GET'
        Headers = @{
            Authorization = "Basic $decrypted"
        }
        OutFile = $Dest
    }

    Remove-Variable decrypted

    Try {
        $TempResult = Invoke-WebRequest @IRMParams

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
