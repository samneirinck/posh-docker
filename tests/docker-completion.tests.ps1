. $PSScriptRoot\..\posh-docker\docker-completion.ps1

Describe "Docker Tab completion tests" {     
    Context "Simple docker commands" {      
        It "Tab completes normal commands"{
            $result = Get-DockerCompletion "docker "
            $result -contains "attach" | Should Be $true
            $result -contains "build" | Should Be $true
            $result -contains "wait" | Should Be $true
        }

        It "Tab completes management commands"{
            $result = Get-DockerCompletion "docker "
            $result -contains "container" | Should Be $true
            $result -contains "image" | Should Be $true
            $result -contains "volume" | Should Be $true
        }

        It "Tab completes commands with a filter"{
            $result = Get-DockerCompletion "docker t"
            $result -contains "tag" | Should Be $true
            $result -contains "top" | Should Be $true
            $result -contains "trust" | Should Be $true
            $result.Length | Should Be 3
        }

        It "Tab completes options"{
            $result = Get-DockerCompletion "docker --"
            $result -contains "--config" | Should Be $true
            $result -contains "--debug" | Should Be $true
            $result -contains "--tlscert" | Should Be $true
            $result -contains "--version" | Should Be $true
        }

        It "Tab completes multiple options"{
            $result = Get-DockerCompletion "docker --tlscert test --tls"
            $result -contains "--tls" | Should Be $true
            $result -contains "--tlscacert" | Should Be $true
            $result -contains "--tlscert" | Should Be $true
            $result -contains "--tlskey" | Should Be $true
            $result -contains "--tlsverify" | Should Be $true
        }


        It "Tab completes log-level"{
            $result = Get-DockerCompletion "docker --log-level "
            $result -contains "debug" | Should Be $true
            $result -contains "info" | Should Be $true
            $result -contains "warn" | Should Be $true
            $result -contains "error" | Should Be $true
            $result -contains "fatal" | Should Be $true
        }

    }
}