Function Get-EdgeApiDeployment {
    <#
    .SYNOPSIS
        Get the deployment status for an apiproxy in Apigee Edge

    .DESCRIPTION
        Get the deployment status for an apiproxy in Apigee Edge

    .PARAMETER Name
        The name of the apiproxy to inquire.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeApiDeployment -Name oauth2-pwd-cc

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Org,
        [Hashtable]$Params
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "You must specify the -Name option."
    }

    $Options = @{
        Collection = 'apis'
    }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Params']) {
        $Options.Add( 'Params', $Params )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    
    $Path = Join-Parts -Separator "/" -Parts $Name, 'deployments'
    $Options.Add( 'Name', $Path )

    Write-Debug ( "Options @Options`n" )

    # an array of environments
    (Get-EdgeObject @Options).environment

}
