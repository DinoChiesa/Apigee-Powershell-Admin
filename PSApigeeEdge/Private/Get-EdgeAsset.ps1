Function Get-EdgeAsset {
    [cmdletbinding()]
    param(
        [string]$Collection,
        [string]$Name,
        [string]$Revision,
        [string]$Org
    )

    if (!$PSBoundParameters['Collection']) {
        throw [System.ArgumentNullException] "Collection", "You must specify the -Collection option."
    }
    $Options = @{ Collection = $Collection }

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

