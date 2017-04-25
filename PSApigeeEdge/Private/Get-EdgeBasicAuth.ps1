function Get-EdgeBasicAuth
{
    [cmdletbinding()]
    PARAM( )
    PROCESS {

        $SecurePass = $MyInvocation.MyCommand.Module.PrivateData.Connection['SecurePass']
        if (!$SecurePass) {
            throw [System.ArgumentNullException] "There is no SecurePass stored. Have you called Set-EdgeConnection ?"
        }

        $Pass = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($SecurePass))

        $User = $MyInvocation.MyCommand.Module.PrivateData.Connection['User']
        $pair = "${User}:${Pass}"
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
        $base64 = [System.Convert]::ToBase64String($bytes)

        Remove-Variable SecurePass
        Remove-Variable Pass
        Remove-Variable User
        Remove-Variable pair
        Remove-Variable bytes

        $base64

    }
}
