# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

PARAM([string]$Connection = '.\ConnectionData.json')

$Verbose = @{}
#if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master") {
#    $Verbose.add("Verbose", $True)
#}

$PSVersion = $PSVersionTable.PSVersion.Major
Import-Module $PSScriptRoot\..\PSApigeeEdge -Force
# Avoid "Invoke-RestMethod : The underlying connection was closed: An unexpected error occurred on a send"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Function ReadJson {
    param($filename)
    $filename = $( Resolve-Path $filename )
    #write-host $([string]::Format("connection data filename: {0}`n", $filename))
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

Function CompareArraysOfNameValuePairs {
    param (
        [Parameter(Mandatory = $true)]
        [System.Object[]] $Left,
        [Parameter(Mandatory = $true)]
        [System.Object[]] $Right
    )

    $Result = @()
    if ( $( $Left.length -ne $Right.length ) ) { $Result += 'wrong length' }

    if ( $Result.length -eq 0 ) {
        for ($i=0; $i -lt $Left.length; $i++) {
            $LeftEntry = $Left[$i]
            $RightEntry = $( $Right | where { $_.name -eq $LeftEntry.name } )
            if ($RightEntry -eq $null) {
                $Result += [string]::Format('{0}. entry({1}) left({2}) right(null)',
                                            $i, $LeftEntry.name, $LeftEntry.value);
            }
            elseif ( $( $LeftEntry.value -ne $RightEntry.value ) ) {
                $Result += [string]::Format('{0}. entry({1}) left({2}) right({3})',
                                            $i, $LeftEntry.name, $LeftEntry.value, $RightEntry.value);
            }
        }
        $Result
    }
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
    OrgIsCps = $False # until we check?
    SpecialPrefix = [string]::Format('pstest-{0}-{1}',
                                     $( Get-Date -format 'yyyyMMdd-HHmmss' ),
                                     $([System.Guid]::NewGuid()).ToString().Replace('-','').Substring(0,12))
                                     # $(Get-Random))
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

Describe "PreClean-Artifacts" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest
        $pattern = '^pstest-([0-9]{8})-([0-9]{6})-([a-z0-9]{12})'
        It 'preclean deletes test KVMs in env <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $kvmNames = @( Get-EdgeKvm -Environment $Name )
            @( $kvmNames -match $pattern ) | % {
                Delete-EdgeKvm -Environment $Name -Name $_
            }
        }

        $response = $( Get-EdgeDevApp -Params @{ expand = 'true'} )
        if ($response.PSobject.Properties.name -match "app") {
            $DevAppsToDelete = @( $response.app |
              ?{ $_.name -match $pattern } | %{ @{ Dev = $_.developerId; Name = $_.name } } )

            if ($DevAppsToDelete.count -gt 0) {
                It 'deletes devapp <Name>' -TestCases $DevAppsToDelete {
                    param($Dev, $Name)
                    Delete-EdgeDevApp -Developer $Dev -AppName $Name
                }
            }
        }
        else {
            write-host ("SMH, Cannot retrieve dev apps")
        }

        $allproxies = @( Get-EdgeApi )
        $ProxiesOfInterest = @( $allproxies -match '^pstest-([0-9]{8})-([0-9]{6})-([a-z0-9]{12})' )
        if ($ProxiesOfInterest.count -gt 0) {
            It 'preclean undeploys and deletes the API <Name>' -TestCases @( ToArrayOfHash $ProxiesOfInterest ) {
                param($Name)

                @( Get-EdgeEnvironment ) | % {
                    $undeployment = Try { @( UnDeploy-EdgeApi -Name $Name -Environment $_ -Revision 1 ) } Catch { $_ }
                }

                $deleted = @( Delete-EdgeApi -Name $Name )
            }
        }

        It 'preclean deletes test keystores in env <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $keystores = @( Get-EdgeKeystore -Environment $Name )
            @( $keystores -match $pattern ) | % {
                Delete-EdgeKeystore -Environment $Name -Name $_
            }
        }

    }
}


