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

function ConvertFrom-HashtableToQueryString {
    <#
    .SYNOPSIS
      Convert a hashtable into a query string

    .DESCRIPTION
      Converts a hashtable into a query string by joining the keys to the values,
      and then joining all the pairs together

    .PARAMETER values
      The hashtable to convert

    .PARAMETER PairSeparator
      The string used to concatenate the sets of key=value pairs, defaults to "&"

    .PARAMETER KeyValueSeparator
      The string used to concatenate the keys to the values, defaults to "="

    .RETURNVALUE
      The query string created by joining keys to values and then joining
      them all together into a single string

    .EXAMPLE
           ConvertFrom-HashTable -Values @{
                name  =  'abcdefg-1'
                apiProduct = 'Product1'
                keyExpiresIn =  86400000
            }
    #>

PARAM(
   [Hashtable] $Values,
   [String] $pairSeparator = '&',  
   [String] $KeyValueSeparator = '=',
   [string[]]$Sort
)
PROCESS {
   [string]::join($pairSeparator, @(
      if($Sort) {
         foreach( $kv in $Values.GetEnumerator() | Sort $Sort) {
            if($kv.Name) {
               '{0}{1}{2}' -f $kv.Name, $KeyValueSeparator, $kv.Value
            }
         }
      } else {
         foreach( $kv in $Values.GetEnumerator()) {
            if($kv.Name) {
               '{0}{1}{2}' -f $kv.Name, $KeyValueSeparator, $kv.Value
            }
         }
      }
   ))
}}