$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

$PSVersion = $PSVersionTable.PSVersion.Major
Import-Module $PSScriptRoot\..\PSApigeeEdge -Force

# --- Get data for the tests
$ConnectionData = Get-Content .\ConnectionData.json -Raw | ConvertFrom-JSON


Function ToArrayOfHash {
  param($a)

  $list = New-Object System.Collections.Generic.List[System.Object]
  for ( $i = 0; $i -lt $a.Length; $i++ ) {
     $list.Add( @{ Name = $a[$i] } )
  }
  $list.ToArray()
}


Describe "Set-EdgeConnection" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'sets the connection info' {
            $ConnectionData.user | Should Not BeNullOrEmpty 
            $ConnectionData.org | Should Not BeNullOrEmpty
            if ( $ConnectionData.cryptoPassword ) {
                Set-EdgeConnection -Org $ConnectionData.org -User $ConnectionData.user -EncryptedPassword $ConnectionData.cryptoPassword
            }
            elseif ( $ConnectionData.password ) {
                Set-EdgeConnection -Org $ConnectionData.org -User $ConnectionData.user -EncryptedPassword $ConnectionData.password
            }
            else {
                throw [System.ArgumentNullException] "need one of password or cryptoPassword in ConnectionData.json"
            }
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
        
        It 'queries environment <Name> by name' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)

            $OneEnv = Get-EdgeEnvironment -Name $Name
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $OneEnv.createdAt | Should BeLessthan $NowMilliseconds
            $OneEnv.lastModifiedAt | Should BeLessthan $NowMilliseconds
            $OneEnv.name | Should Be $Name
            $OneEnv.properties | Should Not BeNullOrEmpty
        }
    }
}



Describe "Get-EdgeApi-1" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'gets a list of proxies' {
            $proxies = @( Get-EdgeApi )
            $proxies.count | Should BeGreaterThan 0
        }
       
        It 'gets details of apiproxy <Name>'  -TestCases @( ToArrayOfHash @( Get-EdgeApi ) ) {
            param($Name)
            $oneproxy = Get-EdgeApi -Name $Name
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

        It 'gets a list of revisions for apiproxy <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeApi ) ) {
            param($Name)
            $revisions = @( Get-EdgeApiRevision -Name $Name )
            $revisions.count | Should BeGreaterThan 0
        }

        It 'gets details for latest revision of <Name>'  -TestCases @( ToArrayOfHash @( Get-EdgeApi ) ) {
            param($Name)

            $revisions = @( Get-EdgeApiRevision -Name $Name )
            $revisions.count | Should BeGreaterThan 0
            $RevisionDetails = Get-EdgeApi -Name $Name -Revision $revisions[-1]
            $RevisionDetails.name | Should Be $Name
            $RevisionDetails.revision | Should Be $revisions[-1]
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $RevisionDetails.createdAt | Should BeLessthan $NowMilliseconds
        }


        It 'gets deployment status of all revisions of <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeApi ) ) {
            param($Name)

            $revisions = @( Get-EdgeApiRevision -Name $Name )
            $revisions.count | Should BeGreaterThan 0

            foreach ($rev in $revisions) {
                $DeploymentStatus = Get-EdgeApiDeployment -Name $Name -Revision $revisions[-1]
                # TODO: insert validation here
            }
        }
    }
}



Describe "Get-Developers-1" {
    
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        It 'gets a list of developers' {
            $devs = @( Get-EdgeDeveloper )
            $devs.count | Should BeGreaterThan 0
        }

        It 'gets a list of developers with expansion' {
            $devs = @( Get-EdgeDeveloper )
            $devs.count | Should BeGreaterThan 0
            $devsExpanded = @(Get-EdgeDeveloper -Params @{ expand = 'true' }).developer
            $devs.count | Should Be $devsExpanded.count
        }

        It 'gets details for developer <Name>'  -TestCases @( ToArrayOfHash  @( Get-EdgeDeveloper ) ) {
            param($Name)

            $dev = @( Get-EdgeDeveloper -Name $Name )
            $dev.email | Should Be $Name
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $dev.createdAt | Should BeLessthan $NowMilliseconds
            $dev.lastModifiedAt | Should BeLessthan $NowMilliseconds
            $dev.organizationName | Should Be $ConnectionData.org 
        }
    }
}

Describe "Get-ApiProduct-1" {
    
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        It 'gets a list of apiproducts' {
            $prods = @( get-edgeapiproduct )
            $prods.count | Should BeGreaterThan 0
        }

        It 'gets a list of apiproducts with expansion' {
            $prods = @( get-edgeapiproduct )
            $prods.count | Should BeGreaterThan 0
            $prodsExpanded = @(Get-edgeapiproduct -Params @{ expand = 'true' }).apiProduct
            $prods.count | Should Be $prodsExpanded.count
        }

        It 'gets details for apiproduct <Name>'  -TestCases @( ToArrayOfHash  @( Get-EdgeApiProduct ) ) {
            param($Name)

            $prod = @( Get-EdgeApiProduct -Name $Name )
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $prod.createdAt | Should BeLessthan $NowMilliseconds
            $prod.lastModifiedAt | Should BeLessthan $NowMilliseconds
            $prod.approvalType | Should Not BeNullOrEmpty
            $prod.lastModifiedBy | Should Not BeNullOrEmpty
        }
    }
}



Describe "Get-Apps-1" {
    
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        It 'gets a list of apps' {
            $apps = @( get-edgeDevApp )
            $apps.count | Should BeGreaterThan 0
        }
        # It 'gets a list of apps with expansion' {
        #     $apps = @( get-edgeDevApp -Params @{ expand = 'true' } )
        #     $apps.count | Should BeGreaterThan 0
        # }
        # 
        # It 'gets a list of apps for developer <Name>'  -TestCases @( ToArrayOfHash  @( Get-EdgeDeveloper ) ) {
        #     param($Name)
        # 
        #     $apps = @( Get-EdgeDevApp -Developer $Name )
        #     $apps.count | Should Not BeNullOrEmpty
        #     $appsExpanded = @(( Get-EdgeDevApp -Developer $Name -Params @{ expand = 'true' } ).app)
        #     $apps.count | Should Be $appsExpanded.count
        # }
        # 
        # It 'gets details of app <Name>'  -TestCases @( ToArrayOfHash  @( Get-EdgeDevApp ) ) {
        #     param($Name)
        # 
        #     $app = Get-EdgeDevApp -Id $Name
        #     $app.appId | Should Be $Name
        #     $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
        #     $app.createdAt | Should BeLessthan $NowMilliseconds
        #     $app.lastModifiedAt | Should BeLessthan $NowMilliseconds
        #     $app.status | Should Not BeNullOrEmpty
        # }
        
        It 'gets a list of apps by ID per developer <Name>'  -TestCases @( ToArrayOfHash  @( Get-EdgeDeveloper ) ) {
            param($Name)
        
            $appsExpanded = @(( Get-EdgeDevApp -Developer $Name -Params @{ expand = 'true' } ).app)
            Write-Host "dev: $Name"

            foreach ($app in $appsExpanded) {
                $app2 = Get-EdgeDevApp -Id $app.appId 
                # $app2 | Should Be $app  # No.

                $app2.psobject.properties | % {
                  $value2 = $_.Value
                  $name = $_.Name
                  Write-Host "prop: $name"
                  Write-Host "value2: $value2"
                  
                  $value1 = $( $app | select -expand $name )
                  Write-Host "value1: $value1"
                  $value2 | Should Be $value1
                }
            }
        }
    }
}


## TODO: insert more tests here 


