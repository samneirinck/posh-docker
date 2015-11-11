$global:DockerRootCommandList = @()
$global:DockerRootOptionsList = @()

# docker [OPTIONS] COMMAND [arg...]
# docker images [OPTIONS] [REPOSITORY]
# docker run [OPTIONS] IMAGE [COMMAND] [ARG...]

$completion_Docker = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    if ($global:DockerRootCommandList.Count -eq 0)
    {
        docker --help | % {
            if ($_ -match "^    (\w+)\s+(.+)")
            {
                $global:DockerRootCommandList += $Matches[1]
            }
            elseif ($_ -match "^  (-[^, =]+),? ?(--[^= ]+)?")
            {
                $global:DockerRootOptionsList += $Matches[1]
                if ($Matches[2].Success -eq $true)
                {
                    $dockerRootOptionsList += $Matches[2]
                }
            }
        }
    }
    $global:DockerRootCommandList | % { if ($_.StartsWith($commandName)) { New-Object System.Management.Automation.CompletionResult $_ } }
    $global:DockerRootOptionsList | % { if ($_.StartsWith($commandName)) { New-Object System.Management.Automation.CompletionResult $_ } }
}

if (-not $global:options) { $global:options = @{CustomArgumentCompleters = @{};NativeArgumentCompleters = @{}}}
$global:options['NativeArgumentCompleters']['docker'] = $Completion_Docker

$function:tabexpansion2 = $function:tabexpansion2 -replace 'End\r\n{','End { if ($null -ne $options) { $options += $global:options} else {$options = $global:options}'