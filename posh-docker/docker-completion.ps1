. $PSScriptRoot\utils.ps1

if ((IsInPath "docker") -eq $false) {
    Write-Warning "docker command could not be found. Please make sure docker is installed correctly."
}

$dockerCommands = @('attach','build','commit','cp','create','deploy','diff','events','exec',
              'export','history','images','import','info','inspect','kill','load','login',
              'logout','logs','pause','port','ps','pull','push','rename','restart','rm',
              'rmi','run','save','search','start','stats','stop','tag','top','unpause',
              'update','version','wait')

$dockerManagementCommands = @('checkpoint','config','container','image','network','node',
                        'plugin','secret','service','stack','swarm','system','trust',
                        'volume')

$dockerOptions = @('config','debug','host','log-level','tls','tlscacert','tlscert','tlskey','tlsverify','version')

$dockerOptionsValues = @{
    '' = @{
        'log-level' = @('debug','info','warn','error','fatal')
    }
}

$dockerAllCommands = $dockerCommands + $dockerManagementCommands

function Invoke-Docker() {
    & "docker.exe" $args
}

function Script:Get-DockerCommands($filter)
{
    $dockerAllCommands | Where-Object { $_ -like "$filter*" } | Sort-Object
}

function Script:Get-DockerOptions($filter)
{
    "Get the options!" > c:\temp\test11.txt
    $dockerOptions | Where-Object { $_ -like "$filter*" } | Sort-Object | ForEach-Object { -join ("--", $_) }
}

function Script:Get-DockerContainers($nameFilter, $filter)
{
    if ($filter -eq $null)
    {
       $names = Invoke-Docker ps -a --no-trunc --format "{{.Names}}"
    }
    else
    {
       $names = Invoke-Docker ps -a --no-trunc --format "{{.Names}}" ($filter | ForEach-Object { "--filter", $_ })
    }

    $names | Where-Object { $_ -like "$nameFilter*" } | Sort-Object
}

function Script:Get-ExpandCommands($command, $option, $value)
{
    $dockerOptionsValues[$command][$option] | Where-Object { $_ -like "$value*" }
}

function Get-DockerCompletion($inputString) {
    switch -regex ($inputString -replace "docker ","") {

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
            Get-DockerOptions $Matches['option']
        }

        # "^attach.* (?<container>\S*)$" {
        #     Get-DockerContainers $Matches['container']
        # }
    }
}
