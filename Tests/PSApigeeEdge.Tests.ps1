PARAM([string]$Connection = '.\ConnectionData.json')

$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master") {
    $Verbose.add("Verbose",$True)
}

$PSVersion = $PSVersionTable.PSVersion.Major
Import-Module $PSScriptRoot\..\PSApigeeEdge -Force

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

Function FiveMinutesInTheFutureMilliseconds {
    $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
    $FiveMinsInTheFuture = $NowMilliseconds + (300 * 1000);
    $FiveMinsInTheFuture
}

function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid().ToString().Replace('-','')
    New-Item -ItemType Directory -Path (Join-Path $parent $name)
}
# --- Get data for the tests

$Script:Props = @{
    guid = $([System.Guid]::NewGuid()).ToString().Replace('-','')
    StartMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
    OrgIsCps = $False
    SpecialPrefix = [string]::Format('pstest-{0}-{1}',
                                     $([System.Guid]::NewGuid()).ToString().Replace('-','').Substring(0,12),
                                     $(Get-Random))
    CreatedProxies = New-Object System.Collections.ArrayList
    FoundEnvironments = New-Object System.Collections.ArrayList
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


Describe "Get-EdgeOrganization-1" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'gets info regarding the default org' {
            $org = $( Get-EdgeOrganization )
            $isCps = @( $org.properties.psobject.properties.value | where { $_.name -eq 'features.isCpsEnabled' })
            if ( $isCps.count -gt 0 ) {
                # need to know CPS in order to decide whether to run KVM tests
                $Script:Props.OrgIsCps = $isCps[0].value 
            }
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
            $Script:Props.FoundEnvironments.Add($Name)
        }
    }
}


Describe "Import-EdgeApi-1" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest
        Add-Type -assembly "system.io.compression.filesystem"
        $datapath = [System.IO.Path]::Combine($PSScriptRoot, "data")

        # get the list of zipfiles
        $i = 0
        $zipfiles = @( Get-ChildItem $(Join-Path -Path $PSScriptRoot -ChildPath "data" -Resolve) ) |
          ?{ $_.Name.EndsWith('.zip') -and $_.Name.StartsWith('apiproxy-') } | %{ @{ Zip = $_.Name; Index=$i++ } }

        It 'imports proxy from ZIP file bundle <Zip>' -TestCases $zipfiles {
            param($Zip, $Index)
            $zipfile = $(Join-Path -Path $datapath -ChildPath $Zip -Resolve)
            
            $apiproxyname = [string]::Format('{0}-apiproxy-{1}', $Script:Props.SpecialPrefix, $Index)
            #write-host $([string]::Format("APIProxy name: {0}", $apiproxyname))
            $api = @(Import-EdgeApi -Source $zipfile -Name $apiproxyname)
            ## now, remember the proxy we just imported, so we can deploy and export and delete, later
            $Script:Props.CreatedProxies.Add($apiproxyname)
        }

        It 'imports proxy from exploded dir for <Zip>' -TestCases $zipfiles {
            param($Zip, $Index)
            $zipfile = $(Join-Path -Path $datapath -ChildPath $Zip -Resolve)
            $destination = New-TemporaryDirectory
            [System.IO.Compression.Zipfile]::ExtractToDirectory($zipfile, $destination)
            $apiproxyname = [string]::Format('{0}-apiproxy-exploded-{1}', $Script:Props.SpecialPrefix, $Index)
            write-host $([string]::Format("APIProxy dir: {0}", $destination))
            $api = @(Import-EdgeApi -Source $destination -Name $apiproxyname)
            Write-host $api
            ## now, remember the proxy we just imported, so we can deploy and export and delete, later
            $Script:Props.CreatedProxies.Add($apiproxyname)
            Write-host "TODO: delete the temporary exploded directory"
            # [System.IO.Directory]::delete($destination)
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
       
        It 'gets details of apiproxy <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeApi ) ) {
            param($Name)
            $oneproxy = Get-EdgeApi -Name $Name
            $oneproxy | Should Not BeNullOrEmpty
            $oneproxy.metaData | Should Not BeNullOrEmpty

            if ($Name.StartsWith($Script:Props.SpecialPrefix)) {
                $oneproxy.metaData.lastModifiedAt | Should BeGreaterThan $Script:Props.StartMilliseconds
            }
            else {
                $oneproxy.metaData.lastModifiedAt | Should BeLessThan $Script:Props.StartMilliseconds
            }
            
            $oneproxy.metaData.lastModifiedBy | Should Not BeNullOrEmpty
        }
    }
}


