Function Update-EdgeKvmEntry {
    <#
    .SYNOPSIS
        Update a specific, named entry in a key-value map in Apigee Edge.

    .DESCRIPTION
        Update a specific, named entry in a key-value map in Apigee Edge.
        The KVM must exist, and the entry must exist.

    .PARAMETER Name
        The name of the key-value map, in which the entry exists.

    .PARAMETER Entry
        Required. The name (or key) of the value to update.

    .PARAMETER NewValue
        Required. A string value to use for the entry.

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
        Update-EdgeKvmEntry -Name kvm101 -Environment test -Entry key1 -NewValue 'updated value'

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Entry,
        [Parameter(Mandatory=$True)][string]$NewValue,
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
    if (!$PSBoundParameters['Entry']) {
      throw [System.ArgumentNullException] "Entry", "You must specify the -Entry option."
    }
    if (!$PSBoundParameters['NewValue']) {
      throw [System.ArgumentNullException] "NewValue", "You must specify the -NewValue option."
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

    $OrgProperties = $( Get-EdgeOrgPropertiesHt -Org $(if ($PSBoundParameters['Org']) { $Org } else { $MyInvocation.MyCommand.Module.PrivateData.Connection['Org'] }) )
    if ($OrgProperties.ContainsKey("features.isCpsEnabled") -and $OrgProperties["features.isCpsEnabled"].Equals("true")) {
        $Options.Add( 'Collection', $( Join-Parts -Separator '/' -Parts $basepath, $Name, 'entries', $Entry ) )
        $Options.Add( 'Payload', @{ name = $Entry; value = $NewValue } )
    }
    else {
        $Options.Add( 'Collection', $( Join-Parts -Separator '/' -Parts $basepath, $Name ) )
        $Options.Add( 'Payload', @{
                          name = $Name
                          entry = @(
                              @{
                                  name = $Entry
                                  value = $NewValue
                              }
                          )
                      } )
    }

    Write-Debug ([string]::Format("Options {0}`n", $( ConvertTo-Json $Options -Compress ) ) )

    Send-EdgeRequest @Options
}
