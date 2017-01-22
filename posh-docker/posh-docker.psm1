$global:DockerCompletion = @{}

$script:flagRegex = "^  (-[^, =]+),? ?(--[^= ]+)?"

function script:Get-Containers($filter)
{
    if ($filter -eq $null)
    {
       $names = docker ps -a --no-trunc --format "{{.Names}}"
    }
    else
    {
       $names = docker ps -a --no-trunc --format "{{.Names}}" ($filter | % { "--filter", $_ })
    }

    $names | %{ $_.Split(",") }
}

function script:Get-Images()
{
    docker images --no-trunc | ConvertFrom-Docker
}

function script:Get-AutoCompleteResult
{
    param([Parameter(ValueFromPipeline=$true)] $value)
    
    Process
    {
        New-Object System.Management.Automation.CompletionResult $value
    }
}

filter script:MatchingCommand($commandName)
{
    if ($_.StartsWith($commandName))
    {
        $_
    }
}

$completion_Docker = {
    param($commandName, $commandAst, $cursorPosition)

    $command = $null
    $commandParameters = @{}
    $state = "Unknown"
    $wordToComplete = $commandAst.CommandElements | Where-Object { $_.ToString() -eq $commandName } | Foreach-Object { $commandAst.CommandElements.IndexOf($_) }

    for ($i=1; $i -lt $commandAst.CommandElements.Count; $i++)
    {
        $p = $commandAst.CommandElements[$i].ToString()

        if ($p.StartsWith("-"))
        {
            if ($state -eq "Unknown" -or $state -eq "Options")
            {
                $commandParameters[$i] = "Option"
                $state = "Options"
            }
            else
            {
                $commandParameters[$i] = "CommandOption"
                $state = "CommandOptions"
            }
        } 
        else 
        {
            if ($state -ne "CommandOptions")
            {
                $commandParameters[$i] = "Command"
                $command = $p
                $state = "CommandOptions"
            } 
            else 
            {
                $commandParameters[$i] = "CommandOther"
            }
        }
    }

    if ($global:DockerCompletion.Count -eq 0)
    {
        $global:DockerCompletion["commands"] = @{}
        $global:DockerCompletion["options"] = @()
        
        docker --help | ForEach-Object {
            Write-Output $_
            if ($_ -match "^\s{2,3}(\w+)\s+(.+)")
            {
                $global:DockerCompletion["commands"][$Matches[1]] = @{}
                
                $currentCommand = $global:DockerCompletion["commands"][$Matches[1]]
                $currentCommand["options"] = @()
            }
            elseif ($_ -match $flagRegex)
            {
                $global:DockerCompletion["options"] += $Matches[1]
                if ($Matches[2] -ne $null)
                {
                    $global:DockerCompletion["options"] += $Matches[2]
                 }
            }
        }

    }
    
    if ($wordToComplete -eq $null)
    {
        $commandToComplete = "Command"
        if ($commandParameters.Count -gt 0)
        {
            if ($commandParameters[$commandParameters.Count] -eq "Command")
            {
                $commandToComplete = "CommandOther"
            }
        } 
    } else {
        $commandToComplete = $commandParameters[$wordToComplete]
    }

    switch ($commandToComplete)
    {
        "Command" { $global:DockerCompletion["commands"].Keys | MatchingCommand -Command $commandName | Sort-Object | Get-AutoCompleteResult }
        "Option" { $global:DockerCompletion["options"] | MatchingCommand -Command $commandName | Sort-Object | Get-AutoCompleteResult }
        "CommandOption" { 
            $options = $global:DockerCompletion["commands"][$command]["options"]
            if ($options.Count -eq 0)
            {
                docker $command --help | % {
                if ($_ -match $flagRegex)
                    {
                        $options += $Matches[1]
                        if ($Matches[2] -ne $null)
                        {
                            $options += $Matches[2]
                        }
                    }
                }
            }

            $global:DockerCompletion["commands"][$command]["options"] = $options
            $options | MatchingCommand -Command $commandName | Sort-Object | Get-AutoCompleteResult
        }
        "CommandOther" {
            $filter = $null
            switch ($command)
            {
                "start" { FilterContainers $commandName "status=created", "status=exited" }
                "stop" { FilterContainers $commandName "status=running" }
                { @("run", "rmi", "history", "push", "save", "tag") -contains $_ } { CompleteImages $commandName }
                default { FilterContainers $commandName }
            }
            
        }
        default { $global:DockerCompletion["commands"].Keys | MatchingCommand -Command $commandName }
    }
}