Describe "Get-EdgeOrganization-1" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'gets info regarding the default org' {
            $org = $( Get-EdgeOrganization )
            $isCps = @( $org.properties.psobject.properties.value |
              where { $_.name -eq 'features.isCpsEnabled' })

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
            $envs[0] | Should Not BeNullOrEmpty
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
            $api.revision | Should Be 1
            $api.name | Should Be $apiproxyname
            ## remember the proxy we just imported, so we can deploy and export and delete, later
            $Script:Props.CreatedProxies.Add($apiproxyname)
        }

        It 'imports proxy from exploded dir for <Zip>' -TestCases $zipfiles {
            param($Zip, $Index)
            $zipfile = $(Join-Path -Path $datapath -ChildPath $Zip -Resolve)
            $destination = New-TemporaryDirectory
            [System.IO.Compression.Zipfile]::ExtractToDirectory($zipfile, $destination)
            $apiproxyname = [string]::Format('{0}-apiproxy-exploded-{1}', $Script:Props.SpecialPrefix, $Index)
            $api = @(Import-EdgeApi -Source $destination -Name $apiproxyname)
            $api.revision | Should Be 1
            $api.name | Should Be $apiproxyname

            ## remember the proxy we just imported, so we can deploy and export and delete, later
            $Script:Props.CreatedProxies.Add($apiproxyname)
            # and delete the temporary directory
            [System.IO.Directory]::delete($destination, $True)
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

        $testcases = Get-EdgeApi | Sort-Object {Get-Random} | Select-Object -first 22 | foreach { @{ Proxy = $_ } }

        It 'gets details of apiproxy <Proxy>' -TestCases $testcases {
            param($Proxy)
            $oneproxy = Get-EdgeApi -Name $Proxy
            $oneproxy | Should Not BeNullOrEmpty
            $oneproxy.metaData | Should Not BeNullOrEmpty

            if ($Proxy.StartsWith($Script:Props.SpecialPrefix)) {
                $oneproxy.metaData.lastModifiedAt | Should BeGreaterThan $Script:Props.StartMilliseconds
            }
            else {
                $oneproxy.metaData.lastModifiedAt | Should BeLessThan $Script:Props.StartMilliseconds
            }

            # Sometimes this is empty.  Not sure why!
            # $oneproxy.metaData.lastModifiedBy | Should Not BeNullOrEmpty
        }
    }
}

Describe "Deploy-EdgeApi-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        ## produce testcases that will deploy the imported proxies to all environments.
        $i=0
        $testcases = $Script:Props.FoundEnvironments |
          foreach { $e = $_; $Script:Props.CreatedProxies |
            foreach { @{ Name = $_; Environment = $e; Index=$i++ } } }

        It 'deploys proxy <Name> to <Environment>' -TestCases $testcases {
            param($Name, $Environment, $Index)
            # use a unique basepath to prevent conflicts
            $basepath = [string]::Format('/{0}-{1}',  $Script:Props.SpecialPrefix, $Index);
            $deployment = @( Deploy-EdgeApi -Name $Name -Environment $Environment -Revision 1 -Basepath $basepath )
            $deployment | Should Not BeNullOrEmpty
            $deployment.state | Should Be "deployed"
        }

        It 'tries again to deploy proxy <Name> to <Environment>' -TestCases $testcases {
            param($Name, $Environment, $Index)
            # use the same basepath; should receive a conflict
            $basepath = [string]::Format('/{0}-{1}',  $Script:Props.SpecialPrefix, $Index);
            { Deploy-EdgeApi -Name $Name -Environment $Environment -Revision 1 -Basepath $basepath } | Should Throw
        }
    }
}

Describe "Export-EdgeApi-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        $i = 0;
        $testcases = Get-EdgeApi | Sort-Object {Get-Random} | Select-Object -first 22 | foreach { @{ Proxy = $_ ; Index = $i++ } }

        It 'exports apiproxy <Proxy> with explicit destination' -TestCases $testcases {
            param($Proxy, $Index)
            $filename = [string]::Format('{0}\{1}-export-{2}.zip',
                                         $env:temp, $Script:Props.SpecialPrefix, $Index )

            $revisions = @( Get-EdgeApiRevision -Name $Proxy )
            $revisions.count | Should BeGreaterThan 0

            Export-EdgeApi -Name $Proxy -Revision $revisions[-1] -Dest $filename
            [System.IO.File]::Exists($filename) | Should Be $True
            [System.IO.File]::delete($filename)
        }

        $testcases = Get-EdgeApi | Sort-Object {Get-Random} | Select-Object -first 18 | foreach { @{ Proxy = $_ } }

        It 'exports apiproxy <Proxy> with inferred destination' -TestCases $testcases {
            param($Proxy)
            $revisions = @( Get-EdgeApiRevision -Name $Proxy )
            $revisions.count | Should BeGreaterThan 0
            $filename = $(Export-EdgeApi -Name $Proxy -Revision $revisions[-1] )
            #write-host $filename
            [System.IO.File]::Exists($filename) | Should Be $True
            [System.IO.File]::delete($filename)
        }
    }
}

