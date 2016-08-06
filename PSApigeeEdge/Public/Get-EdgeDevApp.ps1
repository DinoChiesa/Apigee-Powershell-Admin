Function Get-EdgeDevApp {
    <#
    .SYNOPSIS
        Get one or more developer apps from Apigee Edge

    .DESCRIPTION
        Get one or more developer apps from Apigee Edge

    .PARAMETER Id
        The id of the developer app to retrieve.
        The default is to list all developer app IDs.

    .PARAMETER Developer
        The id or email of the developer for which to retrieve apps.
        The default is to list all developer app IDs.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeDevApp -Org cap500

    .EXAMPLE
        Get-EdgeDeveloper -Id xxxx

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Id,
        [string]$Developer,
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

    if ($PSBoundParameters['Developer']) {
        $Options.Add( 'Collection', 'developers')
        if ($PSBoundParameters['Id']) {
            $Options.Add( 'Name', Join-Parts -Separator '/' -Parts $Developer, 'apps', $Id )
        }
        else {
            $Options.Add( 'Name', Join-Parts -Separator '/' -Parts $Developer, 'apps' )
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
