# Copyright 2017 Google LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#   https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
    if ( $mypath.count -ne 1 ) {
        throw [System.ArgumentException] "SourceDir", [string]::Format("The provided SourceDir ({0}) does not resolve.", $SourceDir)
    }
    $allfiles = @(Get-ChildItem -Path $mypath.Path -Recurse -File).FullName
    $allfiles |% { @{ FullPath = $_; ShortPath = $_.Replace($mypath.Path+'\','').Replace('\','/') } }
}

function Zip-DirectoryEx([string] $SourceDir)
{
    $mypath = $(Resolve-PathSafe $SourceDir)
    if (! $mypath) {
        throw [System.ArgumentException] "SourceDir", "The provided Source does not resolve."
    }

    $ZipFileName = [string]::Format('{0}\bundle-{1}.zip', $env:temp, $(Get-Random))

    Add-Type -AssemblyName System.IO
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    Using-Object ($fs = New-Object System.IO.FileStream($ZipFileName, [System.IO.FileMode]::Create)) {
         Using-Object ($arch = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)) {
             Get-AllFiles $mypath | foreach {
                 $t = @([System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($arch, $_.FullPath, $_.ShortPath) )
             }
         }
    }
    $ZipFileName
}
