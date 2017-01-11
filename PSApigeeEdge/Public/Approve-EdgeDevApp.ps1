Function Approve-EdgeDevApp {
    <#
    .SYNOPSIS
        Approve a developer app, or a credential within an app.

    .DESCRIPTION
        Set the status of the developer app to 'Approved', which means the credentials
        will be treated as valid, at runtime. Or, alternatively, approve a single
        credential within a developer app. 

    .PARAMETER Name
        The name of the app. You must specify the -Developer option if you use -Name. 

    .PARAMETER Id
        The id of the app. Use this in lieu of -Name and -Developer. 

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
         ParameterSetName="byId",
         ValueFromPipeline=$True)]
        [string]$Id,
        
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
        if (!$PSBoundParameters['Name']) {
          throw [System.ArgumentNullException] "Name", 'use -Name with -Developer'
        }
        if ($PSBoundParameters['Key']) {
            $Options.Add( 'Collection', $( Join-Parts -Separator '/' -Parts 'developers',
                                            $Developer, 'apps', $Name, 'keys' ) )
            $Options.Add( 'Name', $Key)
        }
        else {
            $Options.Add( 'Collection', $( Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps' ) )
            $Options.Add( 'Name', $Name)
        }
    }
    else {
        if (!$PSBoundParameters['Id']) {
          throw [System.ArgumentNullException] "Id", 'use -Id if not specifying -Name and -Developer'
        }
        if ($PSBoundParameters['Key']) {
            $Options.Add( 'Collection', $( Join-Parts -Separator '/' -Parts 'apps', $Id, 'keys' ) )
            $Options.Add( 'Name', $Key)
        }
        else {
          $Options.Add( 'Collection', 'apps')
          $Options.Add( 'Name', $Id)
        }
    }

    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    Send-EdgeRequest @Options
}
