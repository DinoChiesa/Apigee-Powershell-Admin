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

Function Put-EdgeAppCredential {
    <#
    .SYNOPSIS
        Put a new credential onto a developer app.

    .DESCRIPTION
        Put a credential on the list for a developer app. Explicitly specify the consumer Key and consumer Secret.

    .PARAMETER AppId
        Optional. The id of the developer app to retrieve. You need to specify either AppId
        or AppName and Developer to uniquely identify the app. 

    .PARAMETER AppName
        Optional. The name of the developer app to update.

    .PARAMETER Developer
        Optional. The id or email of the developer that owns the app to update

    .PARAMETER Attributes
        Optional. Hashtable specifying custom attributes for the app. 

    .PARAMETER Key
        Required. The consumerKey to insert. It must be unique in the organization.

    .PARAMETER Secret
        Required. The consumerSecret to insert. 

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Put-EdgeAppCredential -AppId cc631102-80cd-4491-a99a-121cec08e0bb -Key ABCDE -Secret qw1091092092a

    .EXAMPLE
        Put-EdgeAppCredential -AppName TestApp_2 -Developer dchiesa@google.com -Key ABCDE -Secret qw1091092092a

    .LINK
        Add-EdgeAppCredential

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    param(
        [string]$AppName,
        [string]$AppId,
        [string]$Developer,
        [string]$Key,
        [string]$Secret,
        [hashtable]$Attributes,
        [string]$Org
    )
    
    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    if ((!$PSBoundParameters['AppName'] -and ! $PSBoundParameters['AppId']) -or
      ($PSBoundParameters['AppName']  -and $PSBoundParameters['AppId'])) {
          throw [System.ArgumentNullException] "AppName", "You must specify exactly one of -AppName or -AppId."
      }
    
    if (!$PSBoundParameters['Key']) {
      throw [System.ArgumentNullException] "Key", "You must specify -Key."
    }
    if (!$PSBoundParameters['Secret']) {
      throw [System.ArgumentNullException] "Secret", "You must specify -Secret."
    }
    
    if ($PSBoundParameters['AppId']) {
        $Options.Add( 'Collection', 'apps')
        $Options.Add( 'Name', $AppId )
    }
    else {
        if (!$PSBoundParameters['Developer']) {
            throw [System.ArgumentNullException] "Developer", "You must specify the -Developer option with -AppName."
        }
        $Options.Add( 'Collection', $(Join-Parts -Separator '/' -Parts 'developers', $Developer, 'apps', $AppName, 'keys', 'create' ) )

    }

    $Payload = @{
        consumerKey = $Key
        consumerSecret = $Secret
    }

    if ($PSBoundParameters['Attributes']) {
        $a = @(ConvertFrom-HashtableToAttrList -Values $Attributes)
        $Payload.Add('attributes', $a )
    }
    $Options.Add( 'Payload', $Payload )

    Send-EdgeRequest @Options
}
