function Write-EdgeTokenStash
{
    [cmdletbinding()]
    PARAM(
        [string] $User,
        [string] $NewTokenJson
    )
    PROCESS {
        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }

        $TokenStashFile = $MyInvocation.MyCommand.Module.PrivateData.Connection['TokenStash']
        $TokenData = Read-EdgeTokenStash
        if (! $TokenData) {
            $TokenData = "{}" | ConvertFrom-Json
        }

        Write-Debug ( "NewTokenJson.getType(): " + $( $NewTokenJson.GetType() ) )
        Write-Debug ( "NewTokenJson:`n" + $NewTokenJson )

        $Value = $NewTokenJson | ConvertFrom-Json
        $TokenData | Add-Member -MemberType NoteProperty -Name $User -Value $Value -Force

        $UnexpiredTokenData = "{}" | ConvertFrom-Json
        $TokenData.psobject.properties |?{ $_.MemberType -eq 'NoteProperty' } |% {
            if (! $( Get-EdgeTokenIsExpired $_ ) ) {
              $UnexpiredTokenData | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value -Force
            }
        }
        $UnexpiredTokenData | ConvertTo-Json | Out-File $TokenStashFile
    }
}
