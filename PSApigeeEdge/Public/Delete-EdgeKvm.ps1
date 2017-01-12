Function Delete-EdgeKvm {
    <#
    .SYNOPSIS
        Delete a key-value map from Apigee Edge.

    .DESCRIPTION
        Delete a key-value map from Apigee Edge.

    .PARAMETER Name
        Required. The name of the kvm to delete.
        
    .PARAMETER Env
        Optional. The environment within Apigee Edge with which the keyvaluemap is
        associated. KVMs can be associated to an organization, an environment, or an API
        Proxy. If you specify neither Env nor Proxy, the default is to find the named KVM in
        the list of organization-wide Key-Value Maps.

    .PARAMETER Proxy
        Optional. The API Proxy within Apigee Edge with which the keyvaluemap is
        associated. KVMs can be associated to an organization, an environment, or an API
        Proxy. If you specify neither Env nor Proxy, the default is to find the named KVM in
        the list of organization-wide Key-Value Maps.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeKvm dino-test-2

    .EXAMPLE
        Delete-EdgeKvm -Proxy apiproxy1 -Name dino-test-3

    .LINK
        Create-EdgeKvm

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Env,
        [string]$Proxy,
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
        throw [System.ArgumentNullException] "Name", "The -Name parameter is required."
    }

    if ($PSBoundParameters.ContainsKey('Env') -and $PSBoundParameters.ContainsKey('Proxy')) {
        throw [System.ArgumentException] "You may specify only one of -Env and -Proxy."    
    }

    if ($PSBoundParameters['Env']) {
        $Options['Collection'] = $(Join-Parts -Separator "/" -Parts 'e', $Env, 'keyvaluemaps' )
    }
    elseif ($PSBoundParameters['Proxy']) {
        $Options['Collection'] = $(Join-Parts -Separator "/" -Parts 'apis', $Proxy, 'keyvaluemaps' )
    }
    else {
        $Options['Collection'] = 'keyvaluemaps'
    }
    $Options.Add( 'Name', $Name )

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )
    
    Delete-EdgeObject @Options
}
