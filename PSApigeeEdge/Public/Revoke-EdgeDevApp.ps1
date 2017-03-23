Function Revoke-EdgeDevApp {
    <#
    .SYNOPSIS
        Revoke a developer app in Apigee Edge.

    .DESCRIPTION
        Set the status of the developer app to 'Revoked', which means none of the credentials
        will be treated as valid, at runtime. Or, alternatively, revoke a single
        credential within a developer app.

    .PARAMETER Name
        The name of the app. You must specify the -Developer option if you use -Name.

    .PARAMETER AppId
        The id of the app. Use this in lieu of -Name and -Developer.

    .PARAMETER Developer
        The id or email of the developer that owns the app.

    .PARAMETER Key
        The Key to revoke. Use this to revoke a single credential, rather than the entire app.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Revoke-EdgeDevApp -Name abcdefg-1 -Developer Elaine@example.org

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Position=0,
         Mandatory=$True,
         ParameterSetName="byName",
         ValueFromPipeline=$True)]
        [string]$Name,

        [Parameter(Position=1,
         Mandatory=$True,
         ParameterSetName="byName",
         ValueFromPipeline=$True)]
        [string]$Developer,

        [Parameter(Position=0,
         Mandatory=$True,
         ParameterSetName="byAppId",
         ValueFromPipeline=$True)]
        [string]$AppId,

        [string]$Key,
        [string]$Org
    )

    $Options = @{
       QParams = $( ConvertFrom-HashtableToQueryString @{ action = 'revoke' } )
    }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options['Debug'] = $Debug
    }

    if ($PSBoundParameters['Developer']) {
        if (!$PSBoundParameters['Name']) {
          throw [System.ArgumentNullException] "Name", 'use -Name with -Developer'
        }
        if ($PSBoundParameters['Key']) {
            $Options['Collection'] = $( Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps', $Name, 'keys' )
            $Options['Name'] = $Key
        }
        else {
            $Options['Collection'] = $( Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps' )
            $Options['Name'] = $Name
        }
    }
    else {
        # I think this may not work.  It may not be possible to revoke an App via AppId
        if (!$PSBoundParameters['AppId']) {
          throw [System.ArgumentNullException] "AppId", 'use -AppId if not specifying -Name and -Developer'
        }
        if ($PSBoundParameters['Key']) {
            $Options['Collection'] = $( Join-Parts -Separator '/' -Parts 'apps', $AppId, 'keys' )
            $Options['Name'] = $Key
        }
        else {
          $Options['Collection'] = 'apps'
          $Options['Name'] = $AppId
        }
    }

    if ($PSBoundParameters['Org']) {
        $Options['Org'] = $Org
    }

    Send-EdgeRequest @Options
}
