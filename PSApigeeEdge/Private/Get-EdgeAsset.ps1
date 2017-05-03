Function Get-EdgeAsset {
    [cmdletbinding()]
    param(
        [string]$AssetType,
        [string]$Name,
        [string]$Revision,
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

    if ($PSBoundParameters['Name']) {
      if ($PSBoundParameters['Revision']) {
        $Path = Join-Parts -Separator "/" -Parts $Name, 'revisions', $Revision
        $Options['Name'] = $Path
      }
      else {
        $Options['Name'] = $Name
      }
    }

    Write-Debug $( [string]::Format("Get-Edge{0} Options {1}", (Get-Culture).TextInfo.ToTitleCase($Collection), $(ConvertTo-Json $Options )))
    Get-EdgeObject @Options
}

