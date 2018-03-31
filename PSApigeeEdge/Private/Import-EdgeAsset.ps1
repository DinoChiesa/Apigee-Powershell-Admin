# Copyright 2017 Google Inc.
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

Function Import-EdgeAsset {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Source,
        [Parameter(Mandatory=$True)][string]$FsPath,
        [Parameter(Mandatory=$True)][string]$UriPathElement,
        [string]$Org
    )

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Source']) {
      throw [System.ArgumentNullException] "Source", "You must specify the -Source option."
    }

    $ZipFile = ""
    $isFile = $False
    $mypath = $(Resolve-PathSafe $Source)
    if (! $mypath) {
        throw [System.ArgumentException] "Source", "The provided Source does not resolve."
    }

    if([System.IO.File]::Exists($mypath)){
        $isFile = $True
        $ZipFile = $mypath
        Write-Debug ([string]::Format("Source is file {0}`n", $ZipFile))
    }
    elseif ([System.IO.Directory]::Exists($mypath)) {
        # Validate that there is an apiproxy or sharedflowbundle directory
        $childPaths = @(Join-Path -Path $mypath -ChildPath $FsPath -Resolve)
        if ($childPaths.count -ne 1) {
            throw [System.ArgumentException] $([string]::Format("Cannot find {0} directory under the Source directory", $FsPath))
        }
        Write-Debug ([string]::Format("Source is directory {0}`n", $mypath))
        $ZipFile = Zip-DirectoryEx -SourceDir $mypath
        Write-Debug ([string]::Format("Zipfile {0}`n", $ZipFile))
    }
    else {
      throw [System.ArgumentException] "Source", $([string]::Format("Source file refers to '{0}', not a readable file or directory.", $mypath))
    }

    if( ! $PSBoundParameters.ContainsKey('Org')) {
      if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']) {
        throw [System.ArgumentNullException] 'Org', "use the -Org parameter to specify the organization."
      }
      $Org = $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']
    }
    if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']) {
      throw [System.ArgumentNullException] 'MgmtUri', 'use Set-EdgeConnection to specify the Edge connection information.'
    }
    $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']

    $BaseUri = Join-Parts -Separator '/' -Parts $MgmtUri, '/v1/o', $Org, $UriPathElement

    $IRMParams = @{
        Uri = "${BaseUri}?action=import&name=${Name}"
        Method = 'POST'
        Headers = @{
            Accept = 'application/json'
            'content-type' = 'application/octet-stream'
        }
        InFile = $ZipFile
    }

    Apply-EdgeAuthorization -MgmtUri $MgmtUri -IRMParams $IRMParams

    Write-Debug ([string]::Format("Params {0}`n", $(ConvertTo-Json $IRMParams -Compress ) ) )

    Try {
        $TempResult = Invoke-WebRequest @IRMParams -UseBasicParsing

        Write-Debug "Raw:`n$($TempResult | Out-String)"
    }
    Catch {
        Throw $_
    }
    Finally {
        Remove-Variable IRMParams
        if (! $isFile ) {
            # Source was a dir, the zipfile is a temp file. Clean it up.
            [System.IO.File]::Delete($ZipFile)
        }
    }
    if ($TempResult.StatusCode -eq 201) {
      ConvertFrom-Json $TempResult.Content
    }
    else {
      $TempResult
    }
}
