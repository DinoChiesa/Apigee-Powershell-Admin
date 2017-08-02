Function Delete-EdgeCache {
    <#
    .SYNOPSIS
        Delete a named cache from Apigee Edge.

    .DESCRIPTION
        Delete a named cache from Apigee Edge.

    .PARAMETER Name
        Required. The name of the cache to delete.

    .PARAMETER Environment
        Required. The Edge environment that contains the named cache.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeCache -Environment test  cache101

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Environment,
        [string]$Org
    )

    $Options = @{ }
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options['Debug'] = $Debug
    }
    if ($PSBoundParameters['Org']) {
        $Options['Org'] = $Org
    }

    if (!$PSBoundParameters['Name']) {
        throw [System.ArgumentNullException] "Name", "The -Name parameter is required."
    }
    if (!$PSBoundParameters['Environment']) {
        throw [System.ArgumentNullException] "Environment", "The -Environment parameter is required."
    }

    $Options['Collection'] = $(Join-Parts -Separator "/" -Parts 'e', $Environment, 'caches' )
    $Options['Name'] = $Name

    Write-Debug $( [string]::Format("Delete-EdgeCache Options {0}", $(ConvertTo-Json $Options )))
    Delete-EdgeObject @Options
}
