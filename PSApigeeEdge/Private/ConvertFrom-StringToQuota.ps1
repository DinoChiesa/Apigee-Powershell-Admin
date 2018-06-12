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

function ConvertFrom-StringToQuota {
    <#
    .SYNOPSIS
      Convert a string into a quota. 

    .DESCRIPTION
      Converts a string of the form '100pm' into a hashtable specifying the
      quota, quotaInterval, and quotaTimeUnit. Suffix strings must me pm ph pd or pM, for
      minute, hour, day, or month. 

    .PARAMETER Quota
      The string to convert. 

    .RETURNVALUE
      A hashtable like { quota = 1000; quotaTimeUnit = 'minute'; quotaInterval = 1 }
      If the string is malformed, then an empty hashtable. 

    .EXAMPLE
           ConvertFrom-StringToQuota 100pm
    #>

  PARAM(
     [String] $Quota
  )
  PROCESS {
      $regex1 = New-Object System.Text.RegularExpressions.Regex ('^([1-9][0-9]+)p(mhdM)$')
      $Result = @{}
      $match = $regex1.Match($Value) 
      if ($match.Success) {
          $Result= @{
              quota = 0 + $match.Captures[1].value
              quotaInterval = 1
              quotaTimeUnit = switch ($match.Captures[2].value) { 
                    m { 'minute'; }
                    h { 'hour'; }
                    d { 'day'; }
                    M { 'month'; }
               }
          }
      }
      $Result
  }
}
