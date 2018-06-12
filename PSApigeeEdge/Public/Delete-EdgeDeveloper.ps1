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

Function Delete-EdgeDeveloper {
    <#
    .SYNOPSIS
        Delete an developer app from Apigee Edge.

    .DESCRIPTION
        Delete an developer app from Apigee Edge.

    .PARAMETER Name
        The id or email address of the developer to delete.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeDeveloper -Name dchiesa@example.org

    .EXAMPLE
        Create-EdgeDeveloper

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Org
    )

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", 'The -Name parameter is required.'
    }

    $Options = @{ Collection = 'developers'; Name = $Name; }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options['Debug'] = $Debug
    }
    if ($PSBoundParameters['Org']) {
        $Options['Org'] = $Org
    }

    Write-Debug $( [string]::Format("Delete-EdgeDeveloper Options {0}", $(ConvertTo-Json $Options )))
    Delete-EdgeObject @Options
}
