Function Get-EdgeNewAdminToken {
    <#
    .SYNOPSIS
        Gets an OAuth token for Edge Administration.

    .DESCRIPTION
        Gets an OAuth token for Edge Administration. This works only with Edge SaaS.
        You must have previously called Set-EdgeConnection to specify the user + password.
        In fact this cmdlet gets called implicitly by Set-EdgeConnection as necessary.
        You probably do not need to call it directly. 

    .PARAMETER MfaCode
        Optional. The MFA code for authenticating, if your user requires it.

    .LINK
        Set-EdgeConnection

    .LINK
        Get-EdgeStashedAdminToken

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]

    param([string]$MfaCode)

    PROCESS {
        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }

        $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']
        if (! $MgmtUri.Equals("https://api.enterprise.apigee.com") ) {
            throw [System.InvalidOperationException] "You can get a token only when connecting to Edge SaaS."
        }
        $User = $MyInvocation.MyCommand.Module.PrivateData.Connection['User']
        $SecurePass = $MyInvocation.MyCommand.Module.PrivateData.Connection['SecurePass']
        $Pass = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($SecurePass))

        $IRMParams = @{
            Uri = 'https://login.apigee.com/oauth/token'
            Method = 'POST'
            Headers = @{
                Accept = 'application/json'
                Authorization = 'Basic ZWRnZWNsaTplZGdlY2xpc2VjcmV0'
            }
            Body = @{
                username = $User
                password = $Pass
                grant_type = "password"
                # TODO : handle mfa code here
            }
        }
        if ($MfaCode) {
            $IRMParams.Body.Add('mfa_token', $MfaCode)
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
            }
        }
        Catch {
            Throw $_
        }
        Finally {
            Remove-Variable IRMParams
            Remove-Variable Pass
            Remove-Variable SecurePass
            Remove-Variable User
        }

        Get-EdgeStashedAdminToken
    }
}
