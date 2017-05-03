Function Get-EdgeSharedFlowDeployment {
    <#
    .SYNOPSIS
        Get the deployment status for a sharedflow in Apigee Edge

    .DESCRIPTION
        Get the deployment status for a sharedflow in Apigee Edge

    .PARAMETER Name
        Required. The name of the sharedflow to inquire.

    .PARAMETER Revision
        Optional. The revision of the named sharedflow to inquire.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeSharedFlowDeployment -Name sf1a

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Org,
        [string]$Revision,
        [Hashtable]$Params
    )

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    Get-EdgeAssetDeployment -AssetType 'sharedflows' -Name $Name -Org $Org -Revision $Revision -Params $Params     
}
