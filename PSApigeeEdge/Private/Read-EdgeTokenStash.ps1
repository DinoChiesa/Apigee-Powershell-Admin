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

function Read-EdgeTokenStash
{
    [cmdletbinding()]
    PARAM()
    PROCESS {
        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }
        $TokenStashFile = $MyInvocation.MyCommand.Module.PrivateData.Connection['TokenStash']
        if (!$TokenStashFile) {
            throw [System.InvalidOperationException] "There is no Token stash set. Have you called Set-EdgeConnection ?"
        }
        if(![System.IO.File]::Exists($TokenStashFile)) {
            Write-Debug ([string]::Format( "Read-EdgeTokenStash Token stash file {0} does not exist.", $TokenStashFile) )
            return $null
        }
        Write-Debug ([string]::Format( "Read-EdgeTokenStash Reading token stash file {0} ", $TokenStashFile) )
        # System.Management.Automation.PSCustomObject
        Get-Content $TokenStashFile -Raw | ConvertFrom-JSON
    }
}
