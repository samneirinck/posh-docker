# Pretty much copy/paste from https://github.com/dahlbyk/posh-git/blob/master/install.ps1
param([switch]$WhatIf = $false)

if($PSVersionTable.PSVersion.Major -lt 3) {
    Write-Warning "posh-docker requires PowerShell 3.0 or better; you have version $($Host.Version)."
    return
}

if(!(Test-Path $PROFILE)) {
    Write-Host "Creating PowerShell profile...`n$PROFILE"
    New-Item $PROFILE -Force -Type File -ErrorAction Stop -WhatIf:$WhatIf > $null
}

if(!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Warning 'Could not find docker command. Please create a docker alias or add %ProgramFiles%\Docker Toolbox to PATH.'
    return
}

$installDir = Split-Path $MyInvocation.MyCommand.Path -Parent

# Adapted from http://www.west-wind.com/Weblog/posts/197245.aspx
function Get-FileEncoding($Path) {
    $bytes = [byte[]](Get-Content $Path -Encoding byte -ReadCount 4 -TotalCount 4)

    if(!$bytes) { return 'utf8' }

    switch -regex ('{0:x2}{1:x2}{2:x2}{3:x2}' -f $bytes[0],$bytes[1],$bytes[2],$bytes[3]) {
        '^efbbbf'   { return 'utf8' }
        '^2b2f76'   { return 'utf7' }
        '^fffe'     { return 'unicode' }
        '^feff'     { return 'bigendianunicode' }
        '^0000feff' { return 'utf32' }
        default     { return 'ascii' }
    }
}

$profileLine = ". '$installDir\tabcompletion.ps1'"
if(Select-String -Path $PROFILE -Pattern $profileLine -Quiet -SimpleMatch) {
    Write-Host "It seems posh-docker is already installed..."
    return
}

Write-Host "Adding posh-docker to profile..."
@"

# Load posh-docker tab completion
$profileLine

"@ | Out-File $PROFILE -Append -WhatIf:$WhatIf -Encoding (Get-FileEncoding $PROFILE)

Write-Host 'posh-docker sucessfully installed!'
Write-Host 'Please reload your profile for the changes to take effect:'
Write-Host '    . $PROFILE'