Describe "Get-ApiRevisions-1" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        $testcases = Get-EdgeApi | Sort-Object {Get-Random} | Select-Object -first 28 | foreach { @{ Proxy = $_ } }

        It 'gets a list of revisions for apiproxy <Proxy>' -TestCases $testcases {
            param($Proxy)
            $revisions = @( Get-EdgeApiRevision -Name $Proxy )
            $revisions.count | Should BeGreaterThan 0
        }

        It 'gets details for latest revision of <Proxy>' -TestCases $testcases {
            param($Proxy)

            $revisions = @( Get-EdgeApiRevision -Name $Proxy )
            $revisions.count | Should BeGreaterThan 0
            $RevisionDetails = Get-EdgeApi -Name $Proxy -Revision $revisions[-1]
            $RevisionDetails.name | Should Be $Proxy
            $RevisionDetails.revision | Should Be $revisions[-1]
            # Because of time skew between the server and client, straight time comparisons may fail
            # So, apply a time skew allowance.
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $TimeSkewAllowance = 180000
            $NowMilliseconds += $TimeSkewAllowance
            $RevisionDetails.createdAt | Should BeLessthan $NowMilliseconds
            #

            if ($Proxy.StartsWith($Script:Props.SpecialPrefix)) {
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
                $DeploymentStatus = Get-EdgeApiDeployment -Name $Name -Revision $rev
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
          foreach { $e = $_; $Script:Props.CreatedProxies | foreach { @{ Name = $_; Environment = $e; } } }

        It 'undeploys proxy <Name> from <Environment>' -TestCases $testcases {
            param($Name, $Environment)
            $undeployment = @( UnDeploy-EdgeApi -Name $Name -Environment $Environment -Revision 1 )
            $undeployment | Should Not BeNullOrEmpty
            $undeployment.state | Should Be "undeployed"
        }

        It 'tries again to undeploy proxy <Name> from <Environment>' -TestCases $testcases {
            param($Name, $Environment)
            { UnDeploy-EdgeApi -Name $Name -Environment $Environment -Revision 1 } | Should Throw
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
              Environment = $Name
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
              Environment = $Name
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
              Environment = $Name
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

        It 'tries to create an existing KVM in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $Params = @{
                Name = [string]::Format('{0}-kvm-A', $Script:Props.SpecialPrefix )
                Environment = $Name
            }
            { Create-EdgeKvm @Params }| Should Throw
        }

        It 'tries to create an existing KVM in Environment <Name> catching Exception' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $Params = @{
                Name = [string]::Format('{0}-kvm-A', $Script:Props.SpecialPrefix )
                Environment = $Name
                ErrorAction = 'Stop'
            }
            $result = Try { Create-EdgeKvm @Params } Catch { $_ }
            $result.Exception | Should Not BeNullOrEmpty
            $result.Exception.message | Should Be "The remote server returned an error: (409) Conflict."
        }

        It 'creates an encrypted KVM in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $Params = @{
                Name = [string]::Format('{0}-kvm-encrypted', $Script:Props.SpecialPrefix )
                Environment = $Name
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
                Environment = $Name
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

            $kvm = Get-EdgeKvm -Environment $Name -Name $KvmName
            { $kvm } | Should Not Throw
            # values are not passed back in cleartext on query
            @( $kvm.entry | where { $_.name -eq 'key1' } ).count | Should Be 1
            $( $kvm.entry | where { $_.name -eq 'key1' } ).value | Should Be '*****'
            @( $kvm.entry | where { $_.name -eq 'key2' } ).count | Should Be 1
            $( $kvm.entry | where { $_.name -eq 'key2' } ).value | Should Be '*****'
            @( $kvm.entry | where { $_.name -eq 'key-not-exist' } ).count | Should Be 0
        }

        $i=0
        # It's possible to run this test without having previously run the test that creates proxies
        $testcases = $Script:Props.CreatedProxies | foreach { @{ Name = $_; Index=$i++ } }
        if ($testcases -and $testcases.length -gt 0) {
            It 'creates an encrypted KVM in Proxy Scope <Name>' -TestCases $testcases {
                param($Name, $Index)
                $Params = @{
                    Name = [string]::Format('{0}-kvm-proxyscope-{1}', $Script:Props.SpecialPrefix, $Index )
                    Proxy = $Name
                    Encrypted = $True
                }
                $kvm = Create-EdgeKvm @Params
                @( $kvm.entry | where { $_.name -eq 'key1' } ).count | Should Be 0
            }

            $i=0
            $testcases = $Script:Props.FoundEnvironments |
              foreach { $e = $_; $Script:Props.CreatedProxies |
              foreach { @{ Name = $_; Environment = $e; Index=$i++ } } }

            It 'tries to create a KVM specifying both Proxy <Name> and Environment <Environment>' -TestCases $testcases {
                param($Name, $Environment, $Index)
                $Params = @{
                    Name = [string]::Format('{0}-kvm-fail-{1}', $Script:Props.SpecialPrefix, $Index )
                    Proxy = $Name
                    Environment = $Environment
                }
                { Create-EdgeKvm @Params } | Should Throw
            }

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
                    Environment = $Name
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
                    Environment = $Name
                    Name = $KvmName
                    Entry = $EntryName
                    NewValue = $EntryValue
                }
                $entry = Update-EdgeKvmEntry @Params
                { $entry } | Should Not Throw
                $entry.name | Should Be $EntryName
                $entry.value | Should Be $EntryValue

                $entry = Get-EdgeKvmEntry -Environment $Name -Name $KvmName -Entry $EntryName
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
                    Environment = $Name
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
                    Environment = $Name
                    Name = $KvmName
                    Entry = $EntryName
                    NewValue = $EntryValue
                }
                $entry = Update-EdgeKvmEntry @Params
                { $entry } | Should Not Throw
                $entry.name | Should Be $EntryName
                # upon update, the value is sent back in clear text
                $entry.value | Should Be $EntryValue

                $entry = Get-EdgeKvmEntry -Environment $Name -Name $KvmName -Entry $EntryName
                { $entry } | Should Not Throw
                $entry.name | Should Be $EntryName
                $entry.value | Should Be '*****'
            }

            It 'deletes an entry in an unencrypted KVM in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
                param($Name)
                $KvmName = [string]::Format('{0}-kvm-A', $Script:Props.SpecialPrefix )
                $EntryName = 'entry1'
                $Params = @{
                    Environment = $Name
                    Name = $KvmName
                    Entry = $EntryName
                }
                $entry = Delete-EdgeKvmEntry @Params
                { $entry } | Should Not Throw
                $kvm = Get-EdgeKvm -Environment $Name -Name $KvmName
                # the entry with this name should not be found
                @( $kvm.entry | where { $_.name -eq $EntryName } ).count | Should Be 0
            }

            It 'deletes an entry in an encrypted KVM in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
                param($Name)
                $KvmName = [string]::Format('{0}-kvm-encrypted', $Script:Props.SpecialPrefix )
                $EntryName = 'entry1'
                $Params = @{
                    Environment = $Name
                    Name = $KvmName
                    Entry = $EntryName
                }
                $entry = Delete-EdgeKvmEntry @Params
                { $entry } | Should Not Throw
                $kvm = Get-EdgeKvm -Environment $Name -Name $KvmName
                @( $kvm.entry | where { $_.name -eq $EntryName } ).count | Should Be 0
            }
        }
    }
}


