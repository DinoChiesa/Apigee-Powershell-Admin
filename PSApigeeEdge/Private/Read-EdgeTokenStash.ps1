function Read-EdgeTokenStash
{
    [cmdletbinding()]
    PARAM()
    PROCESS {
        $TokenStashFile = $MyInvocation.MyCommand.Module.PrivateData.Connection['TokenStash']
        if (!$TokenStashFile) {
            throw [System.ArgumentNullException] "There is no Token stash set. Have you called Set-EdgeConnection ?"
        }
        $TokenData = $null
        if([System.IO.File]::Exists($TokenStashFile)) {
            $TokenData = Get-Content $TokenStashFile -Raw | ConvertFrom-JSON
        }
        $TokenData
    }
}
