function IsInPath {
    param(
        [Parameter(Mandatory = $true)]
        [string] $executable
    )

    if ((Get-Command $executable -ErrorAction SilentlyContinue) -eq $null) 
    { 
       return $false
    }
    return $true
}