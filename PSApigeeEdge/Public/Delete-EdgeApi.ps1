Function Delete-EdgeApi {
    <#
    .SYNOPSIS
        Delete an apiproxy, or a revision of an apiproxy, from Apigee Edge.

    .DESCRIPTION
        Delete an apiproxy, or a revision of an apiproxy, from Apigee Edge.

    .PARAMETER Name
        Required. The name of the apiproxy to delete.
        
    .PARAMETER Revision
        Optional. The revision to delete. If not specified, all revisions will be deleted.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeApi dino-test-2

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Revision,
        [string]$Org
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    Delete-EdgeAsset -AssetType 'apis' -Name $Name -Revision $Revision -Org $Org
}