Describe "Update-Kvm-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        $i=0
        $testcases = $Script:Props.CreatedProxies | foreach { @{ Proxy = $_; Index=$i++ } }

        $datapath = $(Join-Path -Path $PSScriptRoot -ChildPath "data" -Resolve)
        $kvmjsonfile = @( Get-ChildItem -File $datapath ) | ?{ $_.Name.EndsWith('.json') -and $_.Name.StartsWith('kvmvalues-') } | Get-Random

        # Read data from the JSON file
        $Source = $(Join-Path -Path $datapath -ChildPath $kvmjsonfile.name -Resolve)
        $json = Get-Content $Source -Raw | ConvertFrom-JSON
        $list = New-Object System.Collections.Generic.List[System.Object]
        $json.psobject.properties.name |% {
            $value = ''
            # convert non-primitives to strings containing json
            if (($json.$_).GetType().Name -eq 'PSCustomObject') {
                $value = $($json.$_ | ConvertTo-json -Compress ).ToString()
            }
            else {
                $value = $json.$_
            }
            $list.Add( @{ name = $_ ; value = $value } )
        }
        $StoredEntries = $list.ToArray()

        It 'updates test KVMs in env <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $kvms = @( Get-EdgeKvm -Environment $Name )
            $KvmsOfInterest = @( $kvms | ?{ $_.StartsWith($Script:Props.SpecialPrefix) -and -Not ($_.Contains('encrypted')) } )

            $KvmsOfInterest.count | Should BeGreaterThan 0
            $KvmsOfInterest | % {
                Update-EdgeKvm -Environment $Name -Name $_ -Source $( [System.IO.Path]::Combine($datapath, $kvmjsonfile.name) )
            }
        }

        It 'verifies that the test KVMs for env <Name> have been updated' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $kvms = @( Get-EdgeKvm -Environment $Name )
            $KvmsOfInterest = @( $kvms | ?{ $_.StartsWith($Script:Props.SpecialPrefix) -and -Not ($_.Contains('encrypted')) } )
            $KvmsOfInterest | % {
                $thisKvm = Get-EdgeKvm -Environment $Name -Name $_
                $ComparisonResult = $( CompareArraysOfNameValuePairs -Left $thisKvm.entry -Right $StoredEntries )
                $ComparisonResult -join ' ' | Should Be ''
                #$ComparisonResult.length | Should Be 0
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

        $testcases = Get-EdgeApiProduct |
          Sort-Object {Get-Random} |
          Select-Object -first 13 |
          foreach { @{ Product = $_ } }

        It 'gets details for apiproduct <Product>' -TestCases $testcases {
            param($Product)
            $entity = @( Get-EdgeApiProduct -Name $Product )
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            # Because of time skew between the server and client, straight time comparisons may fail
            $TimeSkewAllowance = 180000
            $NowMilliseconds += $TimeSkewAllowance

            $entity.createdAt | Should BeLessthan $NowMilliseconds
            $entity.lastModifiedAt | Should BeLessthan $NowMilliseconds

            if ($Product.StartsWith($Script:Props.SpecialPrefix)) {
                $entity.createdAt | Should BeGreaterThan $Script:Props.StartMilliseconds
                $entity.lastModifiedAt | Should BeGreaterThan $Script:Props.StartMilliseconds
            }
            else {
                $entity.createdAt | Should BeLessThan $Script:Props.StartMilliseconds
                $entity.lastModifiedAt | Should BeLessThan $Script:Props.StartMilliseconds
            }

            $entity.approvalType | Should Not BeNullOrEmpty
            $entity.lastModifiedBy | Should Not BeNullOrEmpty
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

        $cases = @{ Expiry = "48h"; Hours = 48 },
                @{ Expiry = '86400'; Hours = 24 }, # default is a number of seconds
                @{ Expiry = '21d'; Hours = 21*24 },
                @{ Expiry = (Get-Date).AddDays(60).ToString('yyyy-MM-dd'); Hours = 60*24 }
                @{ Expiry = "" }

        It 'creates an App with credential expiry <Expiry>' -TestCases $cases {
            param($Expiry, $Hours)

            $Params = @{
                AppName = [string]::Format('{0}-app-{1}', $Script:Props.SpecialPrefix, $expiry )
                Developer = $Developers[0].Email
                ApiProducts = @( $Products[0].Name )
            }
            if (![string]::IsNullOrEmpty($expiry)) {
                $Params['Expiry'] = $expiry
            }

            $app = Create-EdgeDevApp @Params

            $app.credentials[0] | Should Not BeNullOrEmpty

            # verify expiry
            if (![string]::IsNullOrEmpty($expiry)) {
                $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
                $Delta = [int][Math]::Round(($app.credentials[0].expiresAt - $NowMilliseconds)/1000/3600)
                $Delta | Should Be $Hours
            }
            else {
                $app.credentials[0].expiresAt | Should BeNullOrEmpty
            }

        }
    }
}