Describe "Deploy-EdgeApi-1" {
    Context 'Strict mode' { 
        Set-StrictMode -Version latest

        ## produce testcases that will deploy the imported proxies to all environments. 
        $i=0
        $testcases = $Script:Props.FoundEnvironments | 
          foreach { $env= $_; $Script:Props.CreatedProxies | foreach { @{ Name = $_; Env = $env; Index=$i++ } } }
        
        It 'deploys proxy <Name> to <Env>' -TestCases $testcases {
            param($Name, $Env, $Index)
            # use a unique basepath to prevent conflicts
            $basepath = [string]::Format('/{0}-{1}',  $Script:Props.SpecialPrefix, $Index);
            $deployment = @( Deploy-EdgeApi -Name $Name -Env $Env -Revision 1 -Basepath $basepath )
            $deployment | Should Not BeNullOrEmpty
            $deployment.state | Should Be "deployed"
        }
        
        It 'tries again to deploy proxy <Name> to <Env>' -TestCases $testcases {
            param($Name, $Env, $Index)
            # use the same basepath; should receive a conflict
            $basepath = [string]::Format('/{0}-{1}',  $Script:Props.SpecialPrefix, $Index);
            { Deploy-EdgeApi -Name $Name -Env $Env -Revision 1 -Basepath $basepath } | Should Throw
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
            # Because of time skew between the server and client, time comparisons may fail
            # $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            # $RevisionDetails.createdAt | Should BeLessthan $NowMilliseconds
            #

            if ($Name.StartsWith($Script:Props.SpecialPrefix)) {
                $RevisionDetails.createdAt | Should BeGreaterThan $Script:Props.StartMilliseconds
            }
            else {
                $RevisionDetails.createdAt | Should BeLessThan $Script:Props.StartMilliseconds
            }
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


Describe "Undeploy-EdgeApi-1" {
    Context 'Strict mode' { 
        Set-StrictMode -Version latest

        ## produce testcases that will deploy the imported proxies to all environments. 
        $testcases = $Script:Props.FoundEnvironments | 
          foreach { $env= $_; $Script:Props.CreatedProxies | foreach { @{ Name = $_; Env = $env; } } }
        
        It 'undeploys proxy <Name> from <Env>' -TestCases $testcases {
            param($Name, $Env)
            $undeployment = @( UnDeploy-EdgeApi -Name $Name -Env $Env -Revision 1 )
            $undeployment | Should Not BeNullOrEmpty
            $undeployment.state | Should Be "undeployed"
        }
        
        It 'tries again to undeploy proxy <Name> from <Env>' -TestCases $testcases {
            param($Name, $Env)
            { UnDeploy-EdgeApi -Name $Name -Env $Env -Revision 1 } | Should Throw
        }
    }
}

 
Describe "Create-Kvm-1" {
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        It 'creates a KVM in Environment <Name> specifying values' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $Value1 = [string]::Format('value1-{0}', $(Get-Random))
            $Value2 = [string]::Format('value2-{0}', $(Get-Random))
            $Params = @{
              Name = [string]::Format('{0}-kvm-A', $Script:Props.SpecialPrefix )
              Env = $Name
              Values = @{
                 key1 = $Value1
                 key2 = $Value2
                 key3 = [string]::Format('value3-{0}', $([guid]::NewGuid()).ToString().Replace('-',''))
              }
            }
            $kvm = Create-EdgeKvm @Params
            { $kvm } | Should Not Throw
            @( $kvm.entry | where { $_.name -eq 'key1' } ).count | Should Be 1
            $( $kvm.entry | where { $_.name -eq 'key1' } ).value | Should Be $Value1
            @( $kvm.entry | where { $_.name -eq 'key2' } ).count | Should Be 1
            $( $kvm.entry | where { $_.name -eq 'key2' } ).value | Should Be $Value2
            @( $kvm.entry | where { $_.name -eq 'non-existent-key' } ).count | Should Be 0
        }
        
        It 'creates a KVM in Environment <Name> specifying no values' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $Params = @{
              Name = [string]::Format('{0}-kvm-B', $Script:Props.SpecialPrefix )
              Env = $Name
            }
            $kvm = Create-EdgeKvm @Params
            { $kvm } | Should Not Throw
        }

        It 'creates a KVM in Environment <Name> specifying Source file' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $filename = [string]::Format('{0}\{1}-datafile.json', $env:temp, $Script:Props.SpecialPrefix )
            $Value1 = [string]::Format('{0}', $(Get-Random) )
            $Value2 = [string]::Format('V2-{0}-{1}', $Script:Props.guid.Substring(0,10), $(Get-Random))
            $object = @{
                key1 = $Value1
                key2 = $Value2
                envname = $Name
            }
            $object | ConvertTo-Json -depth 10 | Out-File $filename
            
            $Params = @{
              Name = [string]::Format('{0}-kvm-C', $Script:Props.SpecialPrefix )
              Env = $Name
              Source = $filename
            }
            $kvm = Create-EdgeKvm @Params
            { $kvm } | Should Not Throw

            @( $kvm.entry | where { $_.name -eq 'key1' } ).count | Should Be 1
            $( $kvm.entry | where { $_.name -eq 'key1' } ).value | Should Be $Value1
            @( $kvm.entry | where { $_.name -eq 'key2' } ).count | Should Be 1
            $( $kvm.entry | where { $_.name -eq 'key2' } ).value | Should Be $Value2

            Remove-Item -path $filename
        }
        
        It 'creates an encrypted KVM in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $Params = @{
                Name = [string]::Format('{0}-kvm-encrypted', $Script:Props.SpecialPrefix )
                Env = $Name
                Encrypted = $True
            }
            $kvm = Create-EdgeKvm @Params
            { $kvm } | Should Not Throw
            @( $kvm.entry | where { $_.name -eq 'key1' } ).count | Should Be 0
        }
        
        It 'creates an encrypted KVM in Environment <Name> with Values' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $KvmName = [string]::Format('{0}-kvm-encrypted-with-values', $Script:Props.SpecialPrefix )
            $Value1 = [string]::Format('value1-{0}', $(Get-Random))
            $Value2 = [string]::Format('value2-{0}', $(Get-Random))
            $Params = @{
                Name = $KvmName
                Env = $Name
                Encrypted = $True
                Values = @{
                  key1 = $Value1
                  key2 = $Value2
                  key3 = [string]::Format('value3-{0}', $([guid]::NewGuid()).ToString().Replace('-',''))
                }
            }
            $kvm = Create-EdgeKvm @Params
            { $kvm } | Should Not Throw
            # values are passed back in cleartext on creation
            @( $kvm.entry | where { $_.name -eq 'key1' } ).count | Should Be 1
            $( $kvm.entry | where { $_.name -eq 'key1' } ).value | Should Be $Value1
            @( $kvm.entry | where { $_.name -eq 'key2' } ).count | Should Be 1
            $( $kvm.entry | where { $_.name -eq 'key2' } ).value | Should Be $Value2
            @( $kvm.entry | where { $_.name -eq 'key-not-exist' } ).count | Should Be 0

            $kvm = Get-EdgeKvm -Env $Name -Name $KvmName
            { $kvm } | Should Not Throw
            # values are not passed back in cleartext on query
            @( $kvm.entry | where { $_.name -eq 'key1' } ).count | Should Be 1
            $( $kvm.entry | where { $_.name -eq 'key1' } ).value | Should Be '*****'
            @( $kvm.entry | where { $_.name -eq 'key2' } ).count | Should Be 1
            $( $kvm.entry | where { $_.name -eq 'key2' } ).value | Should Be '*****'
            @( $kvm.entry | where { $_.name -eq 'key-not-exist' } ).count | Should Be 0
        }
    }
}



