PARAM([string]$Connection = '.\ConnectionData.json')

$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

$PSVersion = $PSVersionTable.PSVersion.Major
Import-Module $PSScriptRoot\..\PSApigeeEdge -Force

# --- Get data for the tests

$Script:Props = @{
  guid = $([guid]::NewGuid()).ToString().Replace('-','')
  StartMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
}

Function ReadJson {
  param($filename)
  $json = Get-Content $filename -Raw | ConvertFrom-JSON
  $ht = @{}
  foreach ($prop in $json.psobject.properties.name) {
    $ht.Add( $prop , $json.$prop )
  }
  $ht
}

Function ToArrayOfHash {
  param($a)

  $list = New-Object System.Collections.Generic.List[System.Object]
  for ( $i = 0; $i -lt $a.Length; $i++ ) {
     $list.Add( @{ Name = $a[$i] } )
  }
  $list.ToArray()
}

$ConnectionData = ReadJson $Connection 

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


Describe "Create-Kvm-1" {
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        # It 'creates a KVM specifying values' {
        #     $Params = @{
        #       Name = [string]::Format('pstest-A-{0}-{1}', $Script:Props.guid.Substring(0,10), $(Get-Random) )
        #       Env = $( @( Get-EdgeEnvironment )[0]) # the first environment
        #       Values = @{
        #          key1 = 'value1'
        #          key2 = 'value2'
        #          key3 = [string]::Format('value3-{0}', $([guid]::NewGuid()).ToString())
        #       }
        #     }
        #     $kvm = Create-EdgeKvm @Params
        #     { $kvm } | Should Not Throw
        #     $( $kvm.entry | where { $_.name -eq 'key1' } ).value | Should Be 'value1'
        #     $( $kvm.entry | where { $_.name -eq 'key2' } ).value | Should Be 'value2'
        # }

        It 'creates a KVM in Environment <Name> specifying values' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $Value1 = [string]::Format('value1-{0}', $(Get-Random))
            $Value2 = [string]::Format('value2-{0}', $(Get-Random))
            $Params = @{
              Name = [string]::Format('pstest-A-{0}', $Script:Props.guid.Substring(0,10) )
              Env = $Name
              Values = @{
                 key1 = $Value1
                 key2 = $Value2
                 key3 = [string]::Format('value3-{0}', $([guid]::NewGuid()).ToString().Replace('-',''))
              }
            }
            $kvm = Create-EdgeKvm @Params
            { $kvm } | Should Not Throw
            $( $kvm.entry | where { $_.name -eq 'key1' } ).value | Should Be $Value1
            $( $kvm.entry | where { $_.name -eq 'key2' } ).value | Should Be $Value2
        }
        
        It 'creates a KVM in Environment <Name> specifying no values' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $Params = @{
              Name = [string]::Format('pstest-B-{0}-{1}', $Script:Props.guid.Substring(0,10), $(Get-Random))
              Env = $Name
            }
            $kvm = Create-EdgeKvm @Params
            { $kvm } | Should Not Throw
        }

        It 'creates a KVM in Environment <Name> specifying Source file' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $filename = [string]::Format('{0}\pstest-datafile-{1}.json', $env:temp, $(Get-Random))
            $Value1 = [string]::Format('{0}', $(Get-Random) )
            $Value2 = [string]::Format('V2-{0}-{1}', $Script:Props.guid.Substring(0,10), $(Get-Random))
            $object = @{
                key1 = $Value1
                key2 = $Value2
                envname = $Name
            }
            $object | ConvertTo-Json -depth 10 | Out-File $filename
            
            $Params = @{
              Name = [string]::Format('pstest-C-{0}-{1}', $Script:Props.guid.Substring(0,10), $(Get-Random))
              Env = $Name
              Source = $filename
            }
            $kvm = Create-EdgeKvm @Params
            { $kvm } | Should Not Throw

            $( $kvm.entry | where { $_.name -eq 'key1' } ).value | Should Be $Value1
            $( $kvm.entry | where { $_.name -eq 'key2' } ).value | Should Be $Value2

            Remove-Item -path $filename
        }
        
        It 'creates an encrypted KVM in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $Params = @{
                Name = [string]::Format('pstest-encrypted-{0}', $Script:Props.guid.Substring(0,10) )
                Env = $Name
                Encrypted = $True
            }
            $kvm = Create-EdgeKvm @Params
            { $kvm } | Should Not Throw

            Write-Host "TODO: validate response (is encrypted)" 
            $( $kvm.entry | where { $_.name -eq 'key1' } ).value | Should Be $Value1
        }
    }
}



