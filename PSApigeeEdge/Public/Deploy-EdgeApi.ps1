Function Deploy-EdgeApi {
    <#
    .SYNOPSIS
        Deploy an apiproxy in Apigee Edge.

    .DESCRIPTION
        Deploy a revision of an API proxy that is not yet deployed.

    .PARAMETER Name
        Required. The name of the apiproxy to deploy.

    .PARAMETER Env
        Required. The name of the environment to which to deploy the api proxy.

    .PARAMETER Revision
        Required. The revision of the apiproxy.

    .PARAMETER Basepath
        Optional. The basepath to prepend to the proxy endpoints in the API proxy bundle.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Deploy-EdgeApi -Name oauth2-pwd-cc -Env test -Revision 8

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Env,
        [Parameter(Mandatory=$True)][string]$Revision,
        [string]$Org,
        [string]$Basepath,
        [Hashtable]$Params
    )

    Deploy-EdgeAsset -AssetType 'apis' -Name $Name -Env $Env -Revision $Revision -Org $Org -Basepath $Basepath  -Debug:$Debug -Params $Params
}
