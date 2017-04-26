function Read-EdgeTokenStash
{
    [cmdletbinding()]
    PARAM()
    PROCESS {
        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }
        $TokenStashFile = $MyInvocation.MyCommand.Module.PrivateData.Connection['TokenStash']
        if (!$TokenStashFile) {
            throw [System.InvalidOperationException] "There is no Token stash set. Have you called Set-EdgeConnection ?"
        }
        if(![System.IO.File]::Exists($TokenStashFile)) {
            Write-Debug ([string]::Format( "Read-EdgeTokenStash Token stash file {0} does not exist.", $TokenStashFile) )
            return $null
        }
        Write-Debug ([string]::Format( "Read-EdgeTokenStash Reading token stash file {0} ", $TokenStashFile) )
        # System.Management.Automation.PSCustomObject
        Get-Content $TokenStashFile -Raw | ConvertFrom-JSON
    }
}
