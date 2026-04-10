{ inputs, ... }:
{
  flake.nixosModules.claude =
    { pkgs, ... }:
    let
      unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        inherit (pkgs) config;
      };
    in
    {
      environment.systemPackages = [
        unstable.claude-code
      ];
    };
}
