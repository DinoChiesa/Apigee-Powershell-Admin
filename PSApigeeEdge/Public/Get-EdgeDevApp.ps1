Function Get-EdgeDevApp {
    <#
    .SYNOPSIS
        Get one or more developer apps from Apigee Edge.

    .DESCRIPTION
        Get one or more developer apps from Apigee Edge.

    .PARAMETER Id
        The id of the developer app to retrieve.
        The default is to list all developer app IDs.
        Do not specify this if specifying -Name.

    .PARAMETER Name
        The name of the particular developer app to retrieve. You must specify -Developer when
        using this option. 

    .PARAMETER Developer
        The id or email of the developer for which to retrieve apps.
        The default is to list apps for all developers.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeDevApp -Org cap500

    .EXAMPLE
        Get-EdgeDevApp -Id  32ae4dbe-2e39-4225-b994-242042089723

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [string]$Name,
        [string]$Developer,
        [string]$Id,
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
        if ($PSBoundParameters['Name']) {
            $Options.Add( 'Name', $Name )
        }
    }
    else {
        $Options.Add( 'Collection', 'apps')
        if ($PSBoundParameters['Id']) {
            $Options.Add( 'Name', $Id )
        }
    }

    Get-EdgeObject @Options
}
