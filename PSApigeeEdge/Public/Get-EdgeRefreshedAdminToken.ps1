Function Get-EdgeRefreshedAdminToken {
    <#
    .SYNOPSIS
        Gets an OAuth token for Edge Administration.

    .DESCRIPTION
        Gets an OAuth token for Edge Administration. This works only with Edge SaaS.
        You must have previously called Set-EdgeConnection to specify the user + password.

    .PARAMETER SsoZone
        Optional. The SSO Zone for your user. By default there is no zone. This value will affect the SSO Login URL.
        If you pass in "zone1" then the login url will become https://zone1.login.apigee.com/ .  If you would like
        to explicitly specify the SSO URL, then omit this parameter and set the SsoUrl parameter.
        Specify at most one of SsoZone and SsoUrl.

    .PARAMETER SsoUrl
        Optional. This defaults to 'https://login.apigee.com'. If you are using SAML Sign in, then specify
        https://YOURZONE.login.apigee.com/  for this parameter.  Specify at most one of SsoZone and SsoUrl.

    .PARAMETER UserToken
       Required. The user token to refresh.

    .LINK
        Set-EdgeConnection

    .LINK
        Get-EdgeNewAdminToken

    .LINK
        Get-EdgeStashedAdminToken

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]

    PARAM(
        [string]$SsoZone,
        [string]$SsoUrl,
        [System.Management.Automation.PSNoteProperty] $UserToken,
    )

    PROCESS {
        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }

        if (!$UserToken) {
            throw [System.ArgumentNullException] "You must pass a usertoken [PSNoteProperty]."
        }

        $BaseLoginUrl = $(if ($PSBoundParameters['SsoZone']) {
                            [string]::Format('https://{0}.login.apigee.com/', $SsoZone )
                        }
                        elseif ($PSBoundParameters['SsoUrl']) {
                            $SsoUrl
                        }
                        else {
                            'https://login.apigee.com'
                        })

        $User = $MyInvocation.MyCommand.Module.PrivateData.Connection['User']

        # $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']
        # if (! $MgmtUri.Equals("https://api.enterprise.apigee.com") ) {
        #     throw [System.InvalidOperationException] "You can get a token only when connecting to Edge SaaS."
        # }

        $IRMParams = @{
            Uri = $(Join-Parts -Separator '/' -Parts $BaseLoginUrl, 'oauth','token' )
            Method = 'POST'
            Headers = @{
                Accept = 'application/json'
                Authorization = 'Basic ZWRnZWNsaTplZGdlY2xpc2VjcmV0'
            }
            Body = @{
                refresh_token = $UserToken.Value.refresh_token
                grant_type = "refresh_token"
            }
        }

        Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                      "Invoke-RestMethod parameters:`n$($IRMParams | Format-List | Out-String)" )

        Try {
            $TokenResult = Invoke-RestMethod @IRMParams
            Write-Debug "Raw:`n$($TokenResult | Out-String)"

            Write-Debug ("TokenResult type: " + $TokenResult.GetType().ToString())
            if ($TokenResult -and $TokenResult.psobject -and $TokenResult.psobject.properties) {
                Add-Member -InputObject $TokenResult -MemberType NoteProperty -Name "issued_at" -Value $(Get-NowMilliseconds)
                Write-Debug "Updated:`n$($TokenResult | Out-String)"

                Write-EdgeTokenStash -User $User -NewToken $TokenResult
                $MyInvocation.MyCommand.Module.PrivateData.Connection['MostRecentRefresh'] = $(Get-NowMilliseconds)
            }
        }
        Catch {
            Throw $_
        }
        Finally {
            Remove-Variable UserToken
        }

        Get-EdgeStashedAdminToken
    }
}
