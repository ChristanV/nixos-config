_: {
  flake.nixosModules.editors =
    { pkgs, unstable, ... }:
    {
      environment.systemPackages = with pkgs; [
        neovim
        tree-sitter
        unstable.zed-editor
      ];
    };
}
