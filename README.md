# nixos-config

NixOs Configuration for Desktop and WSL using dendritic pattern.

## Desktop Setup

Symlink configuration directory with /etc/nixos and run `sudo task switch`

## WSL Setup and Configure

My custom NixOs configuration for WSL

Make sure the following is installed for this quickstart.

- WSL version 2

### 1.Install NixOs

Download the WSL distribution for NixOS follow reference link below.

https://github.com/nix-community/NixOS-WSL/releases

Reference: https://nix-community.github.io/NixOS-WSL/install.html Packages:
https://search.nixos.org/packages

In Powershell run

- `wsl --update`
- `wsl --install --from-file nixos.wsl`
- `wsl -d NixOS`

### 2. Setup NixOs first install

- `sudo nix-channel --update && sudo nixos-rebuild switch`
- `nix-env -iA nixos.neovim` # Optional step if you want to rename wsl username
  & hostname (or use own editor preference)
- `nix-env -iA nixos.git && nix-env -iA nixos.go-task`

Clone the repo and edit variables in \_variables.nix if needed (change username
and hostname) Symlink configuration directory with /etc/nixos and run
`sudo nixos-rebuild boot --flake .` (Not switch as it may misconfigure on first
setup)

Alternatively run using the included Taskfile.

- `sudo task boot`

On first install restart NixOs WSL distro on powershell

- `wsl -t NixOs`

Start a shell inside NixOS and immediately exit it to apply the new generation

- `wsl -d NixOS --user root exit`

Stop distro again

- `wsl -t NixOs`

Then can open again with default username applied and can continue as normal

### 3. Set NixOs as default WSL Distro

In Powershell run

- `wsl -s NixOS`

### Notes

If you have changed the wsl default user you will need to reclone this in the
new users home folder.

Known unstable items I am still trying to resolve.

- Sometimes first time switch fails on new installs, rerunning resolves the
  issue.

See samples folder for configuration files for nix shell for dev environments

Nerdfonts is installed externally and added to windows terminal
