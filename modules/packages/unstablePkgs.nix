{ inputs, ... }:
{
  flake.nixosModules.unstablePkgs =
    { pkgs, ... }:
    {
      _module.args.unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        inherit (pkgs) config;
      };
    };
}
