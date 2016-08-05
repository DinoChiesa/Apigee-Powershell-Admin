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

        if($PSBoundParameters.ContainsKey('Params'))
        {
            $IRMParams.Add( 'Body', $Params )
        }

        Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                    "PSBoundParameters:$( $PSBoundParameters | Format-List | Out-String)" +
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

}