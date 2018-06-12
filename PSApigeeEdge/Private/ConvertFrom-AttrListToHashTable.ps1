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

function ConvertFrom-AttrListToHashtable {
    <#
    .SYNOPSIS
      Convert an attr list, which is really an array of hashtable objects each with a name and value property, to a single hashtable.

    .DESCRIPTION
      Convert an attr list, which is really an array of hashtable objects each with a name and value property, to a single hashtable.

    .PARAMETER List
      The array of hashtables with name/value pairs to convert.

    .RETURNVALUE
      A hashtable.

    .EXAMPLE
           ConvertFrom-AttrListToHashTable -List  @(
                @{ name = "creator"; value =  'provisioning-script.ps1' },
                @{ name = "created"; value =  [System.DateTime]::Now.ToString("yyyy MM dd") },
            )
    #>

  PARAM(
     [Object[]] $List
  )
  PROCESS {
      $Values = @{}
      foreach($item in $List) {
          $Values[$item['name']] = $item['value']
      }
      $Values
  }
}
