Function Get-EdgeKeystore {
    <#
    .SYNOPSIS
        Get information about a keystore from Apigee Edge.

    .DESCRIPTION
        Get information about a keystore from Apigee Edge.

    .PARAMETER Name
        Optional. The name of the specific keystore to retrieve.
        The default is to list all keystores in the environment.

    .PARAMETER Environment
        Required. The Apigee Edge environment.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeKeystore -Name ks1 -Environment test

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$False)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Environment,
        [string]$Org
        )

    $Options = @{ }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }

    if (!$PSBoundParameters['Environment']) {
      throw [System.ArgumentNullException] "Environment", "You must specify the -Environment option."
    }

    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    $Options.Add( 'Collection', $(Join-Parts -Separator "/" -Parts 'e', $Environment, 'keystores' ) )

    if ($PSBoundParameters['Name']) {
        $Options.Add( 'Name', $Name )
    }

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )

    Get-EdgeObject @Options
}
