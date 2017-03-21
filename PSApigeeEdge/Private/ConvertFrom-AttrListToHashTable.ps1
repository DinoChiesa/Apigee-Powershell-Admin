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
