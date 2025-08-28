{
  config,
  pkgs,
  var,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  system = {
    stateVersion = "25.05";

    autoUpgrade = {
      enable = true;
      flake = inputs.self.outPath;
      flags = [ ];
      dates = "12:00";
      randomizedDelaySec = "45min";
      allowReboot = false;
    };
  };

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnsupportedSystem = false;
    };
  };

  boot = {
    loader = {
      efi.efiSysMountPoint = "/boot";
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [
      "r8125"
      "e1000e"
      "snd_hda_intel"
      "snd_soc_skl"
      "snd_usb_audio"
      "snd_pcm"
    ];
  };

  networking = {
    hostName = var.hostname;
    networkmanager.enable = true;

    # https://nixos.wiki/wiki/Firewall
    firewall.enable = true; # This will make all local ports and services unreachable from external connections.
  };

  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_GB.UTF-8";

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

  services = {
    clamav = {
      daemon.enable = true;
      updater.enable = true;
    };

    xserver = {
      # Keymap
      xkb = {
        layout = "za";
        variant = "";
      };
      enable = true;
      videoDrivers = [ "nvidia" ];
    };

    # Required for password manager
    gnome.gnome-keyring.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable automatic login for the user.
    displayManager = {
      sddm.enable = true;
      autoLogin.enable = true;
      autoLogin.user = "christan";
    };

    # Sound
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
  };

  users.users."${var.username}" = {
    isNormalUser = true;
    description = "${var.username}";
    extraGroups = [
      "networkmanager"
      "wheel"
      #"docker" # Opt for running rootless
      "audio"
      "video"
      "input"
    ];
    shell = pkgs.zsh;
  };

  # Security
  security = {
    sudo.wheelNeedsPassword = true;
    apparmor.enable = true;
    audit.enable = true;
    sudo = {
      enable = true;
      extraConfig = ''
        %wheel ALL=(ALL) NOPASSWD: ALL
      '';
    };
    rtkit.enable = true;
  };

  systemd = {
    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    services."getty@tty1".enable = false;
    services."autovt@tty1".enable = false;
    tmpfiles.rules = [
      "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
    ];
  };

  programs = {
    firefox.enable = true;
    sway.enable = false;

    hyprland = {
      enable = true;
      withUWSM = false;
      xwayland.enable = true;
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "${var.username}" ];
    };

    # Hyprland themes workaround
    dconf.profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          gtk-theme = "Adwaita-dark";
          icon-theme = "Flat-Remix-Red-Dark";
          font-name = "Noto Sans Medium 11";
          document-font-name = "Noto Sans Medium 11";
          monospace-font-name = "Noto Sans Mono Medium 11";
        };
      }
    ];

    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        theme = "agnoster";
        plugins = [
          "git"
          "z"
          "history"
          "sudo"
          "docker"
          "docker-compose"
          "aws"
          "azure"
          "argocd"
          "kubectl"
          "kubectx"
          "pip"
          "ssh"
          "terraform"
          "fzf"
        ];
      };

      # Persist ENV vars accross terminal instances
      shellInit = ''
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        AWS_SECRETS_FILE="$HOME/.config/secrets/awsenv"
        awsctx() {
            local profile

            # Create secrets directory if it doesn't exist
            mkdir -p "$(dirname "$AWS_SECRETS_FILE")"

            # Get profile selection
            profile=$(sed -n "s/\[profile \(.*\)\]/\1/gp" ~/.aws/config | fzf)

            if [ -n "$profile" ]; then
                # Export for current session
                export AWS_PROFILE="$profile"

                # Get credentials and export them
                local creds=$(aws configure export-credentials --profile "$profile" --format env)
                if [ $? -eq 0 ]; then
                    eval "$creds"
                fi

                # Update secrets file for persistence
                if [ -f "$AWS_SECRETS_FILE" ]; then
                    # Remove existing AWS lines
                    sed -i '/^export AWS_/d' "$AWS_SECRETS_FILE"
                else
                    touch "$AWS_SECRETS_FILE"
                    chmod 600 "$AWS_SECRETS_FILE"
                fi

                # Add AWS_PROFILE line
                echo "export AWS_PROFILE=\"$profile\"" >> "$AWS_SECRETS_FILE"
                
                # Add credential environment variables to secrets file
                if [ -n "$creds" ]; then
                    echo "$creds" >> "$AWS_SECRETS_FILE"
                fi
            else
                echo "No profile selected"
            fi
        }

        ONEPASS_SECRETS_FILE="$HOME/.config/secrets/onepassenv"
        oplogin() {
            local session_token
            local account_id

            # Create secrets directory if it doesn't exist
            mkdir -p "$(dirname "$ONEPASS_SECRETS_FILE")"

            echo "Signing in to 1Password..."
            session_token=$(op signin --raw)
            if [ -n "$session_token" ]; then
                # Get the account ID dynamically
                account_id=$(op account list --format=json | jq -r '.[0].user_uuid' 2>/dev/null)

                if [ -z "$account_id" ]; then
                    echo "Warning: Could not determine account ID, using generic session variable"
                    account_id="default"
                fi

                local session_var="OP_SESSION_$account_id"

                # Export for current session
                export "$session_var=$session_token"

                # Update secrets file for persistence
                if [ -f "$ONEPASS_SECRETS_FILE" ]; then
                    # Remove any existing OP_SESSION_* variables
                    sed -i '/^export OP_SESSION_.*=/d' "$ONEPASS_SECRETS_FILE"
                else
                    touch "$ONEPASS_SECRETS_FILE"
                    chmod 600 "$ONEPASS_SECRETS_FILE"
                fi

                echo "export $session_var=\"$session_token\"" >> "$ONEPASS_SECRETS_FILE"

                # Load env vars from ONEPASS
                if [ -f "$HOME/.config/secrets/env" ]; then
                    source "$HOME/.config/secrets/env"
                fi

                echo "✅ Signed in to 1Password (session: $session_var)"
            else
                echo "❌ Failed to sign in to 1Password"
                return 1
            fi
        }
      '';

      # Source secrets file on every shell initialization
      interactiveShellInit = ''
        if [ -f "$HOME/.config/secrets/awsenv" ]; then
            source "$HOME/.config/secrets/awsenv"
        fi

        if [ -f "$HOME/.config/secrets/onepassenv" ]; then
            source "$HOME/.config/secrets/onepassenv"
        fi

        # Source Other env vars - manually add these (only if 1Password CLI is logged in)
        if op whoami >/dev/null 2>&1 && [ -f "$HOME/.config/secrets/env" ]; then
          source "$HOME/.config/secrets/env"
        fi
      '';
    };
  };

  # Hyprland
  # https://wiki.nixos.org/wiki/Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    configPackages = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  environment = {
    sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };

    variables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      EDITOR = "nvim";
    };

    etc."zshrc".text = ''
      eval "$(starship init zsh)"
      alias kc='kubectl'
      alias kctx='kubectx'
      alias kns='kubens'
      alias tf='terraform'
      alias tg='terragrunt'
      vi() { if [ $# -eq 0 ]; then nvim .; else nvim "$@"; fi; }
      alias ll='ls -alF'
      alias la='ls -A'
      alias l='ls -CF'
      alias lg=lazygit
      alias kcgp='kc get pods -l app.kubernetes.io/instance='
      alias kcgd='kc get deploy -l app.kubernetes.io/instance='
      alias kctp='kc top pods --containers -l app.kubernetes.io/instance='
      alias azlogin='az login'
      alias awslogin='aws sso login'
      alias awsconfigure='aws configure sso --profile '
      alias awssso='aws configure sso-session'
      alias show='fastfetch'
      alias nix-shell'nix-shell --run zsh'
      alias nixs='nix-shell --run zsh'
      alias nixr='sudo nixos-rebuild switch'
      alias nixb='nixos-rebuild build'

      # Fix for ollama for neovim
      export XDG_RUNTIME_DIR="/tmp/"

      # Fix for D-Bus session for systemctl --user
      export XDG_RUNTIME_DIR="/run/user/$(id -u)"

      export EDITOR="nvim"
      export KUBE_CONFIG_PATH=~/.kube/config
      export STARSHIP_CONFIG=~/.config/starship-config/starship.toml

      # Disabling paging by default
      export PAGER=cat
      export LESS=

      cat << EOF > ~/.zshrc
      ZSH_HIGHLIGHT_STYLES[comment]='fg=8'                # gray
      ZSH_HIGHLIGHT_STYLES[command]='fg=#769ff0'
      ZSH_HIGHLIGHT_STYLES[alias]='fg=#769ff0'
      ZSH_HIGHLIGHT_STYLES[function]='fg=#769ff0'
      ZSH_HIGHLIGHT_STYLES[builtin]='fg=#769ff0'
      ZSH_HIGHLIGHT_STYLES[globbing]='fg=red'
      ZSH_HIGHLIGHT_STYLES[path]='fg=white'
      EOF
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

  hardware = {
    graphics = {
      enable = true;
    };
    nvidia-container-toolkit = {
      enable = true;
      mount-nvidia-executables = false;
    };
    nvidia = {
      open = true;
      modesetting.enable = true;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
