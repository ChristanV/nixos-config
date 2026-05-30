{ inputs, ... }:
{
  flake.nixosModules.desktopPackages =
    { pkgs, ... }:
    let
      unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        inherit (pkgs) config;
      };
    in
    {
      environment.systemPackages = with pkgs; [
        # Security
        unstable._1password-gui
        clamtk
        sbctl

        # Desktop apps
        google-chrome
        baobab
        steam-run
        bruno
        dbeaver-bin
        nwg-look
        pavucontrol
        vlc
        teams-for-linux
        libreoffice
        brave
        cheese

        # Terminals
        wezterm
        ghostty

        # hyprland
        waybar
        (pkgs.waybar.overrideAttrs (oldAttrs: {
          mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
        }))
        libnotify
        awww
        rofi
        networkmanagerapplet
        hyprpolkitagent
        hyprlock
        kdePackages.qt6ct
        gsettings-desktop-schemas
        wl-clipboard
        wl-clip-persist

        # Gaming
        wineWow64Packages.stable
        winetricks
      ];
    };
}
