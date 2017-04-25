function Resolve-PathSafe
{
    param( [string] $Path )
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
}