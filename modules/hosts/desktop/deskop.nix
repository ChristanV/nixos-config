{ inputs, self, ... }:
let
  var = import ./_variables.nix;
in
{
  flake.nixosConfigurations."${var.hostname}" = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      var = import ./_variables.nix;
    };
    modules = [
      { nix.registry.nixpkgs.flake = inputs.nixpkgs; }
      self.nixosModules.lanzaboote
      self.nixosModules.baseConfig
      self.nixosModules.basePackages
      self.nixosModules.desktopPackages
      self.nixosModules.claude
      self.nixosModules.system
      self.nixosModules.desktop
      ./_hardware-configuration.nix
    ];
  };

  flake.nixosModules.desktop =
    {
      config,
      pkgs,
      var,
      ...
    }:
    {
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
        firewall.enable = true;
        firewall.interfaces."tailscale0".allowedTCPPorts = [ 11434 ];
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
        xserver = {
          xkb = {
            layout = "za";
            variant = "";
          };
          enable = true;
          videoDrivers = [ "nvidia" ];
        };

        gnome.gnome-keyring.enable = true;
        printing.enable = true;

        displayManager = {
          sddm.enable = true;
          autoLogin.enable = false;
          autoLogin.user = "christan";
        };

        tailscale.enable = true;

        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;
          wireplumber.enable = true;
        };
      };

      users.users."${var.username}".extraGroups = [
        "networkmanager"
        "wheel"
        "audio"
        "video"
        "input"
      ];

      security = {
        audit.enable = false;
        sudo = {
          enable = true;
          extraConfig = ''
            %wheel ALL=(ALL) NOPASSWD: ALL
          '';
        };
        rtkit.enable = true;
        pam.services = {
          sddm.enableGnomeKeyring = true;
          login.enableGnomeKeyring = true;
        };
      };

      systemd = {
        services."getty@tty1".enable = false;
        services."autovt@tty1".enable = false;
      };

      programs = {
        firefox.enable = true;
        sway.enable = false;

        chromium = {
          enable = true;
          extraOpts = { };
        };

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
      };

      # Hyprland
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland
          xdg-desktop-portal-gtk
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
        };
      };

      hardware = {
        graphics.enable = true;
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
    };
}
