Function Export-EdgeApi {
    <#
    .SYNOPSIS
        Export an apiproxy from Apigee Edge, into a zip file.

    .DESCRIPTION
        Export an apiproxy from Apigee Edge, into a zip file.

    .PARAMETER Name
        Required. The name of the apiproxy to export.

    .PARAMETER Revision
        Required. The revision of the apiproxy to export.

    .PARAMETER Dest
        Optional. The name of the destination file, which will be a ZIP bundle.
        By default the zip file gets a name derived from the proxy name, the
        revision, and the time of export.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Export-EdgeApi -Name oauth2-pwd-cc -Revision 4 -Dest bundle.zip

    .EXAMPLE
        $filename = $( Export-EdgeApi -Name oauth2-pwd-cc -Revision 4 )

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
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Revision']) {
      throw [System.ArgumentNullException] "Revision", "You must specify the -Revision option."
    }
    if (!$PSBoundParameters['Dest']) {
        $tstmp = [System.DateTime]::Now.ToString('yyyyMMdd-HHmmss')
        $Dest = $( Join-Path -Path $env:temp -ChildPath $( [string]::Format('apiproxy-{0}-r{1}-{2}.zip', $Name, $Revision, $tstmp) ) )
    }
    if( ! $PSBoundParameters.ContainsKey('Org')) {
      if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']) {
        throw [System.ArgumentNullException] 'Org', "use the -Org parameter to specify the organization."
      }
      else {
        $Org = $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']
      }
    }

    Export-EdgeAsset -Name $Name -Revision $Revision -Dest $Dest -Org $Org -UriPathElement "apis"
}
