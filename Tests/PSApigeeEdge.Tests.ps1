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


Describe "Get-EdgeApi-1" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'gets a list of proxies' {
            $proxies = Get-EdgeApi
            $proxies.count | Should BeGreaterThan 0
        }
       
        It 'gets details of one apiproxy' {
            $proxies = Get-EdgeApi
            $proxies.count | Should BeGreaterThan 0
            $oneproxy = Get-EdgeApi -Name $proxies[0]
            $oneproxy | Should Not BeNullOrEmpty
            $oneproxy.metaData | Should Not BeNullOrEmpty
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $oneproxy.metaData.createdAt | Should BeLessthan $NowMilliseconds
            $oneproxy.metaData.lastModifiedBy | Should Not BeNullOrEmpty
        }
    }
}


Describe "Get-ApiRevisions-1" {

    
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        Function ToArrayOfHash {
          param($a)

          $list = New-Object System.Collections.Generic.List[System.Object]
          for ( $i = 0; $i -lt $a.Length; $i++ ) {
             $list.Add( @{ Name = $a[$i] } )
          }
          $list.ToArray()
        }
        
# It "identifies <Number> as <Class>" -TestCases $TestCases {
#         param($Number, $Class, $Reason)
# 
#         $c = & $cmd -Number $Number
#         $c | Should Be $Class
#     }
    
        It 'gets a list of revisions for an API Proxy' -TestCases @( ToArrayOfHash @( Get-EdgeApi ) ) {
            param($Name)
            $revisions = @( Get-EdgeApiRevision -Name $Name )
            $revisions.count | Should BeGreaterThan 0
        }

        It 'gets details for a revision of an API Proxy' {
            $proxies = Get-EdgeApi
            $proxies.count | Should BeGreaterThan 0
            $revisions = Get-EdgeApiRevision -Name $proxies[0]
            $revisions.count | Should BeGreaterThan 0
            $RevisionDetails = Get-EdgeApi -Name $proxies[0] -Revision $revisions[-1]
            $RevisionDetails.name | Should Be $proxies[0]
            $RevisionDetails.revision | Should Be $revisions[-1]
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $RevisionDetails.createdAt | Should BeLessthan $NowMilliseconds
        }
    }
}



Describe "Get-EdgeEnvironment-1" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'gets a list of environments' {
            $envs = Get-EdgeEnvironment
            $envs.count | Should BeGreaterThan 0
        }
        
        It 'gets one environment by name' {
            $envs = Get-EdgeEnvironment
            $OneEnv = Get-EdgeEnvironment -Name $envs[0]
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $OneEnv.createdAt | Should BeLessthan $NowMilliseconds
            $OneEnv.lastModifiedAt | Should BeLessthan $NowMilliseconds
            $OneEnv.name | Should Be $envs[0]
            $OneEnv.properties | Should Not BeNullOrEmpty
        }
    }
}