Describe "CRUD-App-Credential" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        $NewAppName = [string]::Format('{0}-app-{1}', $Script:Props.SpecialPrefix, "credtest" )
        $Developers = @( @( Get-EdgeDeveloper ) |
          ?{ $_.StartsWith($Script:Props.SpecialPrefix) } | % { @{ Email = $_ } } )

        $Products = @( @( Get-EdgeApiProduct -Params @{ expand = 'true'} ).apiProduct |
          ?{ $_.name.StartsWith($Script:Props.SpecialPrefix) } | % { @{ Name = $_.name } } )

        It 'creates an App' {
            $Params = @{
                AppName = $NewAppName
                Developer = $Developers[0].Email
                ApiProducts = @( $Products[0].Name )
                Expiry = '72h'
            }
            $app = $( Create-EdgeDevApp @Params )
            $app.credentials.count | Should Be 1

            # verify expiry
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $Delta = [int][Math]::Round(($app.credentials[0].expiresAt - $NowMilliseconds)/1000/3600)
            $Delta | Should Be 72
        }

        It 'adds a credential on the just-created App' {
            $OriginalCreds = @( Get-EdgeAppCredential -AppName $NewAppName -Developer $Developers[0].Email )
            $OriginalCreds.count | Should Be 1

            $Params = @{
                Name = $NewAppName
                Developer = $Developers[0].Email
                ApiProducts = @( $Products[0].Name )
                Expiry = '96h'
            }

            $app = $( Add-EdgeAppCredential @Params )
            $app.credentials.count | Should Be 2

            $UpdatedCreds = @( Get-EdgeAppCredential -AppName $NewAppName -Developer $Developers[0].Email )
            $UpdatedCreds.count | Should Be 2

            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds

            # verify credential expiry
            $app.credentials | foreach {
                $Delta = [int][Math]::Round(($_.expiresAt - $NowMilliseconds)/1000/3600)
                if ($_.consumerKey -eq $OriginalCreds[0].consumerKey) {
                    $Delta | Should Be 72
                }
                else {
                    $Delta | Should Be 96
                }
            }
        }

        It 'tries to remove a credential that does not exist' {
            { Remove-EdgeAppCredential -AppName $NewAppName -Developer $Developers[0].Email -Key pd0mg1FuedmfCpY9gWZonQmR2fGD3Osw } | Should Throw
        }

        It 'removes a credential on the just-created App' {
            $OriginalCreds = @( Get-EdgeAppCredential -AppName $NewAppName -Developer $Developers[0].Email )
            $OriginalCreds.count | Should Be 2
            $app = $( Remove-EdgeAppCredential -AppName $NewAppName -Developer $Developers[0].Email -Key $OriginalCreds[0].consumerKey )

            $UpdatedCreds = @( Get-EdgeAppCredential -AppName $NewAppName -Developer $Developers[0].Email )
            $UpdatedCreds.count | Should Be 1
        }

        It 'revokes a credential on the just-created App' {
            $OriginalCreds = @( Get-EdgeAppCredential -AppName $NewAppName -Developer $Developers[0].Email )
            $OriginalCreds.count | Should Be 1
            $OriginalCreds[0].status | Should Be "approved"

            Revoke-EdgeAppCredential -AppName $NewAppName -Developer $Developers[0].Email -key $OriginalCreds[0].consumerKey

            $UpdatedCreds = @( Get-EdgeAppCredential -AppName $NewAppName -Developer $Developers[0].Email )
            $UpdatedCreds.count | Should Be 1
            $UpdatedCreds[0].status | Should Be "revoked"
        }

        It 'approves a credential on the just-created App' {
            $OriginalCreds = @( Get-EdgeAppCredential -AppName $NewAppName -Developer $Developers[0].Email )
            $OriginalCreds.count | Should Be 1
            $OriginalCreds[0].status | Should Be "revoked"

            Approve-EdgeAppCredential -AppName $NewAppName -Developer $Developers[0].Email -key $OriginalCreds[0].consumerKey

            $UpdatedCreds = @( Get-EdgeAppCredential -AppName $NewAppName -Developer $Developers[0].Email )
            $UpdatedCreds.count | Should Be 1
            $UpdatedCreds[0].status | Should Be "approved"
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
                AppName = [string]::Format('{0}-app-failure-A-{1}', $Script:Props.SpecialPrefix, $expiry )
                Developer = $Developers[0].Email
                ApiProducts = @( $Products[0].Name )
                Expiry = $expiry
            }
            { Create-EdgeDevApp @Params } | Should Throw
        }

        It 'tries to create an App with missing Developer' {
            $expiry = '28d'
            $Params = @{
                AppName = [string]::Format('{0}-app-failure-B-{1}', $Script:Props.SpecialPrefix, $expiry )
                ApiProducts = @( $Products[0].Name )
                Expiry = $expiry
            }
            { Create-EdgeDevApp @Params } | Should Throw
        }

        It 'tries to create an App with missing ApiProducts' {
            $expiry = '120d'
            $Params = @{
                AppName = [string]::Format('{0}-app-failure-C-{1}', $Script:Props.SpecialPrefix, $expiry )
                Developer = $Developers[0].Email
                Expiry = $expiry
            }
            { Create-EdgeDevApp @Params } | Should Throw
        }

        It 'tries to create an App with missing Name' {
            #$Params = @{
            #    ApiProducts = @( $Products[0].Name )
            #    Developer = $Developers[0].Email
            #}
            { Create-EdgeDevApp -ApiProducts @( $Products[0].Name ) -Developer $Developers[0].Email } | Should Throw
        }
    }
}

