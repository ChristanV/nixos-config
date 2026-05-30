{ ... }:
{
  flake.nixosModules.hyprland =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
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
      ];
    };
}
