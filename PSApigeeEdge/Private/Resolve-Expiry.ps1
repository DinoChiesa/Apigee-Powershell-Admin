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

function Resolve-Expiry {
    <#
    .SYNOPSIS
        Resolve a string into a number of milliseconds from now.

    .DESCRIPTION
        Edge accepts expiry in terms of milliseconds-from-now.
        This function resolves strings like '120d' and '2016-12-10' into
        the correct number of milliseconds. Or, if you pass a bare number, it
        will interpret it as seconds, and return the equivalent milliseconds value. 

    .PARAMETER Value
        The string to convert.

    .EXAMPLE
        Resolve-Expiry 120d
    #>

    [cmdletbinding()]
    PARAM(
      [Parameter(Mandatory=$True)][string]$Value
    )
    
    $result = -1
    $regex1 = New-Object System.Text.RegularExpressions.Regex ('^([1-9][0-9]*)([smhdwy])$')
    $regex2 = New-Object System.Text.RegularExpressions.Regex ('^([1-9][0-9]*)$')
    $match = $regex1.Match($Value) 
    if ($match.Success) {
        $multipliers = @{
          s = 1
          m = 60
          h = 60 * 60
          d = 60 * 60 * 24
          w = 60 * 60 * 24 * 7 
          y = 60 * 60 * 24 * 365
        }
      $result = ($match.Groups[1].Value -as [int]) * ($multipliers[ $match.Groups[2].Value ]) * 1000
    }
    elseif ($Value -match $regex2) {
      ## just a bare number - evaluate it as seconds
      $result = ($Value -as [int]) * 1000;
    }
    else {
      # variable to hold parsed date
      [datetime] $parsedDate = New-Object DateTime
      $possibleFormats = @( 'yyyy-MM-dd',  'dd-MM-yyyy')

      foreach ($format in $possibleFormats) {
        if ($result -lt 0) {
        if([DateTime]::TryParseExact($Value, $format,
          [System.Globalization.CultureInfo]::InvariantCulture, 
          [System.Globalization.DateTimeStyles]::None, 
          [ref] $parsedDate)) {    
            $result = ($parsedDate - [DateTime]::Today).TotalMilliseconds
        }
        }
      }
    }
    $result
}