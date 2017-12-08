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

function Join-Parts
{
    <#
    .SYNOPSIS
        Join strings with a specified separator.

    .DESCRIPTION
        Join strings with a specified separator.

        This strips out null values and any duplicate separator characters.

        See examples for clarification.

    .PARAMETER Separator
        Separator to join with

    .PARAMETER Parts
        Strings to join

    .EXAMPLE
        Join-Parts -Separator "/" this //should $Null /work/ /well

        # Output: this/should/work/well

    .EXAMPLE
        Join-Parts -Parts http://this.com, should, /work/, /wel

        # Output: http://this.com/should/work/wel

    .EXAMPLE
        Join-Parts -Separator "?" this ?should work ???well

        # Output: this?should?work?well

    .EXAMPLE

        $CouldBeOneOrMore = @( "JustOne" )
        Join-Parts -Separator ? -Parts CouldBeOneOrMore

        # Output JustOne

        # If you have an arbitrary count of parts coming in,
        # Unnecessary separators will not be added

    .NOTES
        Author is: RamblingCookieMonster
        Credit to Rob C. and Michael S. from this post:
        http://stackoverflow.com/questions/9593535/best-way-to-join-parts-with-a-separator-in-powershell
    
    #>
    [cmdletbinding()]
    param
    (
    [string]$Separator = "/",

    [parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Parts = $null
        
    )

    ( $Parts |
        Where { $_ } |
        Foreach { ( [string]$_ ).trim($Separator) } |
        Where { $_ }
    ) -join $Separator
}
