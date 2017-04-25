Function Apply-EdgeAuthorization {
    [cmdletbinding()]
    PARAM(
        [string] $MgmtUri,
        [System.Collections.Hashtable] $IRMParams
    )

    Try {
        $usertoken = if ($MgmtUri.Equals("https://api.enterprise.apigee.com")) { $( Get-StashedEdgeAdminToken ) }
        if ( $usertoken -and $usertoken.Value -and $usertoken.Value.access_token ) {
            $IRMParams.Headers.Add('Authorization', 'Bearer ' + $usertoken.Value.access_token)
        }
        else {
            $IRMParams.Headers.Add('Authorization', 'Basic ' + $( Get-EdgeBasicAuth ))
        }
    }
    Finally {
        Remove-Variable usertoken
    }

}
