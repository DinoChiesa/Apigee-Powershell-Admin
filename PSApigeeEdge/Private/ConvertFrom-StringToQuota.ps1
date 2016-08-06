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
      A hashtable of objects.

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
          $intervals = @{ m = 'minute'; h = 'hour'; d = 'day'; M = 'month' }
          $Result= @{
              quota = 0 + $match.Captures[1].value
              quotaInterval = 1
              quotaTimeUnit = $intervals[ $match.Captures[2].value ]
          }
      }
      # Return a Hashtable like { quota = 1000; quotaTimeUnit = 'minute'; quotaInterval = 1 }
      $Result
  }

}
