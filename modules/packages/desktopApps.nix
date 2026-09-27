_: {
  flake.nixosModules.desktopApps =
    { pkgs, unstable, ... }:
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
        mpv
        teams-for-linux
        libreoffice
        cheese
        nautilus

        # Terminals
        ghostty
      ];
    };
}
