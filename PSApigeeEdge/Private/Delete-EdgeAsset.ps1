Function Delete-EdgeAsset {
    <#
    .SYNOPSIS
        Delete an apiproxy or sharedflow, or a revision of same, from Apigee Edge.
    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$AssetType,
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Revision,
        [string]$Org
    )
    
    if (!$PSBoundParameters['AssetType']) {
        throw [System.ArgumentNullException] "AssetType", "You must specify the -AssetType option."
    }

    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    
    if (!$PSBoundParameters['Name']) {
        throw [System.ArgumentNullException] "Name", "The -Name parameter is required."
    }
    
    if ($PSBoundParameters['Revision']) {
        $Options.Add( 'Collection', $(Join-Parts -Separator "/" -Parts $AssetType, $Name, 'revisions' ) )
        $Options.Add( 'Name', $Revision )
    }
    else {
        $Options.Add( 'Collection', $AssetType )
        $Options.Add( 'Name', $Name )
    }

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )
    Delete-EdgeObject @Options
}
