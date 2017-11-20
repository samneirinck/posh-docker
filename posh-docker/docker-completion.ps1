. $PSScriptRoot\utils.ps1

if ((IsInPath "docker") -eq $false) {
    Write-Warning "docker command could not be found. Please make sure docker is installed correctly."
}

$dockerCommands = @('attach', 'build', 'commit', 'cp', 'create', 'deploy', 'diff', 'events', 'exec',
    'export', 'history', 'images', 'import', 'info', 'inspect', 'kill', 'load', 'login',
    'logout', 'logs', 'pause', 'port', 'ps', 'pull', 'push', 'rename', 'restart', 'rm',
    'rmi', 'run', 'save', 'search', 'start', 'stats', 'stop', 'tag', 'top', 'unpause',
    'update', 'version', 'wait')

$dockerManagementCommands = @('checkpoint', 'config', 'container', 'image', 'network', 'node',
    'plugin', 'secret', 'service', 'stack', 'swarm', 'system', 'trust',
    'volume')

$dockerShortOptions = @{
    ''       = @('D', 'H', 'l', 'v')
    'build'  = @('c', 'f', 'm', 'q', 't')
    'commit' = @('a', 'c', 'm', 'p')
}

$dockerLongOptions = @{
    ''       = @('config', 'debug', 'host', 'log-level', 'tls', 'tlscert', 'tlskey', 'tlsverify', 'version')
    'attach' = @('detach-keys', 'no-stdin', 'sig-proxyd')
    'build'  = @('add-host', 'build-arg', 'cache-from', 'cgroup-parent', 'compress', 'cpu-period', 'cpu-quota', 
        'cpu-shares', 'cpuset-cpus', 'cpuset-mems', 'disable-content-trust', 'file', 'force-rm', 'iidfile', 'isolation', 
        'label', 'memory', 'memory-swap', 'network', 'no-cache', 'pull', 'quiet', 'rm', 'security-opt', 'shm-size', 
        'squash', 'stream', 'tag', 'target', 'ulimit')
    'commit' = @('author', 'change', 'message', 'pause')
}

foreach ($key in $($dockerShortOptions.Keys)) {
    $dockerShortOptions[$key] += "h"
}

foreach ($key in $($dockerLongOptions.Keys)) {
    $dockerLongOptions[$key] += "help"
}

$longDockerOptionsValues = @{
    '' = @{
        'log-level' = @('debug', 'info', 'warn', 'error', 'fatal')
    }
}

$dockerAllCommands = $dockerCommands + $dockerManagementCommands

function Invoke-Docker() {
    & "docker.exe" $args
}

function Script:Get-DockerCommands($filter) {
    $dockerAllCommands | Where-Object { $_ -like "$filter*" } | Sort-Object
}

function Script:Get-DockerShortOptions($filter) {
    $dockerShortOptions[''] | Where-Object { $_ -like "$filter*" } | Sort-Object | ForEach-Object { -join ("-", $_) }
}

function Script:Get-DockerLongOptions($filter) {
    $dockerLongOptions[''] | Where-Object { $_ -like "$filter*" } | Sort-Object | ForEach-Object { -join ("--", $_) }
}

function Script:Get-DockerContainers($nameFilter, $filter) {
    if ($filter -eq $null) {
        $names = Invoke-Docker ps -a --no-trunc --format "{{.Names}}"
    }
    else {
        $names = Invoke-Docker ps -a --no-trunc --format "{{.Names}}" ($filter | ForEach-Object { "--filter", $_ })
    }

    $names | Where-Object { $_ -like "$nameFilter*" } | Sort-Object
}

function Script:Get-ExpandCommands($command, $option, $value) {
    $longDockerOptionsValues[$command][$option] | Where-Object { $_ -like "$value*" }
}

function Get-DockerCompletion($inputString) {
    switch -regex ($inputString -replace "docker ", "") {

        # Handles docker <command>
        "^(?<command>\S*)$" {
            Get-DockerCommands $Matches['command']
        }

        # Handles docker --<option> <value>
        "^.*--(?<option>\S*) (?<value>\S*)$" {
            Get-ExpandCommands '' $Matches['option'] $Matches['value']
        }
            
        # Handles docker <--option>
        "^.*--(?<option>\S*)$" {
            Get-DockerLongOptions $Matches['option']
        }

        # Handles docker <-option>
        "^[^-]*-(?<option>\S*)$" {
            Get-DockerShortOptions $Matches['option']
        }

        # "^attach.* (?<container>\S*)$" {
        #     Get-DockerContainers $Matches['container']
        # }
    }
}