Describe "Get-Apps-1" {
    Context 'Strict mode' {

        Set-StrictMode -Version latest

        $appids = @( Get-EdgeDevApp | %{ @{ Id = $_ } } )
        $emails = @( Get-EdgeDeveloper | %{ @{ Email = $_ } } )

        It 'gets a list of apps' {
            $appids.count | Should BeGreaterThan 0
        }

        It 'gets a list of apps with expansion' {
            $getresponse = @( Get-EdgeDevApp -Params @{ expand = 'true' } )
            $getresponse.app.count | Should BeGreaterThan 0
        }

        It 'gets a list of apps for developer <Email>'  -TestCases $emails {
            param($Email)

            $apps = @( Get-EdgeDevApp -Developer $Email )
            $apps.count | Should Not BeNullOrEmpty
            $appsExpanded = @( ( Get-EdgeDevApp -Developer $Email -Params @{ expand = 'true' } ).app )
            $apps.count | Should Be $appsExpanded.count
        }

        It 'gets details of app <Id>' -TestCases $appids {
            param($Id)
            $app = Get-EdgeDevApp -AppId $Id
            $app.appId | Should Be $Id
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $app.createdAt | Should BeLessthan $NowMilliseconds
            $app.lastModifiedAt | Should BeLessthan $NowMilliseconds
            $app.status | Should Not BeNullOrEmpty
        }

        It 'gets a list of apps by ID per developer <Email>' -TestCases $emails {
            param($Email)

            $appsExpanded = @(( Get-EdgeDevApp -Developer $Email -Params @{ expand = 'true' } ).app)
            $excludedProps = @( 'attributes', 'apiProducts', 'credentials' )
            foreach ($app in $appsExpanded) {
                $app2 = Get-EdgeDevApp -AppId $app.appId
                # $app2 | Should Be $app  # No.

                # I think it might be possible to do something smart with Compare-Object
                # But... instead we will iterate the properties and compare each one, while
                # excluding properties with non-primitive values.
                $app2.psobject.properties | % {
                    if ( $excludedProps -notcontains $_.Name ) {
                        $value1 = $( $app | select -expand $_.Name )
                        $_.Value | Should Be $value1
                    }
                }
            }
        }
    }
}

