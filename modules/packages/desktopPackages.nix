{ inputs, ... }:
{
  flake.nixosModules.desktopPackages =
    { pkgs, ... }:
    let
      unstable = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config = pkgs.config;
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
        vscode
        nemo
        nwg-look
        pavucontrol
        vlc
        teams-for-linux
        libreoffice
        brave
        unstable.zed-editor
        cheese

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
        awww
        rofi
        networkmanagerapplet
        hyprpolkitagent
        hyprlock
        kdePackages.qt6ct
        gsettings-desktop-schemas

        # Gaming
        wineWow64Packages.stable
        winetricks
      ];
    };
}
