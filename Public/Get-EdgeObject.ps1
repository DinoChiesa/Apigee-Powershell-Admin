Function Get-EdgeObject {
    <#
    .SYNOPSIS
        Get one or more objects from Apigee Edge

    .DESCRIPTION
        Get one or more objects from Apigee Edge, such as developers, apis, apiproducts

    .PARAMETER Collection
        Type of object to query for. 

        Example: 'developers', 'apis', or 'apiproducts'

    .PARAMETER Name
        Name of the object to retrieve.

    .PARAMETER Org
        The Apigee Edge organization. 

    .PARAMETER Params
        Hash table with query options for the specific collection type

    .EXAMPLE
        Get-EdgeObject -Collection developers -Org cap500

        # List developers on Edge organization 'cap500'

    .EXAMPLE
        Get-EdgeObject -Collection developers -Org cap500 -Params @{ expand='true' }

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Collection,
        [string]$Org,
        [string]$Name,
        [Hashtable]$Params
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

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

    if($PSBoundParameters.ContainsKey('Name')) {
      $BaseUri = Join-Parts -Separator "/" -Parts $MgmtUri, '/v1/o', $Org, $($Collection.ToLower()), $Name
    }
    else {
      $BaseUri = Join-Parts -Separator "/" -Parts $MgmtUri, '/v1/o', $Org, $($Collection.ToLower())
    }

    $decrypted = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($AuthToken))
    
    Write-Debug ( "Uri $BaseUri`n" )

    $IRMParams = @{
        Uri = $BaseUri
        Method = 'Get'
        Headers = @{
            Accept = 'application/json'
            Authorization = "Basic $decrypted"
        }
    }
    
    Remove-Variable decrypted

    if($PSBoundParameters.ContainsKey('Params')) {
        $IRMParams.Add( 'Body', $Params )
    }

    Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                 "Invoke-RestMethod parameters:`n$($IRMParams | Format-List | Out-String)" )

    Try {
        $TempResult = Invoke-RestMethod @IRMParams

        Write-Debug "Raw:`n$($TempResult | Out-String)"
    }
    Catch {
        Throw $_
    }
    Finally {
        Remove-Variable IRMParams
    }

   $TempResult
}