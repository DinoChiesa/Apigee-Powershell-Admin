Function Get-EdgeKvm {
    <#
    .SYNOPSIS
        Get one or more Key-Value Maps (KVMs) from Apigee Edge.

    .DESCRIPTION
        Get one or more Key-Value Maps (KVMs) from Apigee Edge.

    .PARAMETER Name
        Optional. The name of the KVM to retrieve.
        The default is to list all apiproxies.

    .PARAMETER Env
        Optional. The Apigee Edge environment. The default is to use the organization-wide
        Key-Value Map.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeKvm -Env test

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$Env,
        [string]$Org
        )
    
    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    
    if ($PSBoundParameters['Env']) {
        $Options['Collection'] = $(Join-Parts -Separator "/" -Parts 'e', $Env, 'keyvaluemaps' )
    }
    else {
         $Options['Collection'] = 'keyvaluemaps'
    }
    
    if ($PSBoundParameters['Name']) {
        $Options.Add( 'Name', $Name )
    }

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )

    Get-EdgeObject @Options
}
