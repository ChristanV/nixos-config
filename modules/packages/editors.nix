{ inputs, ... }:
{
  flake.nixosModules.editors =
    { pkgs, ... }:
    let
      unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        inherit (pkgs) config;
      };
    in
    {
      environment.systemPackages = with pkgs; [
        neovim
        vimPlugins.packer-nvim
        unstable.zed-editor
        vscode
      ];
    };
}
