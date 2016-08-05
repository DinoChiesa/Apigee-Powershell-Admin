Function Get-EdgeObject {
    <#
    .SYNOPSIS
        Get one or more objects from Apigee Edge

    .DESCRIPTION
        Get one or more objects from Apigee Edge, such as developers, apis, apiproducts

    .PARAMETER Collection
        Type of object to query for. Accepts multiple parts.

        Example: 'developers', 'apis', or 'apiproducts'

    .PARAMETER Org
        The Apigee Edge organization. 

    .PARAMETER Params
        Hash table with query options for the specific collection type

        Example for getting all details of developers:
            -Params @{
                expand  = 'true'
            }

    .EXAMPLE
        Get-EdgeObject -Collection developers -Org cap500

        # List developers on Edge organization 'cap500'

    .EXAMPLE
        Get-EdgeObject -Collection developers -Org cap500 -Params @{
            expand='true'
        }

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Collection,
        [string]$Org,
        #[string]$User,
        #[string]$Pass,
        #[string]$MgmtUri = 'https://api.enterprise.apigee.com',
        [Hashtable]$Params
    )


    if( ! $PSBoundParameters.ContainsKey('Org')) {
      if( ! $MyInvocation.MyCommand.Module.PrivateData['Org']) {
        throw [System.ArgumentNullException] "use the -Org parameter to specify the organization."
      }
      else {
        $Org = $MyInvocation.MyCommand.Module.PrivateData['Org']
      }
    }

      if( ! $MyInvocation.MyCommand.Module.PrivateData['MgmtUri']) {
        throw [System.ArgumentNullException] "use Set-EdgeConnection to specify the Edge connection information."
      }
      else {
        $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData['MgmtUri']
      }

      if( ! $MyInvocation.MyCommand.Module.PrivateData['AuthToken']) {
        throw [System.ArgumentNullException] "use Set-EdgeConnection to specify the Edge connection information."
      }
      else {
        $AuthToken = $MyInvocation.MyCommand.Module.PrivateData['AuthToken']
      }


    $BaseUri = Join-Parts -Separator "/" -Parts $MgmtUri, '/v1/o', $Org, $($Collection.ToLower())

    $decrypted = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($AuthToken))

    $IRMParams = @{
        Uri = $BaseUri
        Method = 'Get'
        Headers = @{
            Accept = 'application/json'
            Authorization = 'Basic $decrypted'
        }
    }

    Remove-Variable $decrypted
    
    if($PSBoundParameters.ContainsKey('Params'))
    {
        $IRMParams.Add( 'Body', $Params )
    }

    Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                 "Invoke-RestMethod parameters:`n$($IRMParams | Format-List | Out-String)" )

    Try
    {
        #We might want to track the HTTP status code to verify success for non-gets...
        $TempResult = Invoke-RestMethod @IRMParams

        Write-Debug "Raw:`n$($TempResult | Out-String)"
    }
    Catch
    {
        Throw $_
   }

   $TempResult
}