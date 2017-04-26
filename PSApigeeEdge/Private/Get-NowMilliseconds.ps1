Function Get-NowMilliseconds
{
    PARAM([int]$Fudge=0)
    PROCESS {
        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }
        $Now = if ($Fudge -and $Fudge -ne 0) {
            [DateTime]::UtcNow.AddMilliseconds($Fudge)
        }
        else {
            [DateTime]::UtcNow
        }
        $UnixEpochStart = new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)
        $NowMilliseconds = [int64](New-TimeSpan -Start $UnixEpochStart -End $Now).TotalMilliseconds
        write-debug ("NowMilliseconds: " + $NowMilliseconds)
        $NowMilliseconds
    }
}
