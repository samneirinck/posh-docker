. $PSScriptRoot\utils.ps1

if ((IsInPath "docker") -eq $false) {
    Write-Warning "docker command could not be found. Please make sure docker is installed correctly."
}

$globalBooleanOptions = @('--debug', '-D', '--tls', '--tlsverify')
$globalOptionsWithArgs = @('--config', '--host', '-H', '--log-level', '-l', '--tlscacert', '--tlscert', '--tlskey')
$currentWord = ''
$previousWord = ''

$dockerCommands = @('attach', 'build', 'commit', 'cp', 'create', 'deploy', 'diff', 'events', 'exec',
    'export', 'history', 'images', 'import', 'info', 'inspect', 'kill', 'load', 'login',
    'logout', 'logs', 'pause', 'port', 'ps', 'pull', 'push', 'rename', 'restart', 'rm',
    'rmi', 'run', 'save', 'search', 'start', 'stats', 'stop', 'tag', 'top', 'unpause',
    'update', 'version', 'wait')

$dockerManagementCommands = @{
    'checkpoint' = @('create', 'ls', 'rm')
    'config'     = @('create', 'inspect', 'ls', 'rm')
    'container'  = @('attach', 'commit', 'cp', 'create', 'diff', 'exec', 'export', 'inspect', 'kill', 'logs', 'ls', 'pause', 'port', 'prune', 'rename', 'restart', 'rm', 'run', 'start', 'stats', 'stop', 'top', 'unpause', 'update', 'wait')
    'image'      = @('build', 'history', 'import', 'inspect', 'load', 'ls', 'prune', 'pull', 'push', 'rm', 'save', 'tag')
    'network'    = @('connect', 'create', 'disconnect', 'inspect', 'ls', 'prune', 'rm')
    'node'       = @('demote', 'inspect', 'ls', 'promote', 'ps', 'rm', 'update')
    'plugin'     = @('create', 'disable', 'enable', 'inspect', 'install', 'ls', 'push', 'rm', 'set', 'upgrade')
    'secret'     = @('create', 'inspect', 'ls', 'rm')
    'service'    = @('create', 'inspect', 'logs', 'ls', 'ps', 'rm', 'rollback', 'scale', 'update')
    'stack'      = @('deploy', 'ls', 'ps', 'rm', 'services')
    'swarm'      = @('ca', 'init', 'join', 'join-token', 'leave', 'unlock', 'unlock-key', 'update')
    'system'     = @('df', 'events', 'info', 'prune')
    'trust'      = @('key generate', 'key load', 'inspect', 'revoke', 'sign', 'view')
    'volume'     = @('create', 'inspect', 'ls', 'prune', 'rm')
}

$dockerShortOptions = @{
    ''        = @('D', 'H', 'l', 'v')
    'build'   = @('c', 'f', 'm', 'q', 't')
    'commit'  = @('a', 'c', 'm', 'p')
    'cp'      = @('a', 'L')
    'create'  = @('a', 'c', 'e', 'h', 'i', 'l', 'm', 'p', 'P', 't', 'u', 'v', 'w')
    'deploy'  = @('c')
    'events'  = @('f')
    'exec'    = @('d', 'e', 'i', 't', 'u')
    'export'  = @('o')
    'history' = @('H', 'q')
    'images'  = @('a', 'f', 'q')
    'import'  = @('c', 'm')
    'info'    = @('f')
    'inspect' = @('f', 's')
    'kill'    = @('s')
    'load'    = @('i', 'q')
    'login'   = @('p', 'u')
    'logs'    = @('f', 't')
    'pause'   = @()
    'port'    = @()
    'ps'      = @('a', 'f', 'n', 'l', 'q', 's')
    'pull'    = @('a')
    'push'    = @()
    'rename'  = @()
    'restart' = @('time')
    'rm'      = @('f', 'l', 'v')
    'rmi'     = @('f')
    'run'     = @()
    'save'    = @('o')
    'search'  = @('f')
    'start'   = @('a', 'i')
    'stats'   = @('a')
    'stop'    = @('t')
    'tag'     = @()
    'top'     = @()
    'unpause' = @()
    'update'  = @('c', 'm')
    'version' = @('f')
}