Describe "Revoke-Approve-Apps-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        $AppList = @( @( Get-EdgeDevApp -Params @{ expand = $True } ).app |
          ?{ $_.name.StartsWith($Script:Props.SpecialPrefix) } | %{ @{ Name = $_.name; Id = $_.appId; DevId = $_.developerId } })

        # $DevList = @( @( Get-EdgeDeveloper -Params @{ expand = $True } ).developer |
        #  ?{ $_.email.StartsWith($Script:Props.SpecialPrefix) } | %{ @{ Apps = $_.apps; Email = $_.email } })

        It 'verifies the count of apps created previously in this test run' {
            $AppList.count | Should BeGreaterThan 0
        }

        It 'revokes app <Id> (<Name>)' -TestCases $AppList {
            param($Name, $Id, $DevId)
            $app = Get-EdgeDevApp -AppId $Id
            $app.status | Should Be 'approved'
            $dev = Get-EdgeDeveloper -Name $DevId
            Revoke-EdgeDevApp -Name $Name -Developer $dev.email
            $app = Get-EdgeDevApp -AppId $Id
            $app.status | Should Be 'revoked'
        }

        It 'approves app <Id> (<Name>)' -TestCases $AppList {
            param($Name, $Id, $DevId)
            $app = Get-EdgeDevApp -AppId $Id
            $app.status | Should Be 'revoked'
            $dev = Get-EdgeDeveloper -Name $DevId
            Approve-EdgeDevApp -Name $Name -Developer $dev.email
            $app = Get-EdgeDevApp -AppId $Id
            $app.status | Should Be 'approved'
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
            $kvms = @( Get-EdgeKvm -Environment $Name )
            $kvms.count | Should BeGreaterThan 0
            # check that we have one or more KVMs created by this script
            @( $kvms | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ).count | Should BeGreaterThan 0
        }

        $i=0
        $testcases = $Script:Props.CreatedProxies | foreach { @{ Proxy = $_; Index=$i++ } }

        It 'lists kvms for proxy <Proxy>' -TestCases $testcases {
            param($Proxy, $Index)
            $kvms = @( Get-EdgeKvm -Proxy $Proxy )
            $kvms.count | Should Be 1
        }

        $testcases = Get-EdgeApi | where { ! $_.StartsWith($Script:Props.SpecialPrefix) } |
          Sort-Object {Get-Random} |
          Select-Object -first 10  |
          foreach { @{ Proxy =$_ } }

        It 'lists kvms for proxy <Proxy>' -TestCases $testcases {
            param($Proxy)
            $kvms = @( Get-EdgeKvm -Proxy $Proxy )
            # Not sure how many KVMs to expect for each proxy. Most will be zero.
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
            Delete-EdgeDevApp -Developer $Dev -AppName $Name
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

        $i=0
        $testcases = $Script:Props.CreatedProxies | foreach { @{ Proxy = $_; Index=$i++ } }

        It 'deletes the KVM for Proxy <Proxy>' -TestCases $testcases {
            param($Proxy, $Index)
            $Name = [string]::Format('{0}-kvm-proxyscope-{1}', $Script:Props.SpecialPrefix, $Index )
            Delete-EdgeKvm -Proxy $Proxy -Name $Name
        }

        It 'deletes test KVMs in env <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $kvms = @( Get-EdgeKvm -Environment $Name )
            @( $kvms | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ).count | Should BeGreaterThan 0
            @( $kvms | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ) | % {
                Delete-EdgeKvm -Environment $Name -Name $_
            }
        }

        It 'verifies that the test KVMs for env <Name> have been deleted' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $kvms = @( Get-EdgeKvm -Environment $Name )
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
                Environment = $Name
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
            $keystores = @( Get-EdgeKeystore -Environment $Name )
            # check that we have one or more keystores
            $keystores.count | Should BeGreaterThan 0
            # check that we have one or more keystores created by this script
            @( $keystores | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ).count | Should BeGreaterThan 0
        }

        It 'gets specific info on each keystore for Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)

            @( Get-EdgeKeystore -Environment $Name ) | % {
                $keystore = Get-EdgeKeystore -Environment $Name -Name $_
                $keystore | Should Not BeNullOrEmpty
                $keystore.name | Should Not BeNullOrEmpty
            }
        }
    }
}


