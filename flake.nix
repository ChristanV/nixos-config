# https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
{
  description = "A SecureBoot-enabled NixOS configurations and always updated packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      lanzaboote,
      ...
    }@inputs:
    let
      var = import ./var.nix;
    in
    {
      nixosConfigurations."${var.hostname}" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          { nix.registry.nixpkgs.flake = nixpkgs; }
          lanzaboote.nixosModules.lanzaboote
          ./configuration.nix
          ./hardware-configuration.nix
          (
            {
              config,
              pkgs,
              lib,
              ...
            }:
            let
              # unstable prefix in systemPackages to use unstable package instead.
              unstable = import nixpkgs-unstable {
                inherit (config.nixpkgs) system;
                inherit (config.nixpkgs) config;
              };
            in
            {
              _module.args = { inherit var; };

              boot.loader.systemd-boot.enable = lib.mkForce false;
              boot.lanzaboote = {
                enable = true;
                pkiBundle = "/var/lib/sbctl";
              };

              environment.systemPackages = with pkgs; [
                # Boot
                sbctl

                # Desktop apps
                google-chrome
                steam-run
                bruno
                dbeaver-bin
                vscode
                nemo # Filemanager
                nwg-look # Themes
                pavucontrol # Sound Control
                vlc
                teams-for-linux

                # Security
                clamav
                clamtk
                unstable._1password-gui
                unstable._1password-cli
                sbctl

                # Storage Viewer
                baobab

                # Core Packages
                neovim
                vimPlugins.packer-nvim
                gnumake
                busybox
                wget
                stern
                jq
                yq
                kubernetes-helm
                openssl
                go-task
                virtualenv
                kubectl
                kubectx
                kubelogin
                git
                postgresql
                eksctl
                lazygit
                fd
                ripgrep
                zoxide
                flyctl
                sops
                gnupg
                k9s
                ssm-session-manager-plugin
                (azure-cli.withExtensions [
                  pkgs.azure-cli-extensions.bastion
                  pkgs.azure-cli-extensions.ssh
                ])
                awscli2
                docker_28
                docker-compose
                zsh
                zsh-fzf-tab
                steampipe
                fzf
                starship
                glow
                nvidia-container-toolkit
                btop-cuda
                plantuml
                graphviz
                fastfetch
                ethtool
                kustomize

                # Required for password manager
                gnome-keyring
                libsecret
                # GNOME webcam viewer
                cheese

                # LSP's for neovim
                terraform-ls
                tflint
                yaml-language-server
                ansible-language-server
                ansible-lint
                lua-language-server
                nodePackages.typescript-language-server
                nodePackages.bash-language-server
                jdt-language-server
                postgres-lsp
                dockerfile-language-server-nodejs
                pyright
                gopls
                nodePackages.typescript-language-server
                helm-ls
                nixd

                # Linters and checkers
                statix
                deadnix

                # Development
                terraform
                terragrunt
                python313
                poetry
                go
                nodejs_22
                typescript
                lua
                yarn
                k3s
                minikube
                jdk23
                nixfmt-rfc-style
                gitleaks
                chromedriver
                pre-commit
                unstable.trunk-io
                tfsec
                terraform-docs
                tfupdate
                terrascan
                unstable.claude-code
                gemini-cli
                gh

                # Terminals
                wezterm
                kitty

                # hyprland
                waybar # Info bar app
                (pkgs.waybar.overrideAttrs (oldAttrs: {
                  mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
                }))
                dunst # Notification daemon
                libnotify
                swww # Wallpapaer
                rofi-wayland
                networkmanagerapplet
                hyprpolkitagent # Authentication daemon
                hyprlock
                kdePackages.qt6ct
                gsettings-desktop-schemas

                # Gaming
                wineWowPackages.stable
                winetricks

                # Other
                vdhcoapp
              ];
            }
          )
        ];
      };
    };
}
