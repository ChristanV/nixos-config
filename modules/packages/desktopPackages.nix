{ self, ... }:
{
  flake.nixosModules.desktopPackages = {
    imports = [
      self.nixosModules.desktopApps
      self.nixosModules.hyprland
      self.nixosModules.gaming
    ];
  };
}
