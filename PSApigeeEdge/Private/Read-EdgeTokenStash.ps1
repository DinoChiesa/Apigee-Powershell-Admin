function Read-EdgeTokenStash
{
    [cmdletbinding()]
    PARAM()
    PROCESS {
        $TokenStashFile = $MyInvocation.MyCommand.Module.PrivateData.Connection['TokenStash']
        if (!$TokenStashFile) {
            throw [System.ArgumentNullException] "There is no Token stash set. Have you called Set-EdgeConnection ?"
        }
        if(![System.IO.File]::Exists($TokenStashFile)) {
            return $null
        }
        # System.Management.Automation.PSCustomObject
        Get-Content $TokenStashFile -Raw | ConvertFrom-JSON
    }
}
