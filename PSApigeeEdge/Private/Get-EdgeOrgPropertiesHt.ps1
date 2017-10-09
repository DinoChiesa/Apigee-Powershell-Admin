Function Get-EdgeOrgPropertiesHt {
    [cmdletbinding()]
    param(
        [Parameter(Position=0)] [string]$Org
    )

    $PropKey = [string]::Format("OrgProps-{0}", $Org)

    if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection[$PropKey]) {
        $Options = @{ Org = $Org }

        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
            $Options.Add( 'Debug', $Debug )
        }

        $OrgInfo = $(Get-EdgeObject @Options)
        $PropsHt = @{}
        $OrgInfo.properties.property |% { $PropsHt[$_.name] = $_.value }
        $MyInvocation.MyCommand.Module.PrivateData.Connection[$PropKey] = $PropsHt
    }

    $MyInvocation.MyCommand.Module.PrivateData.Connection[$PropKey]
}
