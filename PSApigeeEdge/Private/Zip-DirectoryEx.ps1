function Using-Object
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Object]
        $InputObject,

        [Parameter(Mandatory = $true)]
        [scriptblock]
        $ScriptBlock
    )

    try
    {
        . $ScriptBlock
    }
    finally
    {
        if ($null -ne $InputObject -and $InputObject -is [System.IDisposable])
        {
            $InputObject.Dispose()
        }
    }
}

function Get-AllFiles([string] $SourceDir) 
{
    # This gets the flattened list of all the files in the source directory,
    # which is what we need to produce a zip archive. The ShortPath flips 
    # the slashes, for compatibility with Java Zip Stream.

    $mypath = $(Resolve-Path $SourceDir)
    $allfiles = @(Get-ChildItem -Path $mypath.Path  -Recurse -File).FullName
    $allfiles |% { @{ FullPath = $_; ShortPath = $_.Replace($mypath.Path+'\','').Replace('\','/') } }
}

function Zip-DirectoryEx([string] $SourceDir)
{
    $mypath = $(Resolve-Path $SourceDir)
    if ($mypath.count -ne 1) {
        throw [System.ArgumentException] "The provided Source does not resolve."
    }

    $ZipFileName = [string]::Format('{0}\bundle-{1}.zip', $env:temp, $(Get-Random))

    Add-Type -AssemblyName System.IO
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    Using-Object ($fs = New-Object System.IO.FileStream($ZipFileName, [System.IO.FileMode]::Create)) {
         Using-Object ($arch = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)) {
                     Get-AllFiles $mypath.Path | foreach {
                         $t = @([System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($arch, $_.FullPath, $_.ShortPath) )
                     }
         }
    }
    $ZipFileName 
}

