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
        if (! $PSBoundParameters.ContainsKey('User') ) {
            $User = $MyInvocation.MyCommand.Module.PrivateData.Connection['User']
        }
        $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']

        $TokenData = Read-EdgeTokenStash
        if (! $TokenData) {
            $TokenData = "{}" | ConvertFrom-Json
        }

        Write-Debug ( "NewToken:`n" + $NewToken )

        #$Value = $NewTokenJson | ConvertFrom-Json
        $Value = $NewToken
        $Key = Get-EdgeTokenKey $User $MgmtUri
        $TokenData | Add-Member -MemberType NoteProperty -Name $Key -Value $Value -Force

        $UnexpiredTokenData = "{}" | ConvertFrom-Json
        $TokenData.psobject.properties |? { $_.MemberType -eq 'NoteProperty' } |% {
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
