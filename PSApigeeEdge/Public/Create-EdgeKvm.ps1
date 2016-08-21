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
        Optional. A hashtable specifying key/value pairs. Use in lieu of the -Source option.
        Example:
          @{
            key1 = 'value1'
            key2 = 'value2'
          }
          
    .PARAMETER Source
        Optional. A file containing JSON that specifis key/value pairs.  Use in
        lieu of the -Values option. 

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
        [hashtable]$Values,
        [string]$Source,
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
    if (!$PSBoundParameters['Values'] -and !$PSBoundParameters['Source']) {
      throw [System.ArgumentNullException] "You must specify either the -Values or -Source option."
    }

    $Payload = @{ name = $Name }
    
    if ($PSBoundParameters['Values']) {
      $Payload['entry'] = @( $Values.keys |% { @{ name = $_ ; value = $Values[$_] } } )
    }
    else {
      # Read data from the JSON file 
      $json = Get-Content $Source -Raw | ConvertFrom-JSON
      $Payload['entry'] = @( $json.psobject.properties.name |% {
          $value = ''
          # convert non-primitives to strings containing json
          if (($json.$_).GetType().Name -eq 'PSCustomObject') {
            $value = $($json.$_ | ConvertTo-json  -Compress ).ToString()
          }
          else {
            $value = $json.$_ 
          }
          @{ name =  $_ ; value = $value } 
      } )
    }
    
    if ($PSBoundParameters['Env']) {
      $Options['Collection'] = $( Join-Parts -Separator '/' -Parts 'e', $Env, 'keyvaluemaps' )
    }
    else {
      $Options['Collection'] = 'keyvaluemaps'
    }
    
    $Options.Add( 'Payload', $Payload )

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )
    
    Send-EdgeRequest @Options
}
