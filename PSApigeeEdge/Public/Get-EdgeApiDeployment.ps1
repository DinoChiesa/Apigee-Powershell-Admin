Function Get-EdgeApiDeployment {
    <#
    .SYNOPSIS
        Get the deployment status for an apiproxy in Apigee Edge

    .DESCRIPTION
        Get the deployment status for an apiproxy in Apigee Edge

    .PARAMETER Name
        Required. The name of the apiproxy to inquire.

    .PARAMETER Revision
        Optional. The revision of the named apiproxy to inquire.

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
        [string]$Revision,
        [Hashtable]$Params
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
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
    
    if ($PSBoundParameters['Revision']) {
        $Path = Join-Parts -Separator "/" -Parts $Name, 'revisions', $Revision, 'deployments'
    }
    else {
        $Path = Join-Parts -Separator "/" -Parts $Name, 'deployments'
    }
    $Options.Add( 'Name', $Path )

    Write-Debug ( "Options @Options`n" )

    if ( ! $PSBoundParameters['Revision'] ) {
        # an array of environments. Map it appropriately
        (Get-EdgeObject @Options).environment | % {
          @{ 'Environment' = $_.name; 'Revision' = $_.revision }
        }
    }
    else {
        (Get-EdgeObject @Options).environment 
    }

}
