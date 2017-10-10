Function Update-EdgeKvm {
    <#
    .SYNOPSIS
        Update a key-value map in Apigee Edge.

    .DESCRIPTION
        Update a key-value map in Apigee Edge, with all new values. All of the existing values will be removed. 
        The KVM must exist.

    .PARAMETER Name
        The name of the key-value map to update. 

    .PARAMETER Values
        Required. A hashtable specifying key/value pairs. Use in lieu of the -Source option.
        Example:
          @{
            key1 = 'value1'
            key2 = 'value2'
          }

    .PARAMETER Source
        Optional. A file containing JSON that specifis key/value pairs.  Use in
        lieu of the -Values option. Example contents:
          {
            "key1" : "value1", 
            "key2" : "value2"
          }

    .PARAMETER Environment
        Optional. A string, the name of the environment in Apigee Edge with which the keyvalue
        map is associated. KVMs can be associated to an organization, an environment, or an
        API Proxy. If you specify neither Environment nor Proxy, the default is to resolve the name of
        the KVM in the list of organization-wide Key-Value Maps.

    .PARAMETER Proxy
        Optional. The API Proxy within Apigee Edge with which the keyvalue map is
        associated. KVMs can be associated to an organization, an environment, or an API
        Proxy. If you specify neither Environment nor Proxy, the default is to resolve the name of the
        KVM in the list of organization-wide Key-Value Maps.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Update-EdgeKvm -Name kvm101 -Environment test -Values @{ key1  = 'value1'; key2 = 'value2' }

    .EXAMPLE
        Update-EdgeKvm -Name kvm101 -Environment test -Source .\myfile.json

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [hashtable]$Values,
        [string]$Source,
        [string]$Environment,
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

    if ($PSBoundParameters.ContainsKey('Environment') -and $PSBoundParameters.ContainsKey('Proxy')) {
        throw [System.ArgumentException] "You may specify only one of -Environment and -Proxy."
    }

    if (!$PSBoundParameters['Name']) {
        throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
    }

    if ($PSBoundParameters['Values']) {
        $Entries = $Values
    }
    elseif ($PSBoundParameters['Source']) {
        # Read data from the JSON file
        $json = Get-Content $Source -Raw | ConvertFrom-JSON
        $Entries = @{}
        $json.psobject.properties.name |% {
          $value = ''
          # convert non-primitives to strings containing json
          if (($json.$_).GetType().Name -eq 'PSCustomObject') {
            $value = $($json.$_ | ConvertTo-json -Compress ).ToString()
          }
          else {
            $value = $json.$_
          }
          $Entries[$_] = $value
      }
    }

    $basepath = if ($PSBoundParameters['Environment']) {
        $( Join-Parts -Separator '/' -Parts 'e', $Environment, 'keyvaluemaps' )
    }
    elseif ($PSBoundParameters['Proxy']) {
        $(Join-Parts -Separator "/" -Parts 'apis', $Proxy, 'keyvaluemaps' )
    }
    else {
        'keyvaluemaps'
    }

    # Query existing entries
    $Options['Collection'] = $basepath 
    $Options['Name'] = $Name
    $ExistingKvm = $( Get-EdgeObject @Options )

    # Delete existing entries
    $Options['Collection'] = $( Join-Parts -Separator '/' -Parts $basepath, $Name, 'entries' )
    $ExistingKvm.entry |% {
        $Options['Name'] = $_.name
        Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )
        Delete-EdgeObject @Options
    }

    $OrgProperties = $( Get-EdgeOrgPropertiesHt -Org $(if ($PSBoundParameters['Org']) { $Org } else { $MyInvocation.MyCommand.Module.PrivateData.Connection['Org'] } ) )
    
    if ($OrgProperties.ContainsKey("features.isCpsEnabled") -and $OrgProperties["features.isCpsEnabled"].Equals("true")) {
        # Add new entries
        $Options.Remove('Name')
        $Entries.keys |% {
            $Options['Payload'] = @{ name = $_; value = $Entries[$_] }
            Write-Debug ([string]::Format("Options {0}`n", $( ConvertTo-Json $Options -Compress ) ) )
            Send-EdgeRequest @Options
        } 
    }
    else {
        # Add entries in bulk. 
        $Options['Collection'] = $( Join-Parts -Separator '/' -Parts $basepath, $Name )
        $Options['Payload'] = @{
            name = $Name
            entry = @( $Entries.keys |% { @{ name = $_ ; value = $Entries[$_] } } )
        }
        Write-Debug ([string]::Format("Options {0}`n", $( ConvertTo-Json $Options -Compress ) ) )
        Send-EdgeRequest @Options
    }

    $Entries
    
    # if ( $Options['Payload'] -ne $Null ) { $Options.Remove('Payload') }
    # $Options['Collection'] = $basepath 
    # $Options['Name'] = $Name
    # # return existing KVM
    # Get-EdgeObject @Options
}
