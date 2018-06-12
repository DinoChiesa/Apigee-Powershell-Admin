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

Function Revoke-EdgeDeveloper {
    <#
    .SYNOPSIS
        Revoke a developer in Apigee Edge.

    .DESCRIPTION
        Set the status of the developer to 'Inactive', which means none of the credentials
        belonging to this developer will be treated as valid, at runtime. 

    .PARAMETER Name
        The email or id of the Developer to revoke. 

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Revoke-EdgeDeveloper -Name Elaine@example.org

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Org
    )
    
    if (!$PSBoundParameters['Name']) {
       throw [System.ArgumentNullException] "Name", 'the -Name parameter is required.'
    }
    
    $Options = @{
       Collection = 'developers' 
       Name = $Name
       NoAccept = 'true'
       ContentType = 'application/octet-stream'
       QParams = $( ConvertFrom-HashtableToQueryString @{ action = 'inactive' } )
    }
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }

    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    Send-EdgeRequest @Options
}
