{ ... }:
{
  flake.nixosModules.hyprland =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        waybar
        libnotify
        awww
        mpvpaper
        rofi
        networkmanagerapplet
        hyprpolkitagent
        hyprlock
        kdePackages.qt6ct
        gsettings-desktop-schemas
        wl-clipboard
        wl-clip-persist
        wf-recorder
        slurp
      ];
    };
}
