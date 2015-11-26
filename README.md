# posh-docker
Powershell tab completion for Docker

## Commands and options
All commands (start, stop, run, ...) and their options (--attach, --cpuset-mems, ...) are autocompleted.

![Command and option completion](img/command-option-completion.gif)

## Container names
Container names can be autocompleted. Type a command requiring a containername, press `<TAB>` and the name will be completed.

![Container name completion](img/containername-completion.gif)

# Installation (manual)
Installation is done by performing the following steps.

1. Open a powershell prompt
2. Verify you have PowerShell 3.0 or later with `$PSVersionTable.PSVersion`.
3. Verify execution of scripts is allowed with `Get-ExecutionPolicy` (should be `RemoteSigned` or `Unrestricted`). If scripts are not enabled, run PowerShell as Administrator and call `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm`.
4. Verify that docker can be run from PowerShell. If the command is not found, you will need to add a docker alias or add the docker installation folder (e.g. `%ProgramFiles%\Docker Toolbox`) to your PATH environment variable.
5. Clone the posh-docker repository to your local machine.
6. Run `.\install.ps1`
7. posh-docker is now installed, type docker `<TAB>` to see it in action!

Once installed, the docker autocomplete will always work in a powershell session.


## Credits
The install script and this readme, along with the general idea, are based on work by the posh-git team.