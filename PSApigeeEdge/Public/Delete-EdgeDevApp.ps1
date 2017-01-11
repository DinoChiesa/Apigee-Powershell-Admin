Function Delete-EdgeDevApp {
    <#
    .SYNOPSIS
        Delete an developer app from Apigee Edge.

    .DESCRIPTION
        Delete an developer app from Apigee Edge.

    .PARAMETER Name
        Required. The name of the app to delete. Use this with -Developer. 
        
    .PARAMETER Developer
        Required. The developer that owns the app to delete. Use this with -Name.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeDevApp -Developer dchiesa@example.org -Name abcdfege-1

    .LINK
        Create-EdgeDevApp
        
    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Developer,
        [string]$Org
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    
    $Options = @{ }
    
    if (!$PSBoundParameters['Developer']) {
        throw [System.ArgumentNullException] "Developer", 'use -Name and -Developer.'
    }
    if (!$PSBoundParameters['Name']) {
        throw [System.ArgumentNullException] "Name", 'use -Name and -Developer.'
    }

    $Options.Add( 'Collection', $( Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps'))
    $Options.Add( 'Name', $Name)

    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    
    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )

    Delete-EdgeObject @Options
}
