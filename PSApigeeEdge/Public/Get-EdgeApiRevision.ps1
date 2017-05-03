Function Get-EdgeApiRevision {
    <#
    .SYNOPSIS
        Get the list of revisions for an apiproxy from Apigee Edge.

    .DESCRIPTION
        Get the list of revisions for an apiproxy from Apigee Edge.

    .PARAMETER Name
        Required. The name of the apiproxy to retrieve.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeApiRevision -Name myapiproxy

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Org
    )
    @(Get-EdgeAssetRevision -AssetType 'apis' -Name $Name -Org $Org )
}
