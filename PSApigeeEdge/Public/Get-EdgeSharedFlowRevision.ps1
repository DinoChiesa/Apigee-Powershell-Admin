Function Get-EdgeSharedFlowRevision {
    <#
    .SYNOPSIS
        Get the list of revisions for a sharedflow from Apigee Edge.

    .DESCRIPTION
        Get the list of revisions for a sharedflow from Apigee Edge.

    .PARAMETER Name
        Required. The name of the sharedflow to retrieve.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeSharedFlowRevision -Name common-error-handling

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Org
    )
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    @( Get-EdgeAssetRevision -AssetType 'sharedflows' -Name $Name -Org $Org )
}
