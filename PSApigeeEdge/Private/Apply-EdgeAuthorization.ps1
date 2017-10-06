Function OkToTryRefresh {
    PARAM( [int] $Lifetime )

    if (! $MyInvocation.MyCommand.Module.PrivateData.Connection['MostRecentRefresh'] ) {
        return $true;
    }
    # Refresh no more than once every ($Lifetime - 5 minutes).
    $MoratoriumPeriod = [TimeSpan]::FromSeconds($Lifetime)
    $MoratoriumPeriod = $MoratoriumPeriod.Subtract([TimeSpan]::FromMinutes(5))
    $MostRecentRefresh = $MyInvocation.MyCommand.Module.PrivateData.Connection['MostRecentRefresh']
    $NowMilliseconds = $(Get-NowMilliseconds)
    $OneMoratoriumPeriodAgo = $NowMilliseconds - $MoratoriumPeriod.TotalMilliseconds
    $OK = ($MostRecentRefresh -lt $OneMoratoriumPeriodAgo)
    $OK
}


Function Apply-EdgeAuthorization {
    [cmdletbinding()]
    PARAM(
        [string] $MgmtUri,
        [System.Collections.Hashtable] $IRMParams
    )

    PROCESS {
        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }

        Try {
            $NoToken = $MyInvocation.MyCommand.Module.PrivateData.Connection['NoToken']
            if ($NoToken -ne $True) {
                Write-Debug ( "Apply-EdgeAuthorization NoToken: " + $NoToken)
                $UserToken = $( Get-EdgeStashedAdminToken )
                Write-Debug ( "Apply-EdgeAuthorization usertoken: " + $( $UserToken | Format-List | Out-String )  )
                If ( $UserToken -and ! $( Get-EdgeTokenIsExpired $UserToken )) {
                    Write-Debug ( "Apply-EdgeAuthorization using stashed token" )
                    $IRMParams.Headers.Add('Authorization', 'Bearer ' + $usertoken.Value.access_token)
                }
                ElseIf ( $( OkToTryRefresh -Lifetime $UserToken.expires_in ) ) {
                    Write-Debug ( "Apply-EdgeAuthorization try refresh token" )
                    $UserToken = Get-EdgeRefreshedAdminToken -UserToken $UserToken
                    if ( $UserToken -and $UserToken.Value -and $UserToken.Value.access_token ) {
                        Write-Debug ( "Apply-EdgeAuthorization using refreshed token" )
                        $IRMParams.Headers.Add('Authorization', 'Bearer ' + $UserToken.Value.access_token)
                    }
                    else {
                        Write-Debug ( "Apply-EdgeAuthorization could not refresh token, using Basic Auth" )
                        $IRMParams.Headers.Add('Authorization', 'Basic ' + $( Get-EdgeBasicAuth ))
                    }
                }
                else {
                    Write-Debug ( "Apply-EdgeAuthorization not ok to refresh, using Basic Auth" )
                    $IRMParams.Headers.Add('Authorization', 'Basic ' + $( Get-EdgeBasicAuth ))
                }
            }
            else {
                Write-Debug ( "Not using token, using Basic Auth" )
                $IRMParams.Headers.Add('Authorization', 'Basic ' + $( Get-EdgeBasicAuth ))
            }
        }
        Finally {
            if ($usertoken) { Remove-Variable usertoken }
        }
    }
}
