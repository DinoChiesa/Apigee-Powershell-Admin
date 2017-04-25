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
            $usertoken = if ($MgmtUri.Equals("https://api.enterprise.apigee.com")) { $( Get-EdgeStashedAdminToken ) }
            Write-Debug ( "Apply-EdgeAuthorization usertoken: " + $( $usertoken | Format-List | Out-String )  )

            if ( $usertoken -and $usertoken.Value -and $usertoken.Value.access_token ) {
                Write-Debug ( "Apply-EdgeAuthorization using stashed token" )
                $IRMParams.Headers.Add('Authorization', 'Bearer ' + $usertoken.Value.access_token)
            }
            else {
                Write-Debug ( "Apply-EdgeAuthorization using Basic Auth" )
                $IRMParams.Headers.Add('Authorization', 'Basic ' + $( Get-EdgeBasicAuth ))
            }
        }
        Finally {
            if ($usertoken) { Remove-Variable usertoken }
        }
    }
}
