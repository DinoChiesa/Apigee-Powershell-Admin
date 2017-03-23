Function Get-EdgeOrganization {
    <#
    .SYNOPSIS
        Get information regarding an organization in Apigee Edge.

    .DESCRIPTION
        Get information regarding an organization in Apigee Edge.
        You might want to do this to query whether CPS is enabled on an org, for example.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeOrganization -Org cap500

    .LINK
        Get-EdgeEnvironment

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    param(
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

    Write-Debug $( [string]::Format("Get-EdgeOrganization Options {0}", $(ConvertTo-Json $Options )))
    Get-EdgeObject @Options
}
