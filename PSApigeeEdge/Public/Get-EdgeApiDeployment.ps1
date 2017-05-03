Function Get-EdgeApiDeployment {
    <#
    .SYNOPSIS
        Get the deployment status for an apiproxy in Apigee Edge

    .DESCRIPTION
        Get the deployment status for an apiproxy in Apigee Edge

    .PARAMETER Name
        Required. The name of the apiproxy to inquire.

    .PARAMETER Revision
        Optional. The revision of the named apiproxy to inquire.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeApiDeployment -Name oauth2-pwd-cc

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

    Get-EdgeAssetDeployment -AssetType 'apis' -Name $Name -Org $Org -Revision $Revision -Params $Params     
}
