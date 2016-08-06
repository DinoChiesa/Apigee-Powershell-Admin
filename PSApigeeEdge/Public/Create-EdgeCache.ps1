Function Create-EdgeCache {
    <#
    .SYNOPSIS
        Create a named cache in Apigee Edge.

    .DESCRIPTION
        Create a named cache in Apigee Edge.

    .PARAMETER Name
        The name of the cache to create. It must be unique for the environment.

    .PARAMETER Environment
        A string, the name of the environment for this cache. 

    .PARAMETER Expiry
        The default expiry for items placed into the cache. This can be an integer, which
        is interpreted as seconds. For example 86400 is one day. Or, it can be a string,
        such as 600s, 45m, 10h, or 4d, which is intepreted as the intended number of
        seconds, minutes, hours, or days. Defaults to 86400.

    .PARAMETER Description
        A string, describing the purpose of the cache to be created. 

    .PARAMETER Distributed
        Whether the cache will be distributed. Defaults to true. 

    .PARAMETER OtherAttributes
        Optional. A hashtable specifying other attributes for the cache. 

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Create-EdgeCache -Name 'Product-7' -Environments @('test') -Proxies @('oauth2-pwd-cc') -Attributes @{ CreatedBy = 'dino'; access = 'public' } -Quota 30pm


    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Environment,
        [string]$Expiry = '86400',
        [string]$Description = 'a general purpose cache',
        [switch]$Distributed,
        [hashtable]$OtherAttributes,
        [string]$Org
    )
    
    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Environment']) {
      throw [System.ArgumentNullException] "You must specify the -Environment option."
    }

    $Options['Collection'] = $( Join-Parts -Separator '/' -Parts 'e', $Environment, 'caches' ) 
    $Options['QParams'] = $( ConvertFrom-HashtableToQueryString @{ name = $Name } )
      
    $Payload = @{
      description = $Description
      distributed = if ($Distributed) {'true'} else {'false'}
      expirySettings = @{
        timeoutInSec =  @{ value = $(Resolve-Expiry $Expiry)/1000 }
        valuesNull = 'false'
      }
    }
    
    $CacheAttrs= @{
        compression = @{ minimumSizeInKB = 1024 }
        persistent = 'false'
        skipCacheIfElementSizeInKBExceeds = 2048
        diskSizeInMB = 0
        overflowToDisk = 'false'
        maxElementsOnDisk = 1
        maxElementsInMemory = 3000000
        inMemorySizeInKB = 8000
    }

    if ($PSBoundParameters['OtherAttributes']) {
      $OtherAttributes.getEnumerator() | Foreach-Object {
        if( ! $CacheAttrs.ContainsKey($_.Key)) {
          $CacheAttrs[$_.Key] = $_.Value
        }
      }
    }
    $CacheAttrs.getEnumerator() | Foreach-Object {
        $Payload[$_.Key] = $_.Value
    }

    $Options.Add( 'Payload', $Payload )

    Send-EdgeRequest @Options
}
