# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Johannesburg";

  # Select internationalisation properties.
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
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Enable KDE plasma
  # services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;

  programs.sway.enable = false;
  services.xserver.videoDrivers = [ "nvidia" ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "za";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.christan = {
    isNormalUser = true;
    description = "christan";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "audio"
      "video"
      "input"
    ];
    shell = pkgs.zsh;
    # packages = with pkgs; [
    # ];
  };

  security.sudo.wheelNeedsPassword = true;
  security.apparmor.enable = true;
  security.audit.enable = true;
  security.sudo = {
    enable = true;
    extraConfig = ''
      %wheel ALL=(ALL) NOPASSWD: ALL
    '';
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "christan";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Install firefox.
  programs.firefox.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    brave
    chromium
    vim
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
    chromium
    flyctl
    sops
    gnupg
    k9s
    ssm-session-manager-plugin
    azure-cli
    awscli2
    docker_26
    docker-compose

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

    # Other
    starship
    zsh
    glow
    nvidia-container-toolkit
    steampipe
    tmux
    btop
    fzf
    plantuml
    graphviz

    # hyprland
    waybar
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    }))
    dunst
    libnotify
    kitty
    swww
    #alacritty
    rofi-wayland
    networkmanagerapplet
    wofi
  ];

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

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Docker
  virtualisation.docker = {
    enable = true;
    daemon.settings.features.cdi = true;
    rootless = {
      enable = true;
      setSocketVariable = false;
      daemon.settings = {
        features.cdi = true;
        cdi-spec-dirs = [ "/home/christan/.cdi" ];
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
