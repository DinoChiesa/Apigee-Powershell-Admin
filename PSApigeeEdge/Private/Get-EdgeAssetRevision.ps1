Function Get-EdgeAssetRevision {
    <#
    .SYNOPSIS
        Get the list of revisions for an apiproxy or sharedflow from Apigee Edge.
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$AssetType,
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Org
    )

    if (!$PSBoundParameters['AssetType']) {
      throw [System.ArgumentNullException] "AssetType", "You must specify the -AssetType option."
    }
    
    $Options = @{ Collection = $AssetType }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options['Debug'] = $Debug
    }
    if ($PSBoundParameters['Org']) {
        $Options['Org'] = $Org
    }

    if (!$PSBoundParameters['Name']) {
        throw [System.ArgumentNullException] "Name", 'the -Name parameter is required.'
    }
    $Options['Name'] = $( Join-Parts -Separator "/" -Parts $Name, 'revisions' )

    Write-Debug $( [string]::Format("Get-EdgeAssetRevision Options {0}", $(ConvertTo-Json $Options )))
    @( Get-EdgeObject @Options )
}
