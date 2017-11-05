Import-Module -Force $PSScriptRoot\..\posh-docker\docker-completion.ps1

Describe "Get-CompletionForString" {
    Context "With test" {
        It "DockerCompletion hash table is filled in"{
            $Global:DockerCompletion.Count | Should BeGreaterThan 0
        }
    }
}