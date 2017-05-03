Function Delete-EdgeSharedFlow {
    <#
    .SYNOPSIS
        Delete a sharedflow, or a revision of a sharedflow, from Apigee Edge.

    .DESCRIPTION
        Delete a sharedflow, or a revision of a sharedflow, from Apigee Edge.

    .PARAMETER Name
        Required. The name of the sharedflow to delete.
        
    .PARAMETER Revision
        Optional. The revision to delete. If not specified, all revisions will be deleted.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeSharedFlow common-error-handling

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Revision,
        [string]$Org
    )
    
    Delete-EdgeAsset -AssetType 'sharedflows' -Name $Name -Revision $Revision -Org $Org
}
