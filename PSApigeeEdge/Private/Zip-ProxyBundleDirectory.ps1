function Zip-ProxyBundleDirectory {
    <#
    .SYNOPSIS
      Zip a directory containing an API Proxy bundle into a zip file. 

    .DESCRIPTION
      Zip a directory containing an API Proxy bundle into a zip file. 
      The directory 

    .PARAMETER Sourcedir
      The source directory to zip. It must exist.

    .RETURNS
      The name of the newly created zip file, stored in the TEMP directory. 

    .EXAMPLE
      Zip-ProxyBundleDirectory -SourceDir .\myproxy 

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$SourceDir
    )

    $mypath = $(Resolve-Path $SourceDir)
    if ($mypath.count -ne 1) {
        throw [System.ArgumentException] "The provided Source does not resolve."
    }

    $apiproxyPaths = @(Join-Path -Path $mypath.Path -ChildPath "apiproxy" -Resolve)
    if ($apiproxyPaths.count -ne 1) {
        throw [System.ArgumentException] "Cannot find apiproxy directory under the Source directory."
    }
    
    Add-Type -Assembly System.IO.Compression.FileSystem
    $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
    $ExcludeBaseDirectory = $True
    $ZipFileName = [string]::Format('{0}\apigee-edge-apiproxy-bundle-{1}.zip', $env:temp, $(Get-Random))
    [System.IO.Compression.ZipFile]::CreateFromDirectory($apiproxyPaths[0], # the apiproxy dir
                                                         $ZipFileName,
                                                         $compressionLevel,
                                                         $ExcludeBaseDirectory)
    $ZipFileName
}
