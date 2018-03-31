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

Function Set-EdgeConnection {
    <#
    .SYNOPSIS
        Sets connection information for Apigee Edge administrative actions

    .DESCRIPTION
        Sets connection information, including Organization name, and user credentials, for Apigee Edge administrative actions.

    .PARAMETER File
        Optional. A file that contains a JSON representation of the connection informtion. Example:

            {
              "Org" : "myorgname",
              "User" : "dchiesa@google.com",
              "EncryptedPassword" : "01000000d08c9ddf011....."
            }

    .PARAMETER Org
        Optional. Required if File is not specified. This is the Apigee Edge organization.

    .PARAMETER User
        Required. The Apigee Edge administrative user.

    .PARAMETER Password
        Optional. The plaintext password for the Apigee Edge administrative user. Specify this
        or the EncryptedPassword.

    .PARAMETER MfaCode
        Optional. The plaintext MFA code for your user. Used for obtaining a token.

    .PARAMETER SsoZone
        Optional. The SSO Zone for your user. By default there is no zone. This value will affect the SSO Login URL.
        If you pass in "zone1" then the login url will become https://zone1.login.apigee.com/ .  If you would like
        to explicitly specify the SSO URL, then omit this parameter and set the SsoUrl parameter.
        Specify at most one of SsoZone and SsoUrl.

    .PARAMETER SsoUrl
        Optional. This defaults to 'https://login.apigee.com'. If you are using SAML Sign in, then specify
        https://YOURZONE.login.apigee.com/  for this parameter.  Specify at most one of SsoZone and SsoUrl.

    .PARAMETER SsoOneTimePasscode
        The one-time passcode returned by ${SSO_URL}/passcode .  Use this when Single-sign-on has
        been configured for Apigee Edge. In other words, use it when a distinct IdP will authenticate the user. No password is necessary.

    .PARAMETER LoginClientId
        Optional. This defaults to 'edgecli'.

    .PARAMETER LoginClientSecret
        Optional. This defaults to 'edgeclisecret'.

    .PARAMETER NoToken
        A switch, to disable obtaining a token.

    .PARAMETER EncryptedPassword
        Optional. The encrypted password for the Apigee Edge administrative user. Use this as an
        alternative to the Password parameter. To get the encrypted password, you can do this:

         $SecurePass = Read-Host -assecurestring "Please enter the password"
         $EncryptedString = ConvertFrom-SecureString $SecurePass

    .PARAMETER MgmtUri
        The base Uri for the Edge API Management server.
        Default: https://api.enterprise.apigee.com

    .EXAMPLE
        Set-EdgeConnection -Org cap500 -User dino@apigee.com -Password Secret1XYZ

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    [Diagnostics.CodeAnalysis.SuppressMessage("PSAvoidUsingUserNameAndPassWordParams","")]
    [Diagnostics.CodeAnalysis.SuppressMessage("PSAvoidUsingConvertToSecureStringWithPlainText","")]

    PARAM(
        [string]$File,
        [string]$Org,
        [string]$User,
        [string]$Password,
        [string]$SsoOneTimePasscode,
        [string]$SsoZone,
        [string]$SsoUrl,
        [string]$LoginClientId = 'edgecli',
        [string]$LoginClientSecret = 'edgeclisecret',
        [string]$MfaCode,
        [string]$EncryptedPassword,
        [string]$MgmtUri = 'https://api.enterprise.apigee.com',
        [switch]$NoToken
    )

    PROCESS {

        Function SetOrGetEdgePassword {
            PARAM ( [string]$Password, [string]$EncryptedPassword )
            PROCESS {
                if (! $PSBoundParameters.ContainsKey('Password') -and ! $PSBoundParameters.ContainsKey('EncryptedPassword')) {
                    $SecurePass = Read-Host -assecurestring "Please enter the password for ${User}"
                }
                elseif ($PSBoundParameters.ContainsKey('Password')) {
                    $SecurePass = ConvertTo-SecureString -String $Password -AsPlainText -Force
                }
                else {
                    $SecurePass = ConvertTo-SecureString -String $EncryptedPassword
                }
                $MyInvocation.MyCommand.Module.PrivateData.Connection['SecurePass'] = $SecurePass
            }
        }

        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }

        if ($PSBoundParameters.ContainsKey('File')) {
            Function ReadJson {
                param($filename)
                $json = Get-Content $filename -Raw | ConvertFrom-JSON
                $ht = @{}
                foreach ($prop in $json.psobject.properties.name) {
                    $ht[$prop] = $json.$prop
                }
                $ht
            }
            $ConnectionData = ReadJson $File
            if ($ConnectionData.ContainsKey('File')) {
                $ConnectionData.Remove( 'File' )
            }

            # override the params from the file with any that are specified on the command line
            foreach ($key in $MyInvocation.BoundParameters.keys) {
                if ($key -ne "File") {
                    $var = Get-Variable -Name $key -ErrorAction SilentlyContinue
                    if ($var) {
                        $ConnectionData[$var.name] = $var.value
                    }
                }
            }
            Set-EdgeConnection @ConnectionData
        }
        else {
            if (! $PSBoundParameters.ContainsKey('Org')) {
                throw [System.ArgumentNullException] "Org", "you must provide the -Org parameter."
            }
            if (! $PSBoundParameters.ContainsKey('User') ) {
                throw [System.ArgumentNullException] "User", "you must provide the -User parameter."
            }
            if ($PSBoundParameters.ContainsKey('SsoOneTimePasscode') -and $PSBoundParameters.ContainsKey('NoToken') ) {
                throw [System.ArgumentException] "it makes no sense to provide -SsoOneTimePasscode with the -NoToken switch."
            }
            $MyInvocation.MyCommand.Module.PrivateData.Connection['Org'] = $Org
            $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri'] = $MgmtUri
            $MyInvocation.MyCommand.Module.PrivateData.Connection['User'] = $User
            $MyInvocation.MyCommand.Module.PrivateData.Connection['NoToken'] = $(if ($NoToken) { $True } else { $False })
            $MyInvocation.MyCommand.Module.PrivateData.Connection['LoginClientId'] = $LoginClientId
            $MyInvocation.MyCommand.Module.PrivateData.Connection['LoginClientSecret'] = $LoginClientSecret

            $UserToken = $null
            if (! $NoToken ) {
                # connect to Edge, get a token
                Try {
                    $TokenStashPath = $(Resolve-PathSafe -Path $(Join-Path -Path $env:TEMP -ChildPath '.apigee-edge-tokens') )
                    $MyInvocation.MyCommand.Module.PrivateData.Connection['TokenStash'] = $TokenStashPath
                    $UserToken = Get-EdgeStashedAdminToken
                    If ( $UserToken -and $( Get-EdgeTokenIsExpired $UserToken )) {
                        Try {
                            $UserToken = Get-EdgeRefreshedAdminToken -UserToken $UserToken
                        }
                        Catch {
                            # it is possible that the refresh token is expired also
                            if ($_.GetType().ToString().Equals("System.Management.Automation.ErrorRecord")) {
                                $ResponsePayload = $( ConvertFrom-Json $_ )
                                if ($ResponsePayload.error -eq "invalid_token" -and ($ResponsePayload.error_description -match "\(expired\)")) {
                                    SetOrGetEdgePassword @PSBoundParameters
                                    $UserToken = Get-EdgeNewAdminToken -MfaCode $MfaCode
                                }
                                else {
                                    Throw $_
                                }
                            }
                        }
                    }
                    ElseIf (! $UserToken ) {
                        if ($PSBoundParameters.ContainsKey('SsoOneTimePasscode')) {
                            $TokenParams = @{
                                SsoOneTimePasscode = $SsoOneTimePasscode
                            }
                            if ($PSBoundParameters.ContainsKey('SsoZone')) {
                                $TokenParams.Add('SsoZone', $SsoZone)
                            }
                            if ($PSBoundParameters.ContainsKey('SsoUrl')) {
                                $TokenParams.Add('SsoUrl', $SsoUrl)
                            }
                            $UserToken = Get-EdgeNewAdminToken @TokenParams
                        }
                        else {
                            $TokenParams = @{ }
                            if ($PSBoundParameters.ContainsKey('MfaCode')) {
                                $TokenParams.Add('MfaCode', $MfaCode)
                            }
                            if ($PSBoundParameters.ContainsKey('SsoZone')) {
                                $TokenParams.Add('SsoZone', $SsoZone)
                            }
                            elseif ($PSBoundParameters.ContainsKey('SsoUrl')) {
                                $TokenParams.Add('SsoUrl', $SsoUrl)
                            }
                            else {
                                SetOrGetEdgePassword @PSBoundParameters
                            }
                            $UserToken = Get-EdgeNewAdminToken @TokenParams
                        }
                    }
                }
                Catch {
                    write-host "Exception"
                    write-host ([string]::Format("getType: {0}", $_.GetType()))
                    write-host $_
                    if ($_.GetType().ToString() -eq "System.Management.Automation.ErrorRecord") {
                        write-host ([string]::Format("stacktrace: {0}", $_.ScriptStacktrace))
                    }
                    $UserToken = "error"
                }
            }

            if (! $UserToken ) {
                SetOrGetEdgePassword @PSBoundParameters
            }
        }
    }
}
