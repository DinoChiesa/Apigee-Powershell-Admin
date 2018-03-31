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

function Get-EdgeTokenIsExpired
{
    [cmdletbinding()]
    PARAM( [System.Management.Automation.PSNoteProperty] $UserToken )
    PROCESS {
        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }
        if (!$usertoken) {
            throw [System.ArgumentNullException] "You must pass a usertoken [PSNoteProperty]."
        }

        $lifetime = $UserToken.Value.expires_in
        $issuedAt = $UserToken.Value.issued_at
        $NowMilliseconds = Get-NowMilliseconds -Fudge -60000
        Write-Debug ( "Get-EdgeTokenIsExpired  NowMilliseconds: " + $NowMilliseconds )
        $ExpiryMilliseconds = [int64] $issuedAt + ($lifetime * 1000)
        Write-Debug ( "Get-EdgeTokenIsExpired  ExpiryMilliseconds: " + $ExpiryMilliseconds )
        if ($PSBoundParameters['Debug']) {
            $UnixEpochStart = new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)
            $Expiry = $UnixEpochStart.AddMilliseconds($ExpiryMilliseconds)
            Write-Debug ( "Get-EdgeTokenIsExpired  Expiry: " + $Expiry )
        }
        # True if expired
        $isExpired = ($ExpiryMilliseconds -lt $NowMilliseconds)
        Write-Debug ( "Get-EdgeTokenIsExpired  isExpired: " + $isExpired )
        $isExpired
    }
}
