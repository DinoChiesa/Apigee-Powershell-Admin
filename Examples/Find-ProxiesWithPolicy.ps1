# Copyright 2017-2019 Google Inc.
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

Write-Output "Find Proxies with a FlowCallout"

# Assumption is that Set-EdgeConnection has been called.

$proxies = @(Get-EdgeApi)
Write-Output ("Total proxies: " + $proxies.count)

$policyTypeToFind = Read-Host "Policy Type to find"

$proxies |% {
  $proxy = $(Get-EdgeApi -Name $_)
  Write-Output ([string]::Format('{0}', $proxy.name ) )
  $proxy.revision |% {
    #Write-Output ([string]::Format('  Revision: {0}', $_ ) )
    $proxyRev = $(Get-EdgeApi -Name $proxy.name -Revision $_)
    #Write-Output ([string]::Format('    Proxy Rev: {0}', (ConvertTo-Json $proxyRev) ) )
    $proxyRev.policies |% {
      #Write-Output ([string]::Format('    Policy: {0}', $_ ) )
      $policy = get-EdgeApiPolicy -Name $proxy.name -Revision $proxyRev.revision -Policy $_   
      #Write-Output ([string]::Format('    Policy: {0}',  (ConvertTo-Json $policy) ) )
      if ($policy.policyType -eq $policyTypeToFind) {
        #Write-Output ([string]::Format("`nProxy: {0}", $proxy.name ) )
        Write-Output ([string]::Format('  Revision: {0}', $proxyRev.revision ) )
        Write-Output ([string]::Format('    Policy: {0}',  (ConvertTo-Json $policy) ) )
      }
    }
  }
}
