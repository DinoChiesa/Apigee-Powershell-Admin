function Write-EdgeTokenStash
{
    [cmdletbinding()]
    PARAM($User, $NewTokenJson)
    PROCESS {
        $TokenStashFile = $MyInvocation.MyCommand.Module.PrivateData.Connection['TokenStash']
        $TokenData = Read-EdgeTokenStash
        if (! $TokenData) {
            $TokenData = "{}" | ConvertFrom-Json
        }
        $Value = $NewTokenJson | ConvertFrom-Json
        $TokenData | Add-Member -MemberType NoteProperty -Name $User -Value $Value -Force

        $UnexpiredTokenData = "{}" | ConvertFrom-Json
        $TokenData.psobject.properties |?{ $_.MemberType -eq 'NoteProperty' } |% {
            if (! $( Get-EdgeTokenExpired $_ ) ) {
              $UnexpiredTokenData | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value -Force
            }
        }
        $UnexpiredTokenData | ConvertTo-Json | Out-File $TokenStashFile
    }
}
