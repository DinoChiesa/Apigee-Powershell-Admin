Function Update-EdgeAppCredential {
    <#
    .SYNOPSIS
        Update a credential in Apigee Edge, by adding or removing API Products. 

    .DESCRIPTION
        Update a credential in Apigee Edge, by adding or removing API Products. 

    .PARAMETER Remove
        A flag parameter to request the removal of API products from the credential.
        Use one of -Remove or -Add, not both. 

    .PARAMETER Add
        A flag parameter to request the aditionof API products to the credential.
        Use one of -Remove or -Add, not both. 

    .PARAMETER Name
        The name of the developer app from which the credential will be removed.

    .PARAMETER Developer
        The id or email of the developer that owns the app from which the credential will be removed.

    .PARAMETER Key
        The consumer key for the credential to be removed.

    .PARAMETER ApiProducts
        An array of strings, the names of API Products that should be added or removed from this credential.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Update-EdgeAppCredential -Name DPC6 -Developer dchiesa@example.org -Key iQGvTYtUWcWAdJ6WAJebedgLSKaVQidZ -Add -ApiProducts @( 'Product-1971' )

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
         [Parameter(Mandatory=$False)] 
         [switch]$Remove,

         [Parameter(Mandatory=$False)] 
         [switch]$Add,

        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Developer,
        [Parameter(Mandatory=$True)][string]$Key,
        
        [Parameter(Mandatory=$True)][string[]]$ApiProducts,

        [string]$Org
    )
    
    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    if (!$PSBoundParameters['Developer']) {
        throw [System.ArgumentNullException] "Developer", "You must specify the -Developer option."
    }
    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
    }
    if (!$Remove -and ! $Add) {
      throw [System.ArgumentException] "You must specify one of -Remove or -Add."
    }
    if ($Remove -and $Add) {
      throw [System.ArgumentException] "You must specify one of -Remove or -Add."
    }
    if (!$PSBoundParameters['ApiProducts']) {
      throw [System.ArgumentNullException] "ApiProducts", "You must specify the -ApiProducts option."
    }

    if ($Add) {
        $Options.Add( 'Collection', $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps', $Name, keys ) )
        $Options.Add( 'Name', $Key )

        $Payload = @{
          apiProducts = $ApiProducts
        }

        $Options.Add( 'Payload', $Payload )

        Send-EdgeRequest @Options
    }
    else {
        # Remove, each one in series
        $ApiProducts | Foreach-Object {
          $Options['Collection'] = $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps', $Name, keys, $Key, 'apiproducts' )
          $Options['Name'] = $_
          
          Write-Debug ( "Options @Options`n" )
          Delete-EdgeObject @Options
        }
    }

}
