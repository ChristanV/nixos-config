# https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
{
  description = "A SecureBoot-enabled NixOS configurations and always updated packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, lanzaboote, claude-code, ...}: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          lanzaboote.nixosModules.lanzaboote
          ./configuration.nix
          ./hardware-configuration.nix
          ({ pkgs, lib, ... }: {
            environment.systemPackages = [
              pkgs.sbctl
              pkgs.claude-code
            ];
            boot.loader.systemd-boot.enable = lib.mkForce false;
            boot.lanzaboote = {
              enable = true;
              pkiBundle = "/var/lib/sbctl";
            };
          })
        ];
      };
    };
  };
}