Describe "Crud-KvmEntry-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest
        if ( $Script:Props.OrgIsCps ) {

            It 'creates an entry in an unencrypted KVM in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
                param($Name)
                $KvmName = [string]::Format('{0}-kvm-A', $Script:Props.SpecialPrefix )
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
                $KvmName = [string]::Format('{0}-kvm-A', $Script:Props.SpecialPrefix )
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
                $KvmName = [string]::Format('{0}-kvm-encrypted', $Script:Props.SpecialPrefix )
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
                # upon first creation, the value is sent back in clear text
                $entry.value | Should Be $EntryValue
            }

            It 'updates an entry in an encrypted KVM in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
                param($Name)
                $KvmName = [string]::Format('{0}-kvm-encrypted', $Script:Props.SpecialPrefix )
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
                # upon update, the value is sent back in clear text
                $entry.value | Should Be $EntryValue
                
                $entry = Get-EdgeKvmEntry -Env $Name -Name $KvmName -Entry $EntryName
                { $entry } | Should Not Throw
                $entry.name | Should Be $EntryName
                $entry.value | Should Be '*****'
            }
            
            It 'deletes an entry in an unencrypted KVM in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
                param($Name)
                $KvmName = [string]::Format('{0}-kvm-A', $Script:Props.SpecialPrefix )
                $EntryName = 'entry1'
                $Params = @{
                    Env = $Name
                    Name = $KvmName
                    Entry = $EntryName
                }
                $entry = Delete-EdgeKvmEntry @Params
                { $entry } | Should Not Throw
                $kvm = Get-EdgeKvm -Env $Name -Name $KvmName
                # the entry with this name should not be found
                @( $kvm.entry | where { $_.name -eq $EntryName } ).count | Should Be 0
            }
            
            It 'deletes an entry in an encrypted KVM in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
                param($Name)
                $KvmName = [string]::Format('{0}-kvm-encrypted', $Script:Props.SpecialPrefix )
                $EntryName = 'entry1'
                $Params = @{
                    Env = $Name
                    Name = $KvmName
                    Entry = $EntryName
                }
                $entry = Delete-EdgeKvmEntry @Params
                { $entry } | Should Not Throw
                $kvm = Get-EdgeKvm -Env $Name -Name $KvmName
                @( $kvm.entry | where { $_.name -eq $EntryName } ).count | Should Be 0
            }
        }
    }
}


