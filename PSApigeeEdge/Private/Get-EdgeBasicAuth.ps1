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

function Get-EdgeBasicAuth
{
    [cmdletbinding()]
    PARAM( )
    PROCESS {

        $SecurePass = $MyInvocation.MyCommand.Module.PrivateData.Connection['SecurePass']
        if (!$SecurePass) {
            throw [System.ArgumentNullException] "There is no SecurePass stored. Have you called Set-EdgeConnection ?"
        }

        $Pass = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($SecurePass))

        $User = $MyInvocation.MyCommand.Module.PrivateData.Connection['User']
        $pair = "${User}:${Pass}"
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
        $base64 = [System.Convert]::ToBase64String($bytes)

        Remove-Variable SecurePass
        Remove-Variable Pass
        Remove-Variable User
        Remove-Variable pair
        Remove-Variable bytes

        $base64

    }
}
