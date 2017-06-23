Function Import-EdgeApi {
    <#
    .SYNOPSIS
        Import an apiproxy from a zip file or exploded directory into Apigee Edge.

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
        [Parameter(Mandatory=$True)][string]$Source,
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

    if( ! $PSBoundParameters.ContainsKey('Org')) {
      if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']) {
        throw [System.ArgumentNullException] 'Org', "use the -Org parameter to specify the organization."
      }
      $Org = $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']
    }

    Import-EdgeAsset -Name $Name -Source $Source -Org $Org -FsPath "apiproxy" -UriPathElement "apis"
    #Import-EdgeAsset -Name $Name -Source $Source -Org $Org -FsPath "sharedflowbundle" -UriPathElement "sharedflows"
}
