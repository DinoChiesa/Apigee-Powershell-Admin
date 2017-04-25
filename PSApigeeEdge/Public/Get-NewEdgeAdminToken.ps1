Function Get-NewEdgeAdminToken {
    <#
    .SYNOPSIS
        Gets an OAuth token for Edge Administration.

    .DESCRIPTION
        Gets an OAuth token for Edge Administration. This works only with Edge SaaS.
        You must have previously called Set-EdgeConnection to specify the user + password.

    .LINK
        Set-EdgeConnection

    .LINK
        Get-StashedEdgeAdminToken

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]

    param()

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
            Body = [string]::Format("username={0}&password={1}&grant_type=password", $User, $Pass)
        }
        $IRMParams.Headers.Add('content-type', 'application/x-www-form-urlencoded')

        Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                      "Invoke-RestMethod parameters:`n$($IRMParams | Format-List | Out-String)" )

        Try {
            $TokenResult = Invoke-RestMethod @IRMParams
            Write-Debug "Raw:`n$($TokenResult | Out-String)"
            Write-EdgeTokenStash -User $User -NewTokenJson $TokenResult
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

        Get-StashedEdgeAdminToken
    }
}