$dockerLongOptions = @{
    ''        = @('config', 'debug', 'host', 'log-level', 'tls', 'tlscacert', 'tlscert', 'tlskey', 'tlsverify', 'version')
    'attach'  = @('detach-keys', 'no-stdin', 'sig-proxy')
    'build'   = @('add-host', 'build-arg', 'cache-from', 'cgroup-parent', 'compress', 'cpu-period', 'cpu-quota', 
        'cpu-shares', 'cpuset-cpus', 'cpuset-mems', 'disable-content-trust', 'file', 'force-rm', 'iidfile', 'isolation', 
        'label', 'memory', 'memory-swap', 'network', 'no-cache', 'pull', 'quiet', 'rm', 'security-opt', 'shm-size', 
        'squash', 'stream', 'tag', 'target', 'ulimit')
    'commit'  = @('author', 'change', 'message', 'pause')
    'cp'      = @('archive', 'follow-link')
    'create'  = @('add-host', 'attach', 'blkio-weight', 'blkio-weight-device', 'cap-add', 'cap-drop', 'cgroup-parent', 'cidfile',
        'cpu-count', 'cpu-percent', 'cpu-period', 'cpu-quota', 'cpu-rt-period', 'cpu-rt-runtime', 'cpu-shares', 'cpus',
        'cpuset-cpus', 'cpuset-mems', 'device', 'device-cgroup-rule', 'device-read-bps', 'device-read-iops',
        'device-write-bps', 'device-write-iops', 'disable-content-trust', 'dns', 'dns-option', 'dns-search', 'entrypoint',
        'env', 'env-file', 'expose', 'group-add', 'health-cmd', 'health-interval', 'health-retries', 'health-start-period',
        'health-timeout', 'help', 'hostname', 'init', 'interactive', 'io-maxbandwidth', 'io-maxiops', 'ip', 'ip6', 'ipc',
        'isolation', 'kernel-memory', 'label', 'label-file', 'link', 'link-local-ip', 'log-driver', 'log-opt', 'mac-address',
        'memory', 'memory-reservation', 'memory-swap', 'memory-swappiness', 'mount', 'name', 'network', 'network-alias',
        'no-healthcheck', 'oom-kill-disable', 'oom-score-adj', 'pid', 'pids-limit', 'privileged', 'publish', 'publish-all',
        'read-only', 'restart', 'rm', 'runtime', 'security-opt', 'shm-size', 'stop-signal', 'stop-timeout', 'storage-opt',
        'sysctl', 'tmpfs', 'tty', 'ulimit', 'user', 'userns', 'uts', 'volume', 'volume-driver', 'volumes-from', 'workdir')
    'deploy'  = @('bundle-file', 'compose-file', 'prune', 'resolve-image', 'with-registry-auth')
    'events'  = @('filter', 'format', 'since', 'until')
    'exec'    = @('detach', 'detach-keys', 'env', 'interactive', 'privileged', 'tty', 'user')
    'export'  = @('output')
    'history' = @('format', 'human', 'no-trunc', 'quiet')
    'images'  = @('all', 'digests', 'filter', 'format', 'no-trunc', 'quiet')
    'import'  = @('change', 'message')
    'info'    = @('format')
    'inspect' = @('format', 'size', 'type')
    'kill'    = @('signal')
    'load'    = @('input', 'quiet')
    'login'   = @('password', 'password-stdin', 'username')
    'logs'    = @('details', 'follow', 'since', 'tail', 'timestamps')
    'pause'   = @()
    'port'    = @()
    'ps'      = @('all', 'filter', 'format', 'last', 'latest', 'no-trunc', 'quiet', 'size')
    'pull'    = @('all-tags', 'disable-content-trust')
    'push'    = @('disable-content-trust')
    'rename'  = @()
    'restart' = @('time')
    'rm'      = @('force', 'link', 'volumes')
    'rmi'     = @('force', 'no-prune')
    'run'     = @('TODO')
    'save'    = @('output')
    'search'  = @('filter', 'format', 'limit', 'no-trunc')
    'start'   = @('attach', 'checkpoint', 'checkpoint-dir', 'detach-keys', 'interactive')
    'stats'   = @('all', 'format', 'no-stream', 'no-trunc')
    'stop'    = @('t')
    'tag'     = @()
    'top'     = @()
    'unpause' = @()
    'update'  = @('blkio-weight', 'cpu-period', 'cpu-quota', 'cpu-rt-period', 'cpu-rt-runtime', 'cpu-shares',
        'cpus', 'cpuset-cpus', 'cpuset-mems', 'kernel-memory', 'memory', 'memory-reservation',
        'memory-swap', 'restart')
    'version' = @('format')
}

foreach ($key in $($dockerLongOptions.Keys)) {
    $dockerLongOptions[$key] += "help"
}

$longDockerOptionsValues = @{
    '' = @{
        'log-level' = @('debug', 'info', 'warn', 'error', 'fatal')
    }
}

$dockerAllCommands = $dockerCommands + $dockerManagementCommands.Keys

function Script:Get-DockerCommands($filter) {
    $dockerAllCommands | Where-Object { $_ -like "$filter*" } | Sort-Object
}

function Script:Get-DockerMgmtCommands($MgmtCommandName = '', $CommandName = '') {
    $dockerManagementCommands[$MgmtCommandName] | Where-Object { $_ -like "$CommandName*" } | Sort-Object
}

function Script:Get-DockerShortOptions($CommandName = '', $Filter = '') {
    $dockerShortOptions[$CommandName] | Where-Object { $_ -like "$filter*" } | Sort-Object | ForEach-Object { -join ("-", $_) }
}

