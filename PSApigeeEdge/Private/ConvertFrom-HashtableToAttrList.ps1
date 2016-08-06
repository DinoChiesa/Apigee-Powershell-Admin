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
      An array of objects.

    .EXAMPLE
           ConvertFrom-HashTableToAttrList -Values @{
                creator  =  'provisioning-script.ps1'
                created = [System.DateTime]::Now.ToString("yyyy MM dd")
            }
    #>

  PARAM(
     [Hashtable] $Values,
     [String] $NameProp = 'name',  
     [String] $ValueProp = 'value',
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
      $Result
  }

}
