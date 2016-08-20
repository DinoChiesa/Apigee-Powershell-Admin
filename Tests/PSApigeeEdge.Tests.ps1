PARAM([string]$Connection = '.\ConnectionData.json')

$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

$PSVersion = $PSVersionTable.PSVersion.Major
Import-Module $PSScriptRoot\..\PSApigeeEdge -Force

# --- Get data for the tests
$json = Get-Content $Connection -Raw | ConvertFrom-JSON
$ConnectionData = @{}
foreach ($prop in $json.psobject.properties.name) {
  $ConnectionData.Add( $prop , $json.$prop )
}

$Script:Props = @{
  guid = $([guid]::NewGuid()).ToString().Replace('-','')
  StartMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
}

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

            if (! $ConnectionData.ContainsKey("User") -or ! $ConnectionData.ContainsKey('Org')) {
                throw [System.ArgumentNullException] 'must specify Org and User and either Password or EncryptedPassword in ConnectionData.json'
            }
            if (! $ConnectionData.ContainsKey("EncryptedPassword") -and ! $ConnectionData.ContainsKey('Password')) {
                throw [System.ArgumentNullException] 'must specify Org and User and either Password or EncryptedPassword in ConnectionData.json'
            }
            Set-EdgeConnection @ConnectionData
        }
    }
}


Describe "Get-EdgeEnvironment-1" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'gets a list of environments' {
            $envs = @( Get-EdgeEnvironment )
            $envs.count | Should BeGreaterThan 0
        }
        
        It 'queries environment <Name> by name' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)

            $OneEnv = Get-EdgeEnvironment -Name $Name
            $OneEnv.createdAt | Should BeLessthan $Script:Props.StartMilliseconds
            $OneEnv.lastModifiedAt | Should BeLessthan $Script:Props.StartMilliseconds
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
            #$oneproxy.metaData.createdAt | Should BeLessthan $NowMilliseconds
            $oneproxy.metaData.lastModifiedAt | Should BeLessthan $Script:Props.StartMilliseconds
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


Describe "Create-Developer-1" {
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        It 'creates a developer' {
            $Params = @{
              Name = [string]::Format('pstest-{0}',$Script:Props.guid.Substring(0,9))
              First = $Script:Props.guid.Substring(0,9)
              Last = $Script:Props.guid.Substring(9,20)
              Email = [string]::Format('pstest-{0}.{1}@example.org',
                     $Script:Props.guid.Substring(0,9),
                     $Script:Props.guid.Substring(9,20))
            }
            $dev = Create-EdgeDeveloper @Params
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $dev.createdAt | Should BeLessthan $NowMilliseconds
            $dev.lastModifiedAt | Should BeLessthan $NowMilliseconds
            $dev.createdBy | Should Be $ConnectionData.User
            $dev.organizationName | Should Be $ConnectionData.Org
            $dev.email | Should Be $Params['Email']
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

Describe "Create-ApiProduct-1" {
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        It 'creates a product' {
            # Create-EdgeApiProduct -Name pstest-198191891  -Environments @( 'env1' )

            $Params = @{
              Name = [string]::Format('pstest-{0}',$Script:Props.guid.Substring(3,11))
              Environments = @( Get-EdgeEnvironment ) # all of them
              Proxies = @( @( Get-EdgeApi )[0] )
            }
            $prod = Create-EdgeApiProduct @Params
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $prod.createdAt | Should BeLessthan $NowMilliseconds
            $prod.lastModifiedAt | Should BeLessthan $NowMilliseconds
            $prod.createdBy | Should Be $ConnectionData.User
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
        
        It 'gets a list of apps with expansion' {
            $apps = @( get-edgeDevApp -Params @{ expand = 'true' } )
            $apps.count | Should BeGreaterThan 0
        }
        
        It 'gets a list of apps for developer <Name>'  -TestCases @( ToArrayOfHash  @( Get-EdgeDeveloper ) ) {
            param($Name)
        
            $apps = @( Get-EdgeDevApp -Developer $Name )
            $apps.count | Should Not BeNullOrEmpty
            $appsExpanded = @(( Get-EdgeDevApp -Developer $Name -Params @{ expand = 'true' } ).app)
            $apps.count | Should Be $appsExpanded.count
        }
        
        It 'gets details of app <Name>'  -TestCases @( ToArrayOfHash  @( Get-EdgeDevApp ) ) {
            param($Name)
        
            $app = Get-EdgeDevApp -Id $Name
            $app.appId | Should Be $Name
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $app.createdAt | Should BeLessthan $NowMilliseconds
            $app.lastModifiedAt | Should BeLessthan $NowMilliseconds
            $app.status | Should Not BeNullOrEmpty
        }
        
        It 'gets a list of apps by ID per developer <Name>'  -TestCases @( ToArrayOfHash  @( Get-EdgeDeveloper ) ) {
            param($Name)
        
            $appsExpanded = @(( Get-EdgeDevApp -Developer $Name -Params @{ expand = 'true' } ).app)
            $excludedProps = @( 'attributes', 'apiProducts', 'credentials')
            foreach ($app in $appsExpanded) {
                $app2 = Get-EdgeDevApp -Id $app.appId 
                # $app2 | Should Be $app  # No.

                # I think it might be possible to do something smart with Compare-Object
                # But... instead we will iterate the properties and compare each one, while
                # excluding properties with non-primitive values.
                $app2.psobject.properties | % {
                  $value2 = $_.Value
                  $name = $_.Name
                  if ( $excludedProps -notcontains $name ) {
                      $value1 = $( $app | select -expand $name )
                      $value2 | Should Be $value1
                  }
                }
            }
        }
    }
}


Describe "Get-EdgeKvm-1" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'gets a list of kvms' {
            $kvms = @( Get-EdgeKvm )
            $kvms.count | Should BeGreaterThan 0
        }
       
        It 'lists kvms for env <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
        
            $kvms = @( Get-EdgeKvm -Env $Name )
            $kvms.count | Should BeGreaterThan 0
        }
    }
}


Describe "Delete-DevApp-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest
        $DevApps = @( Get-EdgeDevApp -Params @{ expand = 'true'} ).app |
            ?{ $_.name.StartsWith('pstest-') } | % { @{ Dev = $_.developerId; Name = $_.name } }

        It 'deletes devapp <Name>' -TestCases $DevApps {
            param($Dev, $Name)
            Delete-EdgeDevApp -Developer -$Dev -Name $Name
        }
    }
}


Describe "Delete-ApiProduct-1" {
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        # get apiproducts with our special name prefix 

        $Products = @( Get-EdgeApiProduct -Params @{ expand = 'true'} ).apiProduct |
            ?{ $_.name.StartsWith('pstest-') } | % { @{ Name = $_.name } }

        It 'deletes product <Name>' -TestCases $Products  {
            param($Name)
            Delete-EdgeApiProduct -Name $Name -Debug
        }
   }
}


Describe "Delete-Developer-1" {
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        $Developers = @( Get-EdgeDeveloper ) |
          ?{ $_.StartsWith('pstest-') } | % { @{ Email = $_ } }
                 
        It 'deletes developer <Email>' -TestCases $Developers {
            param($Email)
            Delete-EdgeDeveloper -Name -$Email
        }
   }
}


## TODO: insert more tests here 


