Function Approve-EdgeDevApp {
    <#
    .SYNOPSIS
        Approve a developer app in Apigee Edge

    .DESCRIPTION
        Set the status of the developer app to 'Approved', which means the credentials
        will be treated as valid, at runtime. 

    .PARAMETER Name
        The name of the app. You must specify the -Developer option if you use -Name. 

    .PARAMETER Id
        The id of the app. Use this in lieu of -Name and -Developer. 

    .PARAMETER Developer
        The id or email of the developer that owns the app.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Revoke-EdgeDevApp -Name abcdefg-1 -Developer Elaine@example.org

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$Developer,
        [string]$Id,
        [string]$Org
    )
    
    $Options = @{
       QParams = $( ConvertFrom-HashtableToQueryString @{ action = 'approve' } )
    }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    
    if ($PSBoundParameters['Developer']) {
        if (!$PSBoundParameters['Name']) {
          throw [System.ArgumentNullException] 'use -Name with -Developer'
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

    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    Send-EdgeRequest @Options
}
