Function Delete-EdgeKvmEntry {
    <#
    .SYNOPSIS
        Delete an entry from a Key-Value map in Apigee Edge.

    .DESCRIPTION
        Delete an entry from a Key-Value map in Apigee Edge.
        This works only in CPS-enabled Edge organizations. 

    .PARAMETER Name
        Required. The name of the KVM from which to delete an entry.
        
    .PARAMETER Entry
        Required. The name of the KVM entry to delete.
        
    .PARAMETER Env
        Optional. The environment in which the keystore is found. 

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeKvmEntry -Name kvm-2 -Env test -Entry key1

    .LINK
        Create-EdgeKvmEntry

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
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
      throw [System.ArgumentNullException] "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Entry']) {
      throw [System.ArgumentNullException] "You must specify the -Entry option."
    }

    $basepath = if ($PSBoundParameters['Env']) {
        $(Join-Parts -Separator "/" -Parts 'e', $Env, 'keyvaluemaps' )
    }
    else {
        'keyvaluemaps' 
    }
    $Options.Add( 'Collection', $( Join-Parts -Separator '/' -Parts $basepath, $Name, 'entries' ) )
    $Options.Add( 'Name', $Entry )

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )
    
    Delete-EdgeObject @Options
}
