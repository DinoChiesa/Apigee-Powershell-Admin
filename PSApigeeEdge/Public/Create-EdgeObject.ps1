Function Create-EdgeObject {
    <#
    .SYNOPSIS
        Create an object in Apigee Edge

    .DESCRIPTION
        Create an object in Apigee Edge

    .PARAMETER Collection
        Type of object to create. This may be a composite. 

        Example: 'developers', 'apis', or 'apiproducts', or 'developers/dino@apigee.com/apps'
        
    .PARAMETER Payload
        Hashtable, which will become the payload of the POST method. 

    .PARAMETER Org
        The Apigee Edge organization. 

    .EXAMPLE
        Create-EdgeObject -Collection 'developers/dino@apigee.com/apps' -Payload @{
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
        [string]$Org,
        [Hashtable]$Payload
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "You must specify the -Name option."
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

    $BaseUri = Join-Parts -Separator "/" -Parts $MgmtUri, '/v1/o', $Org, $Collection.ToLower()
    Write-Debug ( "Uri $BaseUri`n" )

    $decrypted = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($AuthToken))
    
    $IRMParams = @{
        Uri = $BaseUri
        Method = 'POST'
        Headers = @{
            Accept = 'application/json'
            'content-type' = 'application/json'
            Authorization = "Basic $decrypted"
        }
        Body = $( $Payload | ConvertTo-JSON )
    }
    
    Remove-Variable decrypted

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