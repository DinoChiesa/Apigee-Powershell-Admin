Function Deploy-EdgeSharedFlow {
    <#
    .SYNOPSIS
        Deploy a sharedflow in Apigee Edge.

    .DESCRIPTION
        Deploy a revision of a sharedflow that is not yet deployed. It must exist.

    .PARAMETER Name
        Required. The name of the sharedflow to deploy.

    .PARAMETER Env
        Required. The name of the environment to which to deploy the sharedflow.

    .PARAMETER Revision
        Required. The revision of the sharedflow.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Deploy-EdgeSharedFlow -Name sf-1 -Env test -Revision 8

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Env,
        [Parameter(Mandatory=$True)][string]$Revision,
        [string]$Org,
        [Hashtable]$Params
    )

    Deploy-EdgeAsset -AssetType 'apis' -Name $Name -Env $Env -Revision $Revision -Org $Org -Params $Params  -Debug:$Debug
}
