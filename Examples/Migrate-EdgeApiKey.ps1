# Migrate-ApiKeyForProduct.ps1
function Migrate-EdgeApiKey {
    <#
    .SYNOPSIS
        Migrates a key+secret (a credential) from one developer app to a new app for a different
        developer.

    .DESCRIPTION
        Migrates a key+secret (a credential) from one developer app to a new app for a different
        developer.

    .PARAMETER Org
        Required. The Apigee Edge organization. 

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Key,

        [Parameter(Mandatory = $true)]
        [String]
        $DestinationDeveloper,
        
        [Parameter(Mandatory = $true)]
        [String]
        $DestinationAppName
    )

    # 1. Find the existing app with that Key
    $existingApp = Find-EdgeApp -ConsumerKey $Key
    if ($existingApp -eq $null) {
        throw [System.SystemException] "Cannot find an app for that Key"
    }

    # 1a. Get a reference to the existing credential, we'll need it later
    $existingCredential = @($existingApp.credentials |? { $_.consumerKey -eq $Key })

    # 2. locate the destination developer, make sure it exists and is active
    $newDev = @( Get-EdgeDeveloper -Name $DestinationDeveloper )
    if ($newDev.status -eq 'active') {
        if ($newDev.developerId -eq $existingApp.developerId) {
            throw [System.InvalidOperationException] "DestinationDeveloper", "Cannot migrate to the same developer"
        }
    }
    else {
        throw [System.InvalidOperationException] "DestinationDeveloper", "Developer does not exist or is inactive"
    }

    function ConvertFrom-AttrListToHashtable {
        Param($List)
        $Values = @{}
        foreach($item in $List) {
            $Values[$item.name] = $item.value
        }
        $Values
    }

    Write-Host $( [string]::Format("products:`n{0}", $(ConvertTo-Json $existingCredential.apiProducts)))
    
    $Params = @{
        AppName = $DestinationAppName
        Developer = $newDev.Email
        ApiProducts = @( $existingCredential.apiProducts |% { $_.apiproduct } )
        #ApiProducts = $existingCredential.apiProducts
        Attributes = $( ConvertFrom-AttrListToHashtable $existingApp.attributes )
    }

    # 3. create a new app under that destination developer, generating new creds
    $newApp = Create-EdgeDevApp @Params

    if ($newApp -eq $null) {
        Write-Host "The app could not be created"
    }
    else {
        Write-Host $( [string]::Format("newApp: {0}", $newApp.name ) )
        
        # 4. Remove the implicitly generated credential from the app 
        $generatedCredential = $newApp.credentials[0]
        Remove-EdgeAppCredential -AppName $DestinationAppName -Developer $newDev.Email -Key $generatedCredential.consumerKey
        
        # 5. Remove the credential from the original app
        Remove-EdgeAppCredential -AppName $existingApp.name -Developer $existingApp.developerId -Key $Key
        
        # 6. explicitly add the older credential to the new app
        Put-EdgeAppCredential -AppName $DestinationAppName -Developer $newDev.Email -Key $existingCredential.consumerKey -Secret $existingCredential.consumerSecret -Attributes $( ConvertFrom-AttrListToHashtable $existingApp.attributes )
    }
    
}
