{ inputs, ... }:
{
  flake.nixosModules.baseConfig =
    {
      pkgs,
      var,
      ...
    }:
    {
      system = {
        stateVersion = "25.05";

        autoUpgrade = {
          enable = true;
          flake = inputs.self.outPath;
          flags = [ ];
          dates = "00:00";
          randomizedDelaySec = "45min";
          allowReboot = false;
        };
      };

      documentation = {
        # Tmp fix for python3.12
        doc.enable = false;
        man.enable = false;
        nixos.enable = false;
      };

      nix = {
        settings = {
          download-buffer-size = 524288000; # 500 MiB
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          ssl-cert-file = "/etc/ssl/certs/ca-bundle.crt";
        };

        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 10d";
        };
      };

      nixpkgs.config = {
        allowUnfree = true;
        allowUnsupportedSystem = false;
      };

      fonts = {
        packages = with pkgs; [
          nerd-fonts.hack
          nerd-fonts.symbols-only
        ];
        fontconfig = {
          defaultFonts = {
            monospace = [
              "Hack Nerd Font"
              "NerdFontsSymbolsOnly"
            ];
          };
        };
      };

      programs.nix-ld = {
        enable = true;
        package = pkgs.nix-ld;
        libraries = with pkgs; [ libxcrypt-legacy ];
      };

      programs.zsh = {
        enable = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
        ohMyZsh = {
          enable = true;
          theme = "agnoster";
          plugins = [
            # Version control
            "git"

            # Cloud & Platforms
            "docker"
            "docker-compose"
            "aws"
            "azure"
            "helm"
            "argocd"
            "kubectl"
            "kubectx"
            "ansible"
            "terraform"

            # Development
            "pip"
            "poetry"
            "python"
            "uv"
            "golang"
            "node"
            "dbt"
            "postgres"
            "virtualenv"

            # Navigation & Control
            "z"
            "history"
            "sudo"
            "ssh"
            "fzf"

            # Productivity
            "1password"
          ];
        };

        shellInit = ''
          source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
          if [ -d "$HOME/.config/zsh" ]; then
            export ZDOTDIR="$HOME/.config/zsh"
          fi
        '';
      };

      virtualisation.docker = {
        enable = true;
        daemon.settings.features.cdi = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
          daemon.settings = {
            features.cdi = true;
            cdi-spec-dirs = [ "/home/${var.username}/.cdi" ];
          };
        };
      };

      services.clamav = {
        daemon.enable = true;
        updater.enable = true;
      };

      security.apparmor.enable = true;

      users.users."${var.username}" = {
        isNormalUser = true;
        description = "${var.username}";
        shell = pkgs.zsh;
      };

      environment = {
        etc."ssl/cert.pem".source = "/etc/ssl/certs/ca-bundle.crt";

        variables = {
          EDITOR = "nvim";
          NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
          SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
        };
      };

      systemd.tmpfiles.rules = [
        "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
      ];
    };
}
