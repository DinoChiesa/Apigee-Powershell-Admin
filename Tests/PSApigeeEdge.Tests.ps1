$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

$PSVersion = $PSVersionTable.PSVersion.Major
Import-Module $PSScriptRoot\..\PSApigeeEdge -Force

# --- Get data for the tests
$ConnectionData = Get-Content .\ConnectionData.json -Raw | ConvertFrom-JSON

# --- Startup
$Connection = Connect-vRAServer -Server $JSON.Connection.vRAAppliance -Tenant $JSON.Connection.Tenant -Username $JSON.Connection.Username -Password $JSON.Connection.Password -IgnoreCertRequirements



#Integration test example
Describe "Set-EdgeConnection PS$PSVersion Integrations tests" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'should succeed' {
            Set-EdgeConnection -Org $ConnectionData.org -User $ConnectionData.user -Pass $ConnectionData.password
        }
    }
}

