Function Get-EdgeDevApp {
    <#
    .SYNOPSIS
        Get one or more developer apps from Apigee Edge.

    .DESCRIPTION
        Get one or more developer apps from Apigee Edge.

    .PARAMETER AppId
        The id of the developer app to retrieve.
        The default is to list all developer app IDs.
        Do not specify this if specifying -AppName.

    .PARAMETER AppName
        The name of the particular developer app to retrieve. You must specify -Developer when
        using this option. 

    .PARAMETER Developer
        The id or email of the developer for which to retrieve apps.
        The default is to list apps for all developers.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        $appset = @( Get-EdgeDevApp -Params @{ expand = $True } )

    .EXAMPLE
        Get-EdgeDevApp -Org cap500

    .EXAMPLE
        Get-EdgeDevApp -Id 32ae4dbe-2e39-4225-b994-242042089723

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    PARAM(
        [string]$AppName,
        [string]$Developer,
        [string]$AppId,
        [string]$Org,
        [Hashtable]$Params
    )
    
    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Params']) {
        $Options.Add( 'Params', $Params )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    if ($PSBoundParameters['Developer']) {
        $Options.Add( 'Collection', $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps' ) )
        if ($PSBoundParameters['AppName']) {
            $Options.Add( 'Name', $AppName )
        }
    }
    else {
        $Options.Add( 'Collection', 'apps')
        if ($PSBoundParameters['AppId']) {
            $Options.Add( 'Name', $AppId )
        }
    }

    Get-EdgeObject @Options
}
