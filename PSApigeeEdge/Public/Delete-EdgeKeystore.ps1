Function Delete-EdgeKeystore {
    <#
    .SYNOPSIS
        Delete a keystore from Apigee Edge.

    .DESCRIPTION
        Delete a keystore from Apigee Edge.

    .PARAMETER Name
        Required. The name of the keystore to delete.

    .PARAMETER Environment
        Required. The environment in which the keystore is found.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeKeystore -Name dino-test-2 -Environment test

    .LINK
        Create-EdgeKeystore

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
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Environment']) {
      throw [System.ArgumentNullException] "Environment", "You must specify the -Environment option."
    }

    $Options.Add( 'Collection', $(Join-Parts -Separator "/" -Parts 'e', $Environment, 'keystores' ) )
    $Options.Add( 'Name', $Name )

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )

    Delete-EdgeObject @Options
}
