{ inputs, ... }:
{
  flake.nixosModules.desktopApps =
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
        brave
        baobab
        steam-run
        bruno
        dbeaver-bin
        nwg-look
        pavucontrol
        vlc
        teams-for-linux
        libreoffice
        cheese

        # Terminals
        ghostty
      ];
    };
}
