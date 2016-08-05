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

    .PARAMETER MgmtUri
        The base Uri for the Edge API Management server.

        Default: https://api.enterprise.apigee.com

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
        [string]$User,
        [string]$Pass,
        [string]$MgmtUri = 'https://api.enterprise.apigee.com',
        [Hashtable]$Params
    )


    #Build up URI
    $BaseUri = Join-Parts -Separator "/" -Parts $MgmtUri, '/v1/o', $Org, $($Collection.ToLower())

    #Build up Invoke-RestMethod and Get-SEData parameters for splatting
    $IRMParams = @{
        Uri = $BaseUri
        Method = 'Get'
    }
    $Headers = @{
        Accept = 'application/json'
    }

    $pair = "${User}:${Pass}"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $Headers.Add( 'Authorization', "Basic $base64" )
    
    if($PSBoundParameters.ContainsKey('Params'))
    {
        $IRMParams.Add( 'Body', $Params )
    }

    $IRMParams.Add( 'Headers', $Headers )

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