Function Send-EdgeRequest {
    <#
    .SYNOPSIS
        Send a request to Apigee Edge admin endpoint.
        
    .DESCRIPTION
        Send a request to Apigee Edge admin endpoint. This can be used to create
        an object in Apigee Edge, to Update an object, Revoke a key, etc. 

    .PARAMETER Collection
        Required. Type of object to create. This may be a composite. 

        Example: 'developers', 'apis', or 'apiproducts', or 'developers/dino@apigee.com/apps'

    .PARAMETER Name
        Optional. a Particular name within the collection. 

    .PARAMETER QParams
        Optional. Hashtable, which will be serialized as query params.
        
    .PARAMETER Payload
        Optional. Hashtable, which will become the payload of the POST method. Serialized as JSON. 

    .PARAMETER Org
        The Apigee Edge organization. 

    .EXAMPLE
        Send-EdgeRequest -Collection 'developers/dino@apigee.com/apps' -Payload @{
                name  =  'abcdefg-1'
                apiProducts = @('Product1')
                keyExpiresIn =  86400000
            }

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Collection,
        [string]$Name,
        [string]$QParams,
        [string]$Org,
        [Hashtable]$Payload
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

    if ($PSBoundParameters['Name']) {
      $BaseUri = Join-Parts -Separator "/" -Parts $MgmtUri, '/v1/o', $Org, $Collection, $Name
    }
    else {
      $BaseUri = Join-Parts -Separator "/" -Parts $MgmtUri, '/v1/o', $Org, $Collection
    }
    Write-Debug ( "Uri $BaseUri`n" )

    $decrypted = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($AuthToken))

    if ($PSBoundParameters['QParams']) {
         $qstring = ConvertFrom-Hashtable $QParams
         $BaseUri = "${BaseUri}?${qstring}"
    }
    

    $IRMParams = @{
        Uri = $BaseUri
        Method = 'POST'
        Headers = @{
            Accept = 'application/json'
            Authorization = "Basic $decrypted"
        }
    }
    Remove-Variable decrypted

    if ($PSBoundParameters['Payload']) {
        $IRMParams.Add('Body', $( $Payload | ConvertTo-JSON ) )
        $IRMParams.Headers.Add('content-type', 'application/json')
    }
    else {
        $IRMParams.Headers.Add('content-type', 'application/x-www-form-urlencoded')
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