function script:FilterContainers($commandName, $filter)
{
    Get-Containers $filter | MatchingCommand -Command $commandName | Sort-Object | Get-AutoCompleteResult
}

function script:CompleteImages($commandName)
{
    if ($commandName.Contains(":"))
    {
        Get-Images | % { $_.Repository + ":" + $_.Tag } | MatchingCommand -Command $commandName | Sort-Object -Unique | Get-AutoCompleteResult
    } 
    else 
    {
        Get-Images | Select-Object -ExpandProperty Repository | MatchingCommand -Command $commandName |  Sort-Object -Unique | Get-AutoCompleteResult
    }
}

# Register the TabExpension2 function
if (-not $global:options) { $global:options = @{CustomArgumentCompleters = @{};NativeArgumentCompleters = @{}}}
$global:options['NativeArgumentCompleters']['docker'] = $Completion_Docker

$function:tabexpansion2 = $function:tabexpansion2 -replace 'End\r\n{','End { if ($null -ne $options) { $options += $global:options} else {$options = $global:options}'



function PascalName($name){
    $parts = $name.Split(" ")
    for($i = 0 ; $i -lt $parts.Length ; $i++){
        $parts[$i] = [char]::ToUpper($parts[$i][0]) + $parts[$i].SubString(1).ToLower();
    }
    $parts -join ""
}
function GetHeaderBreak($headerRow, $startPoint=0){
    $i = $startPoint
    while( $i + 1  -lt $headerRow.Length)
    {
        if ($headerRow[$i] -eq ' ' -and $headerRow[$i+1] -eq ' '){
            return $i
            break
        }
        $i += 1
    }
    return -1
}
function GetHeaderNonBreak($headerRow, $startPoint=0){
    $i = $startPoint
    while( $i + 1  -lt $headerRow.Length)
    {
        if ($headerRow[$i] -ne ' '){
            return $i
            break
        }
        $i += 1
    }
    return -1
}
function GetColumnInfo($headerRow){
    $lastIndex = 0
    $i = 0
    while ($i -lt $headerRow.Length){
        $i = GetHeaderBreak $headerRow $lastIndex
        if ($i -lt 0){
            $name = $headerRow.Substring($lastIndex)
            New-Object PSObject -Property @{ HeaderName = $name; Name = PascalName $name; Start=$lastIndex; End=-1}
            break
        } else {
            $name = $headerRow.Substring($lastIndex, $i-$lastIndex)
            $temp = $lastIndex
            $lastIndex = GetHeaderNonBreak $headerRow $i
            New-Object PSObject -Property @{ HeaderName = $name; Name = PascalName $name; Start=$temp; End=$lastIndex}
       }
    }
}
function ParseRow($row, $columnInfo) {
    $values = @{}
    $columnInfo | ForEach-Object {
        if ($_.End -lt 0) {
            $len = $row.Length - $_.Start
        } else {
            $len = $_.End - $_.Start
        }
        $values[$_.Name] = $row.SubString($_.Start, $len).Trim()
    }
    New-Object PSObject -Property $values
}

<#
.SYNOPSIS

Converts from docker output to objects
.DESCRIPTION

Converts from docker tabular output to objects that can be worked with in a familiar way in PowerShell

.EXAMPLE
Get the running containers and 

docker ps -a --no-trunc | ConvertFrom-Docker | ft
#>
function ConvertFrom-Docker{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,
		ValueFromPipeline=$True)]
		[object[]]$items
    )
    
    begin{
        $positions = $null;
    }
    process {
        foreach ($item in $items)
        {
            if($null -eq $positions) {
                # header row => determine column positions
                $positions  = GetColumnInfo -headerRow $item
            } else {
                # data row => output!
                ParseRow -row $item -columnInfo $positions
            }
        }
    }
    end {
    }
}