Describe "Crud-KvmEntry-1" {
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        It 'creates an entry in an unencrypted KVM in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $KvmName = [string]::Format('pstest-A-{0}', $Script:Props.guid.Substring(0,10) )
            $EntryName = 'entry1'
            $EntryValue = [string]::Format('value-unencrypted-{0}', $Script:Props.guid.Substring(0,10) )
            $Params = @{
                Env = $Name
                Name = $KvmName
                Entry = $EntryName
                Value = $EntryValue
            }
            $entry = Create-EdgeKvmEntry @Params
            { $entry } | Should Not Throw
            $entry.name | Should Be $EntryName
            $entry.value | Should Be $EntryValue
        }

        It 'updates an entry in an unencrypted KVM in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $KvmName = [string]::Format('pstest-A-{0}', $Script:Props.guid.Substring(0,10) )
            $EntryName = 'entry1'
            $EntryValue = [string]::Format('updated-value-{0}', $Script:Props.guid.Substring(0,10) )
            $Params = @{
                Env = $Name
                Name = $KvmName
                Entry = $EntryName
                NewValue = $EntryValue
            }
            $entry = Update-EdgeKvmEntry @Params
            { $entry } | Should Not Throw
            $entry.name | Should Be $EntryName
            $entry.value | Should Be $EntryValue
            
            $entry = Get-EdgeKvmEntry -Env $Name -Name $KvmName -Entry $EntryName
            { $entry } | Should Not Throw
            $entry.name | Should Be $EntryName
            $entry.value | Should Be $EntryValue
        }

        It 'creates an entry in an encrypted KVM in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $KvmName = [string]::Format('pstest-encrypted-{0}', $Script:Props.guid.Substring(0,10) )
            $EntryName = 'entry1'
            $EntryValue = [string]::Format('value-encrypted-{0}', $Script:Props.guid.Substring(0,10) )
            $Params = @{
                Env = $Name
                Name = $KvmName
                Entry = $EntryName
                Value = $EntryValue
            }
            $entry = Create-EdgeKvmEntry @Params
            { $entry } | Should Not Throw
            $entry.name | Should Be $EntryName
            $entry.value | Should Be '*****'
        }

        It 'updates an entry in an encrypted KVM in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $KvmName = [string]::Format('pstest-encrypted-{0}', $Script:Props.guid.Substring(0,10) )
            $EntryName = 'entry1'
            $EntryValue = [string]::Format('updated-value-encrypted-{0}', $Script:Props.guid.Substring(0,10) )
            $Params = @{
                Env = $Name
                Name = $KvmName
                Entry = $EntryName
                NewValue = $EntryValue
            }
            $entry = Update-EdgeKvmEntry @Params
            { $entry } | Should Not Throw
            $entry.name | Should Be $EntryName
            $entry.value | Should Be '*****'
            
            $entry = Get-EdgeKvmEntry -Env $Name -Name $KvmName -Entry $EntryName
            { $entry } | Should Not Throw
            $entry.name | Should Be $EntryName
            $entry.value | Should Be '*****'
        }
        
        It 'deletes an entry in an unencrypted KVM in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $KvmName = [string]::Format('pstest-A-{0}', $Script:Props.guid.Substring(0,10) )
            $EntryName = 'entry1'
            $Params = @{
                Env = $Name
                Name = $KvmName
                Entry = $EntryName
            }
            $entry = Delete-EdgeKvmEntry @Params
            { $entry } | Should Not Throw
            $kvm = Get-EdgeKvm -Env $Name -Name $KvmName
            
            $( $kvm.entry | where { $_.name -eq $EntryName } ).value | Should BeNullOrEmpty
        }
        
        It 'deletes an entry in an encrypted KVM in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $KvmName = [string]::Format('pstest-encrypted-{0}', $Script:Props.guid.Substring(0,10) )
            $EntryName = 'entry1'
            $Params = @{
                Env = $Name
                Name = $KvmName
                Entry = $EntryName
            }
            $entry = Delete-EdgeKvmEntry @Params
            { $entry } | Should Not Throw
            $kvm = Get-EdgeKvm -Env $Name -Name $KvmName
            $( $kvm.entry | where { $_.name -eq $EntryName } ).value | Should BeNullOrEmpty
        }

    }
}


