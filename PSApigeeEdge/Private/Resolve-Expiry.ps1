function Resolve-Expiry
{
    <#
    .SYNOPSIS
        Resolve a string into a number of milliseconds from now.

    .DESCRIPTION
        Edge accepts expiry in terms of milliseconds-from-now.
        This function resolves strings like '120d' and '2016-12-10' into
        the correct number of milliseconds. Or, if you pass a bare number, it
        will interpret it as seconds, and return the equivalent milliseconds value. 

    .PARAMETER Value
        The string to convert.

    .EXAMPLE
        Resolve-Expiry 120d

    #>
    [cmdletbinding()]
    PARAM(
      [Parameter(Mandatory=$True)][string]$Value
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    $result = -1
    $regex1 = New-Object System.Text.RegularExpressions.Regex ('^([1-9][0-9]*)([smhdwy])$')
    $regex2 = New-Object System.Text.RegularExpressions.Regex ('^([1-9][0-9]*)$')
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
      $result = $match.Groups[1].Value * $multipliers[ $match.Groups[2].Value ] * 1000
      Write-Debug ( "Resolve-Expiry, case1. Input($Value), result: $result`n" )      
    }
    elseif ($Value -match $regex2) {
      ## just a bare number - evaluate it as seconds
      $result = (0 + $Value) * 1000;
      Write-Debug ( "Resolve-Expiry, case2. Input($Value), result: $result`n" )      
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
      Write-Debug ( "Resolve-Expiry, case3. Input($Value), result: $result`n" )      
    }
    $result
}