Describe "Import-KeyAndCert-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        $datapath = $(Join-Path -Path $PSScriptRoot -ChildPath "data" -Resolve)
        $certfile = @( Get-ChildItem -File $datapath ) | ?{ $_.Name.EndsWith('.cert') } | Get-Random
        $keyfile = $certfile -replace "cert$", "key"

        It 'imports key and cert into keystore for Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            @( Get-EdgeKeystore -Environment $Name ) | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } |% {
                $keystore = Get-EdgeKeystore -Environment $Name -Name $_
                Import-EdgeKeyAndCert -Environment $Name -Keystore $_ -Alias alias1 -CertFile $(Join-Path $datapath $certfile) -KeyFile $(Join-Path $datapath $keyfile)
            }
        }

        It 'gets specific info on alias1 in each keystore for Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)

            @( Get-EdgeKeystore -Environment $Name ) | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } |% {
                $alias = Get-EdgeAlias -Environment $Name -Keystore $_ -Alias alias1
                $alias.certsInfo | Should Not BeNullOrEmpty
            }
        }
    }
}
Describe "Import-Cert-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        $datapath = $(Join-Path -Path $PSScriptRoot -ChildPath "data" -Resolve)
        $certfile = @( Get-ChildItem -File $datapath ) | ?{ $_.Name.EndsWith('.cert') } | Get-Random

        It 'imports a cert into a truststore for Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            @( Get-EdgeKeystore -Environment $Name ) | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } |% {
                $keystore = Get-EdgeKeystore -Environment $Name -Name $_
                Import-EdgeCert -Environment $Name -Truststore $_ -Alias alias2 -CertFile $(Join-Path $datapath $certfile)
            }
        }

        It 'gets specific info on alias2 in each truststore for Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)

            @( Get-EdgeKeystore -Environment $Name ) | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } |% {
                $alias = Get-EdgeAlias -Environment $Name -Keystore $_ -Alias alias2
                $alias.certsInfo | Should Not BeNullOrEmpty
            }
        }
    }
}


Describe "Create-KeystoreRef-1" {
    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'creates a keystore ref in Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $keystores = @( Get-EdgeKeystore -Environment $Name )
            # check that we have one or more keystores to work with
            $keystores.count | Should BeGreaterThan 0
            $Params = @{
                Name = [string]::Format('{0}-ksref', $Script:Props.SpecialPrefix )
                Environment = $Name
                Refers = $keystores[0]
                ResourceType = 'KeyStore'
            }
            $reference = Create-EdgeReference @Params
            { $reference } | Should Not Throw
        }
    }
}

Describe "Get-KeystoreRef-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'gets a list of keystore references for Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $references = @( Get-EdgeReference -Environment $Name )
            # check that we have one or more references
            $references.count | Should BeGreaterThan 0
            # check that we have one or more keystores created by this script
            @( $references | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ).count | Should BeGreaterThan 0
        }

        It 'gets specific info on each keystore ref for Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)

            @( Get-EdgeReference -Environment $Name ) | % {
                $reference = Get-EdgeReference -Environment $Name -Name $_
                $reference | Should Not BeNullOrEmpty
                $reference.name | Should Not BeNullOrEmpty
            }
        }
    }
}


Describe "Delete-KeystoreRef-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'deletes the test keystore references in Env <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $references = @( Get-EdgeReference -Environment $Name )
            @( $references | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ).count | Should BeGreaterThan 0

            @( $references | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ) | % {
                Delete-EdgeReference -Environment $Name -Name $_
            }
            @( $references | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ) | % {
                { Delete-EdgeReference -Environment $Name -Name $_ } | Should Throw
            }
        }

        It 'verifies that the test keystore references for Environment <Name> have been removed' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $references = @( Get-EdgeReference -Environment $Name )
            # check that we now have zero keystores references created by this script
            @( $references | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ).count | Should Be 0
        }
    }
}


Describe "Delete-Keystore-1" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'deletes the test keystores in Env <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $keystores = @( Get-EdgeKeystore -Environment $Name )
            @( $keystores | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ).count | Should BeGreaterThan 0

            @( $keystores | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ) | % {
                Delete-EdgeKeystore -Environment $Name -Name $_
            }
            @( $keystores | ?{ $_.StartsWith($Script:Props.SpecialPrefix) } ) | % {
                { Delete-EdgeKeystore -Environment $Name -Name $_ } | Should Throw
            }
        }

        It 'verifies that the test keystores for Environment <Name> have been removed' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)
            $keystores = @( Get-EdgeKeystore -Environment $Name )
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
          $vhosts = @( Get-EdgeVhost -Environment $Name )
          $vhosts.count | Should BeGreaterThan 0
        }

        It 'gets specific info on each vhost for Environment <Name>' -TestCases @( ToArrayOfHash @( Get-EdgeEnvironment ) ) {
            param($Name)

            @( Get-EdgeVhost -Environment $Name ) | % {
                $vhost = Get-EdgeVhost -Environment $Name -Name $_
                $vhost | Should Not BeNullOrEmpty
                $vhost.name | Should Not BeNullOrEmpty
            }
        }
    }
}


## TODO: insert more tests here:
# eg,
# - CRUD for EdgeAppCredential - add a new credential to an app
# - Update-EdgeAppCredential.ps1 - revoke or approve a credential, or change products list
# - {Create,Get,Update,Delete} for KvmEntry at proxy scope (iff CPS)
