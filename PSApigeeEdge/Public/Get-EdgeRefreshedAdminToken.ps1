Function Get-EdgeRefreshedAdminToken {
    <#
    .SYNOPSIS
        Gets an OAuth token for Edge Administration.

    .DESCRIPTION
        Gets an OAuth token for Edge Administration. This works only with Edge SaaS.
        You must have previously called Set-EdgeConnection to specify the user + password.

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

    PARAM( [System.Management.Automation.PSNoteProperty] $UserToken )

    PROCESS {
        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }

        if (!$UserToken) {
            throw [System.ArgumentNullException] "You must pass a usertoken [PSNoteProperty]."
        }
        $User = $MyInvocation.MyCommand.Module.PrivateData.Connection['User']

        $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']
        if (! $MgmtUri.Equals("https://api.enterprise.apigee.com") ) {
            throw [System.InvalidOperationException] "You can get a token only when connecting to Edge SaaS."
        }

        $IRMParams = @{
            Uri = 'https://login.apigee.com/oauth/token'
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
