_: {
  flake.nixosModules.editors =
    { pkgs, unstable, ... }:
    {
      environment.systemPackages = with pkgs; [
        neovim
        vimPlugins.packer-nvim
        unstable.zed-editor
      ];
    };
}
