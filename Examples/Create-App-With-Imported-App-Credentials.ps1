# Create-App-With-Imported-App-Credentials.ps1
function Create-App-With-Imported-App-Credentials {
    <#
    .SYNOPSIS
        Imports a key+secret (a credential) into Apigee Edge.

    .DESCRIPTION
        Imports a key+secret (a credential) into Apigee Edge. This will be stored in
        a newly-created developer app, which will be associated to an existing developer.

    .PARAMETER Key
        Required. The key to import. It must be unique across the Edge Organization.

    .PARAMETER Secret
        Required. The secret to import.

    .PARAMETER Developer
        Required. The email of the existing developer.

    .PARAMETER NewAppName
        Required. The name of the to-be-created app for that developer.

    .PARAMETER ApiProduct
        Required. The name of the existing API Product to add to the credential.

    #>

    [CmdletBinding()]
    PARAM (
        [Parameter(Mandatory = $true)] [String] $Key,
        [Parameter(Mandatory = $true)] [String] $Secret,
        [Parameter(Mandatory = $true)] [String] $Developer,
        [Parameter(Mandatory = $true)] [String] $NewAppName,
        [Parameter(Mandatory = $true)] [String] $ApiProduct
    )

    PROCESS {
        $existingDev = @( Get-EdgeDeveloper -Name $Developer )
        if ($existingDev -eq $null -or $existingDev.status -ne 'active') {
            throw [System.InvalidOperationException] "Developer", "Developer does not exist or is inactive"
        }
        Write-Debug $( [string]::Format("dev:`n{0}", $(ConvertTo-Json $existingDev)))

        $existingProduct = @( Get-EdgeApiProduct -Name $ApiProduct )
        if ($existingProduct -eq $null -or $existingProduct.name -ne $ApiProduct ) {
            throw [System.InvalidOperationException] "ApiProduct", "ApiProduct does not exist"
        }
        Write-Debug $( [string]::Format("product:`n{0}", $(ConvertTo-Json $existingProduct)))

        $Params = @{
            AppName = $NewAppName
            Developer = $existingDev.Email
            ApiProducts = @( $ApiProduct )
            Attributes = @{
                ImportedBy = "Create-App-With-Imported-App-Credentials.ps1"
                ImportDateUtc = [System.DateTime]::UtcNow.ToString()
            }
        }

        $newApp = Create-EdgeDevApp @Params

        if ($newApp -eq $null) {
            Write-Host "The app could not be created"
        }
        else {
            Write-Host $( [string]::Format("newApp: {0}", $newApp.name ) )
            $generatedCredential = $newApp.credentials[0]

            # explicitly add the specific credential to the app
            $newCredential = $(Put-EdgeAppCredential -AppName $NewAppName -Developer $existingDev.Email -Key $Key -Secret $Secret)

            # add a product to the newly-added credential.
            $newCredential = $( Update-EdgeAppCredential -AppName $NewAppName -Developer $existingDev.Email -Key $Key -Add -ApiProducts @( $ApiProduct ) )

            # Remove the implicitly generated credential from the app
            $oldCredential = $( Remove-EdgeAppCredential -AppName $NewAppName -Developer $existingDev.Email -Key $generatedCredential.consumerKey )
        }
    }
}
