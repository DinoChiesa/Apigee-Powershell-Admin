Function Set-EdgeConnection {
    <#
    .SYNOPSIS
        Sets connection information for Apigee Edge administrative actions

    .DESCRIPTION
        Sets connection information, including Organization name, and user credentials, for Apigee Edge administrative actions.

    .PARAMETER Org
        Required. The Apigee Edge organization. 

    .PARAMETER User
        Required. The Apigee Edge administrative user. 

    .PARAMETER Password
        Optional. The plaintext password for the Apigee Edge administrative user. Specify this
        or the EncryptedPassword. 

    .PARAMETER EncryptedPassword
        Optional. The encrypted password for the Apigee Edge administrative user. Use this as an
        alternative to the Password parameter. To get the encrypted password, you can do this:

         $SecurePass = Read-Host -assecurestring "Please enter the password"
         $EncryptedString = ConvertFrom-SecureString $SecurePass

    .PARAMETER MgmtUri
        The base Uri for the Edge API Management server.

        Default: https://api.enterprise.apigee.com

    .EXAMPLE
        Set-EdgeConnection -Org cap500 -User dino@apigee.com -Password Secret1XYZ

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    [Diagnostics.CodeAnalysis.SuppressMessage("PSAvoidUsingUserNameAndPassWordParams","")]
    [Diagnostics.CodeAnalysis.SuppressMessage("PSAvoidUsingConvertToSecureStringWithPlainText","")]
    
    param(
        [Parameter(Mandatory=$True)][string]$Org,
        [Parameter(Mandatory=$True)][string]$User,
        [string]$Password,
        [string]$EncryptedPassword,
        [string]$MgmtUri = 'https://api.enterprise.apigee.com'
    )

    if( $PSBoundParameters.ContainsKey('Org')) {
      $MyInvocation.MyCommand.Module.PrivateData.Connection['Org'] = $Org
    }
    
    if(! $PSBoundParameters.ContainsKey('User') ) {
       throw [System.ArgumentNullException] "USer", "you must provide the -User parameter."
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

    $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri'] = $MgmtUri
    $MyInvocation.MyCommand.Module.PrivateData.Connection['User'] = $User
    $MyInvocation.MyCommand.Module.PrivateData.Connection['SecurePass'] = $SecurePass
}
