Function Get-EdgeAssetDeployment {
    <#
    .SYNOPSIS
        Get the deployment status for an apiproxy or sharedflow in Apigee Edge
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$AssetType,
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Org,
        [string]$Revision,
        [Hashtable]$Params
    )
    
    if (!$PSBoundParameters['AssetType']) {
      throw [System.ArgumentNullException] "AssetType", "You must specify the -AssetType option."
    }
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
    }

    $Options = @{
        Collection = $AssetType
    }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Params']) {
        $Options.Add( 'Params', $Params )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    
    if ($PSBoundParameters['Revision']) {
        $Path = Join-Parts -Separator "/" -Parts $Name, 'revisions', $Revision, 'deployments'
    }
    else {
        $Path = Join-Parts -Separator "/" -Parts $Name, 'deployments'
    }
    $Options.Add( 'Name', $Path )

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )

    if ( ! $PSBoundParameters['Revision'] ) {
        # an array of environments. Map it appropriately
        (Get-EdgeObject @Options).environment | % {
          @{ 'Environment' = $_.name; 'Revision' = $_.revision }
        }
    }
    else {
        (Get-EdgeObject @Options).environment 
    }

}
