{ inputs, ... }:
{
  flake.nixosModules.claude =
    { pkgs, ... }:
    let
      unstable = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config = pkgs.config;
      };
    in
    {
      environment.systemPackages = [
        unstable.claude-code
      ];
    };
}
