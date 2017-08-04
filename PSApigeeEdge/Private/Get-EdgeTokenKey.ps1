Function Get-EdgeTokenKey {
    [cmdletbinding()]
    param(
        [Parameter(Position=0)] [string]$User,
        [Parameter(Position=1)] [string]$MgmtUri
    )
    [string]::Format("{0}##{1}", $User, $MgmtUri)
}
