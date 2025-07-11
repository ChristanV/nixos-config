{ config, pkgs, ... }:

let
  # unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  username = "christan";
  hostname = "nixos";
  grub-device = "/dev/nvme0n1";

  azure-cli = pkgs.azure-cli.withExtensions [
    pkgs.azure-cli-extensions.bastion
    pkgs.azure-cli-extensions.ssh
  ];

in
{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.05";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = false;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = grub-device;
  boot.loader.grub.useOSProber = true;

  networking.hostName = hostname;
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

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Enable KDE plasma
  # services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "christan";

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
  };

  users.users."${username}" = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
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

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Hyprland themes workaround
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        gtk-theme = "Adwaita";
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
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
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
    alias awsctx='export AWS_PROFILE=$(sed -n "s/\[profile \(.*\)\]/\1/gp" ~/.aws/config | fzf)'

    # Fix for ollama for neovim
    export XDG_RUNTIME_DIR="/tmp/"

    export EDITOR="nvim"
    export KUBE_CONFIG_PATH=~/.kube/config
    export STARSHIP_CONFIG=~/.config/starship-config/starship.toml

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

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  virtualisation.docker = {
    enable = true;
    daemon.settings.features.cdi = true;
    rootless = {
      enable = true;
      setSocketVariable = false;
      daemon.settings = {
        features.cdi = true;
        cdi-spec-dirs = [ "/home/${username}/.cdi" ];
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

  environment.systemPackages = with pkgs; [
    # Desktop apps
    brave
    chromium
    steam-run
    nordpass
    bruno
    dbeaver-bin
    vscode

    # Security
    clamav

    # Core Packages
    neovim
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
    flyctl
    sops
    gnupg
    k9s
    ssm-session-manager-plugin
    azure-cli
    awscli2
    docker_26
    docker-compose
    zsh
    steampipe
    fzf
    starship
    glow
    nvidia-container-toolkit
    btop
    plantuml
    graphviz

    # LSP's for neovim
    terraform-ls
    terraform-lsp
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

    # Development
    terraform
    terragrunt
    python312Full
    python312Packages.ansible-core
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

    # Terminals
    wezterm
    kitty

    # hyprland
    waybar
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    }))
    dunst
    libnotify
    swww
    rofi-wayland
    networkmanagerapplet
    wofi

    # Gaming
    wineWowPackages.stable
    winetricks
  ];
}
