$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

$PSVersion = $PSVersionTable.PSVersion.Major
Import-Module $PSScriptRoot\..\PSApigeeEdge -Force

# --- Get data for the tests
$ConnectionData = Get-Content .\ConnectionData.json -Raw | ConvertFrom-JSON


Describe "Set-EdgeConnection" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'sets the connection info' {
            $ConnectionData.password | Should Not BeNullOrEmpty 
            $ConnectionData.user | Should Not BeNullOrEmpty 
            $ConnectionData.org | Should Not BeNullOrEmpty 
            Set-EdgeConnection -Org $ConnectionData.org -User $ConnectionData.user -EncryptedPassword $ConnectionData.password
        }
    }
}


Describe "Get-Apiproxy-1" {

    Context 'Strict mode' { 
        $proxies = @()
        Set-StrictMode -Version latest

        It 'gets a list of proxies' {
            $proxies = Get-EdgeApi
            $proxies.count | Should BeGreaterThan 0
        }
        
        It 'gets a list of proxies with expanded details' {
            $detailproxies = Get-EdgeApi -Params @{ expand = 'true' }
            $detailproxies.count | Should BeGreaterThan 0
            $detailproxies.count | Should Be $proxies.count
        }
       
        It 'gets one apiproxy with expanded details' {
            $oneproxy = Get-EdgeApi -Name $proxies[0] -Params @{ expand = 'true' }
            $oneproxy | Should Not BeNullOrEmpty
            $oneproxy.metaData | Should Not BeNullOrEmpty
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $oneproxy.metaData.createdAt | Should BeLessthan $NowMilliseconds
            $oneproxy.metaData.lastModifiedBy | Should Not BeNullOrEmpty
        }
    }
}