Describe "Create-Developer-1" {
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        It 'creates a developer' {
            $Params = @{
              Name = [string]::Format('{0}-developer', $Script:Props.SpecialPrefix )
              First = $Script:Props.guid.Substring(0,6)
              Last = $Script:Props.guid.Substring(7,15)
              Email = [string]::Format('{0}@example.org', $Script:Props.SpecialPrefix )
            }
            $dev = Create-EdgeDeveloper @Params
            # Start-Sleep -Milliseconds 3000
            $FiveMinsInTheFuture = FiveMinutesInTheFutureMilliseconds
            
            # These time comparisons will be valid iff the server time is not skewed from the client time
            $dev.createdAt | Should BeLessthan $FiveMinsInTheFuture
            $dev.lastModifiedAt | Should BeLessthan $FiveMinsInTheFuture
            $dev.createdAt | Should BeGreaterthan $Script:Props.StartMilliseconds
            $dev.lastModifiedAt | Should BeGreaterthan $Script:Props.StartMilliseconds
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

        It 'gets details for developer <Name>' -TestCases @( ToArrayOfHash  @( Get-EdgeDeveloper ) ) {
            param($Name)

            $dev = @( Get-EdgeDeveloper -Name $Name )
            #Start-Sleep -Milliseconds 3000
            
            # These time comparisons will be valid iff the server time is not skewed from the client time
            # $FiveMinsInTheFuture = FiveMinutesInTheFutureMilliseconds
            $dev.email | Should Be $Name
            
            if ($Name.StartsWith($Script:Props.SpecialPrefix)) {
                $dev.createdAt | Should BeGreaterThan $Script:Props.StartMilliseconds
                $dev.lastModifiedAt | Should BeGreaterThan $Script:Props.StartMilliseconds
            }
            else {
                $dev.createdAt | Should BeLessThan $Script:Props.StartMilliseconds
                $dev.lastModifiedAt | Should BeLessThan $Script:Props.StartMilliseconds
            }
            
            $dev.organizationName | Should Be $ConnectionData.org 
        }
    }
}


