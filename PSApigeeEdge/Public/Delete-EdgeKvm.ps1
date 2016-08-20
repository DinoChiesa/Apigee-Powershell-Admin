Function Delete-EdgeKvm {
    <#
    .SYNOPSIS
        Delete a key-value map from Apigee Edge.

    .DESCRIPTION
        Delete a key-value map from Apigee Edge.

    .PARAMETER Name
        The name of the kvm to delete.
        
    .PARAMETER Env
        Optional. The environment in which the KVM is found. If not specified, it operates
        on an organization-scoped KVM.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeKvm dino-test-2

    .LINK
        Create-EdgeKvm

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
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
    
    if (!$PSBoundParameters['Name']) {
        throw [System.ArgumentNullException] "The -Name parameter is required."
    }
    
    if ($PSBoundParameters['Env']) {
        $Options['Collection'] = $(Join-Parts -Separator "/" -Parts 'e', $Env, 'keyvaluemaps' )
    }
    else {
        $Options['Collection'] = 'keyvaluemaps'
    }
    $Options.Add( 'Name', $Name )

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )
    
    Delete-EdgeObject @Options
}
