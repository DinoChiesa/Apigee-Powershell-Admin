Function Send-EdgeRequest {
    <#
    .SYNOPSIS
        Send a POST request to Apigee Edge admin endpoint.

    .DESCRIPTION
        Send a POST request to Apigee Edge admin endpoint. This can be used to create
        an object in Apigee Edge, to Update an object, Revoke a key, etc.

    .PARAMETER Collection
        Required. Type of object to create. This may be a composite.

        Example: 'developers', 'apis', or 'apiproducts', or 'developers/dino@apigee.com/apps'

    .PARAMETER Name
        Optional. a Particular name within the collection.

    .PARAMETER QParams
        Optional. Hashtable, which will be serialized as query params.

    .PARAMETER NoAccept
        Optional. A string; set it to turn off the Accept header.

    .PARAMETER ContentType
        Optional. A string, to override the content-type header.

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
    PARAM(
        [string]$Collection,
        [string]$Name,
        [string]$QParams,
        [string]$NoAccept,
        [string]$ContentType,
        [string]$Org,
        [Hashtable]$Payload
    )

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if( ! $PSBoundParameters.ContainsKey('Org')) {
      if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']) {
        throw [System.ArgumentNullException] 'Org', "use the -Org parameter to specify the organization."
      }
      $Org = $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']
    }

    if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']) {
      throw [System.ArgumentNullException] 'MgmtUri', "use Set-EdgeConnection to specify the Edge connection information."
    }
    $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']

    # if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['SecurePass']) {
    #   throw [System.ArgumentNullException] 'SecurePass', "use Set-EdgeConnection to specify the Edge connection information."
    # }

    if ($PSBoundParameters['Name']) {
      $BaseUri = Join-Parts -Separator "/" -Parts $MgmtUri, '/v1/o', $Org, $Collection, $Name
    }
    else {
      $BaseUri = Join-Parts -Separator "/" -Parts $MgmtUri, '/v1/o', $Org, $Collection
    }

    if ($PSBoundParameters['QParams']) {
         Write-Debug ( "Send-EdgeRequest QParams: $QParams`n" )
         $BaseUri = "${BaseUri}?${QParams}"
    }
    Write-Debug ( "Send-EdgeRequest Uri $BaseUri`n" )

    $IRMParams = @{
        Uri = $BaseUri
        Method = 'POST'
        Headers = @{
            Accept = 'application/json'
        }
    }

    Apply-EdgeAuthorization -MgmtUri $MgmtUri -IRMParams $IRMParams

    if ($PSBoundParameters['Payload']) {
        $IRMParams.Add('Body', $( $Payload | ConvertTo-JSON ) )
        $IRMParams.Headers.Add('content-type', 'application/json')
    }
    else {
        $IRMParams.Headers.Add('content-type', 'application/x-www-form-urlencoded')
    }

    if ($PSBoundParameters['NoAccept']) {
      $IRMParams.Headers.Remove('Accept')
    }
    if ($PSBoundParameters['ContentType']) {
      $IRMParams.Headers['content-type'] = $ContentType  # overwrite
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