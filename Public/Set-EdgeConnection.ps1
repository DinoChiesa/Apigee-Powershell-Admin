Function Set-EdgeConnection {
    <#
    .SYNOPSIS
        Sets connection information for Apigee Edge administrative actions

    .DESCRIPTION
        Sets connection information, including Organization name, and user credentials, for Apigee Edge administrative actions.

    .PARAMETER Org
        The Apigee Edge organization. 

    .PARAMETER User
        The Apigee Edge administrative user. 

    .PARAMETER Pass
        The password for the Apigee Edge administrative user. 

    .PARAMETER MgmtUri
        The base Uri for the Edge API Management server.

        Default: https://api.enterprise.apigee.com

    .EXAMPLE
        Set-EdgeConnection -Org cap500 -User dino@apigee.com -Pass Secret1XYZ

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Org,
        [string]$User,
        [string]$Pass,
        [string]$MgmtUri = 'https://api.enterprise.apigee.com'
    )

    if( $PSBoundParameters.ContainsKey('Org')) {
      $MyInvocation.MyCommand.Module.PrivateData['Org'] = $Org
    }
    
    if(! $PSBoundParameters.ContainsKey('User') -or 
      ! $PSBoundParameters.ContainsKey('Pass')) {
        throw [System.ArgumentNullException] "provide -User and -Pass."
    }
    
    $MyInvocation.MyCommand.Module.PrivateData['MgmtUri'] = $MgmtUri
    $MyInvocation.MyCommand.Module.PrivateData['User'] = $User
    $pair = "${User}:${Pass}"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $secureString = ConvertTo-SecureString -Force -AsPlainText $base64
    $MyInvocation.MyCommand.Module.PrivateData['AuthToken'] = $secureString
    
    Remove-Variable $base64
    Remove-Variable $Pass
    Remove-Variable $pair
    Remove-Variable $bytes
}
