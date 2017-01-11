Function Update-EdgeKvmEntry {
    <#
    .SYNOPSIS
        Update a named entry in a key-value map in Apigee Edge.

    .DESCRIPTION
        Update a named entry in a key-value map in Apigee Edge.
        The KVM must exist, and the entry must exist.  This works only on CPS-enabled organizations.

    .PARAMETER Name
        The name of the key-value map, in which the entry exists. 

    .PARAMETER Entry
        Required. The name (or key) of the value to update.

    .PARAMETER NewValue
        Required. A string value to use for the entry.
          
    .PARAMETER Env
        Optional. A string, the name of the environment for this key-value map.
        The default behavior is to create an organization-wide KVM. 

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Update-EdgeKvmEntry -Name kvm101 -Env test -Entry key1 -NewValue 'updated value'

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Entry,
        [Parameter(Mandatory=$True)][string]$NewValue,
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
    if (!$PSBoundParameters['NewValue']) {
      throw [System.ArgumentNullException] "You must specify the -NewValue option."
    }
    
    $basepath = if ($PSBoundParameters['Env']) {
        $( Join-Parts -Separator '/' -Parts 'e', $Env, 'keyvaluemaps' )
    }
    else {
        'keyvaluemaps'
    }
    
    $Options.Add( 'Collection', $( Join-Parts -Separator '/' -Parts $basepath, $Name, 'entries', $Entry ) )
    $Options.Add( 'Payload', @{ name = $Entry; value = $NewValue } )

    Write-Debug ([string]::Format("Options {0}`n", $( ConvertTo-Json $Options -Compress ) ) )
    
    Send-EdgeRequest @Options
}