Describe "Create-Developer-1" {
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        It 'creates a developer' {
            $Params = @{
              Name = [string]::Format('pstest-{0}', $Script:Props.guid.Substring(0,9))
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

        It 'gets a list of all developers with expansion' {
            $devs = @( Get-EdgeDeveloper )
            $devs.count | Should BeGreaterThan 0
            $devsExpanded = @(Get-EdgeDeveloper -Params @{ expand = 'true' }).developer
            $devs.count | Should Be $devsExpanded.count
            $devsExpanded[0].GetType().Name | Should Be 'PSCustomObject'
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
              Name = [string]::Format('pstest-{0}', $Script:Props.guid.Substring(3,11))
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



Describe "Create-App-1" {
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        It 'creates Apps with different credential expiry' {
            $Developers = @( @( Get-EdgeDeveloper ) |
              ?{ $_.StartsWith('pstest-') } | % { @{ Email = $_ } } )
              
            $Products = @( @( Get-EdgeApiProduct -Params @{ expand = 'true'} ).apiProduct |
              ?{ $_.name.StartsWith('pstest-') } | % { @{ Name = $_.name } } )

            $expiryOptions = @(
                "48h", "21d", (Get-Date).AddDays(60).ToString('yyyy-MM-dd'), ""
            )

            foreach ($expiry in $expiryOptions) {
                
                $Params = @{
                    Name = [string]::Format('pstest-{0}-{1}', $Script:Props.guid.Substring(0,5), $expiry )
                    Developer = $Developers[0].Email
                    ApiProducts = @( $Products[0].Name )
                }
                if ($expiry) {
                    Write-Host "expiry: ${expiry}" 
                    $Params['Expiry'] = $expiry
                }
                else {
                    Write-Host "expiry: -none-" 
                }

                $app = Create-EdgeDevApp @Params
                { $app } | Should Not Throw
                #TODO : verify expiry?
            }
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
            $excludedProps = @( 'attributes', 'apiProducts', 'credentials' )
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


Describe "Get-EdgeKVM-1" {
    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'gets a list of kvms' { # org-scopes kvms. 
            $kvms = @( Get-EdgeKvm )
            { $kvms } | Should Not Throw
        }
       
        It 'lists kvms for env <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $kvms = @( Get-EdgeKvm -Env $Name )
            $kvms.count | Should BeGreaterThan 0
            # check that we have one or more KVMs created by this script
            @( $kvms | ?{ $_.StartsWith('pstest-') } ).count | Should BeGreaterThan 0
        }
    }
}


Describe "Delete-DevApp-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest
        $DevApps = @( @( Get-EdgeDevApp -Params @{ expand = 'true'} ).app |
            ?{ $_.name.StartsWith('pstest-') } | % { @{ Dev = $_.developerId; Name = $_.name } } )

        It 'deletes devapp <Name>' -TestCases $DevApps {
            param($Dev, $Name)
            Delete-EdgeDevApp -Developer $Dev -Name $Name
        }
    }
}


Describe "Delete-ApiProduct-1" {
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        # get apiproducts with our special name prefix 

        $Products = @( @( Get-EdgeApiProduct -Params @{ expand = 'true'} ).apiProduct |
            ?{ $_.name.StartsWith('pstest-') } | % { @{ Name = $_.name } } )

        It 'deletes product <Name>' -TestCases $Products  {
            param($Name)
            Delete-EdgeApiProduct -Name $Name
        }
    }
}


Describe "Delete-Developer-1" {
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        $Developers = @( @( Get-EdgeDeveloper ) |
          ?{ $_.StartsWith('pstest-') } | % { @{ Email = $_ } } )
                 
        It 'deletes developer <Email>' -TestCases $Developers {
            param($Email)
            Delete-EdgeDeveloper -Name $Email
        }
    }
}


