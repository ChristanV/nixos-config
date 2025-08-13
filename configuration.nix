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

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "25.05";

  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [ ];
    dates = "12:00";
    randomizedDelaySec = "45min";
    allowReboot = false;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = false;

  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [
    "r8125"
    "e1000e"
    "snd_hda_intel"
    "snd_soc_skl"
    "snd_usb_audio"
    "snd_pcm"
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = false;
    xwayland.enable = true;
  };

  networking.hostName = var.hostname;
  networking.networkmanager.enable = true;

  # https://nixos.wiki/wiki/Firewall
  networking.firewall.enable = true; # This will make all local ports and services unreachable from external connections.

  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_GB.UTF-8";

  fonts.packages = with pkgs; [
    nerd-fonts.hack
    nerd-fonts.symbols-only
  ];
  fonts.fontconfig = {
    defaultFonts = {
      monospace = [
        "Hack Nerd Font"
        "NerdFontsSymbolsOnly"
      ];
    };
  };

  # Keymap
  services.xserver.xkb = {
    layout = "za";
    variant = "";
  };

  # Required for password manager
  services.gnome.gnome-keyring.enable = true;

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  # services.desktopManager.plasma6.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "christan";

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
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
  security.sudo.wheelNeedsPassword = true;
  security.apparmor.enable = true;
  security.audit.enable = true;
  security.sudo = {
    enable = true;
    extraConfig = ''
      %wheel ALL=(ALL) NOPASSWD: ALL
    '';
  };
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  programs.firefox.enable = true;
  programs.sway.enable = false;

  # Hyprland themes workaround
  programs.dconf.profiles.user.databases = [
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

  programs.zsh = {
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
      ];
    };

    # Persist ENV vars accross terminal instances
    shellInit = ''
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
              
              # Update secrets file for persistence
              if [ -f "$AWS_SECRETS_FILE" ]; then
                  # Remove existing AWS_PROFILE line
                  sed -i '/^export AWS_PROFILE=/d' "$AWS_SECRETS_FILE"
              else
                  touch "$AWS_SECRETS_FILE"
                  chmod 600 "$AWS_SECRETS_FILE"
              fi
              
              # Add new AWS_PROFILE line
              echo "export AWS_PROFILE=\"$profile\"" >> "$AWS_SECRETS_FILE"
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

  systemd.tmpfiles.rules = [
    "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "${var.username}" ];
  };

  environment.variables.EDITOR = "nvim";
  environment.etc."zshrc".text = ''
    eval "$(starship init zsh)"
    alias kc='kubectl'
    alias kctx='kubectx'
    alias kns='kubens'
    alias tf='terraform'
    alias tg='terragrunt'
    alias vi='nvim .'
    alias nixr='sudo nixos-rebuild switch'
    alias nixb='nixos-rebuild build'
    alias nixs='nix-shell'
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
    alias lg=lazygit
    alias kcgp='kc get pods -l app.kubernetes.io/instance='
    alias kcgd='kc get deploy -l app.kubernetes.io/instance='
    alias kctp='kc top pods --containers -l app.kubernetes.io/instance='

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

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  environment.variables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
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
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
