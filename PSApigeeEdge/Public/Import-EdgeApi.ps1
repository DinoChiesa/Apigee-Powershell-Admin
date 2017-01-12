Function Import-EdgeApi {
    <#
    .SYNOPSIS
        Import an apiproxy from a zip file into Apigee Edge.

    .DESCRIPTION
        Import an apiproxy from a zip file or directory into Apigee Edge.

    .PARAMETER Name
        Required. The name to use for the apiproxy, once imported.

    .PARAMETER Source
        Required. A string, repreenting the source of the apiproxy bundle to import. This
        can be the name of a file, in zip format; or it can be the name of a directory, which 
        this cmdlet will zip itself. In either case, the structure must be like so: 

            .\apiproxy 
            .\apiproxy\proxies 
            .\apiproxy\proxies\proxy1.xml
            .\apiproxy\policies 
            .\apiproxy\policies\Policy1.xml
            .\apiproxy\policies\...
            .\apiproxy\targets
            .\apiproxy\resources
            ...

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Import-EdgeApi -Name oauth2-pwd-cc -Source bundle.zip

    .EXAMPLE
        Import-EdgeApi -Name oauth2-pwd-cc -Source .\mydirectory

    .LINK
       Deploy-EdgeApi

    .LINK
       Export-EdgeApi

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Source,
        [string]$Org
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Source']) {
      throw [System.ArgumentNullException] "Source", "You must specify the -Source option."
    }

    $ZipFile = ""
    $isFile = $False
    $mypath = $(Resolve-Path $Source)
    if ($mypath.count -ne 1) {
        throw [System.ArgumentException] "The provided Source does not resolve."
    }
    
    if([System.IO.File]::Exists($mypath.Path)){
        $isFile = $True
        $ZipFile = $mypath.Path
    }
    elseif ([System.IO.Directory]::Exists($mypath.Path)) {
        $apiproxyPaths = @(Join-Path -Path $mypath -ChildPath "apiproxy" -Resolve)
        if ($apiproxyPaths.count -ne 1) {
            throw [System.ArgumentException] "Cannot find apiproxy directory under the Source directory."
        }
        $ZipFile = Zip-ProxyBundleDirectory $Source
    }
    else {
      throw [System.ArgumentException] "Source does not refer to a readable file or directory."
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

    if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['SecurePass']) {
      throw [System.ArgumentNullException] 'SecurePass', 'use Set-EdgeConnection to specify the Edge connection information.'
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
        InFile = $ZipFile
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
        if (! $isFile ) {
            # Source was a dir, the zipfile is a temp file
            [System.IO.File]::Delete($ZipFile)
        }
    }
    if ($TempResult.StatusCode -eq 201) {
      ConvertFrom-Json $TempResult.Content
    }
    else {
      $TempResult
    }

}
