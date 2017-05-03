Function UnDeploy-EdgeSharedFlow {
    <#
    .SYNOPSIS
        UnDeploy an sharedflow in Apigee Edge.

    .DESCRIPTION
        UnDeploy a revision of a sharedflow that is deployed.

    .PARAMETER Name
        Required. The name of the sharedflow to undeploy.

    .PARAMETER Env
        Required. The name of the environment from which to undeploy the sharedflow.

    .PARAMETER Revision
        Required. The revision of the sharedflow.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        UnDeploy-EdgeSharedFlow -Name sf1a -Env test -Revision 2

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Env,
        [Parameter(Mandatory=$True)][string]$Revision,
        [string]$Org
    )

    UnDeploy-EdgeAsset -AssetType 'sharedflows' -Name $Name -Env $Env -Revision $Revision -Org $Org
}
