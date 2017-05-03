Function Get-EdgeSharedFlow {
    <#
    .SYNOPSIS
        Get one or more sharedflows from Apigee Edge.

    .DESCRIPTION
        Get one or more sharedflows from Apigee Edge.

    .PARAMETER Name
        Optional. The name of the sharedflow to retrieve.
        The default is to list all of them.

    .PARAMETER Revision
        Optional. The revision of the sharedflow. Use only when also using the -Name option.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeSharedFlow -Org cap500

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$Revision,
        [string]$Org
    )

    Get-EdgeAsset -AssetType 'sharedflows' -Name $Name -Revision $Revision -Org $Org
}