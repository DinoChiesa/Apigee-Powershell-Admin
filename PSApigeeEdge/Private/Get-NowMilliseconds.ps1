Function Get-NowMilliseconds
{
    PARAM([int]$Fudge=0)
    if ($Fudge -and $Fudge -ne 0) {
        $Now = [DateTime]::UtcNow.AddMilliseconds($Fudge)
    }
    $UnixEpochStart = new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)
    $NowMilliseconds = [int64](New-TimeSpan -Start $UnixEpochStart -End $Now).TotalMilliseconds
}
