function ConvertFrom-Hashtable {
#.Synopsis
#  Convert a hashtable into a query string
#.Description
#  Converts a hashtable into a query string by joining the keys to the values, and then joining all the pairs together
#.Parameter values
#  The hashtable to convert
#.Parameter PairSeparator
#  The string used to concatenate the sets of key=value pairs, defaults to "&"
#.Parameter KeyValueSeparator
#  The string used to concatenate the keys to the values, defaults to "="
#.ReturnValue
#  The query string created by joining keys to values and then joining them all together into a single string
PARAM(
   [Parameter(ValueFromPipeline=$true, Position=0, Mandatory=$true)]
   [Hashtable]
   $Values,
   [Parameter(Position=1)]
   [String]
   $pairSeparator = '&',  
   [Parameter(Position=2)]
   [String]
   $KeyValueSeparator = '=',
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