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

Function Get-EdgeOrganization {
    <#
    .SYNOPSIS
        Get information regarding an organization in Apigee Edge.

    .DESCRIPTION
        Get information regarding an organization in Apigee Edge.
        You might want to do this to query whether CPS is enabled on an org, for example.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Get-EdgeOrganization -Org cap500

    .LINK
        Get-EdgeEnvironment

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    PARAM(
        [string]$Org
    )

    PROCESS {
        $Options = @{ }

        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
            $Options['Debug'] = $Debug
        }
        if ($PSBoundParameters['Org']) {
            $Options['Org'] = $Org
        }

        Write-Debug $( [string]::Format("Get-EdgeOrganization Options {0}", $(ConvertTo-Json $Options )))
        try {
            $obj = $(Get-EdgeObject @Options)
        }
        catch {
            $obj = $_
        }
        $obj
    }
}
