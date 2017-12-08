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

Function Get-EdgeDeveloper {
    <#
    .SYNOPSIS
        Get one or more developers from Apigee Edge

    .DESCRIPTION
        Get one or more developers from Apigee Edge

    .PARAMETER Name
        Optional. The name of the developer to retrieve. This can be either the
        email address or the developerId. If you do specify this parameter, you'll
        get a developer entity. If you do not specify it, the return value is a list
        of email addresses for all developers.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .PARAMETER Params
        Hash table with query options for the specific collection type

        Example for getting all details of developers:
            -Params @{
                expand  = 'true'
            }

    .EXAMPLE
        Get-EdgeDeveloper -Org cap500

    .EXAMPLE
        Get-EdgeDeveloper -Name lx7kRoayaqsgm96i

    .EXAMPLE
        Get-EdgeDeveloper -Name tlasorda@example.org

    .EXAMPLE
        Get-EdgeDeveloper -Params @{ expand = 'true' }

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [string]$Name,
        [string]$Org,
        [Hashtable]$Params
    )

    $Options = @{
        Collection = 'developers'
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Params']) {
        $Options.Add( 'Params', $Params )
    }
    if ($PSBoundParameters['Name']) {
        $Options.Add( 'Name', $Name )
    }

    Get-EdgeObject @Options
}
