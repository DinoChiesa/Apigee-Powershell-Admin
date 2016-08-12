function Get-EdgeBasicAuth
{
    [cmdletbinding()]
    PARAM( )
    PROCESS {

      $SecurePass = $MyInvocation.MyCommand.Module.PrivateData['SecurePass']
      $Pass = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($SecurePass))

      $User = $MyInvocation.MyCommand.Module.PrivateData['User']
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
