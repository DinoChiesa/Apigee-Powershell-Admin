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


Describe "List-Apiproxies-1" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'gets a list of proxies' {
            $proxies = Get-EdgeApi
            $proxies.count | Should BeGreaterThan 0
        }
    }
}

Describe "List-Apiproxies-2" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'gets a list of proxies with expanded details' {
            $proxies = Get-EdgeApi -Params @{ expand = 'true' }
            $proxies.count | Should BeGreaterThan 0
        }
    }
}

