Function Get-EdgeDevApp {
    <#
    .SYNOPSIS
        Get one or more developer apps from Apigee Edge

    .DESCRIPTION
        Get one or more developer apps from Apigee Edge

    .PARAMETER Id
        The id of the developer app to retrieve.
        The default is to list all developer app IDs.
        Do not specify this if specifying -Name.

    .PARAMETER Name
        The name of the developer app to retrieve. You must specify -Developer when
        using this option. 

    .PARAMETER Developer
        The id or email of the developer for which to retrieve apps.
        The default is to list all developer app IDs.

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
    param(
        [string]$Id,
        [string]$Name,
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
            $NameToUse = Join-Parts -Separator '/' -Parts $Developer, 'apps', $Id 
        }
        else if ($PSBoundParameters['Name']) {
            $NameToUse = Join-Parts -Separator '/' -Parts $Developer, 'apps', $Name 
        }
        else {
            $NameToUse = Join-Parts -Separator '/' -Parts $Developer, 'apps' 
       }
       $Options.Add( 'Name', $NameToUse )
    }
    else {
        $Options.Add( 'Collection', 'apps')
        if ($PSBoundParameters['Id']) {
            $Options.Add( 'Name', $Id )
        }
    }

    Get-EdgeObject @Options
}
