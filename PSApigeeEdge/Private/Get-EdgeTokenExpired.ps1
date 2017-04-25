function Get-EdgeTokenExpired
{
    [cmdletbinding()]
    PARAM($usertoken)
    PROCESS {
        if (!$usertoken) {
            throw [System.ArgumentNullException] "You must pass a usertoken [pscustomobject]."
        }
        else {
            $lifetime = $usertoken.Value.expires_in
            $issuedAt = $usertoken.Value.issued_at
            $Now = [DateTime]::UtcNow.AddMinutes(-1) # Fudge
            $UnixEpochStart = new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)
            $Epoch = [int64](New-TimeSpan -Start $UnixEpochStart -End $Now).TotalMilliseconds
            #$Expiry = $UnixEpochStart.AddMilliseconds($issuedAt + ($lifetime * 1000))
            # True if expired
            ($issuedAt + ($lifetime * 1000) -lt $Epoch)
        }
    }
}
