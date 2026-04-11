# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
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
      inputs.nixos-wsl.nixosModules.wsl
      self.nixosModules.baseConfig
      self.nixosModules.basePackages
      self.nixosModules.wslPackages
      self.nixosModules.claude
      self.nixosModules.system
      self.nixosModules.wsl
    ];
  };

  flake.nixosModules.wsl =
    {
      pkgs,
      var,
      ...
    }:
    {
      # DNS fix for WSL2
      networking.nameservers = [
        "8.8.8.8"
        "1.1.1.1"
      ];

      security.pki.certificates = [
        "/etc/ssl/certs/ca-bundle.crt"
      ];

      users.users."${var.username}".extraGroups = [ "docker" ];

      environment.variables.LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";

      wsl = {
        enable = true;
        defaultUser = var.username;
        wslConf = {
          network.hostname = var.hostname;
          network.generateResolvConf = false;
          boot.command = "";
          user.default = var.username;
        };
        useWindowsDriver = true;

        extraBin = with pkgs; [
          { src = "${coreutils}/bin/mkdir"; }
          { src = "${coreutils}/bin/cat"; }
          { src = "${coreutils}/bin/whoami"; }
          { src = "${coreutils}/bin/ls"; }
          { src = "${busybox}/bin/addgroup"; }
          { src = "${coreutils}/bin/uname"; }
          { src = "${coreutils}/bin/dirname"; }
          { src = "${coreutils}/bin/readlink"; }
          { src = "${coreutils}/bin/sed"; }
          { src = "/run/current-system/sw/bin/sed"; }
          { src = "${su}/bin/groupadd"; }
          { src = "${su}/bin/usermod"; }
        ];
      };
    };
}
