Import-Module -Force $PSScriptRoot\..\posh-docker\posh-docker.psm1

Describe "Initialization" {
    Context "When module is loaded" {
        It "DockerCompletion hash table is filled in"{
            $Global:DockerCompletion.Count | Should BeGreaterThan 0
        }
    }
}

Describe "CompleteCommands" {
    Context "When docker command is typed" {

        $result = CompleteCommand "docker [ ]"

        It "Can complete" {
            $result.Count | Should BeGreaterThan 0
        }
       
        It "Completes core commands" {
            $result -contains "ps" | Should Be $true
            $result -contains "pull" | Should Be $true
            $result -contains "wait" | Should Be $true
            $result -contains "attach" | Should Be $true
        }

        It "Completes options" {
            $result -contains "--version" | Should Be $true
        }

        It "Completes management commands" {
            $result -contains "config" | Should Be $true
            $result -contains "system" | Should Be $true
        }
    }
}