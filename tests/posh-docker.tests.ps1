Import-Module -Force $PSScriptRoot\..\posh-docker\posh-docker.psm1


Describe "CompleteCommands" {
    Context "When there are commands" {

        $result = 5

        $result | Should Be 1.2
    }
}