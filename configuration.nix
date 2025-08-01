{ config, pkgs, ... }:

let
  # unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  userName = "christan";
  hostName = "nixos";

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

  system.autoUpgrade = {
    enable = true;
    flags = [];
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

  boot.loader.systemd-boot.enable = true;
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

  networking.hostName = hostName;
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

  users.users."${userName}" = {
    isNormalUser = true;
    description = "${userName}";
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
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
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
        cdi-spec-dirs = [ "/home/${userName}/.cdi" ];
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
    google-chrome
    steam-run
    nordpass
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
    chromedriver

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
  ];
}
