Function Delete-EdgeDevApp {
    <#
    .SYNOPSIS
        Delete an developer app from Apigee Edge.

    .DESCRIPTION
        Delete an developer app from Apigee Edge.

    .PARAMETER AppId
        The id of the developer app to delete. Use this instead of -Name and -Developer. 
        
    .PARAMETER Name
        The name of the app to delete. Use this with -Developer. 
        
    .PARAMETER Developer
        The developer that owns the app to delete. Use this with -Name.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeDevApp -Developer dchiesa@example.org -Name abcdfege-1

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$Developer,
        [string]$AppId,
        [string]$Org
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    
    $Options = @{ }
    
    if ($PSBoundParameters['Developer']) {
        if (!$PSBoundParameters['Name']) {
          throw [System.ArgumentNullException] 'use -Name with -Developer.'
        }
        $Options.Add( 'Collection', $( Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps' ) )
        $Options.Add( 'Name', $Name)
    }
    else {
        if (!$PSBoundParameters['Id']) {
          throw [System.ArgumentNullException] 'use -Id if not specifying -Name and -Developer'
        }
        $Options.Add( 'Collection', 'apps')
        $Options.Add( 'Name', $Id)
    }

    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    
    Write-Debug ( "Options @Options`n" )

    Delete-EdgeObject @Options
}
