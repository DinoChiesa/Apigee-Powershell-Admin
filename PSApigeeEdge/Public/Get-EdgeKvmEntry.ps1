Function Get-EdgeKvmEntry {
    <#
    .SYNOPSIS
        Get (read) an entry in a Key-Value Map (KVM) in Apigee Edge.

    .DESCRIPTION
        Get (read) an entry in a Key-Value Map (KVM) in Apigee Edge.
        The organization must be CPS-enabled. 

    .PARAMETER Name
        Required. The name of the specific KVM from which to retrieve.

    .PARAMETER Entry
        Required. The name of the specific entry in the KVM to retrieve.

    .PARAMETER Env
        Optional. The Apigee Edge environment. The default is to use the organization-wide
        Key-Value Map.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeKvmEntry -Env test -Name map1 -Entry key1

    .LINK
        Create-EdgeKvmEntry

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Entry,
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
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Entry']) {
      throw [System.ArgumentNullException] "Entry", "You must specify the -Entry option."
    }

    $basepath = if ($PSBoundParameters['Env']) {
        $(Join-Parts -Separator "/" -Parts 'e', $Env, 'keyvaluemaps' )
    }
    else {
        'keyvaluemaps'
    }
    $Options.Add( 'Collection', $(Join-Parts -Separator "/" -Parts $basepath, $Name, 'entries' ) )
    $Options.Add( 'Name', $Entry )

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )

    Get-EdgeObject @Options
}
