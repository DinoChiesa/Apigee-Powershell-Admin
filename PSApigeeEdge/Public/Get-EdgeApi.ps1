Function Get-EdgeApi {
    <#
    .SYNOPSIS
        Get one or more apiproxies from Apigee Edge.

    .DESCRIPTION
        Get one or more apiproxies from Apigee Edge.

    .PARAMETER Name
        Optional. The name of the apiproxy to retrieve.
        The default is to list all apiproxies.

    .PARAMETER Revision
        Optional. The revision of the apiproxy. Use only when also using the -Name option.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeApi -Org cap500

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$Revision,
        [string]$Org
    )

    Get-EdgeAsset -AssetType 'apis' -Name $Name -Revision $Revision -Org $Org
}