Describe "Create-ApiProduct-1" {
    Context 'Strict mode' {
        
        Set-StrictMode -Version latest

        It 'creates a product' {
            $Params = @{
                Name = [string]::Format('{0}-apiproduct', $Script:Props.SpecialPrefix )
                Environments = @( Get-EdgeEnvironment ) # all of them
                Proxies = @( @( Get-EdgeApi )[0] )
            }
            $prod = Create-EdgeApiProduct @Params
            Start-Sleep -Milliseconds 3000
            
            # These time comparisons will be valid iff the server time is not skewed from the client time
            $FiveMinsInTheFuture = FiveMinutesInTheFutureMilliseconds
            $prod.createdAt | Should BeLessthan $FiveMinsInTheFuture
            $prod.lastModifiedAt | Should BeLessthan $FiveMinsInTheFuture
            $prod.createdAt | Should BeGreaterThan $Script:Props.StartMilliseconds
            $prod.lastModifiedAt | Should BeGreaterThan $Script:Props.StartMilliseconds
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

        It 'gets details for apiproduct <Name>' -TestCases @( ToArrayOfHash  @( Get-EdgeApiProduct ) ) {
            param($Name)
            $prod = @( Get-EdgeApiProduct -Name $Name )
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            
            $prod.createdAt | Should BeLessthan $NowMilliseconds
            $prod.lastModifiedAt | Should BeLessthan $NowMilliseconds
            
            if ($Name.StartsWith($Script:Props.SpecialPrefix)) {
                $prod.createdAt | Should BeGreaterThan $Script:Props.StartMilliseconds
                $prod.lastModifiedAt | Should BeGreaterThan $Script:Props.StartMilliseconds
            }
            else {
                $prod.createdAt | Should BeLessThan $Script:Props.StartMilliseconds
                $prod.lastModifiedAt | Should BeLessThan $Script:Props.StartMilliseconds
            }
            
            $prod.approvalType | Should Not BeNullOrEmpty
            $prod.lastModifiedBy | Should Not BeNullOrEmpty
        }
    }
}


Describe "Create-App-1" {
    Context 'Strict mode' {

        Set-StrictMode -Version latest

        $Developers = @( @( Get-EdgeDeveloper ) |
          ?{ $_.StartsWith($Script:Props.SpecialPrefix) } | % { @{ Email = $_ } } )

        $Products = @( @( Get-EdgeApiProduct -Params @{ expand = 'true'} ).apiProduct |
          ?{ $_.name.StartsWith($Script:Props.SpecialPrefix) } | % { @{ Name = $_.name } } )

        $cases = @{ expiry = "48h" },
                @{ expiry = '86400' }, # default is a number of seconds
                @{ expiry = '21d' },
                @{ expiry = (Get-Date).AddDays(60).ToString('yyyy-MM-dd') }
                @{ expiry = "" }

        It 'creates an App with credential expiry <expiry>' -TestCases $cases {
            param($expiry)

            $Params = @{
                Name = [string]::Format('{0}-app-{1}', $Script:Props.SpecialPrefix, $expiry )
                Developer = $Developers[0].Email
                ApiProducts = @( $Products[0].Name )
            }
            if (![string]::IsNullOrEmpty($expiry)) {
                $Params['Expiry'] = $expiry
            }

            $app = Create-EdgeDevApp @Params
            { $app } | Should Not Throw
            #TODO : verify expiry?
        }
    }
}


Describe "Create-App-Failures" {
    Context 'Strict mode' {

        Set-StrictMode -Version latest

        $Developers = @( @( Get-EdgeDeveloper ) |
          ?{ $_.StartsWith($Script:Props.SpecialPrefix) } | % { @{ Email = $_ } } )

        $Products = @( @( Get-EdgeApiProduct -Params @{ expand = 'true'} ).apiProduct |
          ?{ $_.name.StartsWith($Script:Props.SpecialPrefix) } | % { @{ Name = $_.name } } )

        $expiryCases = @{ expiry = "2016-12-10" }, # in the past
                @{ expiry = '-43200' }, # negative integer
                @{ expiry = 'ABCDE' } # invalid

        It 'creates an App with invalid expiry <expiry>' -TestCases $expiryCases {
            param($expiry)

            $Params = @{
                Name = [string]::Format('{0}-app-failure-A-{1}', $Script:Props.SpecialPrefix, $expiry )
                Developer = $Developers[0].Email
                ApiProducts = @( $Products[0].Name )
                Expiry = $expiry
            }

            { Create-EdgeDevApp @Params } | Should Throw
        }
        
        It 'creates an App with missing Developer' {
            $Params = @{
                Name = [string]::Format('{0}-app-failure-B-{1}', $Script:Props.SpecialPrefix, $expiry )
                ApiProducts = @( $Products[0].Name )
            }
            { Create-EdgeDevApp @Params } | Should Throw
        }
            
        It 'creates an App with missing ApiProducts' {
            $Params = @{
                Name = [string]::Format('{0}-app-failure-C-{1}', $Script:Props.SpecialPrefix, $expiry )
                Developer = $Developers[0].Email
            }
            { Create-EdgeDevApp @Params } | Should Throw
        }
        
        It 'creates an App with missing Name' {
            $Params = @{
                ApiProducts = @( $Products[0].Name )
                Developer = $Developers[0].Email
            }
            { Create-EdgeDevApp @Params } | Should Throw
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


Describe "Get-Kvm-1" {
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
            @( $kvms | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ).count | Should BeGreaterThan 0
        }
    }
}


Describe "Delete-DevApp-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest
        $DevApps = @( @( Get-EdgeDevApp -Params @{ expand = 'true'} ).app |
          ?{ $_.name.StartsWith($Script:Props.SpecialPrefix) } | %{ @{ Dev = $_.developerId; Name = $_.name } } )

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
            ?{ $_.name.StartsWith($Script:Props.SpecialPrefix) } | % { @{ Name = $_.name } } )

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
          ?{ $_.StartsWith($Script:Props.SpecialPrefix) } | % { @{ Email = $_ } } )
                 
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
            @( $kvms | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ).count | Should BeGreaterThan 0
            @( $kvms | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ) | % { 
                Delete-EdgeKvm -Env $Name -Name $_
            }
        }

        It 'verifies that the test KVMs for env <Name> have been deleted' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $kvms = @( Get-EdgeKvm -Env $Name )
            @( $kvms | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ).count | Should Be 0
        }
    }
}



