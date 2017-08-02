Function Get-EdgeVhost {
    <#
    .SYNOPSIS
        Get one or more virtualhost objects from Apigee Edge

    .DESCRIPTION
        Get information about one or more virtualhosts from Apigee Edge

    .PARAMETER Environment
        Required. The name of the environment to search for virtualhosts.

    .PARAMETER Name
        Optional. The name of the virtualhost to retrieve.
        The default is to list all virtualhosts.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeVhost -Org cap500 -Environment test

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Environment,
        [string]$Name,
        [string]$Org,
        [Hashtable]$Params
    )

    if (!$PSBoundParameters['Environment']) {
        throw [System.ArgumentNullException] "Environment", "The -Environment parameter is required."
    }
    $Options = @{ }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options['Debug'] = $Debug
    }
    if ($PSBoundParameters['Org']) {
        $Options['Org'] = $Org
    }

   $Options['Collection'] = $( Join-Parts -Separator '/' -Parts 'e', $Environment, 'virtualhosts' )

    if ($PSBoundParameters['Name']) {
        $Options['Name'] = $Name
    }

    Write-Debug $( [string]::Format("Get-EdgeVhost Options {0}", $(ConvertTo-Json $Options )))
    Get-EdgeObject @Options
}
