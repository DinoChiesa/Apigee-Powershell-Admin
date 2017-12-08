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

function ConvertFrom-HashtableToAttrList {
    <#
    .SYNOPSIS
      Convert a hashtable into an attr list, which is really an array of objects.

    .DESCRIPTION
      Converts a hashtable into an array of objects, each with a name and value.

    .PARAMETER Values
      The hashtable to convert.

    .PARAMETER NameProp
      The string used for the name or key of the k/v pair. Defaults to 'name'.

    .PARAMETER ValueProp
      The string used for the value of the k/v pair. Defaults to 'value'.

    .RETURNVALUE
      An array of hashtable objects with name,value keys. 

    .EXAMPLE
           ConvertFrom-HashTableToAttrList -Values @{
                creator  =  'provisioning-script.ps1'
                created = [System.DateTime]::Now.ToString("yyyy MM dd")
            }
    #>

  PARAM(
     [Hashtable] $Values,
     [String] $NameProp = 'name',  
     [String] $ValueProp = 'value'
  )
  PROCESS {
      $Result = @()
      foreach( $kv in $Values.GetEnumerator()) {
        if($kv.Name) {
            $hash = @{}
            $hash[$NameProp] = $kv.Name
            $hash[$ValueProp] = $kv.Value
            $Result += $hash
        }
      }
      # Return an ARRAY of objects like { name = something; value = somethingelse }
      $Result
  }

}