Describe "Create-Keystore-1" {
    Context 'Strict mode' {
    
        Set-StrictMode -Version latest

        It 'creates a keystore in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $Params = @{
                Name = [string]::Format('{0}-keystore', $Script:Props.SpecialPrefix )
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
            @( $keystores | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ).count | Should BeGreaterThan 0
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

            $keystores = @( Get-EdgeKeystore -Env $Name )            
            @( $keystores | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ).count | Should BeGreaterThan 0

            @( $keystores | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ) | % { 
                Delete-EdgeKeystore -Env $Name -Name $_
            }
            @( $keystores | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ) | % { 
                { Delete-EdgeKeystore -Env $Name -Name $_ } | Should Throw
            }
        }

        It 'verifies that the test keystores for Environment <Name> have been removed' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $keystores = @( Get-EdgeKeystore -Env $Name )
            # check that we have one or more keystores
            $keystores.count | Should BeGreaterThan 0
            # check that we now have zero keystores created by this script
            @( $keystores | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ).count | Should Be 0
        }
    }
}


Describe "Delete-EdgeApi-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'deletes the API <Name>' -TestCases @( ToArrayOfHash @( $Script:Props.CreatedProxies ) ) {
            param($Name)
            $deleted = @( Delete-EdgeApi -Name $Name )
        }
        It 'tries again to delete the API <Name>' -TestCases @( ToArrayOfHash @( $Script:Props.CreatedProxies ) ) {
            param($Name)
            { Delete-EdgeApi -Name $Name } | Should Throw
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

