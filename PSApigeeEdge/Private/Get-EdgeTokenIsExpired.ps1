function Get-EdgeTokenIsExpired
{
    [cmdletbinding()]
    PARAM( [System.Management.Automation.PSNoteProperty] $usertoken )
    PROCESS {
        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }
        if (!$usertoken) {
            throw [System.ArgumentNullException] "You must pass a usertoken [PSNoteProperty]."
        }
        else {
            $lifetime = $usertoken.Value.expires_in
            $issuedAt = $usertoken.Value.issued_at
            $NowMilliseconds = Get-NowMilliseconds -Fudge -60000
            Write-Debug ( "Get-EdgeTokenIsExpired  NowMilliseconds: " + $NowMilliseconds )
            $ExpiryMilliseconds = [int64] $issuedAt + ($lifetime * 1000)
            Write-Debug ( "Get-EdgeTokenIsExpired  ExpiryMilliseconds: " + $ExpiryMilliseconds )
            if ($PSBoundParameters['Debug']) {
                $UnixEpochStart = new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)
                $Expiry = $UnixEpochStart.AddMilliseconds($ExpiryMilliseconds)
                Write-Debug ( "Get-EdgeTokenIsExpired  Expiry: " + $Expiry )
            }
            # True if expired
            $isExpired = ($issuedAt + ($lifetime * 1000) -lt $NowMilliseconds)
            Write-Debug ( "Get-EdgeTokenIsExpired  isExpired: " + $isExpired )
            $isExpired
        }
    }
}
