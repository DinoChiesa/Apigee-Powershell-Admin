Function Delete-EdgeDevApp {
    <#
    .SYNOPSIS
        Delete an developer app from Apigee Edge.

    .DESCRIPTION
        Delete an developer app from Apigee Edge.

    .PARAMETER AppName
        Required. The name of the developer app to delete.

    .PARAMETER Name
        A synonym for AppName.
        
    .PARAMETER Developer
        Required. The developer that owns the app to delete.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeDevApp -Developer dchiesa@example.org -AppName abcdfege-1

    .LINK
        Create-EdgeDevApp
        
    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$AppName,
        [Parameter(Mandatory=$True)][string]$Developer,
        [string]$Org
    )

    $Options = @{ }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }
    if (!$PSBoundParameters['Developer']) {
        throw [System.ArgumentNullException] "Developer", 'use -AppName and -Developer.'
    }
    if (!$PSBoundParameters['Name'] -and !$PSBoundParameters['AppName']) {
        throw [System.ArgumentNullException] "AppName", 'use -AppName and -Developer.'
    }
    $RealAppName = if ($PSBoundParameters['AppName']) { $AppName } else { $Name }
    $Options.Add( 'Collection', $( Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps' ))
    $Options.Add( 'Name', $AppName )

    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    
    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )
    Delete-EdgeObject @Options
}
