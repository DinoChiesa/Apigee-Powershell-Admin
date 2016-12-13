Function Import-EdgeApi {
    <#
    .SYNOPSIS
        Import an apiproxy from a zip file into Apigee Edge.

    .DESCRIPTION
        Import an apiproxy from a zip file into Apigee Edge.
        You will need to produce the zipfile, probably with something
        like this:

        function ZipFiles( $zipfilename, $sourcedir )
        {
           Add-Type -Assembly System.IO.Compression.FileSystem
           $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
           [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcedir,
                $zipfilename, $compressionLevel, $false)
        }

    .PARAMETER Name
        The name to use for the apiproxy, once imported.

    .PARAMETER Source
        The source of the apiproxy bundle to import.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Import-EdgeApi -Name oauth2-pwd-cc -Source bundle.zip

    .LINK
       Deploy-EdgeApi
       Export-EdgeApi

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Source,
        [string]$Org
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Source']) {
      throw [System.ArgumentNullException] "You must specify the -Source option."
    }

    if( ! $PSBoundParameters.ContainsKey('Org')) {
      if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']) {
        throw [System.ArgumentNullException] "use the -Org parameter to specify the organization."
      }
      $Org = $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']
    }
    if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']) {
      throw [System.ArgumentNullException] 'use Set-EdgeConnection to specify the Edge connection information.'
    }
    $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']

    if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['SecurePass']) {
      throw [System.ArgumentNullException] 'use Set-EdgeConnection to specify the Edge connection information.'
    }

    $BaseUri = Join-Parts -Separator '/' -Parts $MgmtUri, '/v1/o', $Org, 'apis'

    $IRMParams = @{
        Uri = "${BaseUri}?action=import&name=${Name}"
        Method = 'POST'
        Headers = @{
            Accept = 'application/json'
            'content-type' = 'application/octet-stream'
            Authorization = 'Basic ' + $( Get-EdgeBasicAuth )
        }
        InFile = $Source
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
    if ($TempResult.StatusCode -eq 201) {
      ConvertFrom-Json $TempResult.Content
    }
    else {
      $TempResult
    }

}
