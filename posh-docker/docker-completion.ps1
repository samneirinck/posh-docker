. $PSScriptRoot\utils.ps1

$global:DockerCompletion = @{}

function Script:InitializeDockerCompletion() {
    if ((IsInPath "docker") -eq $false) {
        Write-Warning "docker command could not be found. Please make sure docker is installed correctly."
        return;
    }

    if ($Global:DockerCompletion.Count -ne 0) {
        return;
    }

    $global:DockerCompletion = Get-CompletionForString (docker --help)
}

function Script:Get-CompletionForString($inputString) {
    $completion = @{
        "usage"    = ""
        "commands" = @()
        "options"  = @()
    }

    $parsingOptions = $false
    $parsingCommands = $true

    $inputString | ForEach-Object {
        if ($_ -match "^Usage:\s*(.*)") {
            $completion["usage"] = $Matches[1]
        }
        elseif ($_ -match "^Options:") {
            $parsingOptions = $true
        }
        elseif ($_ -match "^Commands:" -or $_ -match "^Management Commands:") {
            $parsingCommands = $true
        }
        elseif ($_ -eq $null -or $_ -eq "") {
            $parsingOptions = $false
            $parsingCommands = $false
        }
        elseif ($parsingOptions -eq $true -and $_ -match "^.*--(\w+).*$") {
            $completion["options"] += $Matches[1]
        }
        elseif ($parsingCommands -eq $true -and $_ -match "^[^\w]*(\w+).*$") {
            $completion["commands"] += $Matches[1]
        }
    }

    return $completion
}

InitializeDockerCompletion