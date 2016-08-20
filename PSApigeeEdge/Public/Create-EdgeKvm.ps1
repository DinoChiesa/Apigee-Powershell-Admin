Function Create-EdgeKvm {
    <#
    .SYNOPSIS
        Create a named key-value map in Apigee Edge.

    .DESCRIPTION
        Create a named key-value map in Apigee Edge.

    .PARAMETER Name
        The name of the key-value map to create. It must be unique for the scope
        (organization or environment). 

    .PARAMETER Values
        Required. A hashtable specifying key/value pairs. Eg,

    .PARAMETER Env
        Optional. A string, the name of the environment for this key-value map.
        The default behavior is to create an organization-wide KVM. 

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Create-EdgeKvm -Name kvm101 -Env test -Values @{ key1 = 'value1'; key2 = 'value2' }

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][hashtable]$Values,
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
    if (!$PSBoundParameters['Values']) {
      throw [System.ArgumentNullException] "You must specify the -Values option."
    }

    if ($PSBoundParameters['Env']) {
      $Options['Collection'] = $( Join-Parts -Separator '/' -Parts 'e', $Env, 'keyvaluemaps' )
    }
    else {
      $Options['Collection'] = 'keyvaluemaps'
    }
      
    $Payload = @{
      name = $Name
      entry = @( $Values.keys |% { @{ name = $_ ; value = $map[$_] } } )
    }
    
    $Options.Add( 'Payload', $Payload )

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )
    
    Send-EdgeRequest @Options
}
