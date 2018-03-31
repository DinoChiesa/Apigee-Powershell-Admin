# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#   https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Function Get-EdgeNewAdminToken {
    <#
    .SYNOPSIS
        Gets an OAuth token for Edge Administration.

    .DESCRIPTION
        Gets an OAuth token for Edge Administration. This works only with Edge SaaS.
        You must have previously called Set-EdgeConnection to specify the user + password.
        In fact this cmdlet gets called implicitly by Set-EdgeConnection as necessary.
        You probably do not need to call it directly.

    .PARAMETER SsoOneTimePasscode
        Optional. The one-time passcode for authenticating, obtained from the https://ZONE.login.apigee.com/passcode endpoint.
        This is applicable only when using SAML-based SSO for login to Apigee Edge.

    .PARAMETER SsoZone
        Optional. The SSO Zone for your user. By default there is no zone. This value will affect the SSO Login URL.
        If you pass in "zone1" then the login url will become https://zone1.login.apigee.com/ .  If you would like
        to explicitly specify the SSO URL, then omit this parameter and set the SsoUrl parameter.
        Specify at most one of SsoZone and SsoUrl.

    .PARAMETER SsoUrl
        Optional. This defaults to 'https://login.apigee.com'. If you are using SAML Sign in, then specify
        https://YOURZONE.login.apigee.com/  for this parameter.  Specify at most one of SsoZone and SsoUrl.

    .PARAMETER MfaCode
        Optional. The MFA code for authenticating, if your user requires it.

    .LINK
        Set-EdgeConnection

    .LINK
        Get-EdgeStashedAdminToken

    .LINK
        Get-EdgeRefreshedAdminToken

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]

    param(
        [string]$SsoOneTimePasscode,
        [string]$SsoZone,
        [string]$SsoUrl,
        [string]$MfaCode
    )

    PROCESS {
        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }

        # $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']
        # if (! $MgmtUri.Equals("https://api.enterprise.apigee.com") ) {
        #    throw [System.InvalidOperationException] "You can get a token only when connecting to Edge SaaS."
        # }

        if ($PSBoundParameters['SsoZone'] -and $PSBoundParameters['SsoUrl']) {
            throw [System.ArgumentException] "You may specify only one of -SsoUrl and -SsoZone."
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
        $LoginClientId = $MyInvocation.MyCommand.Module.PrivateData.Connection['LoginClientId']
        $LoginClientSecret = $MyInvocation.MyCommand.Module.PrivateData.Connection['LoginClientSecret']
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes([string]::Format('{0}:{1}', $LoginClientId, $LoginClientSecret))

        $Base64Blob = [Convert]::ToBase64String($Bytes)

        $IRMParams = @{
            Uri = $(Join-Parts -Separator '/' -Parts $BaseLoginUrl, 'oauth','token' )
            Method = 'POST'
            Headers = @{
                Accept = 'application/json'
                Authorization = "Basic $($Base64Blob)"
            }
            Body = @{
                grant_type = "password"
            }
        }
        if ($PSBoundParameters['SsoOneTimePasscode']) {
            # Using passcode for SAML-SSO
            $IRMParams.Body.Add('response_type', 'token')
            $IRMParams.Body.Add('passcode', $SsoOneTimePasscode)
            #  curl -i -X POST -H "Authorization: Basic ZWRnZWNsaTplZGdlY2xpc2VjcmV0" -H Accept:application/json \
            #       https://google.login.e2e.apigee.net/oauth/token -d 'grant_type=password&response_type=token&passcode=NsJQAe'
        }
        else {
            # Assume username / password authn
            $SecurePass = $MyInvocation.MyCommand.Module.PrivateData.Connection['SecurePass']
            $Pass = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($SecurePass))
            #write-debug $( [string]::Format("Get-EdgeNewAdminToken() username ({0}) password ({1})`n", $User, $Pass))
            $IRMParams.Body.Add('username', $User)
            $IRMParams.Body.Add('password', $Pass)
            if ($MfaCode) {
                $IRMParams.Body.Add('mfa_token', $MfaCode)
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
            }
        }
        Catch {
            Throw $_
        }
        Finally {
            Remove-Variable IRMParams, Pass, SecurePass, User -ea SilentlyContinue
        }

        Get-EdgeStashedAdminToken
    }
}
