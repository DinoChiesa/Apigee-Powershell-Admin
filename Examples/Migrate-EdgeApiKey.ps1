# Migrate-ApiKeyForProduct.ps1
function Migrate-EdgeApiKey {
    <#
    .SYNOPSIS
        Migrates a key+secret (a credential) from one developer app to a different (possibly new)
        app for a different developer.

    .DESCRIPTION
        Migrates a key+secret (a credential) from one developer app to a new app for a different
        developer.

    .PARAMETER DestinationDeveloper
        Required. The id or email of the developer to which the credential should be migrated.

    .PARAMETER DestinationAppName
        Required. The name developer app to which the credential should be migrated.
        If this app does not exist under the destination developer, it will be created.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

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
        $DestinationAppName,

        [string]$Org
    )

    $Params = @{ }
    if ($PSBoundParameters['Org']) {
        $Params.Add( 'Org', $Org )
    }
    $Params.Add( 'ConsumerKey', $Key )
    # 1. Find the existing app with that Key
    Write-Host $( [string]::Format("Finding the App with key {0}", $Key ) )
    $existingApp = Find-EdgeApp @Params
    if ($existingApp -eq $null) {
        throw [System.SystemException] "Cannot find an app for that Key"
    }

    Write-Host $( [string]::Format("App:`n{0}", $(ConvertTo-Json $existingApp )))

    # 1a. Get a reference to the existing credential, we'll need it later
    $existingCredential = @($existingApp.credentials |? { $_.consumerKey -eq $Key })

    ## at this point, ($existingCredential.consumerKey == $Key)

    # 2. locate the destination developer, make sure it exists and is active
    $Params.Remove( 'ConsumerKey' )
    $Params.Add( 'Name', $DestinationDeveloper )
    Write-Host "Retrieving the Developer for that app"
    $destDev = @( Get-EdgeDeveloper @Params )
    if ($destDev.status -eq 'active') {
        if ($destDev.developerId -eq $existingApp.developerId) {
            throw [System.InvalidOperationException] "DestinationDeveloper", "Cannot migrate to the same developer"
        }
    }
    else {
        throw [System.InvalidOperationException] "DestinationDeveloper", "Developer does not exist or is not active"
    }

    function ConvertFrom-AttrListToHashtable {
        Param($List)
        $Values = @{}
        foreach($item in $List) {
            $Values[$item.name] = $item.value
        }
        $Values
    }

    # 3a. determine if the destination app exists under the destination developer
    $Params.Remove( 'Name' )
    $Params.Add( 'AppName', $DestinationAppName )
    $Params.Add( 'Developer', $destDev.Email )
    $destApp = Get-EdgeDevApp @Params
    $destAppIsNew = $False
    if ($destApp -eq $Null -or $destApp.status -eq 404) {
        # destination app does not exist
        # 3b. create a new app under that destination developer, generating new creds
        $Params.Add('Attributes', $( ConvertFrom-AttrListToHashtable $existingApp.attributes ) )
        Write-Host $( [string]::Format("destination App {0} does not exist; creating it", $destApp.name ) )
        $destApp = Create-EdgeDevApp @Params
        if ($destApp -eq $Null) {
            Write-Host "The app could not be created"
        }
        else {
            $destAppIsNew = $True
        }
    }

    if ($destApp -ne $Null -and $destApp.status -ne 404) {

        Write-Host $( [string]::Format("destination App: {0}", $destApp.name ) )
        $Params.Remove( 'ApiProducts' )
        $Params.Remove( 'Attributes' )

        # 4. Optionally, Remove the implicitly generated credential from the app
        if ($destAppIsNew) {
            $generatedCredential = $destApp.credentials[0]
            $Params.Add( 'Key', $generatedCredential.consumerKey )
            Write-Host $( [string]::Format("removing generated credential: {0}", $generatedCredential.consumerKey  ) )
            Remove-EdgeAppCredential @Params
        }

        # 5. Remove the credential from the original app
        $Params.Set( 'AppName', $existingApp.name )
        $Params.Set( 'Developer', $existingApp.developerId )
        $Params.Set( 'Key', $existingCredential.consumerKey )
        Write-Host $( [string]::Format("removing original credential: {0}", $existingCredential.consumerKey  ) )
        Remove-EdgeAppCredential @Params

        # 6. explicitly add the older credential to the new app
        $Params.Set( 'AppName', $DestinationAppName )
        $Params.Set( 'Developer', $destDev.Email )
        $Params.Set( 'Key', $existingCredential.consumerKey )
        $Params.Set( 'Secret', $existingCredential.consumerSecret )
        $Params.Set( 'Attributes', $( ConvertFrom-AttrListToHashtable $existingApp.attributes ) )
        Write-Host $( [string]::Format("adding credential: {0}", $existingCredential.consumerKey  ) )
        Put-EdgeAppCredential @Params

        # 7. add the API Products to the new Credential
        $Params.Add('ApiProducts', @( $existingCredential.apiProducts |% { $_.apiproduct } ) )
        $Params.Remove( 'Secret')
        $Params.Reomve( 'Attributes')
        Write-Host $( [string]::Format("updating API Products list:`n{0}", $(ConvertTo-Json $existingCredential.apiProducts)))
        $destinationCredential = $(Update-EdgeAppCredential @Params)

        # 8. Optionally update the status for each apiproduct on the new credential, if necessary
        Write-Host "checking product status"
        $Params = @{
            AppName = $DestinationAppName
            Developer = $destDev.Email
            Key = $existingCredential.consumerKey
        }
        if ($PSBoundParameters['Org']) {
            $Params.Add( 'Org', $Org )
        }
        $existingCredential.apiProducts |% {
            $existingProduct = $_.apiproduct
            $existingStatus = $_.status
            $oneProduct = $destinationCredential.apiProducts |? { $_.apiproduct -eq $existingProduct }
            if ($oneProduct.status -ne $existingStatus) {
                $Params.Set('ApiProduct', $existingProduct )
                if ($existingStatus -eq "revoked") {
                    Write-Host $( [string]::Format("updating product {0} to revoked status", $existingProduct)
                    Revoke-EdgeAppCredential @Params
                }
                elseif ($existingStatus -eq "approved" ) {
                    Write-Host $( [string]::Format("updating product {0} to approved status", $existingProduct)
                    Approve-EdgeAppCredential @Params
                }
            }
        }
    }
}
