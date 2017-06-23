Function Export-EdgeSharedFlow {
    <#
    .SYNOPSIS
        Export a sharedflow from Apigee Edge, into a zip file.

    .DESCRIPTION
        Export a sharedflow from Apigee Edge, into a zip file.

    .PARAMETER Name
        Required. The name of the sharedflow to export.

    .PARAMETER Revision
        Required. The revision of the sharedflow to export.

    .PARAMETER Dest
        Optional. The name of the destination file, which will be a ZIP bundle.
        By default the zip file gets a name derived from the name of the sharedflow, the
        revision, and the time of export.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Export-EdgeSharedFlow -Name log-to-splunk -Revision 4 -Dest sf-bundle.zip

    .EXAMPLE
        $filename = $( Export-EdgeSharedFlow -Name log-to-splunk -Revision 4 )

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
        $Dest = "sharedflow-${Name}-r${Revision}-${tstmp}.zip"
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
