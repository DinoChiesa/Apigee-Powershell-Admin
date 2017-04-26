function Write-EdgeTokenStash
{
    [cmdletbinding()]
    PARAM(
        [string] $User,
        $NewToken
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

        Write-Debug ( "NewToken:`n" + $NewToken )

        #$Value = $NewTokenJson | ConvertFrom-Json
        $Value = $NewToken
        $TokenData | Add-Member -MemberType NoteProperty -Name $User -Value $Value -Force

        $UnexpiredTokenData = "{}" | ConvertFrom-Json
        $TokenData.psobject.properties |?{ $_.MemberType -eq 'NoteProperty' } |% {
            if (! $( Get-EdgeTokenIsExpired $_ ) ) {
                $UnexpiredTokenData | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value -Force
                Write-Debug ( "Write-EdgeTokenStash keep " + $_.Value )
            }
            else {
                Write-Debug ( "Write-EdgeTokenStash expired " + $_.Value )
            }
        }
        Write-Debug ( "Write-EdgeTokenStash stashing " + $( $UnexpiredTokenData | ConvertTo-Json | Out-String ) )
        $UnexpiredTokenData | ConvertTo-Json | Out-File $TokenStashFile
    }
}
