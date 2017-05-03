Function UnDeploy-EdgeApi {
    <#
    .SYNOPSIS
        UnDeploy an apiproxy in Apigee Edge.

    .DESCRIPTION
        UnDeploy a revision of an API proxy that is deployed.

    .PARAMETER Name
        Required. The name of the apiproxy to undeploy.

    .PARAMETER Env
        Required. The name of the environment from which to undeploy the api proxy.

    .PARAMETER Revision
        Required. The revision of the apiproxy.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        UnDeploy-EdgeApi -Name oauth2-pwd-cc -Env test -Revision 2

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

    UnDeploy-EdgeAsset -AssetType 'apis' -Name $Name -Env $Env -Revision $Revision -Org $Org -Debug:$Debug
}
