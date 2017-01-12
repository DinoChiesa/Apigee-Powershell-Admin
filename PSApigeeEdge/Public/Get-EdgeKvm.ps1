Function Get-EdgeKvm {
    <#
    .SYNOPSIS
        Get one or more Key-Value Maps (KVMs) from Apigee Edge.

    .DESCRIPTION
        Get one or more Key-Value Maps (KVMs) from Apigee Edge.

    .PARAMETER Name
        Optional. The name of the specific KVM to retrieve.
        The default is to list all KVMs in scope (org or environment).

    .PARAMETER Env
        Optional. The Apigee Edge environment. KVMs can be associated to an organization, 
        an environment, or an API Proxy.  If you specify neither Env nor Proxy, the default 
        is to list or query the organization-wide Key-Value Maps.

    .PARAMETER Proxy
        Optional. The API Proxy within Apigee Edge. KVMs can be associated to an organization, 
        an environment, or an API Proxy.  If you specify neither Env nor Proxy, the default 
        is to list or query the organization-wide Key-Value Maps.

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
    
    if ($PSBoundParameters['Name']) {
        $Options.Add( 'Name', $Name )
    }

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )

    Get-EdgeObject @Options
}
