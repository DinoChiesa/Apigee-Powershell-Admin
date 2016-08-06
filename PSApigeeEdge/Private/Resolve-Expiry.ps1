function Resolve-Expiry
{
    <#
    .SYNOPSIS
        Resolve a string into a number of milliseconds from now.

    .DESCRIPTION
        Edge accepts expiry in terms of milliseconds-from-now.
        This function resolves strings like '120d' and '2016-12-10' into
        the correct number of milliseconds.

    .PARAMETER Value
        The string to convert from 

    .EXAMPLE
        Resolve-Expiry 120d

    #>
    [cmdletbinding()]
    param(
      [Parameter(Mandatory=$True)][string]$Value
    )

    $result = -1
    $regex1 = New-Object System.Text.RegularExpressions.Regex ('^([1-9][0-9]+)(smhdwy)$')
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
      $result = $match.Captures[1].value * $multipliers[ $match.Captures[2].value ] * 1000
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