Function Approve-EdgeDevApp {
    <#
    .SYNOPSIS
        Approve a developer app, or a credential within an app.

    .DESCRIPTION
        Set the status of the developer app to 'Approved', which means the credentials
        will be treated as valid, at runtime. Or, alternatively, approve a single
        credential within a developer app. 

    .PARAMETER AppName
        The name of the app. You must specify the -Developer option if you use -AppName. 

    .PARAMETER Name
        Synonum for AppName.

    .PARAMETER AppId
        The id of the app. Use this in lieu of -AppName and -Developer. 

    .PARAMETER Developer
        The id or email of the developer that owns the app.

    .PARAMETER Key
        The Key to revoke. Use this to revoke a single credential, rather than the entire app. 

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Revoke-EdgeDevApp -Name abcdefg-1 -Developer Elaine@example.org

    .EXAMPLE
        Revoke-EdgeDevApp -Name abcdefg-1 -Developer Elaine@example.org -Key B34aa6c286524cF1A8Dd

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [string]$Name,
        [string]$AppName,
        [string]$Developer,
        [string]$AppId,
        [string]$Key,
        [string]$Org
    )
    
    $Options = @{
       QParams = $( ConvertFrom-HashtableToQueryString @{ action = 'approve' } )
    }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    
    if ($PSBoundParameters['Developer']) {
        if (!$PSBoundParameters['Name'] -and !$PSBoundParameters['AppName']) {
            throw [System.ArgumentNullException] "AppName", 'use -AppName and -Developer.'
        }
        $RealAppName = if ($PSBoundParameters['AppName']) { $AppName } else { $Name }
        # also handle key approval?   Not sure I like this option. 
        if ($PSBoundParameters['Key']) {
            $Options.Add( 'Collection', $( Join-Parts -Separator '/' -Parts 'developers',
                                            $Developer, 'apps', $RealAppName, 'keys' ) )
            $Options.Add( 'Name', $Key)
        }
        else {
            $Options.Add( 'Collection', $( Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps' ) )
            $Options.Add( 'Name', $RealAppName)
        }
    }
    else {
        if (!$PSBoundParameters['AppId']) {
          throw [System.ArgumentNullException] "AppId", 'use -AppId if not specifying -AppName and -Developer'
        }
        if ($PSBoundParameters['Key']) {
            $Options.Add( 'Collection', $( Join-Parts -Separator '/' -Parts 'apps', $AppId, 'keys' ) )
            $Options.Add( 'Name', $Key)
        }
        else {
          $Options.Add( 'Collection', 'apps')
          $Options.Add( 'Name', $AppId)
        }
    }

    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    Write-Debug ([string]::Format("Options {0}`n", $(ConvertTo-Json $Options -Compress ) ) )
    Send-EdgeRequest @Options
}