function Script:Get-DockerLongOptions($CommandName = '', $Filter = '') {
    $dockerLongOptions[$CommandName] | Where-Object { $_ -like "$Filter*" } | Sort-Object | ForEach-Object { -join ("--", $_) }
}

function Script:Get-DockerFiltersForCommand($CommandName = '') {
    $filters = @()
    switch ($CommandName) {
        "rm" { $filters = @('status=created', 'status=exited') }
        { @("checkpoint", "attach", "exec", "kill", "pause", "run", "stats", "stop", "top", "network connect") -contains $_ } { $filters = @("status=running") }
        "start" { $filters = @("status=exited") }
        "unpause" { $filters = @("status=paused") }
    }
    return $filters
}


function Script:Get-DockerContainers($CommandName = '', $Filter = '') {
    $dockerFilters = Get-DockerFiltersForCommand -CommandName $CommandName

    if ($dockerFilters.Length -eq 0) {
        $names = docker ps -a --no-trunc --format "{{.Names}}"
    }
    else {
        $names = docker ps -a --no-trunc --format "{{.Names}}" ($dockerFilters | ForEach-Object { "--filter", $_ })
    }

    $names | Where-Object { $_ -like "$Filter*" } | Sort-Object
}

function Script:Complete-Docker-Docker() {
    $options = $globalBooleanOptions + ('--help', '--version', '-v')

    switch ($previousWord) {
        "--config" { return }
        { @("--log-level", '') -contains $_ } {}
    }

    if ($currentWord.StartsWith("-"))
    {
        return $options + $globalOptionsWithArgs | Where-Object { $_ -like "$currentWord*" } | Sort-Object
    }

    return @('attach', 'build', 'commit', 'cp', 'create', 'deploy', 'diff', 'events', 'exec',
    'export', 'history', 'images', 'import', 'info', 'inspect', 'kill', 'load', 'login',
    'logout', 'logs', 'pause', 'port', 'ps', 'pull', 'push', 'rename', 'restart', 'rm',
    'rmi', 'run', 'save', 'search', 'start', 'stats', 'stop', 'tag', 'top', 'unpause',
    'update', 'version', 'wait') | Where-Object { $_ -like "$currentWord*" } | Sort-Object
}

function Script:Complete-Docker-Network-Connect() {

}

function Script:Get-ExpandCommands($command, $option, $value) {
    $longDockerOptionsValues[$command][$option] | Where-Object { $_ -like "$value*" }
}

function Get-DockerCompletion($inputString) {
    $words = $inputString.Split(' ')
    $command = "docker"

    $currentWord = $words[$words.Length-1]
    $previousWord = $words[$words.Length-2]
    for ($i = 1; $i -lt $words.Length; $i++) {
        $word = $words[$i]
        if ($globalOptionsWithArgs -ccontains $word) {
            $i++
            continue
        }

        if ($word.StartsWith("-") -or [string]::IsNullOrWhitespace($word)) {
            continue
        }
        $command = $word
        break
    }

    Invoke-Expression "Complete-Docker-$command"

    # switch -regex ($inputString -replace "docker ", "") {

    #     # docker <command>
    #     "^(?<command>\S*)$" {
    #         Get-DockerCommands $Matches['command']
    #     }

    #     # docker <command> --<option>
    #     "^(?<command>$($dockerLongOptions.Keys -join '|'))\s+--(?<option>\S*)$" {
    #         Get-DockerLongOptions -CommandName $Matches['command'] -Filter $Matches['option']
    #     }
 
    #     # docker <command> -<option>
    #     "^(?<command>$($dockerShortOptions.Keys -join '|'))\s+-(?<option>\S*)$" {
    #         Get-DockerShortOptions -CommandName $Matches['command'] -Filter $Matches['option']
    #     }
        
    #     # docker <mgmtcmd>
    #     "^(?<mgmtcommand>$($dockerManagementCommands.Keys -join '|'))\s+(?<command>\S*)$" {
    #         Get-DockerMgmtCommands -MgmtCommandName $Matches['mgmtcommand'] -CommandName $Matches['command']
    #     }

    #     # docker --<option> <value>
    #     "--(?<option>\S*) (?<value>\S*)$" {
    #         Get-ExpandCommands '' $Matches['option'] $Matches['value']
    #     }
            
    #     # docker <--option>
    #     "^(--.*)*--(?<option>\S*)$" {
    #         Get-DockerLongOptions -Filter $Matches['option']
    #     }

    #     # docker <-option>
    #     "^(-.*)*-(?<option>\S*)$" {
    #         Get-DockerShortOptions -Filter $Matches['option']
    #     }

    #     # docker <cmd> CONTAINER
    #     # .*\s(\S*)
    #     "^(?<command>attach|commit|diff|exec|export|kill|logs|pause|port|rename|restart|rm|start|stats|stop|top|unpause|update|wait).*\s(?<containerName>\S*)$" {
    #         Get-DockerContainers -CommandName $Matches['command'] -Filter $Matches['containerName']
    #     }
    # }
}
