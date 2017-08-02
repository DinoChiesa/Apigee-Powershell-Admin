Function Create-EdgeKeystore {
    <#
    .SYNOPSIS
        Create a keystore in Apigee Edge.

    .DESCRIPTION
        Create a keystore in Apigee Edge. A keystore holds a certificate and private key.

    .PARAMETER Name
        Required. The name to give to this new keystore. It must be unique in the environment.

    .PARAMETER Environment
        Required. The name of the environment in which to create the keystore.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Create-EdgeKeystore -Name ks1 -Environment test

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Environment,
        [string]$Org
    )

    $Options = @{ }

    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }

    if (!$PSBoundParameters['Environment']) {
      throw [System.ArgumentNullException] "Environment", "You must specify the -Environment option."
    }
    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
    }

    $Options['Collection'] = $(Join-Parts -Separator "/" -Parts 'e', $Environment, 'keystores' )

    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    $Payload = @{
      name = $Name
    }
    $Options.Add( 'Payload', $Payload )

    Send-EdgeRequest @Options
}
