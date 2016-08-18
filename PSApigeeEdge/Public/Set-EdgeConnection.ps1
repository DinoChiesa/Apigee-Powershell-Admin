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
        [Parameter(Mandatory=$True)][string]$User,
        [string]$Password,
        [string]$EncryptedPassword,
        [string]$MgmtUri = 'https://api.enterprise.apigee.com'
    )

    if( $PSBoundParameters.ContainsKey('Org')) {
      $MyInvocation.MyCommand.Module.PrivateData['Org'] = $Org
    }
    
    if(! $PSBoundParameters.ContainsKey('User') ) {
        throw [System.ArgumentNullException] "provide -User and -Pass."
    }

    if (! $PSBoundParameters.ContainsKey('Password') -and ! $PSBoundParameters.ContainsKey('EncryptedPassword')) {
         $SecurePass = Read-Host -assecurestring "Please enter the password for ${User}"
    }
    elseif ($PSBoundParameters.ContainsKey('Password')) {
         $SecurePass = ConvertTo-SecureString -String $Password -AsPlainText -Force
    }
    else {
         $SecurePass = ConvertTo-SecureString -String $EncryptedPassword 
    }

    $MyInvocation.MyCommand.Module.PrivateData['MgmtUri'] = $MgmtUri
    $MyInvocation.MyCommand.Module.PrivateData['User'] = $User
    $MyInvocation.MyCommand.Module.PrivateData['SecurePass'] = $SecurePass
}
