Function Find-EdgeApp {
    <#
    .SYNOPSIS
        Finds an Edge App given the API Key. 

    .DESCRIPTION
        Finds an Edge App given the API Key. The result is the developer app that 
        owns the credential with that API key.

    .PARAMETER ConsumerKey
        The API key to find. 

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Find-EdgeApp -ConsumerKey B792a022098d48618c6d 

    .LINK
        Add-EdgeAppCredential

    .LINK
        Get-EdgeAppCredential

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [string]$ConsumerKey,
        [string]$Org
    )


    $Options = @{ }

    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }

    if (!$PSBoundParameters['ConsumerKey']) {
        throw [System.ArgumentNullException] "ConsumerKey", "You must specify the -ConsumerKey option."
    }

    # $appsExpanded = @(Get-EdgeDevApp -Params @{ expand = 'true' }).app
    
    $theApp = @( @( Get-EdgeDevApp -Params @{ expand = 'true' }).app |? {
                     $_.credentials |? { $_.consumerKey -eq $ConsumerKey }
                 })
    
    if ($theApp.count -gt 1) {
        throw [System.SystemException] "More than one app was found with that key."
    }
    if ($theApp.count -eq 0) {
        $Null
    }
    else {
        $theApp[0]
    }
}
