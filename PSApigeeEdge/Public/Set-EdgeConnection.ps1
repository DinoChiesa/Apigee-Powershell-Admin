Function Set-EdgeConnection {
    <#
    .SYNOPSIS
        Sets connection information for Apigee Edge administrative actions

    .DESCRIPTION
        Sets connection information, including Organization name, and user credentials, for Apigee Edge administrative actions.

    .PARAMETER File
        Optional. A file that contains a JSON representation of the connection informtion. Example:

            {
              "Org" : "myorgname",
              "User" : "dchiesa@google.com",
              "EncryptedPassword" : "01000000d08c9ddf011....."
            }

    .PARAMETER Org
        Optional. Required if File is not specified. This is the Apigee Edge organization. 

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
        [string]$File,
        [string]$Org,
        [string]$User,
        [string]$Password,
        [string]$EncryptedPassword,
        [string]$MgmtUri = 'https://api.enterprise.apigee.com'
    )
    
    if ($PSBoundParameters.ContainsKey('File')) {
        Function ReadJson {
            param($filename)
            $json = Get-Content $filename -Raw | ConvertFrom-JSON
            $ht = @{}
            foreach ($prop in $json.psobject.properties.name) {
                $ht.Add( $prop , $json.$prop )
            }
            $ht
        }
        $ConnectionData = ReadJson $File
        if ($ConnectionData.ContainsKey('File')) {
            $ConnectionData.Remove( 'File' )
        }

        # override the params from the file with any that are specified on the command line
        # $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters
        # foreach ($key in $ParameterList.keys) {
        foreach ($key in $MyInvocation.BoundParameters.keys) {
            if ($key -ne "File") {
                $var = Get-Variable -Name $key -ErrorAction SilentlyContinue
                if ($var) {
                    $ConnectionData.Set( $var.name, $var.value )
                }
            }
        }
        Set-EdgeConnection @ConnectionData
    }
    else {
        if (! $PSBoundParameters.ContainsKey('Org')) {
            throw [System.ArgumentNullException] "Org", "you must provide the -Org parameter."
        }
        $MyInvocation.MyCommand.Module.PrivateData.Connection['Org'] = $Org
        
        if (! $PSBoundParameters.ContainsKey('User') ) {
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
}