Describe "Delete-Kvm-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'deletes test KVMs in env <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $kvms = @( Get-EdgeKvm -Env $Name )
            @( $kvms | ?{ $_.StartsWith('pstest-') } ).count | Should BeGreaterThan 0
            @( $kvms | ?{ $_.StartsWith('pstest-') } ) | % { 
                Delete-EdgeKvm -Env $Name -Name $_
            }
        }

        It 'verifies that the test KVMs for env <Name> have been deleted' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $kvms = @( Get-EdgeKvm -Env $Name )
            @( $kvms | ?{ $_.StartsWith('pstest-') } ).count | Should Be 0
        }
    }
}



Describe "Create-Keystore-1" {
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        It 'creates a keystore in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $Params = @{
              Name = [string]::Format('pstest-{0}{1}', $Script:Props.guid.Substring(0,10), $(Get-Random))
              Env = $Name
            }
            $keystore = Create-EdgeKeystore @Params
            { $keystore } | Should Not Throw
            # TODO? - validate response
        }
    }
}


Describe "Get-Keystore-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'gets a list of keystores for Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $keystores = @( Get-EdgeKeystore -Env $Name )
            # check that we have one or more keystores
            $keystores.count | Should BeGreaterThan 0
            # check that we have one or more keystores created by this script
            @( $keystores | ?{ $_.StartsWith('pstest-') } ).count | Should BeGreaterThan 0
        }

        It 'gets specific info on each keystore for Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            
            @( Get-EdgeKeystore -Env $Name ) | % {
                $keystore = Get-EdgeKeystore -Env $Name -Name $_
                $keystore | Should Not BeNullOrEmpty
                $keystore.name | Should Not BeNullOrEmpty
            }
        }
    }
}


Describe "Delete-Keystore-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'deletes the test keystores in Env <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            @( @( Get-EdgeKeystore -Env $Name ) | ?{ $_.StartsWith('pstest-') } ) | % { 
                Delete-EdgeKeystore -Env $Name -Name $_
            }
        }

        It 'verifies that the test keystores for Environment <Name> have been removed' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $keystores = @( Get-EdgeKeystore -Env $Name )
            # check that we have one or more keystores
            $keystores.count | Should BeGreaterThan 0
            # check that we now have zero keystores created by this script
            @( $keystores | ?{ $_.StartsWith('pstest-') } ).count | Should Be 0
        }
    }
}



Describe "Get-Vhost-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'gets a list of Vhosts for Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
          param($Name)
          $vhosts = @( Get-EdgeVhost -Env $Name )
          $vhosts.count | Should BeGreaterThan 0
        }

        It 'gets specific info on each vhost for Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            
            @( Get-EdgeVhost -Env $Name ) | % {
                $vhost = Get-EdgeVhost -Env $Name -Name $_
                $vhost | Should Not BeNullOrEmpty
                $vhost.name | Should Not BeNullOrEmpty
            }
        }
    }
}


## TODO: insert more tests here 

# Add-EdgeAppCredential - add a new credential to an app
# Update-EdgeAppCredential.ps1 - revoke or approve a credential, or change products list

